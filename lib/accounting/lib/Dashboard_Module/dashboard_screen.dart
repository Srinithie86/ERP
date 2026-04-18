import 'package:flutter/material.dart';
import 'package:erp_smart/utils/widgets/dynamic_drawer.dart';
import 'dart:math' as math;
import '../Drawer_Module/receipt_voucher.dart';
import '../Drawer_Module/payment_voucher.dart';
import '../Drawer_Module/debit_voucher.dart';
import '../Drawer_Module/journal_voucher.dart';

// ════════════════════════════════════════════════════
//  COLOR CONSTANTS
// ════════════════════════════════════════════════════
class C {
  static const bg           = Colors.white;
  static const brand        = Color(0xFF26A69A);
  static const orange       = Color(0xFFFF7043);
  static const orangeLight  = Color(0xFFFFF3EF);
  static const blue         = Color(0xFF2196F3);
  static const blueLight    = Color(0xFFE3F2FD);
  static const purple       = Color(0xFF9C27B0);
  static const purpleLight  = Color(0xFFF3E5F5);
  static const teal         = Color(0xFF009688);
  static const tealLight    = Color(0xFFE0F2F1);
  static const pink         = Color(0xFFE91E63);
  static const pinkLight    = Color(0xFFFCE4EC);
  static const green        = Color(0xFF4CAF50);
  static const greenLight   = Color(0xFFE8F5E9);
  static const yellow       = Color(0xFFFFC107);
  static const yellowLight  = Color(0xFFFFFDE7);
  static const cardBg       = Color(0x3D07F6DB);
  static const text1        = Color(0xFF1A1A2E);
  static const text2        = Color(0xFF6B7280);
  static const lightGrey    = Color(0xFFF5F5F5);

  static const orangeDark   = Color(0xFF56D092);
  static const blueDark     = Color(0xFF397ADE);
  static const purpleDark   = Color(0xFFA674E1);
  static const brandDark    = Color(0xE5F60773);

  static const sectionBg    = Color(0xFFE8F5E9);
  static const sectionBg2   = Color(0xFFF1FAF2);

  static const primary      = brand;
  static const primaryLight = Color(0xFFE0F2F1);
  static const textLight    = Color(0xFFB0BEC5);
}

// ════════════════════════════════════════════════════
//  FILTER ENUM
// ════════════════════════════════════════════════════
enum TrendFilter { days, weekly, monthly, yearly }

// ════════════════════════════════════════════════════
//  RECENT ACTIVITY MODEL
// ════════════════════════════════════════════════════
class _Activity {
  final IconData icon;
  final Color    iconColor;
  final Color    iconBg;
  final String   title;
  final String   subtitle;
  final String   time;

