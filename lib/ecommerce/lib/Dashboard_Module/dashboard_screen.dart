// ════════════════════════════════════════════════════
//  dashboard_screen.dart  ──  UPDATED VERSION
//  Sales Analytics with Filter functionality
// ════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../Theme_Module/colors_and_models.dart';
import 'drawer_screen.dart';
import '../Order_Module/order_screen.dart';
import '../Products_Module/product_screen.dart';
import '../Reports_Module/reports_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ═══════════════════════════════════════════
//  MAIN SHELL
// ═══════════════════════════════════════════
class MainShell extends StatefulWidget {
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const MainShell({super.key, this.isEmbedded = false, this.scaffoldKey});
  @override State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const OrdersScreen(),
      const ProductsScreen(),
      const ReportsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _idx == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_idx != 0) {
          setState(() {
            _idx = 0;
          });
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _idx, children: _screens),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = [
      (Icons.dashboard_rounded,    'Dashboard'),
      (Icons.receipt_long_rounded, 'Orders'),
      (Icons.inventory_2_rounded,  'Products'),
      (Icons.bar_chart_rounded,    'Reports'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.07),
          blurRadius: 18, offset: const Offset(0, -3),
        )],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == _idx;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _idx = i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: active ? C.primaryLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(items[i].$1, size: 20,
                            color: active ? C.primary : C.textLight),
                      ),
                      const SizedBox(height: 2),
                      Text(items[i].$2,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                            color: active ? C.primary : C.textLight,
                          )),
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

// ═══════════════════════════════════════════
//  SALES DATA MODEL
// ═══════════════════════════════════════════
class _SalesData {
  final List<String> labels;
  final List<double> revenue;
  final List<double> orders;
  final String       range;
  final String       growth;
  final String       total;

  const _SalesData({
    required this.labels,
    required this.revenue,
    required this.orders,
    required this.range,
    required this.growth,
    required this.total,
  });
}

const _salesDataMap = {
  'Today': _SalesData(
    labels:  ['9AM','11AM','1PM','3PM','5PM','7PM','9PM'],
    revenue: [0.20, 0.45, 0.60, 0.38, 0.72, 0.88, 0.55],
    orders:  [0.15, 0.35, 0.50, 0.28, 0.60, 0.74, 0.42],
    range:   'Hourly — Today',
    growth:  '↑ 18.5%',
    total:   '₹24.8k',
  ),
  'Week': _SalesData(
    labels:  ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'],
    revenue: [0.42, 0.55, 0.38, 0.70, 0.62, 0.88, 0.74],
    orders:  [0.30, 0.45, 0.28, 0.58, 0.50, 0.72, 0.60],
    range:   'Daily — This Week',
    growth:  '↑ 12.3%',
    total:   '₹1.2L',
  ),
  'Month': _SalesData(
    labels:  ['W1','W2','W3','W4','W5','W6','W7'],
    revenue: [0.30, 0.48, 0.36, 0.65, 0.52, 0.88, 0.74],
    orders:  [0.20, 0.38, 0.28, 0.55, 0.42, 0.70, 0.60],
    range:   'Weekly — This Month',
    growth:  '↑ 22.1%',
    total:   '₹4.8L',
  ),
  'Quarter': _SalesData(
    labels:  ['Jan','Feb','Mar','Apr','May','Jun','Jul'],
    revenue: [0.35, 0.52, 0.44, 0.68, 0.58, 0.82, 0.76],
    orders:  [0.25, 0.42, 0.34, 0.56, 0.46, 0.68, 0.62],
    range:   'Monthly — This Quarter',
    growth:  '↑ 31.4%',
    total:   '₹18.2L',
  ),
  'Year': _SalesData(
    labels:  ['Q1','Q2','Q3','Q4','Q5','Q6','Q7'],
    revenue: [0.40, 0.55, 0.48, 0.72, 0.64, 0.90, 0.78],
    orders:  [0.30, 0.45, 0.38, 0.60, 0.52, 0.76, 0.65],
    range:   'Quarterly — This Year',
    growth:  '↑ 45.2%',
    total:   '₹62.5L',
  ),
};

