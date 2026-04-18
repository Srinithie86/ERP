// ════════════════════════════════════════════════════
//  reports_screen.dart  —  OVERFLOW FIXED
// ════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../Theme_Module/colors_and_models.dart';
import '../Dashboard_Module/drawer_screen.dart';
import '../Dashboard_Module/dashboard_screen.dart';

// ═══════════════════════════════════════════
//  REPORTS SCREEN
// ═══════════════════════════════════════════
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static const _tiles = [
    _ReportMeta(
      icon: Icons.trending_up_rounded,
      title: 'Sales Report',
      sub: 'Revenue & growth',
      ic: C.teal,
      bg: C.primaryLight,
      screen: SalesReportScreen(),
    ),
    _ReportMeta(
      icon: Icons.receipt_long_rounded,
      title: 'Order Report',
      sub: 'Order stats & fulfilment',
      ic: C.blue,
      bg: C.blueLight,
      screen: OrderReportScreen(),
    ),
    _ReportMeta(
      icon: Icons.people_rounded,
      title: 'Customer Report',
      sub: 'Acquisition & retention',
      ic: C.purple,
      bg: C.purpleLight,
      screen: CustomerReportScreen(),
    ),
    _ReportMeta(
      icon: Icons.inventory_2_rounded,
      title: 'Product Report',
      sub: 'Top sellers & inventory',
      ic: C.orange,
      bg: C.orangeLight,
      screen: ProductReportScreen(),
    ),
    _ReportMeta(
      icon: Icons.local_shipping_rounded,
      title: 'Shipping Reports',
      sub: 'Courier & delivery stats',
      ic: C.red,
      bg: C.redLight,
      screen: ShippingReportScreen(),
    ),
    _ReportMeta(
      icon: Icons.payment_rounded,
      title: 'Payment Reports',
      sub: 'Collections & dues',
      ic: C.green,
      bg: C.greenLight,
      screen: PaymentReportScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    drawer: EcomDrawer(),
    appBar: const EcomAppBar(),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SecTitle('Sales Analytics'),
        const SizedBox(height: 14),
        const SalesBarLineChart(),
        const SizedBox(height: 14),
        const TrafficRingChart(),
        const SizedBox(height: 28),
        const SecTitle('Report Categories'),
        const SizedBox(height: 14),
        ..._tiles.map((t) => _RTile(meta: t)),
      ],
    ),
  );
}



// ═══════════════════════════════════════════
//  META MODEL
// ═══════════════════════════════════════════
class _ReportMeta {
  final IconData icon;
  final String title, sub;
  final Color ic, bg;
  final Widget screen;
  const _ReportMeta({
    required this.icon,
    required this.title,
    required this.sub,
    required this.ic,
    required this.bg,
    required this.screen,
  });
}

// ═══════════════════════════════════════════
//  TILE WIDGET
// ═══════════════════════════════════════════
class _RTile extends StatelessWidget {
  final _ReportMeta meta;
  const _RTile({required this.meta});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => meta.screen),
    ),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: kCard(),
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
              color: meta.bg,
              borderRadius: BorderRadius.circular(14)),
          child: Icon(meta.icon, color: meta.ic, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meta.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: C.textDark)),
                Text(meta.sub,
                    style: const TextStyle(
                        fontSize: 12, color: C.textLight)),
              ]),
        ),
        Icon(Icons.arrow_forward_ios_rounded,
            size: 15, color: meta.ic),
      ]),
    ),
  );
}

// ═══════════════════════════════════════════
//  BASE REPORT DETAIL SCREEN
// ═══════════════════════════════════════════
class _ReportDetailScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color ic, bg;
  final List<_StatCard> stats;
  final List<_ReportRow> rows;
  final String tableTitle;

  const _ReportDetailScreen({
    required this.title,
    required this.icon,
    required this.ic,
    required this.bg,
    required this.stats,
    required this.rows,
    required this.tableTitle,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: C.bg,
    appBar: AppBar(
      backgroundColor: C.primary,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
      title: Text(title,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800)),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20)),
          child: const Text('Apr 2026',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Header banner ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [C.primary, C.primary.withValues(alpha: 0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    const Text('April 2026  •  Live data',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12)),
                  ]),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // ── Stat cards ──
        const SecTitle('Key Metrics'),
        const SizedBox(height: 12),
        // ✅ FIX: Use _StatGrid (IntrinsicHeight rows) instead of GridView
        _StatGrid(stats: stats),
        const SizedBox(height: 24),

        // ── Table ──
        SecTitle(tableTitle),
        const SizedBox(height: 12),
        Container(
          decoration: kCard(),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16)),
                ),
                child: Row(children: [
                  Expanded(
                      flex: 3,
                      child: Text('Name',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ic))),
                  Expanded(
                      flex: 2,
                      child: Text('Amount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ic))),
                  Expanded(
                      flex: 2,
                      child: Text('Status',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: ic))),
                ]),
              ),
              ...rows.asMap().entries.map((e) => _TableRow(
                row: e.value,
                isLast: e.key == rows.length - 1,
              )),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    ),
  );
}

