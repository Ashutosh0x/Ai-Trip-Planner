const functions = require('firebase-functions');
const admin = require('firebase-admin');
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

admin.initializeApp();
const db = admin.firestore();

const stripeSecret = process.env.STRIPE_SECRET || (functions.config().stripe && functions.config().stripe.secret);
const stripeWebhookSecret = process.env.STRIPE_WEBHOOK_SECRET || (functions.config().stripe && functions.config().stripe.webhook_secret);

if (!stripeSecret) {
  console.warn('Stripe secret not set. Set env var STRIPE_SECRET or functions config stripe.secret');
}
const Stripe = require('stripe');
// In emulator, prefer env vars. If missing, create a dummy client so endpoints still mount.
const stripe = stripeSecret ? Stripe(stripeSecret) : Stripe('sk_test_dummy');

const app = express();
app.use(cors({ origin: true }));
app.use(bodyParser.json());

async function verifyIdToken(req, res, next) {
  const auth = req.get('Authorization') || '';
  if (!auth.startsWith('Bearer ')) return res.status(401).json({ error: 'Missing token' });
  const token = auth.substring(7);
  try {
    const decoded = await admin.auth().verifyIdToken(token);
    req.user = { uid: decoded.uid, email: decoded.email };
    next();
  } catch (e) {
    return res.status(401).json({ error: 'Invalid token' });
  }
}

async function ensureCustomer(uid, email) {
  const ref = db.collection('users').doc(uid);
  const doc = await ref.get();
  if (doc.exists && doc.data().stripeCustomerId) return doc.data().stripeCustomerId;
  const customer = await stripe.customers.create({ email, metadata: { firebaseUid: uid } });
  await ref.set({ stripeCustomerId: customer.id, email }, { merge: true });
  return customer.id;
}

app.post('/create-payment-intent', verifyIdToken, async (req, res) => {
  try {
    const { amount, currency = 'usd' } = req.body;
    if (!amount || typeof amount !== 'number') return res.status(400).json({ error: 'Invalid amount' });
    const customerId = await ensureCustomer(req.user.uid, req.user.email);
    const pi = await stripe.paymentIntents.create({
      amount,
      currency,
      customer: customerId,
      receipt_email: req.user.email,
      metadata: { firebaseUid: req.user.uid },
    });
    await db.collection('users').doc(req.user.uid).collection('payments').doc(pi.id).set({
      stripeId: pi.id,
      amount: pi.amount,
      currency: pi.currency,
      status: pi.status,
      type: 'payment_intent',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      firebaseUid: req.user.uid,
    }, { merge: true });
    res.json({ clientSecret: pi.client_secret, paymentIntentId: pi.id });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});

// Create Payment Intent endpoint
app.post('/create-payment-intent', verifyIdToken, async (req, res) => {
  try {
    const { amount, currency = 'usd', customerId, metadata = {} } = req.body;
    
    if (!amount || amount < 50) {
      return res.status(400).json({ error: 'Invalid amount' });
    }

    // Ensure customer exists
    const stripeCustomerId = customerId || await ensureCustomer(req.user.uid, req.user.email);
    
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount), // Ensure integer
      currency: currency.toLowerCase(),
      customer: stripeCustomerId,
      payment_method_types: ['card'],
      description: 'Alventura Booking',
      metadata: {
        firebaseUid: req.user.uid,
        ...metadata,
      },
      // Enable 3D Secure
      confirmation_method: 'automatic',
      confirm: false,
    });

    res.json({ 
      clientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id,
    });
  } catch (e) {
    console.error('Payment intent creation error:', e);
    res.status(500).json({ error: e.message });
  }
});

app.get('/payment-methods', verifyIdToken, async (req, res) => {
  try {
    const userDoc = await db.collection('users').doc(req.user.uid).get();
    const customerId = userDoc.exists ? userDoc.data().stripeCustomerId : null;
    if (!customerId) return res.json({ paymentMethods: [] });
    const list = await stripe.paymentMethods.list({ customer: customerId, type: 'card', limit: 20 });
    const mapped = list.data.map(pm => ({
      id: pm.id,
      brand: pm.card && pm.card.brand,
      last4: pm.card && pm.card.last4,
      exp_month: pm.card && pm.card.exp_month,
      exp_year: pm.card && pm.card.exp_year,
      type: pm.type,
    }));
    res.json({ paymentMethods: mapped });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: e.message });
  }
});

exports.api = functions.https.onRequest(app);

const webhook = express();
webhook.post('/', bodyParser.raw({ type: 'application/json' }), async (req, res) => {
  let event;
  try {
    if (!stripeWebhookSecret) {
      console.error('Missing STRIPE_WEBHOOK_SECRET; cannot verify signature');
      return res.status(400).send('Missing webhook secret');
    }
    event = stripe.webhooks.constructEvent(req.body, req.headers['stripe-signature'], stripeWebhookSecret);
  } catch (err) {
    console.error('Webhook signature error', err.message);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }
  try {
    switch (event.type) {
      case 'payment_intent.succeeded': {
        const pi = event.data.object;
        const uid = pi.metadata && pi.metadata.firebaseUid;
        const receiptUrl = pi.charges && pi.charges.data[0] && pi.charges.data[0].receipt_url;
        const doc = {
          stripeId: pi.id,
          amount: pi.amount_received || pi.amount,
          currency: pi.currency,
          status: 'succeeded',
          type: 'payment_intent',
          createdAt: admin.firestore.Timestamp.fromDate(new Date(pi.created * 1000)),
          receiptUrl,
          paymentMethod: pi.payment_method_types && pi.payment_method_types[0],
          metadata: pi.metadata || {},
        };
        await db.collection('payments').doc(pi.id).set(doc, { merge: true });
        if (uid) await db.collection('users').doc(uid).collection('payments').doc(pi.id).set(doc, { merge: true });
        break;
      }
      case 'invoice.paid': {
        const inv = event.data.object;
        const uid = inv.metadata && inv.metadata.firebaseUid;
        const doc = {
          stripeId: inv.id,
          amount: inv.amount_paid,
          currency: inv.currency,
          status: 'paid',
          type: 'invoice',
          createdAt: admin.firestore.Timestamp.fromDate(new Date(inv.created * 1000)),
          invoicePdf: inv.invoice_pdf || inv.hosted_invoice_url,
          metadata: inv.metadata || {},
        };
        await db.collection('invoices').doc(inv.id).set(doc, { merge: true });
        if (uid) await db.collection('users').doc(uid).collection('payments').doc(inv.id).set(doc, { merge: true });
        break;
      }
      default:
        break;
    }
    res.json({ received: true });
  } catch (e) {
    console.error('Webhook handling error', e);
    res.status(500).send();
  }
});

exports.stripeWebhook = functions.https.onRequest(webhook);

// Auto-create user profile on signup (SSO or email)
exports.createUserProfile = functions.auth.user().onCreate(async (user) => {
  const ref = admin.firestore().collection('users').doc(user.uid);
  await ref.set({
    fullName: user.displayName || '',
    email: user.email || '',
    photoUrl: user.photoURL || '',
    country: null,
    travelStyle: null,
    dreamTrip: null,
    preferredActivities: [],
    memberSince: admin.firestore.FieldValue.serverTimestamp(),
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  }, { merge: true });
});


