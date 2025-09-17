import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/payments_service.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key, required this.paymentsService});
  final PaymentsService paymentsService;

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.paymentsService.fetchPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final items = snap.data ?? <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const Center(child: Text('No saved payment methods'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = items[i];
              final brand = (m['brand'] ?? '').toString().toUpperCase();
              final last4 = (m['last4'] ?? '').toString();
              final expMonth = m['exp_month'];
              final expYear = m['exp_year'];
              return ListTile(
                leading: const Icon(Icons.credit_card),
                title: Text(
                  '$brand •••• $last4',
                  style: GoogleFonts.dosis(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Exp $expMonth/$expYear',
                  style: GoogleFonts.dosis(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