// ═══════════════════════════════════════════
//  STAT GRID — IntrinsicHeight, no fixed ratio
//  ✅ Eliminates overflow completely
// ═══════════════════════════════════════════
class _StatGrid extends StatelessWidget {
  final List<_StatCard> stats;
  const _StatGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (int i = 0; i < stats.length; i += 2) {
      final right = i + 1 < stats.length ? stats[i + 1] : const SizedBox();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: stats[i]),
              const SizedBox(width: 12),
              Expanded(child: right),
            ],
          ),
        ),
      );
      if (i + 2 < stats.length) rows.add(const SizedBox(height: 12));
    }
    return Column(children: rows);
  }
}

// ═══════════════════════════════════════════
//  STAT CARD — mainAxisSize.min, no Spacer
//  ✅ Height adapts to content
// ═══════════════════════════════════════════
class _StatCard extends StatelessWidget {
  final String label, value, trend;
  final bool pos;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.pos,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: C.border),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // ✅ key fix
      children: [
        Row(children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: color),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: (pos ? C.green : C.red).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(trend,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: pos ? C.green : C.red)),
          ),
        ]),
        const SizedBox(height: 10), // ✅ fixed gap instead of Spacer
        Text(value,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: C.textDark)),
        const SizedBox(height: 3),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: C.textMid)),
      ],
    ),
  );
}

// ═══════════════════════════════════════════
//  TABLE ROW MODEL + WIDGET
// ═══════════════════════════════════════════
class _ReportRow {
  final String name, amount, status;
  final Color statusColor;
  const _ReportRow(this.name, this.amount, this.status, this.statusColor);
}

class _TableRow extends StatelessWidget {
  final _ReportRow row;
  final bool isLast;
  const _TableRow({required this.row, required this.isLast});

  @override
  Widget build(BuildContext context) => Container(
    padding:
    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      border: isLast
          ? null
          : const Border(
          bottom: BorderSide(color: C.border, width: 0.8)),
    ),
    child: Row(children: [
      Expanded(
          flex: 3,
          child: Text(row.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: C.textDark))),
      Expanded(
          flex: 2,
          child: Text(row.amount,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: C.textDark))),
      Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: row.statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(row.status,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: row.statusColor)),
            ),
          )),
    ]),
  );
}

// ═══════════════════════════════════════════
//  1. SALES REPORT SCREEN
// ═══════════════════════════════════════════
class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});
  @override
  Widget build(BuildContext context) => _ReportDetailScreen(
    title: 'Sales Report',
    icon: Icons.trending_up_rounded,
    ic: C.teal,
    bg: C.primaryLight,
    tableTitle: 'Top Sales Channels',
    stats: const [
      _StatCard(label: 'Total Revenue',   value: '₹2,48,500', trend: '+18.5%', pos: true,  color: C.teal,    icon: Icons.currency_rupee_rounded),
      _StatCard(label: 'Avg Daily Sales', value: '₹8,283',    trend: '+6.2%',  pos: true,  color: C.green,   icon: Icons.show_chart_rounded),
      _StatCard(label: 'Refunds',         value: '₹4,200',    trend: '+2.1%',  pos: false, color: C.red,     icon: Icons.replay_rounded),
      _StatCard(label: 'Net Revenue',     value: '₹2,44,300', trend: '+17.8%', pos: true,  color: C.primary, icon: Icons.account_balance_wallet_rounded),
    ],
    rows: const [
      _ReportRow('Organic Search', '₹9,443', 'Active',  C.green),
      _ReportRow('Social Media',   '₹7,211', 'Active',  C.green),
      _ReportRow('Direct Traffic', '₹5,467', 'Active',  C.green),
      _ReportRow('Paid Ads',       '₹2,734', 'Paused',  C.orange),
      _ReportRow('Email Campaign', '₹1,845', 'Active',  C.green),
      _ReportRow('Referral',       '₹650',   'Low',     C.red),
    ],
  );
}

