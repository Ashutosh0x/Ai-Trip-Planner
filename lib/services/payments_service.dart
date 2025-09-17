import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class PaymentsService {
  PaymentsService({required this.backendBaseUrl});

  final String
  backendBaseUrl; // e.g., https://your-region-yourproj.cloudfunctions.net/api

  Future<List<Map<String, dynamic>>> fetchPayments() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final QuerySnapshot<Map<String, dynamic>> snap = await FirebaseFirestore
        .instance
        .collection('users')
        .doc(uid)
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPaymentMethods() async {
    final String idToken = await FirebaseAuth.instance.currentUser!
        .getIdToken(true)
        .then((value) => value ?? '');
    if (idToken.isEmpty) {
      throw Exception('Failed to get Firebase ID token');
    }
    final Uri url = Uri.parse('$backendBaseUrl/payment-methods');
    final http.Response resp = await http.get(
      url,
      headers: {'Authorization': 'Bearer $idToken'},
    );
    if (resp.statusCode != 200) {
      throw Exception('Failed to load payment methods: ${resp.statusCode}');
    }
    final Map<String, dynamic> data =
        jsonDecode(resp.body) as Map<String, dynamic>;
    final List<dynamic> pms =
        data['paymentMethods'] as List<dynamic>? ?? <dynamic>[];
    return pms.cast<Map<String, dynamic>>();
  }
}