// ═══════════════════════════════════════════
//  DASHBOARD SCREEN
// ═══════════════════════════════════════════
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _ecomMenus = [];

  @override
  void initState() {
    super.initState();
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
          if (key.trim().toUpperCase() == "ECOMMERCE" || key.trim().toUpperCase() == "E-COMMERCE") targetKey = key;
        }
        if (targetKey != null && fullMenu[targetKey] is List) {
          setState(() {
            _ecomMenus = List<Map<String, dynamic>>.from(fullMenu[targetKey]);
          });
        }
      }
    } catch (e) {
      debugPrint("E-Commerce Dashboard => Error: $e");
    }
  }

  bool _isVisible(String apiKey) {
    return _ecomMenus.any((item) => item['name'].toString().trim().toUpperCase() == apiKey.trim().toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final w  = MediaQuery.of(context).size.width;
    final hp = w > 600 ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: C.bg,
      drawer: const EcomDrawer(),
      appBar: const EcomAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hp, vertical: 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 14),

          // OCards
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: w > 600 ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
            children: const [
              _OCard(icon: Icons.attach_money_rounded,        label: "Today's Sales",    value: '24,850', prefix: '₹', trend: '+18.5%', pos: true,  border: C.orange),
              _OCard(icon: Icons.inbox_rounded,                label: 'Total Orders',     value: '156',    prefix: '',  trend: '+12.3%', pos: true,  border: C.blue),
              _OCard(icon: Icons.show_chart_rounded,           label: 'Conversion Rate',  value: '4.8%',   prefix: '',  trend: '+0.3%',  pos: true,  border: C.purple),
              _OCard(icon: Icons.credit_card_rounded,          label: 'Avg. Order Value', value: '159',    prefix: '₹', trend: '+5.2%',  pos: true,  border: C.teal),
              _OCard(icon: Icons.remove_shopping_cart_rounded, label: 'Abandoned Carts',  value: '24',     prefix: '',  trend: '-8.0%',  pos: false, border: C.red),
              _OCard(icon: Icons.group_add_rounded,            label: 'New Customers',    value: '89',     prefix: '',  trend: '+2.3%',  pos: true,  border: C.pink),
            ],
          ),
          const SizedBox(height: 28),

          // Module grid
          const SecTitle('E-COMMERCE Modules'),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1,
            children: [
              if (_isVisible('Orders Mgmt') || _isVisible('Orders'))
                _Mod(Icons.shopping_cart_rounded, 'Orders\nMgmt',         C.orangeLight, C.orange, badge: '12 new', onTap: () => _push(context, const OrdersScreen())),
              if (_isVisible('Product Catalog') || _isVisible('Products'))
                _Mod(Icons.category_rounded,       'Product\nCatalog',     C.yellowLight, C.orange, onTap: () => _push(context, const ProductsScreen())),
              if (_isVisible('Customer Mgmt') || _isVisible('Customers'))
                _Mod(Icons.people_rounded,         'Customer\nMgmt',       C.purpleLight, C.purple, onTap: () => _push(context, const CustomerScreen())),
              if (_isVisible('Marketing & Promos') || _isVisible('Marketing'))
                _Mod(Icons.campaign_rounded,       'Marketing\n& Promos',  C.pinkLight,   C.pink,   onTap: () => _push(context, const MarketingScreen())),
              if (_isVisible('Inventory Mgmt') || _isVisible('Inventory'))
                _Mod(Icons.bar_chart_rounded,      'Inventory\nMgmt',      C.blueLight,   C.blue,   badge: '3 low', onTap: () {}),
              if (_isVisible('Shipping & Delivery') || _isVisible('Shipping'))
                _Mod(Icons.local_shipping_rounded, 'Shipping\n& Delivery', C.greenLight,  C.green,  onTap: () => _push(context, const ShippingScreen())),
            ],
          ),
          const SizedBox(height: 28),

          // ── Sales Analytics with Filter ──
          const SecTitle('Sales Analytics'),
          const SizedBox(height: 14),
          const SalesBarLineChart(),
          const SizedBox(height: 14),
          const TrafficRingChart(),
          const SizedBox(height: 28),

          // Recent orders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SecTitle('Recent Orders'),
              TextButton(
                onPressed: () => _push(context, const OrdersScreen()),
                child: const Text('See All →',
                    style: TextStyle(color: C.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...kAllOrders.take(3).map((o) => OrderRow(order: o)),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }

  void _push(BuildContext ctx, Widget s) =>
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => s));
}

