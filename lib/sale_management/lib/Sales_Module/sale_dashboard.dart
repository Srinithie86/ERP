import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sale_management/Delivery_chellan_module/all_voice_screen.dart'
    as dc_voice;
import 'package:sale_management/Proforma_Invoice_Module/all_voice_screen.dart'
    as proforma_voice;
import 'package:sale_management/Proforma_Invoice_Module/generate_info.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:sale_management/Sales_Module/approve_screen.dart';
import 'package:sale_management/widgets/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:sale_management/widgets/app_theme.dart';
import 'package:erp_localization/erp_localization.dart';
import 'notification_screen.dart';
import 'inventory_catalog_screen.dart';
import 'package:sale_management/profile module/profile_screen.dart';
import 'receipt_voucher_screen.dart';
import 'package:sale_management/Direct_invoice_module/direct_generate_info.dart';

import 'package:sale_management/sales_order_module/generate_info.dart';
import 'package:sale_management/sales_order_module/all_voice_screen.dart'
    as so_voice;
import 'package:sale_management/sales_invoice_module/all_voice_screen.dart'
    as si_voice;
import 'package:sale_management/sales_invoice_module/generate_info.dart';
import 'package:sale_management/core/api_config.dart';

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

  List<Widget> _buildTabPages() => const [
        _DashboardBody(),
        ReceiptVoucherScreen(),
        SalesOrderInventoryCatalogScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final tabPages = _buildTabPages();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarTeal,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        drawer: const AppDrawer(),
        body: tabPages[_selectedIndex],
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
class _DashboardBody extends StatefulWidget {
  const _DashboardBody();

  @override
  State<_DashboardBody> createState() => _DashboardBodyState();
}

class _DashboardBodyState extends State<_DashboardBody> {
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? '44555666';
      final uid = prefs.getString('uid') ?? '1';
      final roleId = prefs.getString('role_id') ?? '1';
      final deviceId = prefs.getString('device_id') ?? 'abc123';
      final token = prefs.getString('token') ?? 'gjfhh';
      final lt = prefs.getString('lt') ?? '123';
      final ln = prefs.getString('ln') ?? '123';

      final response = await http.post(
        Uri.parse(await ApiConfig.getBaseUrl()),
        body: {
          'type': '8016',
          'cid': cid,
          'role_id': roleId,
          'lt': lt,
          'ln': ln,
          'device_id': deviceId,
          'uid': uid,
          'token': token,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _dashboardData = data;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF26A69A)));
    }

    final counts = _dashboardData?['counts'] ?? {};
    final revenueData = _dashboardData?['monthly_revenue'] ?? {};
    final topProducts = (_dashboardData?['top_products'] as List?) ?? [];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildAppBar(context),
        const SliverToBoxAdapter(child: SizedBox(height: 1)),
        _buildStatsGrid(context, counts),
        _buildSectionLabel(AppLocalization.of('Quick Actions')),
        _buildQuickActions(context),
        _buildReportsAnalyticsBanner(),
        _buildRevenueChart(revenueData),
        _buildSectionLabel(AppLocalization.of('Monthly Revenue Trend')),
        _buildTopProductsSection(topProducts),
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
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        AppLocalization.of('Sales Management'),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
      actions: const [],
    );
  }

  SliverToBoxAdapter _buildQuickActions(BuildContext context) {
    // Modular fix: Use a local list of sub-menus instead of the global MenuProvider
    // to avoid dependency on the erp_smart main app.
    final List<Map<String, dynamic>> subMenus = [
      {'name': 'Sales Order'},
      {'name': 'Sales Invoice'},
      {'name': 'Proforma Invoice'},
      {'name': 'Direct Invoice'},
      {'name': 'Delivery Challan'},
      {'name': 'Approval'},
      {'name': 'Receipt Voucher'},
    ];

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
                    icon: _getLocalIcon(trimmedName),
                    label: _getShortLabel(trimmedName),
                    color: _getActionColor(trimmedName),
                    onTap: () => _handleLocalNavigation(context, trimmedName),
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

  SliverToBoxAdapter _buildStatsGrid(
      BuildContext context, Map<String, dynamic> counts) {
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
              value: counts['sales_order']?.toString() ?? '0',
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
                        builder: (context) => const so_voice.AllSalesOrderPage()));
              },
            ),
            StatCard(
              icon: Icons.description,
              title: 'Sales Invoice',
              value: counts['invoice']?.toString() ?? '0',
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
                        builder: (context) => const si_voice.SalesInvoiceAllScreen()));
              },
            ),
            StatCard(
              icon: Icons.monetization_on,
              title: 'Delivery Challan',
              value: counts['delivery_challan']?.toString() ?? '0',
              change: '+8.0%',
              isPositive: true,
              accentColor: const Color(0xFF00D1FF),
              gradient: const LinearGradient(
                colors: [Color(0xFF018477), Color(0xFF15F3DD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const dc_voice.DeliveryChallanAllScreen()));
              },
            ),
            StatCard(
              icon: Icons.track_changes,
              title: 'Proforma Invoice',
              value: counts['proforma']?.toString() ?? '0',
              change: '-12%',
              isPositive: false,
              accentColor: const Color(0xFFD81B60),
              gradient: const LinearGradient(
                colors: [Color(0xFFA8076A), Color(0xFFFF7CCD)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const proforma_voice.ProformaAllInvoicePage(
                              title: 'Proforma Invoice',
                            )));
              },
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRevenueChart(Map<String, dynamic> revenueData) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: RevenueChartCard(revenueData: revenueData),
      ),
    );
  }

  SliverToBoxAdapter _buildTopProductsSection(List<dynamic> products) {
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
              'Top Products',
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 16),
            if (products.isEmpty)
              const Center(child: Text("No product data available"))
            else
              ...products.map((p) => _buildProductItem(p)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    final name = product['product_name'] ?? 'Unknown';
    final qty = product['quantity']?.toString() ?? '0';
    final perc = (product['percentage'] as num?)?.toDouble() ?? 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$qty units',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF26A69A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (perc / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF26A69A), Color(0xFF4DB6AC)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${perc.toStringAsFixed(1)}% of total sales',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

  IconData _getLocalIcon(String name) {
    final String n = name.toUpperCase();
    if (n.contains("ORDER")) return Icons.local_offer_outlined;
    if (n.contains("INVOICE")) return Icons.receipt_long_outlined;
    if (n.contains("PROFORMA")) return Icons.description_outlined;
    if (n.contains("DIRECT")) return Icons.bolt_rounded;
    if (n.contains("CHALLAN")) return Icons.local_shipping_outlined;
    if (n.contains("RETURN")) return Icons.assignment_return_outlined;
    if (n.contains("APPROVAL")) return Icons.assignment_ind_outlined;
    if (n.contains("RECEIPT") || n.contains("VOUCHER"))
      return Icons.account_balance_wallet_outlined;
    return Icons.circle_outlined;
  }

  void _handleLocalNavigation(BuildContext context, String name) {
    final String n = name.trim().toUpperCase();
    if (n.contains("SALES ORDER")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const so_voice.AllSalesOrderPage()));
    } else if (n.contains("SALES INVOICE")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const si_voice.SalesInvoiceAllScreen()));
    } else if (n.contains("DELIVERY CHALLAN")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const dc_voice.DeliveryChallanAllScreen()));
    } else if (n.contains("PROFORMA INVOICE")) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  const proforma_voice.ProformaAllInvoicePage(title: 'Proforma Invoice')));
    } else if (n.contains("DIRECT INVOICE")) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const DirectInvoiceGenerateInfoScreen()));
    } else if (n.contains("APPROVAL")) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const ApproveScreen()));
    } else if (n.contains("RECEIPT") || n.contains("VOUCHER")) {
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ReceiptVoucherScreen()));
    }
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
  final Map<String, dynamic> revenueData;
  const RevenueChartCard({super.key, required this.revenueData});

  @override
  Widget build(BuildContext context) {
    final rawData = (revenueData['data'] as List?) ?? [];
    List<_BarData> chartData = [];

    double maxRevenue = 0;
    for (var d in rawData) {
      double rev = (d['total_revenue'] as num?)?.toDouble() ?? 0.0;
      if (rev > maxRevenue) maxRevenue = rev;
    }

    if (maxRevenue == 0) maxRevenue = 1.0; // Avoid division by zero

    for (var d in rawData) {
      double rev = (d['total_revenue'] as num?)?.toDouble() ?? 0.0;
      chartData.add(_BarData(
          d['month']?.toString().substring(0, 3) ?? '',
          rev / maxRevenue,
          _getMonthColor(d['month_num'] ?? 0),
          '₹${(rev / 1000).toStringAsFixed(1)}k'));
    }

    // Default bars if empty
    if (chartData.isEmpty) {
      chartData = [
        const _BarData('No Data', 0.1, Color(0xFF26A69A), '0'),
      ];
    }

    final totalRevenue = revenueData['total_revenue'] ?? 0;
    final financialYear = revenueData['financial_year'] ?? 'N/A';

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
          Text(
            '₹${((totalRevenue as num) / 100000).toStringAsFixed(2)}L',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Total Revenue FY $financialYear',
            style: const TextStyle(
              color: Color(0xFF26A69A),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 34),
          SizedBox(
            height: 240,
            child: CustomPaint(
              painter: _BarChartPainter(chartData),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMonthColor(int num) {
    List<Color> colors = [
      const Color(0xFFFFAA00),
      const Color(0xFFFF2D85),
      const Color(0xFFCC00EE),
      const Color(0xFF5500DD),
      const Color(0xFF3300AA),
      const Color(0xFF26A69A)
    ];
    return colors[num % colors.length];
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
    const dotArea = 48.0; // Increased to prevent overshooting at the top
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