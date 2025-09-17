import 'dart:convert';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SecurePaymentService {
  SecurePaymentService({required this.backendBaseUrl});

  final String backendBaseUrl;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initializeStripe(String publishableKey) async {
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  static Future<void> initializeGooglePay({
    required String merchantName,
    required String countryCode,
    bool testEnv = true,
  }) async {
    await Stripe.instance.initGooglePay(
      GooglePayInitParams(
        testEnv: testEnv,
        merchantName: merchantName,
        countryCode: countryCode,
      ),
    );
  }

  Future<String> createPaymentIntent({
    required int amount,
    required String currency,
    String? customerId,
    Map<String, String>? metadata,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final idToken = await user.getIdToken(true);

    final resp = await http.post(
      Uri.parse('$backendBaseUrl/create-payment-intent'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: json.encode({
        'amount': amount,
        'currency': currency,
        'customerId': customerId,
        'metadata': metadata ?? {},
      }),
    );

    if (resp.statusCode != 200) {
      throw Exception('Failed to create payment intent: ${resp.body}');
    }
    final data = json.decode(resp.body) as Map<String, dynamic>;
    return data['clientSecret'] as String;
  }

  Future<PaymentResult> processCardPayment({
    required String clientSecret,
    required String cardholderName,
    String? billingAddress,
    bool saveCard = false,
  }) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: cardholderName,
              address: billingAddress != null
                  ? Address(
                      city: 'Unknown',
                      state: 'NA',
                      country: 'US',
                      postalCode: '00000',
                      line1: billingAddress,
                      line2: '',
                    )
                  : null,
            ),
          ),
        ),
      );
      return PaymentResult.success(paymentIntentId: clientSecret);
    } on StripeException catch (e) {
      return PaymentResult.failure(e.error.message ?? 'Payment failed');
    } catch (e) {
      return PaymentResult.failure(e.toString());
    }
  }

  Future<PaymentResult> processGooglePayPayment({
    required String clientSecret,
  }) async {
    try {
      await Stripe.instance.presentGooglePay(
        PresentGooglePayParams(clientSecret: clientSecret),
      );
      return PaymentResult.success(paymentIntentId: clientSecret);
    } on StripeException catch (e) {
      return PaymentResult.failure(e.error.message ?? 'Google Pay failed');
    } catch (e) {
      return PaymentResult.failure(e.toString());
    }
  }

  Future<PaymentResult> processSavedPaymentMethod({
    required String clientSecret,
    required String paymentMethodId,
  }) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(paymentMethodId: paymentMethodId),
        ),
      );
      return PaymentResult.success(paymentIntentId: clientSecret, paymentMethodId: paymentMethodId);
    } on StripeException catch (e) {
      return PaymentResult.failure(e.error.message ?? 'Payment failed');
    } catch (e) {
      return PaymentResult.failure(e.toString());
    }
  }

  Future<void> savePaymentMethodLocally({
    required String paymentMethodId,
    required CardType cardType,
    required String last4,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('payment_methods')
        .doc(paymentMethodId)
        .set({
      'paymentMethodId': paymentMethodId,
      'cardType': cardType.toString(),
      'last4': last4,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<SavedPaymentMethod>> getSavedPaymentMethods() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final snap = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('payment_methods')
        .get();

    return snap.docs.map((d) {
      final data = d.data();
      return SavedPaymentMethod(
        id: d.id,
        cardType: _parseCardType(data['cardType'] as String?),
        last4: (data['last4'] as String?) ?? '****',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> deleteSavedPaymentMethod(String paymentMethodId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('payment_methods')
        .doc(paymentMethodId)
        .delete();
  }

  CardType _parseCardType(String? cardTypeString) {
    switch (cardTypeString) {
      case 'CardType.visa':
        return CardType.visa;
      case 'CardType.mastercard':
        return CardType.mastercard;
      case 'CardType.amex':
        return CardType.amex;
      case 'CardType.discover':
        return CardType.discover;
      default:
        return CardType.unknown;
    }
  }
}

class CardValidator {
  static bool isValidCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 13 || digits.length > 19) return false;
    int sum = 0;
    bool alt = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int d = int.parse(digits[i]);
      if (alt) {
        d *= 2;
        if (d > 9) d = (d % 10) + 1;
      }
      sum += d;
      alt = !alt;
    }
    return sum % 10 == 0;
  }

  static CardType getCardType(String cardNumber) {
    final n = cardNumber.replaceAll(RegExp(r'\D'), '');
    if (n.startsWith('4')) return CardType.visa;
    if (n.startsWith('5') || n.startsWith('2')) return CardType.mastercard;
    if (n.startsWith('3')) return CardType.amex;
    if (n.startsWith('6')) return CardType.discover;
    return CardType.unknown;
  }

  static bool isValidExpiryDate(String expiryDate) {
    if (expiryDate.length != 5 || !expiryDate.contains('/')) return false;
    final parts = expiryDate.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse('20${parts[1]}');
    if (month == null || year == null || month < 1 || month > 12) return false;
    final now = DateTime.now();
    final exp = DateTime(year, month);
    return exp.isAfter(now) || (exp.year == now.year && exp.month == now.month);
  }

  static bool isValidCVC(String cvc, CardType type) {
    final d = cvc.replaceAll(RegExp(r'\D'), '');
    return type == CardType.amex ? d.length == 4 : d.length == 3;
  }

  static String formatCardNumber(String input) {
    final d = input.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (int i = 0; i < d.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(d[i]);
    }
    return buf.toString();
  }

  static String formatExpiryDate(String input) {
    final d = input.replaceAll(RegExp(r'\D'), '');
    if (d.length <= 2) return d;
    return '${d.substring(0, 2)}/${d.substring(2)}';
  }
}

enum CardType { visa, mastercard, amex, discover, unknown }

class PaymentResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? paymentIntentId;
  final String? paymentMethodId;

  PaymentResult._({
    required this.isSuccess,
    this.errorMessage,
    this.paymentIntentId,
    this.paymentMethodId,
  });

  factory PaymentResult.success({
    required String paymentIntentId,
    String? paymentMethodId,
  }) => PaymentResult._(
        isSuccess: true,
        paymentIntentId: paymentIntentId,
        paymentMethodId: paymentMethodId,
      );

  factory PaymentResult.failure(String errorMessage) =>
      PaymentResult._(isSuccess: false, errorMessage: errorMessage);
}

class SavedPaymentMethod {
  final String id;
  final CardType cardType;
  final String last4;
  final DateTime createdAt;
  SavedPaymentMethod({
    required this.id,
    required this.cardType,
    required this.last4,
    required this.createdAt,
  });
  String get displayName {
    switch (cardType) {
      case CardType.visa:
        return 'Visa';
      case CardType.mastercard:
        return 'Mastercard';
      case CardType.amex:
        return 'American Express';
      case CardType.discover:
        return 'Discover';
      default:
        return 'Card';
    }
  }
}

class PaymentException implements Exception {
  final String message;
  PaymentException(this.message);
  @override
  String toString() => 'PaymentException: $message';
}