// ═══════════════════════════════════════════
//  ORDER ROW
// ═══════════════════════════════════════════
class OrderRow extends StatelessWidget {
  final Order order;
  const OrderRow({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final sc = statusColor(order.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: kCard(),
      padding: const EdgeInsets.all(14),
      child: Column(children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: C.blueLight, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.receipt_long_rounded, color: C.blue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.id, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: C.textDark)),
              Text(order.name, style: const TextStyle(fontSize: 12, color: C.textMid)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('₹${order.amount}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: C.textDark)),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: sc.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
              child: Text(order.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: sc)),
            ),
          ]),
        ]),
        const SizedBox(height: 10),
        const Divider(height: 1, color: C.bg),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.calendar_today_rounded, size: 11, color: C.textLight),
              const SizedBox(width: 4),
              Text(order.date, style: const TextStyle(fontSize: 11, color: C.textLight)),
            ]),
            Row(children: [
              const Icon(Icons.layers_rounded, size: 11, color: C.textLight),
              const SizedBox(width: 4),
              Text('${order.items} items', style: const TextStyle(fontSize: 11, color: C.textLight)),
            ]),
            const Text('View Details →',
                style: TextStyle(fontSize: 11, color: C.primary, fontWeight: FontWeight.w700)),
          ],
        ),
      ]),
    );
  }
}

// ═══════════════════════════════════════════
//  _OCard
// ═══════════════════════════════════════════
class _OCard extends StatelessWidget {
  final IconData icon;
  final String   label, value, prefix, trend;
  final bool     pos;
  final Color    border;

  const _OCard({
    required this.icon, required this.label, required this.value,
    required this.prefix, required this.trend, required this.pos,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: border,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(
          color: border.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4),
        )],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(trend,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$prefix$value',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.85))),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════
//  _Mod
// ═══════════════════════════════════════════
class _Mod extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        ibg, ic;
  final String?      badge;
  final VoidCallback onTap;
  const _Mod(this.icon, this.label, this.ibg, this.ic, {this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: kCard(),
      child: LayoutBuilder(builder: (ctx, bc) {
        final iconSize  = (bc.maxHeight * 0.40).clamp(28.0, 42.0);
        final iconInner = (iconSize * 0.46).clamp(14.0, 20.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: iconSize, height: iconSize,
                decoration: BoxDecoration(color: ibg, shape: BoxShape.circle),
                child: Icon(icon, color: ic, size: iconInner),
              ),
              const SizedBox(height: 4),
              Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 9.5, fontWeight: FontWeight.w700,
                      color: C.textDark, height: 1.2)),
              if (badge != null) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: C.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(badge!,
                      style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w700, color: C.red)),
                ),
              ],
            ],
          ),
        );
      }),
    ),
  );
}

// ═══════════════════════════════════════════
//  CHART 1 — Sales Bar + Line  WITH FILTER
// ═══════════════════════════════════════════
class SalesBarLineChart extends StatefulWidget {
  const SalesBarLineChart({super.key});
  @override State<SalesBarLineChart> createState() => _SalesBarLineChartState();
}

class _SalesBarLineChartState extends State<SalesBarLineChart> {
  String _selected = 'Month';
  static const _filters = ['Today', 'Week', 'Month', 'Quarter', 'Year'];

  @override
  Widget build(BuildContext context) {
    final data = _salesDataMap[_selected]!;

    return Container(
      decoration: kCard(),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ──
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Sales Performance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.textDark)),
              const SizedBox(height: 2),
              Text(data.range,
                  style: const TextStyle(fontSize: 11, color: C.textMid)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: C.primaryLight, borderRadius: BorderRadius.circular(20)),
            child: Text(data.growth,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: C.primary)),
          ),
        ]),
        const SizedBox(height: 14),

        // ── Filter Chips ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((f) {
              final sel = f == _selected;
              return GestureDetector(
                onTap: () => setState(() => _selected = f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? C.primary : C.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: sel ? C.primary : C.border,
                      width: 1.2,
                    ),
                    boxShadow: sel
                        ? [BoxShadow(
                        color: C.primary.withValues(alpha: 0.25),
                        blurRadius: 6, offset: const Offset(0, 2))]
                        : [],
                  ),
                  child: Text(f,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : C.textMid)),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // ── Legend ──
        const Row(children: [
          _CLeg(C.primary, 'Revenue'),
          SizedBox(width: 16),
          _CLeg(Color(0xFFFF9F43), 'Orders'),
        ]),
        const SizedBox(height: 14),

        // ── Summary stats ──
        Row(children: [
          _MiniStat('Total Revenue', data.total, C.primaryLight, C.primary),
          const SizedBox(width: 10),
          _MiniStat('Growth', data.growth, C.greenLight, C.green),
          const SizedBox(width: 10),
          _MiniStat('Period', _selected, C.blueLight, C.blue),
        ]),
        const SizedBox(height: 14),

        // ── Bar + Line Chart ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, anim) =>
              FadeTransition(opacity: anim, child: child),
          child: SizedBox(
            key: ValueKey(_selected),
            height: 175,
            child: CustomPaint(
              painter: BarLinePainter(data.revenue, data.orders),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // ── X-axis labels ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Row(
            key: ValueKey('lbl_$_selected'),
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.labels.map((m) => Text(m,
                style: const TextStyle(fontSize: 10, color: C.textLight))).toList(),
          ),
        ),
      ]),
    );
  }
}

