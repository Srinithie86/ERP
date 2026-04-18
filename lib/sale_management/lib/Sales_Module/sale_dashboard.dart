import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sale_management/Proforma_Invoice_Module/generate_info.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:erp_smart/providers/menu_provider.dart';
import 'package:erp_smart/utils/app_navigation.dart';
import 'package:erp_smart/utils/widgets/dynamic_drawer.dart';
import 'package:erp_smart/utils/widgets/profile_details_sheet.dart';

import '../widgets/app_theme.dart';
import 'notification_screen.dart';
import 'inventory_catalog_screen.dart';
import '../profile module/profile_screen.dart';
import 'receipt_voucher_screen.dart';
import '../Direct_invoice_module/direct_generate_info.dart';

import '../sales_order_module/generate_info.dart';
import '../sales_order_module/all_voice_screen.dart';
import '../sales_invoice_module/all_voice_screen.dart';
import '../sales_invoice_module/generate_info.dart';
import '../Proforma_Invoice_Module/generate_info.dart';

export 'approve_screen.dart';
export 'receipt_voucher_screen.dart';

class DashboardPage extends StatefulWidget {
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DashboardPage({
    super.key,
    this.isEmbedded = false,
    this.scaffoldKey,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  static const _navItems = [
    _BottomNavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
    ),
    _BottomNavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Receipt',
    ),
    _BottomNavItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      label: 'Products',
    ),
    // _BottomNavItem(
    //   icon: Icons.person_outline_rounded,
    //   activeIcon: Icons.person_rounded,
    //   label: 'Profile',
    // ),
  ];

  static final _tabPages = [
    const _DashboardBody(),
    const ReceiptVoucherScreen(),
    const SalesOrderInventoryCatalogScreen(),
   // const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarTeal,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        endDrawer: const DynamicDrawer(moduleName: "SALES"),
        body: _tabPages[_selectedIndex],
        bottomNavigationBar: _BottomNavBar(
          selectedIndex: _selectedIndex,
          items: _navItems,
          onTap: (i) => setState(() => _selectedIndex = i),
        ),
      ),
    );
  }
}

// ─── BOTTOM NAV BAR ──────────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<_BottomNavItem> items;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE8EDF2), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = selectedIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary.withOpacity(0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive
                              ? AppColors.primary
                              : const Color(0xFFB0BEC5),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 220),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? AppColors.primary
                              : const Color(0xFFB0BEC5),
                          fontFamily: 'Poppins',
                        ),
                        child: Text(item.label),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─── DASHBOARD BODY ───────────────────────────────────────────────────────────
