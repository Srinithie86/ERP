import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Order Managment/orderdetails_screen.dart';
import '../Order Managment/confirmorders_screen.dart';
import '../Order Managment/dispatchment_screen.dart';
import '../Order Managment/dealersalesinvoice_screen.dart';
import '../Order Managment/ordertracking_screen.dart';
import '../Pricing & Schemes/price_screen.dart';
import '../Pricing & Schemes/discountschems_screen.dart';
import '../Inventory & Returns/purchasereturn_screen.dart';
import '../Inventory & Returns/stockavailability_screen.dart';
import '../Inventory & Returns/salesreturn_screen.dart';
import '../Inventory & Returns/replacementcredit_screen.dart';
import '../Payment & Credit/paymentcollections_screen.dart';
import '../Payment & Credit/creditmanagement_screen.dart';
import 'notification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  const DashboardScreen({super.key, this.isEmbedded = false, this.scaffoldKey});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final GlobalKey<ScaffoldState> _scaffoldKey;
  final GlobalKey<ScaffoldState> _innerScaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  String _selectedTimeframe = 'Month';
  List<Map<String, dynamic>> _dealerMenus = [];

  @override
  void initState() {
    super.initState();
    _scaffoldKey = widget.scaffoldKey ?? GlobalKey<ScaffoldState>();
    _loadMenuData();
  }

  Future<void> _loadMenuData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('user_menu_data');
      if (saved != null) {
        final Map<String, dynamic> fullMenu = json.decode(saved);
        String? targetKey;
        for (final key in fullMenu.keys) {
          if (key.trim().toUpperCase() == "DEALER MANAGEMENT" || key.trim().toUpperCase() == "DEALER") targetKey = key;
        }
        if (targetKey != null && fullMenu[targetKey] is List) {
          setState(() {
            _dealerMenus = List<Map<String, dynamic>>.from(fullMenu[targetKey]);
          });
        }
      }
    } catch (e) {
      debugPrint("Dealer Dashboard => Error: $e");
    }
  }

  bool _isVisible(String apiKey) {
    if (_dealerMenus.isEmpty) return true; // Show all by default if no dealer menu (or customize per requirement)
    return _dealerMenus.any((item) => item['name'].toString().trim().toUpperCase() == apiKey.trim().toUpperCase());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _innerScaffoldKey,
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: widget.isEmbedded 
        ? AppBar(
            backgroundColor: const Color(0xFF26A69A),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => _innerScaffoldKey.currentState?.openDrawer(),
            ),
            title: Text(
              'Dealer Management',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                ),
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  radius: 14,
                  backgroundImage: AssetImage('assets/Profile.png'),
                ),
              ),
            ],
          )
        : null,
      drawer: _buildCustomDrawer(context),
      bottomNavigationBar: _buildBottomNavBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!widget.isEmbedded) _buildPremiumHeader(context),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCards(),
                  const SizedBox(height: 24),
                  _buildQuickActionsSection(),
                  const SizedBox(height: 24),
                  _buildOrderSnapshot(),
                  const SizedBox(height: 24),
                  _buildSalesSection(),
                  const SizedBox(height: 24),
                  _buildTopDealers(),
                  const SizedBox(height: 24),
                  _buildAlertsSection(),
                  const SizedBox(height: 24),
                  _buildFooter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A1C1E),
      ),
    );
  }

  Widget _buildPremiumHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF26A69A),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (widget.scaffoldKey != null) {
                      widget.scaffoldKey!.currentState?.openDrawer();
                    } else {
                      _innerScaffoldKey.currentState?.openDrawer();
                    }
                  },
                  icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dealer Management',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationScreen()),
                ),
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
              const CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage('assets/Profile.png'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final allActions = [
      {'title': 'Create PR', 'icon': Icons.add, 'color': Colors.pink[400], 'key': 'Create PR'},
      {'title': 'SQ', 'icon': Icons.refresh, 'color': Colors.purple[400], 'key': 'SQ'},
      {'title': 'RFQ', 'icon': Icons.receipt, 'color': Colors.teal[400], 'key': 'RFQ'},
      {'title': 'PO', 'icon': Icons.local_offer, 'color': Colors.pink[400], 'key': 'PO'},
      {'title': 'GRN', 'icon': Icons.assignment_turned_in, 'color': Colors.green[400], 'key': 'GRN'},
      {'title': 'QC', 'icon': Icons.verified_user, 'color': Colors.blue[300], 'key': 'QC'},
      {'title': 'Approval', 'icon': Icons.description, 'color': Colors.lime[600], 'key': 'Approval'},
      {'title': 'Compare', 'icon': Icons.compare_arrows, 'color': Colors.red[400], 'key': 'Compare'},
    ];

    final actions = allActions.where((action) => _isVisible(action['key'] as String)).toList();

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Quick Actions'),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () {
                final key = action['key'] as String;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Action: $key triggered')),
                );
                // Navigation logic can be added here
              },
              child: Column(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: action['color'] as Color,
                      boxShadow: [
                        BoxShadow(
                          color: (action['color'] as Color).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(action['icon'] as IconData, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    action['title'] as String,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildImage2StyleCard(String title, String value, Color color1, Color color2, IconData icon, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color1, color2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color2.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: GoogleFonts.outfit(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShinyCardRow(List<Map<String, dynamic>> items) {
    if (items.isEmpty) { return const SizedBox.shrink(); }
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildImage2StyleCard(
          item['label'] as String,
          item['value'] as String,
          item['color1'] as Color,
          item['color2'] as Color,
          item['icon'] as IconData,
          subtitle: item['subtitle'] as String?,
        );
      },
    );
  }

  Widget _buildSummaryCards() {
    final summaryItems = [
      {'value': '₹24.5L', 'label': 'TOTAL SALES (MTD)', 'icon': Icons.trending_up, 'color1': Colors.blue[400], 'color2': Colors.blue[600], 'subtitle': '↑ 12.5%'},
      {'value': '1,247', 'label': 'TOTAL ORDERS', 'icon': Icons.assignment, 'color1': Colors.green[400], 'color2': Colors.green[600], 'subtitle': '↑ 8.3%'},
      {'value': '1,189', 'label': 'INVOICES', 'icon': Icons.receipt, 'color1': Colors.orange[400], 'color2': Colors.orange[600], 'subtitle': '↑ 5.2%'},
      {'value': '₹8.2L', 'label': 'OUTSTANDING', 'icon': Icons.money_off, 'color1': Colors.red[400], 'color2': Colors.red[600], 'subtitle': '↓ 3.1%'},
      {'value': '₹18.9L', 'label': 'COLLECTIONS', 'icon': Icons.savings, 'color1': Colors.teal[400], 'color2': Colors.teal[600], 'subtitle': '↑ 15.8%'},
      {'value': '342', 'label': 'ACTIVE DEALERS', 'icon': Icons.storefront, 'color1': Colors.purple[400], 'color2': Colors.purple[600], 'subtitle': '+12 New'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Summary Overview'),
            const Icon(Icons.analytics_outlined, color: Color(0xFF26A69A)),
          ],
        ),
        const SizedBox(height: 16),
        _buildShinyCardRow(summaryItems),
      ],
    );
  }

  Widget _buildLiteCardRow(List<Map<String, dynamic>> items) {
    if (items.isEmpty) { return const SizedBox.shrink(); }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final color = item['color'] as Color;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Icon(item['icon'] as IconData, color: color, size: 20),
                  ),
                  if (item['subtitle'] != null)
                    Text(item['subtitle'] as String, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Text(item['value'] as String, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87))),
                   const SizedBox(height: 4),
                   Text(item['label'] as String, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                ]
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSnapshot() {
    final orderItems = [
      {'value': '142', 'label': 'New Orders', 'icon': Icons.add_shopping_cart, 'color': Colors.pink[500], 'subtitle': '+12%'},
      {'value': '89', 'label': 'Approved', 'icon': Icons.check_circle_outline, 'color': Colors.blue[500]},
      {'value': '234', 'label': 'Dispatched', 'icon': Icons.local_shipping_outlined, 'color': Colors.teal[500]},
      {'value': '56', 'label': 'Pending', 'icon': Icons.pending_actions, 'color': Colors.orange[500]},
      {'value': '12', 'label': 'Cancelled', 'icon': Icons.cancel_outlined, 'color': Colors.red[500]},
      {'value': '45', 'label': 'Delivered', 'icon': Icons.done_all, 'color': Colors.green[500]},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildSectionTitle('Order Management\nSnapshot')),
            Text('Manage →', style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF26A69A), fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        _buildLiteCardRow(orderItems),
      ],
    );
  }

  Widget _buildSalesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle('Sales Trends'),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTimeframe,
                  items: ['Day', 'Month', 'Year'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF26A69A))),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() => _selectedTimeframe = newValue!),
                  icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF26A69A)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(_selectedTimeframe == 'Day' ? 0.3 : (_selectedTimeframe == 'Month' ? 0.4 : 0.6), 'Kikko'),
              _buildBar(_selectedTimeframe == 'Day' ? 0.5 : (_selectedTimeframe == 'Month' ? 0.7 : 0.8), 'Kellog\'s'),
              _buildBar(_selectedTimeframe == 'Day' ? 0.2 : (_selectedTimeframe == 'Month' ? 0.3 : 0.5), 'Mars'),
              _buildBar(_selectedTimeframe == 'Day' ? 0.4 : (_selectedTimeframe == 'Month' ? 0.5 : 0.7), 'Osem'),
              _buildBar(_selectedTimeframe == 'Day' ? 0.6 : (_selectedTimeframe == 'Month' ? 0.9 : 1.0), 'Nestle', isHighlighted: true),
              _buildBar(_selectedTimeframe == 'Day' ? 0.1 : (_selectedTimeframe == 'Month' ? 0.2 : 0.4), 'Godiva'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double heightFactor, String label, {bool isHighlighted = false}) {
    return Column(
      children: [
        Container(
          height: 120,
          width: 12,
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: heightFactor,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isHighlighted ? [Colors.blue, Colors.purple] : [Colors.blue.withValues(alpha: 0.3), Colors.blue.withValues(alpha: 0.1)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildTopDealers() {
    final dealers = [
      {'name': 'Hariharan\nDistributors', 'value': '₹2.4L', 'color': const Color(0xFF673AB7)},
      {'name': 'Kumar\nEnterprises', 'value': '₹2.1L', 'color': const Color(0xFF2196F3)},
      {'name': 'Patel\nTrading Co.', 'value': '₹1.9L', 'color': const Color(0xFF009688)},
      {'name': 'Singh\nBrothers', 'value': '₹1.7L', 'color': const Color(0xFFE91E63)},
      {'name': 'Gupta\nWholesale', 'value': '₹1.5L', 'color': const Color(0xFFFF9800)},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Top 5 Dealers by Revenue'),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: dealers.map((dealer) {
              return Container(
                width: 140,
                height: 140,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: dealer['color'] as Color, 
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: (dealer['color'] as Color).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ]
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dealer['name'] as String, style: GoogleFonts.outfit(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(dealer['value'] as String, style: GoogleFonts.outfit(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Alerts & Notifications'),
            Text('View All →', style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF26A69A), fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[400]!, Colors.red[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.red[600]!.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text('8 products are out of stock', style: GoogleFonts.outfit(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                     const SizedBox(height: 4),
                     Text('Immediate action required', style: GoogleFonts.outfit(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF26A69A),
        unselectedItemColor: Colors.grey[500],
        selectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w500, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.dashboard_rounded)), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.assignment_outlined)), label: 'PR'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.fact_check_outlined)), label: 'Approvals'),
          BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.shopping_cart_outlined)), label: 'PO'),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(child: Text('© 2026 Smart Global Solutions', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[400])));
  }

  Widget _buildCustomDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(0, 60, 0, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF26A69A),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  'DEALER MANAGEMENT',
                  style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                _buildDrawerItem('Dashboard', Icons.dashboard_outlined, () => Navigator.pop(context)),
                _buildDrawerItem('Profile', Icons.person_outline, () {}),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text('MANAGEMENT', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.2)),
                ),
                
                ..._buildManagementDropdowns(context),

                const Divider(),
                _buildDrawerItem('Help & Support', Icons.help_outline_rounded, () {}),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: Text('Logout', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  onTap: () {},
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF26A69A)),
      title: Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
      onTap: onTap,
    );
  }

  List<Widget> _buildManagementDropdowns(BuildContext context) {
    final modules = [
      {'title': 'Order Management', 'icon': Icons.assignment_outlined, 'subItems': ['Order Details', 'Confirm Orders', 'Dispatchment', 'Dealer Sales Invoice', 'Order Tracking']},
      {'title': 'Pricing & Schemes', 'icon': Icons.local_offer_outlined, 'subItems': ['Price', 'Discount Schemes']},
      {'title': 'Inventory & Returns', 'icon': Icons.inventory_2_outlined, 'subItems': ['Purchase return', 'Stock Availability', 'Sales return', 'Replacement/ Credit Note']},
      {'title': 'Payment & Credit', 'icon': Icons.account_balance_wallet_outlined, 'subItems': ['Payment Collections', 'Credit Management', 'Payment Reconciliation', 'Dealer Ledger']},
      {'title': 'Dealer Reports', 'icon': Icons.analytics_outlined, 'subItems': ['Sales & Collection Report', 'Dealer performance']},
      {'title': 'Dealer Details', 'icon': Icons.business_outlined, 'subItems': ['Product Details', 'E com product', 'Wishlist', 'Order Status', 'License Uploads', 'Advertisement', 'Delivery', 'Category List']},
      {'title': 'Access Control', 'icon': Icons.security_outlined, 'subItems': []},
    ];

    return modules.map((m) {
      final title = m['title'] as String;
      final icon = m['icon'] as IconData;
      final subItems = List<String>.from(m['subItems'] as List);

      if (subItems.isEmpty) {
        return ListTile(
          leading: Icon(icon, color: const Color(0xFF26A69A)),
          title: Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
          onTap: () {},
        );
      }

      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Icon(icon, color: const Color(0xFF26A69A)),
          title: Text(title, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
          iconColor: Colors.black,
          collapsedIconColor: Colors.black54,
          childrenPadding: const EdgeInsets.only(left: 32, bottom: 8),
          children: subItems.map((item) {
            return ListTile(
              dense: true,
              title: Text(item, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500)),
              onTap: () {
                _navigateToScreen(context, item);
              },
            );
          }).toList(),
        ),
      );
    }).toList();
  }

  void _navigateToScreen(BuildContext context, String item) {
    if (item == 'Order Details') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const OrderDetailsScreen()));
    } else if (item == 'Confirm Orders') {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ConfirmOrdersScreen()));
    } else if (item == 'Dispatchment') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => const DispatchmentScreen()));
    } else if (item == 'Dealer Sales Invoice') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => const DealerSalesInvoiceScreen()));
    } else if (item == 'Order Tracking') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => const OrderTrackingScreen()));
    } else if (item == 'Price') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => const PriceScreen()));
    } else if (item == 'Discount Schemes') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => const DiscountSchemesScreen()));
    } else if (item == 'Purchase return') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => const PurchaseReturnScreen()));
    } else if (item == 'Stock Availability') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => const StockAvailabilityScreen()));
    } else if (item == 'Sales return') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => const SalesReturnScreen()));
    } else if (item == 'Replacement/ Credit Note') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => const ReplacementCreditScreen()));
    } else if (item == 'Payment Collections') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => const PaymentCollectionsScreen()));
    } else if (item == 'Credit Management') {
      Navigator.push(context, CupertinoPageRoute(builder: (context) => const CreditManagementScreen()));
    }
  }
}