// ── Mini stat chip inside chart ──
class _MiniStat extends StatelessWidget {
  final String label, value;
  final Color  bg, fg;
  const _MiniStat(this.label, this.value, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 9, color: C.textMid)),
        const SizedBox(height: 2),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: fg)),
      ]),
    ),
  );
}

class _CLeg extends StatelessWidget {
  final Color  col;
  final String label;
  const _CLeg(this.col, this.label);

  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 24, height: 8,
        decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(4))),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(fontSize: 11, color: C.textMid)),
  ]);
}

class BarLinePainter extends CustomPainter {
  final List<double> revenue, orders;
  const BarLinePainter(this.revenue, this.orders);

  @override
  void paint(Canvas canvas, Size s) {
    final n    = revenue.length;
    final barW = s.width / (n * 2.2);
    final gap  = s.width / n;
    final gp   = Paint()
      ..color = const Color(0xFF6B7280).withValues(alpha: 0.10)
      ..strokeWidth = 0.8;

    for (int i = 1; i <= 4; i++) {
      canvas.drawLine(Offset(0, s.height * i / 4),
          Offset(s.width, s.height * i / 4), gp);
    }

    for (int i = 0; i < n; i++) {
      final cx   = gap * i + gap / 2;
      final bh   = s.height * revenue[i];
      final top  = s.height - bh;
      final rect = RRect.fromRectAndCorners(
          Rect.fromLTWH(cx - barW / 2, top, barW, bh),
          topLeft: const Radius.circular(5), topRight: const Radius.circular(5));
      canvas.drawRRect(rect, Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [const Color(0xFF26A69A), const Color(0xFF26A69A).withValues(alpha: 0.45)],
        ).createShader(Rect.fromLTWH(cx - barW / 2, top, barW, bh)));

      if (revenue[i] > 0.55) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${(revenue[i] * 100).toInt()}k',
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF26A69A)),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, top - tp.height - 3));
      }
    }

    final opts = List.generate(n,
            (i) => Offset(gap * i + gap / 2, s.height * (1 - orders[i])));
    final lp = Path()..moveTo(opts[0].dx, opts[0].dy);
    for (int i = 0; i < opts.length - 1; i++) {
      final cx = (opts[i].dx + opts[i + 1].dx) / 2;
      lp.cubicTo(cx, opts[i].dy, cx, opts[i + 1].dy, opts[i + 1].dx, opts[i + 1].dy);
    }
    canvas.drawPath(lp, Paint()
      ..color = const Color(0xFFFF9F43)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    for (final p in opts) {
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(p, 3.5, Paint()..color = const Color(0xFFFF9F43));
    }
  }

  @override bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════
//  CHART 2 — Ring chart (Traffic Sources)
// ═══════════════════════════════════════════
class TrafficRingChart extends StatefulWidget {
  const TrafficRingChart({super.key});
  @override State<TrafficRingChart> createState() => _TrafficRingChartState();
}

class _TrafficRingChartState extends State<TrafficRingChart> {
  String _period = 'Apr 2026';
  static const _periods = ['Jan 2026', 'Feb 2026', 'Mar 2026', 'Apr 2026'];

  static const _segMap = {
    'Jan 2026': [('Organic',0.35,Color(0xFF26A69A),'₹7,218'),('Social',0.27,Color(0xFF8B5CF6),'₹5,572'),('Direct',0.25,Color(0xFFF59E0B),'₹5,155'),('Paid Ads',0.13,Color(0xFF3B82F6),'₹2,681')],
    'Feb 2026': [('Organic',0.40,Color(0xFF26A69A),'₹8,120'),('Social',0.25,Color(0xFF8B5CF6),'₹5,080'),('Direct',0.22,Color(0xFFF59E0B),'₹4,472'),('Paid Ads',0.13,Color(0xFF3B82F6),'₹2,641')],
    'Mar 2026': [('Organic',0.36,Color(0xFF26A69A),'₹8,856'),('Social',0.30,Color(0xFF8B5CF6),'₹7,380'),('Direct',0.20,Color(0xFFF59E0B),'₹4,920'),('Paid Ads',0.14,Color(0xFF3B82F6),'₹3,444')],
    'Apr 2026': [('Organic',0.38,Color(0xFF26A69A),'₹9,443'),('Social',0.29,Color(0xFF8B5CF6),'₹7,211'),('Direct',0.22,Color(0xFFF59E0B),'₹5,467'),('Paid Ads',0.11,Color(0xFF3B82F6),'₹2,734')],
  };

