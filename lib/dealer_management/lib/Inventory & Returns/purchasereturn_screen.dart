import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum PurchaseReturnView { viewList, addNew, filter }

class PurchaseReturnScreen extends StatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  final PurchaseReturnView _currentView = PurchaseReturnView.viewList;
  final Color primaryColor = const Color(0xFF26A69A);
  final Color darkNavy = const Color(0xFF26A69A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        top: false,
        child: _buildMainContent(),
      ),
    );
  }

  Widget _buildMainContent() {
    switch (_currentView) {
      case PurchaseReturnView.viewList:
        return _buildListView();
      case PurchaseReturnView.addNew:
        return _buildAddView();
      case PurchaseReturnView.filter:
        return _buildFilterView();
    }
  }

  Widget _buildListView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOvalHeader(),
          const SizedBox(height: 100), // Space for overlapping card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Recent Returns', 'See all'),
                const SizedBox(height: 16),
                _buildReturnItem('PR-882-JTO', 'Sri Julaekha', '12 Apr 2026', '€ 1,240.00', 'In Process', Colors.orange),
                _buildReturnItem('PR-771-BKK', 'Modern Spares', '10 Apr 2026', '€ 450.00', 'Verified', Colors.blue),
                const SizedBox(height: 32),
                _buildSectionHeader('Monthly Statistics', 'Details'),
                const SizedBox(height: 16),
                _buildStatsCard(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOvalHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          height: 240,
          decoration: BoxDecoration(
            color: darkNavy,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(60),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                  Row(
                    children: [
                      Text(
                        'Oval',
                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(color: Color(0xFFE0F2F1), shape: BoxShape.circle),
                        child: Icon(Icons.person_outline_rounded, color: primaryColor, size: 24),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // Overlapping Stats Card (Oval Future style)
        Positioned(
          bottom: -70,
          left: 24,
          right: 24,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Refundable', style: GoogleFonts.outfit(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w500)),
                    Icon(Icons.arrow_forward_rounded, color: primaryColor, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '€ 14.710,00',
                      style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: darkNavy),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.trending_up_rounded, color: Colors.green, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: darkNavy)),
        Text(action, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: primaryColor)),
      ],
    );
  }

  Widget _buildReturnItem(String id, String dealer, String date, String amount, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.assignment_return_outlined, color: statusColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(id, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy)),
                Text(dealer, style: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: darkNavy)),
              Text(status, style: GoogleFonts.outfit(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: darkNavy,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: darkNavy.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly Return Hub', style: GoogleFonts.outfit(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Monitor your return trends and refunds', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatDetail('€ 4.2K', 'Returned'),
              _buildStatDetail('€ 3.8K', 'Refunded'),
              _buildStatDetail('12', 'Active'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDetail(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: GoogleFonts.outfit(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _buildAddView() {
    return const Center(child: Text('Add New Return Form'));
  }

  Widget _buildFilterView() {
    return const Center(child: Text('Filter View'));
  }
}
