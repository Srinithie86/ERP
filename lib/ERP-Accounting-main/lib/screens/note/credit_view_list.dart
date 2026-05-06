import 'package:flutter/material.dart';

import '../../../services/note/credit_view_api.dart';
import '../../../widgets/app_colors.dart';

class CreditViewListScreen extends StatefulWidget {
  const CreditViewListScreen({super.key});

  @override
  State<CreditViewListScreen> createState() => _CreditViewListScreenState();
}

class _CreditViewListScreenState extends State<CreditViewListScreen> {
  late Future<List<CreditNoteItemModel>> _creditListFuture;

  @override
  void initState() {
    super.initState();
    _creditListFuture = CreditViewApiService.fetchCreditNoteList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Credit Note List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.brand,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: FutureBuilder<List<CreditNoteItemModel>>(
        future: _creditListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No records found.'));
          }

          final data = snapshot.data!;
          return ListView.separated(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            itemCount: data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = data[index];
              return _CreditNoteCard(item: item);
            },
          );
        },
      ),
    );
  }
}

class _CreditNoteCard extends StatelessWidget {
  final CreditNoteItemModel item;

  const _CreditNoteCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5ECF5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.brand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.brand,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.assetName?.isNotEmpty == true ? item.assetName! : 'N/A',
                      style: const TextStyle(
                        color: AppColors.text1,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Ref: #${item.id ?? '-'}',
                      style: const TextStyle(
                        color: AppColors.text2,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹ ${item.purchaseValue ?? '0.00'}',
                style: const TextStyle(
                  color: AppColors.brand,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE5ECF5)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                size: 15,
                color: AppColors.text2,
              ),
              const SizedBox(width: 8),
              Text(
                item.purchaseDate ?? 'N/A',
                style: const TextStyle(
                  color: AppColors.text2,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