  const _Activity({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

const _activities = [
  _Activity(
    icon:      Icons.check_rounded,
    iconColor: Color(0xFF26A69A),
    iconBg:    Color(0xFFE0F2F1),
    title:     'Journal entry approved',
    subtitle:  'Invoice #INV-2024-001 has been approved',
    time:      '10 minutes ago',
  ),
  _Activity(
    icon:      Icons.warning_amber_rounded,
    iconColor: Color(0xFFFFC107),
    iconBg:    Color(0xFFFFFDE7),
    title:     'Tax filing due',
    subtitle:  'Q1 tax filing due in 7 days',
    time:      '1 hour ago',
  ),
  _Activity(
    icon:      Icons.bar_chart_rounded,
    iconColor: Color(0xFF2196F3),
    iconBg:    Color(0xFFE3F2FD),
    title:     'Monthly report generated',
    subtitle:  'Financial report for March 2024 is ready',
    time:      '2 hours ago',
  ),
  _Activity(
    icon:      Icons.credit_card_rounded,
    iconColor: Color(0xFF26A69A),
    iconBg:    Color(0xFFE0F2F1),
    title:     'Payment received',
    subtitle:  'Payment of \$15,000 received from Client XYZ',
    time:      '5 hours ago',
  ),
  _Activity(
    icon:      Icons.lock_rounded,
    iconColor: Color(0xFFFF7043),
    iconBg:    Color(0xFFFFF3EF),
    title:     'Audit alert',
    subtitle:  '3 transactions require audit review',
    time:      '1 day ago',
  ),
];

// ════════════════════════════════════════════════════
//  MAIN SHELL  ←  4-tab host
// ════════════════════════════════════════════════════
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  // ── 4 screens rendered inside IndexedStack ──
  // Index 0 → Dashboard
  // Index 1 → Receipt   (SupplierPaymentForm1)
  // Index 2 → Payment   (SupplierPaymentForm)
  // Index 3 → Journal   (VoucherEntryRoot)
  static const _screens = [
    DashboardScreen(),
    SupplierPaymentForm1(),   // receipt_voucher.dart
    SupplierPaymentForm(),    // payment_voucher.dart
    VoucherEntryRoot(),       // journal_voucher.dart
  ];

  static const _navItems = [
    (Icons.dashboard_rounded,    'Dashboard'),
    (Icons.receipt_long_rounded, 'Receipt'),
    (Icons.inventory_2_rounded,  'Payment'),
    (Icons.bar_chart_rounded,    'Journal'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all 4 screens alive; only the selected one is visible
      body: IndexedStack(
        index: _idx,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 18,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_navItems.length, (i) {
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: active ? C.primaryLight : Colors.transparent,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Icon(
                          _navItems[i].$1,
                          size: 20,
                          color: active ? C.primary : C.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _navItems[i].$2,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                          active ? FontWeight.w700 : FontWeight.w400,
                          color: active ? C.primary : C.textLight,
                        ),
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

// ════════════════════════════════════════════════════
//  DASHBOARD SCREEN
// ════════════════════════════════════════════════════
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  TrendFilter _filter = TrendFilter.monthly;

  static const _cashFlowData = {
    TrendFilter.days: (
    [10200.0, 13500.0, 9800.0, 15000.0, 18200.0, 12400.0, 16800.0],
    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    ),
    TrendFilter.weekly: (
    [42000.0, 55000.0, 48000.0, 61000.0, 53000.0, 67000.0],
    ['Wk1', 'Wk2', 'Wk3', 'Wk4', 'Wk5', 'Wk6'],
    ),
    TrendFilter.monthly: (
    [10500.0, 18000.0, 13000.0, 25000.0, 26000.0, 31000.0, 23000.0],
    ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
    ),
    TrendFilter.yearly: (
    [180000.0, 210000.0, 195000.0, 240000.0, 275000.0],
    ['2020', '2021', '2022', '2023', '2024'],
    ),
  };

  static const _budgetData = {
    TrendFilter.days: (
    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    [8000.0, 9500.0, 7000.0, 11000.0, 9000.0],
    [7500.0, 10200.0, 7800.0, 10500.0, 9800.0],
    ),
    TrendFilter.weekly: (
    ['Wk1', 'Wk2', 'Wk3', 'Wk4', 'Wk5'],
    [30000.0, 45000.0, 28000.0, 52000.0, 38000.0],
    [28000.0, 47000.0, 31000.0, 49000.0, 41000.0],
    ),
    TrendFilter.monthly: (
    ['Marketing', 'Operations', 'R&D', 'Sales', 'Admin'],
    [50000.0, 75000.0, 30000.0, 88000.0, 22000.0],
    [45000.0, 80000.0, 35000.0, 82000.0, 28000.0],
    ),
    TrendFilter.yearly: (
    ['2021', '2022', '2023', '2024', '2025'],
    [200000.0, 230000.0, 210000.0, 270000.0, 250000.0],
    [190000.0, 240000.0, 225000.0, 260000.0, 265000.0],
    ),
  };

  @override
  Widget build(BuildContext context) {
    final w  = MediaQuery.of(context).size.width;
    final hp = w > 600 ? 24.0 : 16.0;

    final cashFlow  = _cashFlowData[_filter]!;
    final budgetAct = _budgetData[_filter]!;

    return Scaffold(
      backgroundColor: C.bg,

      // ── Drawer ──
      drawer: const DynamicDrawer(moduleName: "ACCOUNTING"),

      // ── AppBar ──
      appBar: AppBar(
        backgroundColor: C.brand,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Accounting',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18)),
        actions: [
          IconButton(
            icon:
            const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ── Body ──
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hp, vertical: 4),
        child:
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 14),

          // ── Overview Cards ──
          LayoutBuilder(builder: (context, constraints) {
            final cols      = w > 600 ? 3 : 2;
            const spacing   = 12.0;
            final cardWidth =
                (constraints.maxWidth - spacing * (cols - 1)) / cols;
            final cardHeight = cardWidth / 1.1;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                _OCard(
                    width: cardWidth,
                    height: cardHeight,
                    icon: Icons.attach_money_rounded,
                    label: 'Cash Balance',
                    value: '24,850',
                    prefix: '₹',
                    trend: '+18.5%',
                    pos: true,
                    bgColor: C.orangeDark),
                _OCard(
                    width: cardWidth,
                    height: cardHeight,
                    icon: Icons.inbox_rounded,
                    label: 'YTD Revenue',
                    value: '156',
                    prefix: '',
                    trend: '+12.3%',
                    pos: true,
                    bgColor: C.blueDark),
                _OCard(
                    width: cardWidth,
                    height: cardHeight,
                    icon: Icons.show_chart_rounded,
                    label: 'Pending Approvals',
                    value: '4.8%',
                    prefix: '',
                    trend: '+0.3%',
                    pos: true,
                    bgColor: C.purpleDark),
                _OCard(
                    width: cardWidth,
                    height: cardHeight,
                    icon: Icons.credit_card_rounded,
                    label: 'Tax Deadline',
                    value: '159',
                    prefix: '₹',
                    trend: '+5.2%',
                    pos: true,
                    bgColor: C.brandDark),
              ],
            );
          }),

          const SizedBox(height: 28),

          // ── Quick Access ──
          const _SecTitle('Quick Access'),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.72,
            children: const [
              _ModCard(
                  icon: Icons.book_rounded,
                  label: 'Journal\nEntry',
                  subtitle: 'Record transactions',
                  iconColor: C.orange,
                  badge: '3 pending'),
              _ModCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Cash\nMgmt',
                  subtitle: 'Bank & cash flow',
                  iconColor: C.yellow),
              _ModCard(
                  icon: Icons.pie_chart_rounded,
                  label: 'Budgeting',
                  subtitle: 'Plan & track',
                  iconColor: C.purple),
              _ModCard(
                  icon: Icons.apartment_rounded,
                  label: 'Fixed\nAssets',
                  subtitle: 'Asset depreciation',
                  iconColor: C.pink),
              _ModCard(
                  icon: Icons.receipt_rounded,
                  label: 'Tax\nCenter',
                  subtitle: 'Tax compliance',
                  iconColor: C.blue,
                  badge: '2 pending'),
              _ModCard(
                  icon: Icons.trending_up_rounded,
                  label: 'Profit\n& Loss',
                  subtitle: 'Financial statements',
                  iconColor: C.green),
              _ModCard(
                  icon: Icons.track_changes_rounded,
                  label: 'Audit\nTrail',
                  subtitle: 'Compliance logs',
                  iconColor: C.brand),
              _ModCard(
                  icon: Icons.summarize_rounded,
                  label: 'Reports',
                  subtitle: 'Generate reports',
                  iconColor: C.purple),
              _ModCard(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  subtitle: 'App preferences',
                  iconColor: C.text2),
            ],
          ),

          const SizedBox(height: 28),

          // ── Financial Trends ──
          Row(children: [
            const _SecTitle('Financial Trends'),
            const Spacer(),
            _TrendFilterBar(
              selected: _filter,
              onChanged: (f) => setState(() => _filter = f),
            ),
          ]),
          const SizedBox(height: 14),

          _ChartCard(
            title: 'Cash Flow',
            bgColor: C.sectionBg,
            borderColor: const Color(0xFFA5D6A7),
            child: SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _LineChartPainter(
                  data: List<double>.from(cashFlow.$1),
                  labels: List<String>.from(cashFlow.$2),
                  lineColor: C.brand,
                  fillColor: const Color(0x2226A69A),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          _ChartCard(
            title: 'Budget vs Actual',
            bgColor: C.sectionBg,
            borderColor: const Color(0xFFA5D6A7),
            legend: Row(children: const [
              _LegendDot(color: C.green, label: 'Budget'),
              SizedBox(width: 16),
              _LegendDot(color: C.blue, label: 'Actual'),
            ]),
            child: SizedBox(
              height: 220,
              child: CustomPaint(
                painter: _BarChartPainter(
                  categories: List<String>.from(budgetAct.$1),
                  budget: List<double>.from(budgetAct.$2),
                  actual: List<double>.from(budgetAct.$3),
                  budgetColor: C.green,
                  actualColor: C.blue,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          _ChartCard(
            title: 'Revenue Breakdown',
            bgColor: C.sectionBg,
            borderColor: const Color(0xFFA5D6A7),
            child: Column(children: [
              SizedBox(
                height: 200,
                child: CustomPaint(
                  painter: _DonutChartPainter(
                    values: const [45, 25, 15, 15],
                    colors: const [C.blue, C.green, C.orange, C.purple],
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 20,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: const [
                  _LegendDot(color: C.blue, label: 'Product Sales'),
                  _LegendDot(color: C.green, label: 'Services'),
                  _LegendDot(color: C.orange, label: 'Licenses'),
                  _LegendDot(color: C.purple, label: 'Subscriptions'),
                ],
              ),
            ]),
          ),

          const SizedBox(height: 28),

          const _SecTitle('Recent Activity'),
          const SizedBox(height: 14),
          const _RecentActivityCard(),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  RECENT ACTIVITY CARD
// ════════════════════════════════════════════════════
class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_activities.length, (i) {
          final a      = _activities[i];
          final isLast = i == _activities.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: a.iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(a.icon, color: a.iconColor, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.title,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: C.text1)),
                          const SizedBox(height: 3),
                          Text(a.subtitle,
                              style: const TextStyle(
                                  fontSize: 12, color: C.text2)),
                          const SizedBox(height: 4),
                          Text(a.time,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF9CA3AF))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF3F4F6),
                    indent: 72),
            ],
          );
        }),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  TREND FILTER BAR
// ════════════════════════════════════════════════════
class _TrendFilterBar extends StatelessWidget {
  final TrendFilter selected;
  final ValueChanged<TrendFilter> onChanged;
  const _TrendFilterBar({required this.selected, required this.onChanged});

  static const _labels = {
    TrendFilter.days:    'Day',
    TrendFilter.weekly:  'Week',
    TrendFilter.monthly: 'Month',
    TrendFilter.yearly:  'Year',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: TrendFilter.values.map((f) {
          final isSelected = f == selected;
          return GestureDetector(
            onTap: () => onChanged(f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
              const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: isSelected ? C.brand : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                _labels[f]!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : C.text2,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  DRAWER ITEM
// ════════════════════════════════════════════════════
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final bool     active;
  final Widget?  page;
  const _DrawerItem(
      {required this.icon,
        required this.label,
        this.active = false,
        this.page});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: active ? C.brand.withOpacity(0.10) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        dense: true,
        leading:
        Icon(icon, color: active ? C.brand : C.text2, size: 20),
        title: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
              active ? FontWeight.w700 : FontWeight.w500,
              color: active ? C.brand : C.text1,
            )),
        onTap: () {
          Navigator.pop(context);
          if (page != null) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => page!));
          }
        },
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  OVERVIEW CARD
// ════════════════════════════════════════════════════
class _OCard extends StatelessWidget {
  final double   width, height;
  final IconData icon;
  final String   label, value, prefix, trend;
  final bool     pos;
  final Color    bgColor;

  const _OCard({
    required this.width,
    required this.height,
    required this.icon,
    required this.label,
    required this.value,
    required this.prefix,
    required this.trend,
    required this.pos,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(11),
        color: bgColor,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: Colors.white, size: 17),
              ),
              const SizedBox(height: 4),
              Text('$prefix$value',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white)),
              const SizedBox(height: 1),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.70))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    pos
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 9,
                    color: pos
                        ? const Color(0xFF69F0AE)
                        : const Color(0xFFFF5252),
                  ),
                  const SizedBox(width: 2),
                  Text(trend,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: pos
                            ? const Color(0xFF69F0AE)
                            : const Color(0xFFFF5252),
                      )),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  MODULE CARD
// ════════════════════════════════════════════════════
class _ModCard extends StatelessWidget {
  final IconData icon;
  final String   label, subtitle;
  final Color    iconColor;
  final String?  badge;
  final Color?   bgColor;

  const _ModCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.iconColor,
    this.badge,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = bgColor != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor ?? C.sectionBg,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: const Color(0xFFA5D6A7).withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.18)
                  : iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: isDark ? Colors.white : iconColor, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: isDark ? Colors.white : C.text1,
              )),
          const SizedBox(height: 2),
          Text(subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 8.5,
                color:
                isDark ? Colors.white.withOpacity(0.65) : C.text2,
              )),
          if (badge != null) ...[
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.18)
                    : C.pink.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge!,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF69F0AE)
                        : C.pink,
                  )),
            ),
          ],
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════
//  CHART CARD
// ════════════════════════════════════════════════════
class _ChartCard extends StatelessWidget {
  final String  title;
  final Widget  child;
  final Widget? legend;
  final Color   bgColor;
  final Color   borderColor;

