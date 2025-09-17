# Firebase Functions (Stripe) setup

1) Install tools
- Node 18+
- Firebase CLI: `npm i -g firebase-tools`

2) Install deps
```
cd functions
npm install
```

3) Configure secrets (choose one)
- Using functions config:
```
firebase functions:config:set stripe.secret="sk_test_..." stripe.webhook_secret="whsec_..."
```
- Or environment variables when serving:
```
set STRIPE_SECRET=sk_test_...
set STRIPE_WEBHOOK_SECRET=whsec_...
```

4) Serve locally
```
firebase emulators:start --only functions
```
Endpoints (by default at http://localhost:5001/<project>/us-central1):
- `api/create-payment-intent` (POST, Bearer <Firebase ID token>)
- `api/payment-methods` (GET, Bearer <Firebase ID token>)
- `stripeWebhook` (POST, Stripe webhooks)

5) Deploy
```
firebase deploy --only functions
```

6) Stripe webhook
- Add endpoint URL `https://us-central1-<project>.cloudfunctions.net/stripeWebhook`
- Select events: payment_intent.succeeded, invoice.paid (and others as needed)
- Use the signing secret shown -> set to `stripe.webhook_secret`

7) Flutter app
- Run with
```
flutter run --dart-define=BACKEND_BASE_URL=https://us-central1-<project>.cloudfunctions.net/api
```