// ═══════════════════════════════════════════
//  2. ORDER REPORT SCREEN
// ═══════════════════════════════════════════
class OrderReportScreen extends StatelessWidget {
  const OrderReportScreen({super.key});
  @override
  Widget build(BuildContext context) => _ReportDetailScreen(
    title: 'Order Report',
    icon: Icons.receipt_long_rounded,
    ic: C.blue,
    bg: C.blueLight,
    tableTitle: 'Recent Order Summary',
    stats: const [
      _StatCard(label: 'Total Orders', value: '156', trend: '+12.3%', pos: true,  color: C.blue,   icon: Icons.inbox_rounded),
      _StatCard(label: 'Delivered',    value: '98',  trend: '+8.5%',  pos: true,  color: C.green,  icon: Icons.check_circle_rounded),
      _StatCard(label: 'Pending',      value: '34',  trend: '-3.2%',  pos: false, color: C.orange, icon: Icons.hourglass_top_rounded),
      _StatCard(label: 'Cancelled',    value: '24',  trend: '-5.1%',  pos: true,  color: C.red,    icon: Icons.cancel_rounded),
    ],
    rows: const [
      _ReportRow('Thanu',      '₹4,200', 'Delivered',  C.green),
      _ReportRow('Ravi Kumar', '₹2,850', 'Processing', C.blue),
      _ReportRow('Priya S',    '₹6,400', 'Pending',    C.orange),
      _ReportRow('Ajith M',    '₹1,100', 'Cancelled',  C.red),
      _ReportRow('Sundar R',   '₹1,450', 'Delivered',  C.green),
      _ReportRow('Kavitha N',  '₹7,700', 'Processing', C.blue),
    ],
  );
}

// ═══════════════════════════════════════════
//  3. CUSTOMER REPORT SCREEN
// ═══════════════════════════════════════════
class CustomerReportScreen extends StatelessWidget {
  const CustomerReportScreen({super.key});
  @override
  Widget build(BuildContext context) => _ReportDetailScreen(
    title: 'Customer Report',
    icon: Icons.people_rounded,
    ic: C.purple,
    bg: C.purpleLight,
    tableTitle: 'Top Customers',
    stats: const [
      _StatCard(label: 'Total Customers', value: '1,284', trend: '+9.4%', pos: true,  color: C.purple, icon: Icons.people_rounded),
      _StatCard(label: 'New This Month',  value: '89',    trend: '+2.3%', pos: true,  color: C.blue,   icon: Icons.group_add_rounded),
      _StatCard(label: 'Retention Rate',  value: '74%',   trend: '+1.5%', pos: true,  color: C.green,  icon: Icons.loop_rounded),
      _StatCard(label: 'Churn Rate',      value: '6.2%',  trend: '-0.8%', pos: true,  color: C.red,    icon: Icons.person_remove_rounded),
    ],
    rows: const [
      _ReportRow('Kavitha N',  '₹12,400', 'VIP',     C.purple),
      _ReportRow('Priya S',    '₹9,800',  'Regular', C.blue),
      _ReportRow('Sundar R',   '₹7,200',  'Regular', C.blue),
      _ReportRow('Ravi Kumar', '₹5,600',  'New',     C.green),
      _ReportRow('Manoj K',    '₹4,300',  'Regular', C.blue),
      _ReportRow('Divya P',    '₹2,100',  'New',     C.green),
    ],
  );
}

