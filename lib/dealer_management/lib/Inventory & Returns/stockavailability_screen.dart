import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StockAvailabilityScreen extends StatefulWidget {
  const StockAvailabilityScreen({super.key});

  @override
  State<StockAvailabilityScreen> createState() => _StockAvailabilityScreenState();
}

class _StockAvailabilityScreenState extends State<StockAvailabilityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildTotalStockCard(),
                const SizedBox(height: 32),
                _buildSectionHeader('Low Stock Alerts', 'See all'),
                const SizedBox(height: 16),
                _buildLowStockHorizontalList(),
                const SizedBox(height: 32),
                _buildSectionHeader('Stock Breakdown', 'See all'),
                const SizedBox(height: 16),
                _buildStockBreakdownChart(),
                const SizedBox(height: 32),
                _buildSectionHeader('Quick Menu', 'See all'),
                const SizedBox(height: 16),
                _buildQuickMenu(),
                const SizedBox(height: 32),
                _buildSectionHeader('Purchase Returns', 'See all'),
                const SizedBox(height: 16),
                _buildPurchaseReturnsList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF1E234E)),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Stock Availability',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E234E),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.inventory_2_outlined, size: 20, color: Color(0xFF1E234E)),
        ),
      ],
    );
  }

  Widget _buildTotalStockCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF26A69A), Color(0xFF00796B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009688).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Stock Available',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '14,570 Units',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E234E),
          ),
        ),
        Text(
          action,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockHorizontalList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _buildLowStockCard('Brake Pads', 'Auto Parts', '8 Units Left', const Color(0xFF009688), Icons.warning_amber_rounded),
          const SizedBox(width: 16),
          _buildLowStockCard('Engine Oil', 'Lubricants', '12 Units Left', Colors.white, Icons.water_drop_outlined, isLight: true),
        ],
      ),
    );
  }

  Widget _buildLowStockCard(String item, String category, String status, Color bgColor, IconData icon, {bool isLight = false}) {
    final textColor = isLight ? const Color(0xFF1E234E) : Colors.white;
    final subtitleColor = isLight ? Colors.grey[500] : Colors.white.withValues(alpha: 0.7);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isLight ? const Color(0xFFF3F4F6) : Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: textColor, size: 20),
              ),
              Icon(Icons.more_vert, color: textColor, size: 20),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            item,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            category,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            status,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: isLight ? Colors.redAccent : Colors.white,
              fontWeight: isLight ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBreakdownChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Value',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      'Month',
                      style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1E234E)),
                    ),
                    const Icon(Icons.keyboard_arrow_down, size: 16),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '\$145,570.80',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E234E),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Synthetic pie chart
          SizedBox(
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: 0.7,
                    strokeWidth: 25,
                    color: const Color(0xFF009688), // Main Teal
                    backgroundColor: const Color(0xFF80CBC4), // Lighter Teal
                    strokeCap: StrokeCap.round,
                  ),
                ),
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: 0.3,
                    strokeWidth: 25,
                    color: const Color(0xFF00695C), // Dark Teal
                    backgroundColor: Colors.transparent,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '8,245',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E234E),
                      ),
                    ),
                    Text(
                      'Active Items',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickMenuCard('Add New\nStock', Icons.add_box_rounded),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickMenuCard('Audit\nInventory', Icons.fact_check_rounded),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickMenuCard('Transfer\nGoods', Icons.local_shipping_rounded),
        ),
      ],
    );
  }

  Widget _buildQuickMenuCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1), // Very light teal
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF009688), size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E234E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseReturnsList() {
    final returns = [
      {'item': 'Defective Shocks', 'date': '21 Sep, 03:02 PM', 'val': '-12 Units', 'icon': Icons.car_crash_rounded},
      {'item': 'Excess Oil Filters', 'date': '21 Sep, 03:22 PM', 'val': '-45 Units', 'icon': Icons.filter_alt_off_rounded},
      {'item': 'Damaged Mirrors', 'date': '21 Sep, 02:02 PM', 'val': '-3 Units', 'icon': Icons.broken_image_rounded},
    ];

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: returns.map((r) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FE),
                shape: BoxShape.circle,
              ),
              child: Icon(r['icon'] as IconData, color: const Color(0xFF1E234E)),
            ),
            title: Text(
              r['item'] as String,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E234E),
              ),
            ),
            subtitle: Text(
              r['date'] as String,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            trailing: Text(
              r['val'] as String,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
