import 'package:flutter/material.dart';
import '../../../services/voucher/payment_view_api.dart';
import '../../../widgets/app_colors.dart';

class PaymentViewListScreen extends StatefulWidget {
  const PaymentViewListScreen({super.key});

  @override
  State<PaymentViewListScreen> createState() => _PaymentViewListScreenState();
}

class _PaymentViewListScreenState extends State<PaymentViewListScreen> {
  late Future<List<PaymentItemModel>> _paymentListFuture;

  @override
  void initState() {
    super.initState();
    _paymentListFuture = PaymentViewApiService.fetchPaymentList();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Voucher List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.brand,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF0F4F8),
        child: FutureBuilder<List<PaymentItemModel>>(
          future: _paymentListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No records found.'));
            }

            final data = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(isMobile ? size.width * 0.05 : size.width * 0.02),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.only(bottom: size.height * 0.02),
                  shadowColor: Colors.black.withValues(alpha: 0.18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ledger Name (Big)
                        Text(
                          item.ledgerName?.isNotEmpty == true ? item.ledgerName! : 'N/A',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF263238),
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Date
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              item.date ?? 'N/A',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        
                        // Details: Pay Type, Pay Account, Amount, Remarks
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Pay Type:', item.payMode ?? 'N/A'),
                                  const SizedBox(height: 6),
                                  _buildDetailRow('Account:', item.payAccount ?? 'N/A'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Amount:', '₹ ${item.total ?? '0'}', isAmount: true),
                                  const SizedBox(height: 6),
                                  _buildDetailRow('Remarks:', item.remark?.isNotEmpty == true ? item.remark! : 'None'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isAmount = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black54,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isAmount ? FontWeight.bold : FontWeight.normal,
              color: isAmount ? Colors.green[700] : Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