// ═══════════════════════════════════════════
//  4. PRODUCT REPORT SCREEN
// ═══════════════════════════════════════════
class ProductReportScreen extends StatelessWidget {
  const ProductReportScreen({super.key});
  @override
  Widget build(BuildContext context) => _ReportDetailScreen(
    title: 'Product Report',
    icon: Icons.inventory_2_rounded,
    ic: C.orange,
    bg: C.orangeLight,
    tableTitle: 'Top Selling Products',
    stats: const [
      _StatCard(label: 'Total Products', value: '8',  trend: '+2', pos: true,  color: C.orange, icon: Icons.inventory_2_rounded),
      _StatCard(label: 'Low Stock',      value: '3',  trend: '+1', pos: false, color: C.red,    icon: Icons.warning_rounded),
      _StatCard(label: 'Approved',       value: '5',  trend: '+1', pos: true,  color: C.green,  icon: Icons.check_circle_rounded),
      _StatCard(label: 'Pending Review', value: '3',  trend: '0',  pos: true,  color: C.orange, icon: Icons.hourglass_top_rounded),
    ],
    rows: const [
      _ReportRow('Smart Watch S5',      '₹3,800', 'Top Seller', C.green),
      _ReportRow('Running Sneakers',     '₹2,200', 'High',       C.blue),
      _ReportRow('Wireless Earbuds Pro', '₹1,500', 'High',       C.blue),
      _ReportRow('Denim Jacket',         '₹1,200', 'Medium',     C.orange),
      _ReportRow('Yoga Mat Premium',     '₹850',   'Medium',     C.orange),
      _ReportRow('Cotton T-Shirt',       '₹500',   'Low Stock',  C.red),
    ],
  );
}

// ═══════════════════════════════════════════
//  5. SHIPPING REPORT SCREEN
// ═══════════════════════════════════════════
class ShippingReportScreen extends StatelessWidget {
  const ShippingReportScreen({super.key});
  @override
  Widget build(BuildContext context) => _ReportDetailScreen(
    title: 'Shipping Reports',
    icon: Icons.local_shipping_rounded,
    ic: C.red,
    bg: C.redLight,
    tableTitle: 'Courier Performance',
    stats: const [
      _StatCard(label: 'Shipped Today',   value: '24',   trend: '+4',    pos: true, color: C.red,    icon: Icons.local_shipping_rounded),
      _StatCard(label: 'In Transit',      value: '58',   trend: '+12',   pos: true, color: C.orange, icon: Icons.directions_car_rounded),
      _StatCard(label: 'Delivered Today', value: '18',   trend: '+3',    pos: true, color: C.green,  icon: Icons.done_all_rounded),
      _StatCard(label: 'Avg Delivery',    value: '2.4d', trend: '-0.3d', pos: true, color: C.blue,   icon: Icons.timer_rounded),
    ],
    rows: const [
      _ReportRow('BlueDart',   '₹1,240', 'On Time', C.green),
      _ReportRow('Delhivery',  '₹980',   'On Time', C.green),
      _ReportRow('DTDC',       '₹760',   'Delayed', C.orange),
      _ReportRow('Ecom Exp.',  '₹540',   'On Time', C.green),
      _ReportRow('FedEx',      '₹320',   'Delayed', C.orange),
      _ReportRow('Speed Post', '₹180',   'Late',    C.red),
    ],
  );
}

// ═══════════════════════════════════════════
//  6. PAYMENT REPORT SCREEN
// ═══════════════════════════════════════════
class PaymentReportScreen extends StatelessWidget {
  const PaymentReportScreen({super.key});
  @override
  Widget build(BuildContext context) => _ReportDetailScreen(
    title: 'Payment Reports',
    icon: Icons.payment_rounded,
    ic: C.green,
    bg: C.greenLight,
    tableTitle: 'Payment Transactions',
    stats: const [
      _StatCard(label: 'Collected',    value: '₹2,44,300', trend: '+17.8%', pos: true,  color: C.green,  icon: Icons.account_balance_wallet_rounded),
      _StatCard(label: 'Pending Dues', value: '₹12,400',   trend: '+3.2%',  pos: false, color: C.orange, icon: Icons.pending_actions_rounded),
      _StatCard(label: 'Refunded',     value: '₹4,200',    trend: '-1.4%',  pos: true,  color: C.red,    icon: Icons.replay_rounded),
      _StatCard(label: 'Success Rate', value: '96.4%',      trend: '+0.8%',  pos: true,  color: C.blue,   icon: Icons.verified_rounded),
    ],
    rows: const [
      _ReportRow('UPI',         '₹98,400', 'Success', C.green),
      _ReportRow('Credit Card', '₹76,200', 'Success', C.green),
      _ReportRow('Debit Card',  '₹42,800', 'Success', C.green),
      _ReportRow('Net Banking', '₹18,600', 'Pending', C.orange),
      _ReportRow('Wallet',      '₹6,900',  'Success', C.green),
      _ReportRow('COD',         '₹1,400',  'Failed',  C.red),
    ],
  );
}