  @override
  Widget build(BuildContext context) {
    final segs = _segMap[_period]!;

    return Container(
      decoration: kCard(),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Header ──
        Row(children: [
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Traffic Sources',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.textDark)),
              SizedBox(height: 2),
              Text('Revenue by acquisition channel',
                  style: TextStyle(fontSize: 11, color: C.textMid)),
            ]),
          ),

          // ── Month Dropdown ──
          GestureDetector(
            onTap: () => _showPeriodPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: C.blueLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: C.blue.withValues(alpha: 0.3)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(_period,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: C.blue)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: C.blue),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 18),

        // ── Ring + Segments ──
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Row(
            key: ValueKey(_period),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 130, height: 130,
                child: Stack(alignment: Alignment.center, children: [
                  CustomPaint(
                    painter: RingPainter(segs.map((s) => (s.$2, s.$3)).toList()),
                    size: const Size(130, 130),
                  ),
                  Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(_totalRevenue(segs),
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w900, color: C.textDark)),
                    const Text('Total',
                        style: TextStyle(fontSize: 10, color: C.textMid)),
                  ]),
                ]),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: segs.map((s) => _SegRow(s.$1, s.$2, s.$3, s.$4)).toList(),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  String _totalRevenue(List segs) {
    // static per period
    const totals = {
      'Jan 2026': '₹20.6k',
      'Feb 2026': '₹20.3k',
      'Mar 2026': '₹24.6k',
      'Apr 2026': '₹24.8k',
    };
    return totals[_period] ?? '₹24.8k';
  }

  void _showPeriodPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4,
              decoration: BoxDecoration(
                  color: C.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Select Month',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: C.textDark)),
          const SizedBox(height: 16),
          ..._periods.map((p) => GestureDetector(
            onTap: () {
              setState(() => _period = p);
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _period == p ? C.primaryLight : C.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _period == p ? C.primary : C.border),
              ),
              child: Row(children: [
                Icon(Icons.calendar_month_rounded,
                    size: 16,
                    color: _period == p ? C.primary : C.textMid),
                const SizedBox(width: 10),
                Text(p, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600,
                    color: _period == p ? C.primary : C.textDark)),
                const Spacer(),
                if (_period == p)
                  const Icon(Icons.check_circle_rounded, size: 18, color: C.primary),
              ]),
            ),
          )),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}

class _SegRow extends StatelessWidget {
  final String label, amt;
  final double pct;
  final Color  col;
  const _SegRow(this.label, this.pct, this.col, this.amt);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(width: 8, height: 8,
            decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Expanded(child: Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: C.textDark))),
        Text('${(pct * 100).toInt()}%',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: col)),
      ]),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: pct, minHeight: 5,
          backgroundColor: col.withValues(alpha: 0.12),
          valueColor: AlwaysStoppedAnimation<Color>(col),
        ),
      ),
      const SizedBox(height: 3),
      Text(amt, style: const TextStyle(fontSize: 10, color: C.textMid)),
    ]),
  );
}

class RingPainter extends CustomPainter {
  final List<(double, Color)> data;
  const RingPainter(this.data);

  @override
  void paint(Canvas canvas, Size s) {
    final c      = Offset(s.width / 2, s.height / 2);
    final r      = math.min(s.width, s.height) / 2 - 8;
    double start = -math.pi / 2;
    const strokeW = 22.0;
    const gap     = 0.05;

    for (final item in data) {
      final sweep = 2 * math.pi * item.$1 - gap;
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep, false,
          Paint()..color = item.$2.withValues(alpha: 0.12)..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.round);
      canvas.drawArc(Rect.fromCircle(center: c, radius: r), start, sweep, false,
          Paint()..color = item.$2..style = PaintingStyle.stroke..strokeWidth = strokeW..strokeCap = StrokeCap.round);
      start += sweep + gap;
    }
  }

  @override bool shouldRepaint(_) => false;
}

// ═══════════════════════════════════════════
//  _LiveStat (unused but kept)
// ═══════════════════════════════════════════
class _LiveStat extends StatelessWidget {
  final String val, lbl;
  const _LiveStat(this.val, this.lbl);

  @override
  Widget build(BuildContext context) => Container(
    width: 108, decoration: kCard(),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(val, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: C.title)),
      const SizedBox(height: 3),
      Text(lbl, style: const TextStyle(fontSize: 11, color: C.textMid)),
    ]),
  );
}