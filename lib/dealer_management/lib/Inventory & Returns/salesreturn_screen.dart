import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SalesReturnScreen extends StatelessWidget {
  const SalesReturnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1D1E)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Return #SR-98745',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1A1D1E),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Approved',
                style: GoogleFonts.outfit(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFinanceStackedCards(),
                const SizedBox(height: 32),
                _buildActionButtons(),
                const SizedBox(height: 32),
                _buildSectionLabel('RETURN SUMMARY'),
                const SizedBox(height: 12),
                _buildReturnSummaryCard(),
                const SizedBox(height: 24),
                _buildSectionLabel('DEALER DETAILS'),
                const SizedBox(height: 12),
                _buildDealerCard(),
                const SizedBox(height: 24),
                _buildSectionLabel('RETURN TIMELINE'),
                const SizedBox(height: 12),
                _buildTimelineList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceStackedCards() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Back Card
          Positioned(
            top: 0,
            left: 20,
            right: 20,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF80CBC4), // Light Teal
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          // Middle Card
          Positioned(
            top: 20,
            left: 10,
            right: 10,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF26A69A), // Medium Teal
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              height: 160,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        'Total Refund Value',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.visibility_off_outlined, size: 16, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹ 45,500.50',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E234E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Credited to Wallet',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton('Refund', Icons.south_west_rounded, Colors.teal),
        const SizedBox(width: 12),
        _buildActionButton('Credit Note', Icons.receipt_rounded, Colors.blueGrey),
        const SizedBox(width: 12),
        _buildIconActionBtn(Icons.swap_horiz_rounded),
        const SizedBox(width: 12),
        _buildIconActionBtn(Icons.history_rounded),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, MaterialColor color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.shade100),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color.shade700, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color.shade800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconActionBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(icon, color: Colors.grey[700], size: 20),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey[500],
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildReturnSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.car_crash_rounded, size: 30, color: Colors.grey),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Alloy Wheels - 18"',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E234E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Qty: 2  •  DEFECTIVE',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Divider(height: 1, color: Color(0xFFEEEEEE)),
          ),
          _buildSummaryRow('Subtotal', '₹ 38,500.00'),
          const SizedBox(height: 12),
          _buildSummaryRow('Taxes (18% GST)', '₹ 6,930.00'),
          const SizedBox(height: 12),
          _buildSummaryRow('Freight Deduction', '- ₹ 430.00'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Refund',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E234E),
                ),
              ),
              Text(
                '₹ 45,000.00',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E234E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          amount,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1E234E),
          ),
        ),
      ],
    );
  }

  Widget _buildDealerCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFFFE0B2), // Soft Orange
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                'SM',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sharma Motors',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E234E),
                ),
              ),
              Text(
                'sharma@dealernet.com',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.grey[500],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimelineList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          _buildTimelineStep(
            title: 'Return Initiated',
            desc: 'Dealer logged a return request.',
            date: '28 OCT 2024, 10:15',
            icon: Icons.assignment_returned_rounded,
            color: Colors.blue,
            isCompleted: true,
          ),
          _buildTimelineStep(
            title: 'Package Shipped',
            desc: 'Handed to Logistics Partner',
            date: '29 OCT 2024, 09:30',
            icon: Icons.local_shipping_rounded,
            color: Colors.orange,
            isCompleted: true,
          ),
          _buildTimelineStep(
            title: 'Received & Inspected',
            desc: 'Items validated at warehouse.',
            date: '31 OCT 2024, 14:00',
            icon: Icons.fact_check_rounded,
            color: Colors.purple,
            isCompleted: true,
          ),
          _buildTimelineStep(
            title: 'Refund Approved',
            desc: 'Credit note has been issued.',
            date: '02 NOV 2024, 11:20',
            icon: Icons.check_circle_rounded,
            color: Colors.green,
            isCompleted: true,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String desc,
    required String date,
    required IconData icon,
    required Color color,
    bool isCompleted = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Column
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted ? color.withValues(alpha: 0.1) : Colors.grey[100],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? color.withValues(alpha: 0.3) : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isCompleted ? color : Colors.grey[400],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 45,
                color: isCompleted ? const Color(0xFFEEEEEE) : Colors.grey[200],
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Content Column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? const Color(0xFF1E234E) : Colors.grey[500],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isCompleted ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