class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context),
        const SliverToBoxAdapter(child: SizedBox(height: 1)),
        _buildStatsGrid(context),
        _buildSectionLabel('Quick Actions'),
        _buildQuickActions(context),
        _buildReportsAnalyticsBanner(),
        _buildSectionLabel('Monthly Revenue Trend'),
        _buildRevenueChart(),
        _buildOrderStatusSection(),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: const Color(0xFF26A69A),
      titleSpacing: 20,
      title: const Text(
        'Sales Management',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const NotificationPage()),
             );
          },
          icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 4),
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openEndDrawer(),
            child: const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  SliverToBoxAdapter _buildQuickActions(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final subMenus = menuProvider.getSubMenus("SALES");

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: subMenus.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("No actions available"),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.65,
                ),
                itemCount: subMenus.length,
                itemBuilder: (context, index) {
                  final item = subMenus[index];
                  final String name = (item['name'] ?? '').toString();
                  final String trimmedName = name.trim();

                  return _QuickActionButton(
                    icon: AppNavigation.getIcon(trimmedName),
                    label: _getShortLabel(trimmedName),
                    color: _getActionColor(trimmedName),
                    onTap: () => AppNavigation.handleNavigation(context, trimmedName, moduleContext: "SALES"),
                  );
                },
              ),
      ),
    );
  }

  String _getShortLabel(String label) {
    final String n = label.toUpperCase();
    if (n.contains("SALES ORDER")) return "Order";
    if (n.contains("SALES INVOICE")) return "Invoice";
    if (n.contains("PROFORMA")) return "Proforma";
    if (n.contains("DIRECT INVOICE")) return "Direct";
    if (n.contains("DELIVERY CHALLAN")) return "Challan";
    if (n.contains("RETURN")) return "Return";
    if (n.contains("DASHBOARD")) return "Dashboard";
    if (n.contains("APPROVAL")) return "Approval";
    if (label.length > 10) return label.split(' ').first;
    return label;
  }

  Color _getActionColor(String name) {
    final String n = name.toUpperCase();
    if (n.contains("INVOICE")) return const Color(0xFFF7143C);
    if (n.contains("ORDER")) return const Color(0xFF3C03CB);
    if (n.contains("PROFORMA")) return const Color(0xFF13EAD4);
    if (n.contains("DIRECT")) return const Color(0xFFB31677);
    if (n.contains("CHALLAN")) return const Color(0xFF26A69A);
    if (n.contains("RETURN")) return Colors.orange;
    return const Color(0xFF26A69A);
  }

  SliverToBoxAdapter _buildReportsAnalyticsBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF26A69A),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF26A69A).withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: const [
            Text(
              'Reports & Analytics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
            ),
            Spacer(),
            Icon(Icons.chevron_right_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionLabel(String title, {bool showMore = false}) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1A2332),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            if (showMore) ...[
              const Spacer(),
              const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF26A69A),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF26A69A), size: 16),
            ],
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildStatsGrid(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            StatCard(
              icon: Icons.shopping_cart,
              title: 'Sales Orders',
              value: '248',
              change: '+8.3%',
              isPositive: true,
              accentColor: const Color(0xFFFF2D55),
              gradient: const LinearGradient(
                colors: [Color(0xFFF70E37), Color(0xFFFF869B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AllSalesOrderPage()));
              },
            ),
            StatCard(
              icon: Icons.description,
              title: 'Invoice Issued',
              value: '12',
              change: '+5.7%',
              isPositive: true,
              accentColor: const Color(0xFF5856D6),
              gradient: const LinearGradient(
                colors: [Color(0xFF3A00CA), Color(0xFF8E60FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SalesInvoiceAllScreen()));
              },
            ),
            StatCard(
              icon: Icons.monetization_on,
              title: 'Collections',
              value: '28',
              change: '+8.0%',
              isPositive: true,
              accentColor: const Color(0xFF00D1FF),
              gradient: const LinearGradient(
                colors: [Color(0xFF018477), Color(0xFF15F3DD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            StatCard(
              icon: Icons.track_changes,
              title: 'Sales Returns',
              value: '16',
              change: '-12%',
              isPositive: false,
              accentColor: const Color(0xFFD81B60),
              gradient: const LinearGradient(
                colors: [Color(0xFFA8076A), Color(0xFFFF7CCD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRevenueChart() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: RevenueChartCard(),
      ),
    );
  }

  SliverToBoxAdapter _buildOrderStatusSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Status',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CustomPaint(
                    painter: PieChartPainter(),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: [
                      _buildLegendItem('Rejected', const Color(0xFF00CED1)),
                      _buildLegendItem('Completed', const Color(0xFFCD853F)),
                      _buildLegendItem('Pending', const Color(0xFFF0E68C)),
                      _buildLegendItem('Process', const Color(0xFF003D4D)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── REUSABLE WIDGETS ────────────────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String change;
  final bool isPositive;
  final Color accentColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.accentColor,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -10,
                  child: Icon(
                    icon,
                    size: 80,
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          change,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RevenueChartCard extends StatelessWidget {
  const RevenueChartCard({super.key});

  // Heights as fractions of the chart area (ascending)
  static const _data = [
    _BarData('January',  0.28, Color(0xFFFFAA00), '+12.2'),
    _BarData('February', 0.44, Color(0xFFFF2D85), '+23.5'),
    _BarData('March',    0.60, Color(0xFFCC00EE), '+32.5'),
    _BarData('April',    0.76, Color(0xFF5500DD), '+43.3'),
    _BarData('May',      0.92, Color(0xFF3300AA), '+55.5'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '₹2.85M',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Total Revenue FY 2025-26',
            style: TextStyle(
              color: Color(0xFF26A69A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: CustomPaint(
              painter: _BarChartPainter(_data),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarData {
  final String label;
  final double heightFactor;
  final Color color;
  final String value;
  const _BarData(this.label, this.heightFactor, this.color, this.value);
}

class _BarChartPainter extends CustomPainter {
  final List<_BarData> data;
  const _BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    const labelHeight = 28.0;
    const dotArea = 24.0;
    final chartH = size.height - labelHeight - dotArea;
    final barW = size.width / data.length;
    final halfBar = barW * 0.32;

    final dotCenters = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final barH = chartH * d.heightFactor;
      final left = barW * i + (barW - halfBar * 2) / 2;
      final right = left + halfBar * 2;
      final bottom = chartH;
      final top = bottom - barH;
      final peakX = (left + right) / 2;

      // Pentagon path (house top)
      final path = Path()
        ..moveTo(left, bottom)
        ..lineTo(left, top + halfBar * 0.45)
        ..lineTo(peakX, top)
        ..lineTo(right, top + halfBar * 0.45)
        ..lineTo(right, bottom)
        ..close();

      // Gradient fill
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [d.color.withOpacity(0.65), d.color],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(left, top, halfBar * 2, barH));
      canvas.drawPath(path, paint);

      // Dot center (above peak)
      final dotY = chartH - barH - 16;
      dotCenters.add(Offset(peakX, dotY));

      // Value label above dot
      final tp = TextPainter(
        text: TextSpan(
          text: d.value,
          style: TextStyle(
            color: d.color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(peakX - tp.width / 2, dotY - tp.height - 4));

      // Month label at bottom
      final ltp = TextPainter(
        text: TextSpan(
          text: d.label,
          style: TextStyle(
            color: d.color,
            fontSize: 9.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: barW - 4);
      final lblX = barW * i + (barW - ltp.width) / 2;
      ltp.paint(canvas, Offset(lblX, chartH + 6));
    }

    // Draw Bezier curve through dot centers
    if (dotCenters.length >= 2) {
      final curvePaint = Paint()
        ..color = Colors.grey.withOpacity(0.45)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final curvePath = Path();
      curvePath.moveTo(dotCenters.first.dx, dotCenters.first.dy);

      for (int i = 0; i < dotCenters.length - 1; i++) {
        final p0 = dotCenters[i];
        final p1 = dotCenters[i + 1];
        final cpX = (p0.dx + p1.dx) / 2;
        curvePath.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
      }
      canvas.drawPath(curvePath, curvePaint);

      // Draw dots on the curve
      for (int i = 0; i < dotCenters.length; i++) {
        final dotPaint = Paint()
          ..color = data[i].color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(dotCenters[i], 5, dotPaint);
        canvas.drawCircle(
          dotCenters[i],
          5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class PieChartPainter extends CustomPainter {
  // Segments: [Process=40%, Rejected=22%, Completed=20%, Pending=18%]
  static const _segments = [
    _PieSegment(0.40, Color(0xFF00586A), '40%'),  // Process  – dark teal
    _PieSegment(0.22, Color(0xFF2ECFCF), '22%'),  // Rejected – cyan
    _PieSegment(0.20, Color(0xFFBF8C3A), '20%'),  // Completed – golden-brown
    _PieSegment(0.18, Color(0xFFE8D580), '18%'),  // Pending  – yellow cream
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width < size.height ? size.width : size.height) / 2 - 4;

    double startAngle = -math.pi / 2; // Start at top

    for (final seg in _segments) {
      final sweepAngle = seg.fraction * 2 * math.pi;
      final paint = Paint()
        ..color = seg.color
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // White gap separator line
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(startAngle),
          center.dy + radius * math.sin(startAngle),
        ),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke,
      );

      // Percentage label in the middle of the slice
      final midAngle = startAngle + sweepAngle / 2;
      final labelR = radius * 0.65;
      final lx = center.dx + labelR * math.cos(midAngle);
      final ly = center.dy + labelR * math.sin(midAngle);

      final tp = TextPainter(
        text: TextSpan(
          text: seg.label,
          style: TextStyle(
            color: seg.color == const Color(0xFFE8D580)
                ? const Color(0xFF7A6A00)
                : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _PieSegment {
  final double fraction;
  final Color color;
  final String label;
  const _PieSegment(this.fraction, this.color, this.label);
}