  const _ChartCard({
    required this.title,
    required this.child,
    required this.bgColor,
    required this.borderColor,
    this.legend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: C.text1)),
        if (legend != null) ...[const SizedBox(height: 10), legend!],
        const SizedBox(height: 12),
        child,
      ]),
    );
  }
}

// ════════════════════════════════════════════════════
//  CHART PAINTERS
// ════════════════════════════════════════════════════
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final Color lineColor, fillColor;

  const _LineChartPainter({
    required this.data,
    required this.labels,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const lp = 52.0, rp = 12.0, tp = 12.0, bp = 36.0;
    final cw    = size.width - lp - rp;
    final ch    = size.height - tp - bp;
    final maxV  = data.reduce(math.max);
    const minV  = 0.0;
    final range = maxV - minV;

    final gridP  = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    final tPaint = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 5; i++) {
      final y = tp + ch - (ch * i / 5);
      canvas.drawLine(Offset(lp, y), Offset(lp + cw, y), gridP);
      tPaint.text = TextSpan(
          text: _fmt((range * i / 5 + minV).roundToDouble()),
          style: const TextStyle(
              color: Color(0xFF9CA3AF), fontSize: 10));
      tPaint.layout();
      tPaint.paint(canvas,
          Offset(lp - tPaint.width - 6, y - tPaint.height / 2));
    }

    final pts = List.generate(
        data.length,
            (i) => Offset(
          lp + cw * i / (data.length - 1),
          tp + ch - (ch * (data[i] - minV) / range),
        ));

    final fp = Path()..moveTo(pts.first.dx, tp + ch);
    for (final p in pts) fp.lineTo(p.dx, p.dy);
    fp
      ..lineTo(pts.last.dx, tp + ch)
      ..close();
    canvas.drawPath(fp, Paint()..color = fillColor);

    final lnP = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    final ln = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) ln.lineTo(pts[i].dx, pts[i].dy);
    canvas.drawPath(ln, lnP);

    for (final p in pts) {
      canvas.drawCircle(p, 5, Paint()..color = Colors.white);
      canvas.drawCircle(
          p,
          5,
          Paint()
            ..color = lineColor
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    }

    for (int i = 0; i < labels.length; i++) {
      tPaint.text = TextSpan(
          text: labels[i],
          style:
          const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10));
      tPaint.layout();
      tPaint.paint(canvas,
          Offset(pts[i].dx - tPaint.width / 2, tp + ch + 8));
    }
  }

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toStringAsFixed(0);

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class _BarChartPainter extends CustomPainter {
  final List<String> categories;
  final List<double> budget, actual;
  final Color budgetColor, actualColor;

  const _BarChartPainter({
    required this.categories,
    required this.budget,
    required this.actual,
    required this.budgetColor,
    required this.actualColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const lp = 56.0, rp = 12.0, tp = 12.0, bp = 48.0;
    final cw   = size.width - lp - rp;
    final ch   = size.height - tp - bp;
    final maxV = [...budget, ...actual].reduce(math.max) * 1.15;

    final gridP  = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    final tPaint = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 4; i++) {
      final y = tp + ch - (ch * i / 4);
      canvas.drawLine(Offset(lp, y), Offset(lp + cw, y), gridP);
      tPaint.text = TextSpan(
          text: _fmt((maxV * i / 4).roundToDouble()),
          style: const TextStyle(
              color: Color(0xFF9CA3AF), fontSize: 10));
      tPaint.layout();
      tPaint.paint(canvas,
          Offset(lp - tPaint.width - 4, y - tPaint.height / 2));
    }

    final gw = cw / categories.length;
    const bPad = 6.0, bGap = 3.0;
    final bw = (gw - bPad * 2 - bGap) / 2;

    for (int i = 0; i < categories.length; i++) {
      final gx = lp + gw * i + bPad;
      final bH = ch * budget[i] / maxV;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(gx, tp + ch - bH, bw, bH),
              const Radius.circular(3)),
          Paint()..color = budgetColor.withOpacity(0.85));

      final aH = ch * actual[i] / maxV;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(gx + bw + bGap, tp + ch - aH, bw, aH),
              const Radius.circular(3)),
          Paint()..color = actualColor.withOpacity(0.75));

      tPaint.text = TextSpan(
          text: categories[i],
          style:
          const TextStyle(color: Color(0xFF9CA3AF), fontSize: 10));
      tPaint.layout();
      canvas.save();
      canvas.translate(gx + bw, tp + ch + 6 + tPaint.width);
      canvas.rotate(-math.pi / 2);
      tPaint.paint(canvas, Offset(0, -tPaint.height / 2));
      canvas.restore();
    }
  }

  String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v.toStringAsFixed(0);

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color>  colors;
  const _DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total  = values.fold(0.0, (a, b) => a + b);
    final cx     = size.width  / 2;
    final cy     = size.height / 2;
    final radius = math.min(cx, cy) - 10;
    const hole   = 0.55;
    double startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweep = 2 * math.pi * values[i] / total;
      final path  = Path();
      path.moveTo(cx + radius * hole * math.cos(startAngle),
          cy + radius * hole * math.sin(startAngle));
      path.arcTo(
          Rect.fromCircle(center: Offset(cx, cy), radius: radius),
          startAngle,
          sweep,
          false);
      path.arcTo(
          Rect.fromCircle(
              center: Offset(cx, cy), radius: radius * hole),
          startAngle + sweep,
          -sweep,
          false);
      path.close();
      canvas.drawPath(path, Paint()..color = colors[i]);
      canvas.drawLine(
        Offset(cx + radius * hole * math.cos(startAngle),
            cy + radius * hole * math.sin(startAngle)),
        Offset(cx + radius * math.cos(startAngle),
            cy + radius * math.sin(startAngle)),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ════════════════════════════════════════════════════
//  REUSABLE WIDGETS
// ════════════════════════════════════════════════════
class _LegendDot extends StatelessWidget {
  final Color  color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
          width: 28,
          height: 14,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(label,
          style: const TextStyle(fontSize: 12, color: C.text2)),
    ]);
  }
}

class _SecTitle extends StatelessWidget {
  final String text;
  const _SecTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: C.text2,
        letterSpacing: 0.6),
  );
}