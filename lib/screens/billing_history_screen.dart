import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/payments_service.dart';

class BillingHistoryScreen extends StatefulWidget {
  const BillingHistoryScreen({super.key, required this.paymentsService});
  final PaymentsService paymentsService;

  @override
  State<BillingHistoryScreen> createState() => _BillingHistoryScreenState();
}

class _BillingHistoryScreenState extends State<BillingHistoryScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.paymentsService.fetchPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final List<Map<String, dynamic>> items =
              snap.data ?? <Map<String, dynamic>>[];
          if (items.isEmpty) {
            return const Center(child: Text('No payments found'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final m = items[i];
              final int amount = (m['amount'] ?? 0) as int;
              final String currency = (m['currency'] ?? 'usd') as String;
              final String status = (m['status'] ?? 'succeeded') as String;
              final String? receiptUrl = m['receiptUrl'] as String?;
              final DateTime? createdAt = (m['createdAt'] != null)
                  ? (m['createdAt'] as dynamic).toDate() as DateTime
                  : null;

              return ListTile(
                title: Text(
                  '${(amount / 100).toStringAsFixed(2).toString()} ${currency.toUpperCase()}',
                  style: GoogleFonts.dosis(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '${status.toUpperCase()} • ${createdAt != null ? createdAt.toLocal().toString() : ''}',
                  style: GoogleFonts.dosis(),
                ),
                trailing: receiptUrl != null
                    ? IconButton(
                        icon: const Icon(Icons.receipt_long),
                        onPressed: () async {
                          final uri = Uri.parse(receiptUrl);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
