import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../widgets/app_bottom_nav_bar.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/dashboard/dashboard_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import '../voucher/journal/journal_voucher.dart';
import '../voucher/payment/payment_voucher.dart';
import '../voucher/receipt/receipt_voucher.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens = [
    DashboardScreen(scaffoldKey: _scaffoldKey),
    const ReceiptVoucherScreen(),
    const PaymentVoucherScreen(),
    const VoucherEntryRoot(),
  ];

  static const _navItems = [
    (Icons.home_rounded, 'Home'),
    (Icons.receipt_long_rounded, 'Receipt'),
    (Icons.inventory_2_rounded, 'Payment'),
    (Icons.bar_chart_rounded, 'Journal'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DashboardDrawer(),
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _idx,
        items: _navItems,
        onTap: (index) => setState(() => _idx = index),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DashboardScreen({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final horizontalPadding = width > 600 ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.brand,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          iconSize: 26,
          icon: const Icon(Icons.menu_rounded),
          color: Colors.white,
          onPressed: () {
            scaffoldKey?.currentState?.openDrawer();
          },
        ),
        title: const Text(
          'Accounting',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            iconSize: 24,
            color: Colors.white,
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14, left: 2),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.75),
                    width: 2,
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A4A4A), Color(0xFF1E1E1E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          12,
          horizontalPadding,
          18,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = width > 600 ? 4 : 2;
                const spacing = 16.0;
                final cardWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                final cardHeight = width > 600 ? cardWidth * 0.72 : 112.0;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children:
                      const [
                        _OverviewCard(
                          label: 'Cash Balance',
                          value: '\u20B924,850',
                          trend: '+18.5%',
                          icon: Icons.account_balance_wallet_rounded,
                          startColor: AppColors.orangeDark,
                          endColor: AppColors.orangeLight,
                        ),
                        _OverviewCard(
                          label: 'YTD Revenue',
                          value: '156',
                          trend: '+12.3%',
                          icon: Icons.trending_up_rounded,
                          startColor: AppColors.blueDark,
                          endColor: AppColors.blueLight,
                        ),
                        _OverviewCard(
                          label: 'Pending Approvals',
                          value: '4.8%',
                          trend: '+5.3%',
                          icon: Icons.fact_check_rounded,
                          startColor: AppColors.greenDark,
                          endColor: AppColors.greenLight,
                        ),
                        _OverviewCard(
                          label: 'Tax Deadline',
                          value: '\u20B9159',
                          trend: '+3.1%',
                          icon: Icons.receipt_long_rounded,
                          startColor: AppColors.pinkDark,
                          endColor: AppColors.pinkLight,
                        ),
                      ].map((card) {
                        return SizedBox(
                          width: cardWidth,
                          height: cardHeight,
                          child: card,
                        );
                      }).toList(),
                );
              },
            ),
            const SizedBox(height: 18),
            const _SectionTitle('Quick Actions'),
            const SizedBox(height: 10),
            const _QuickActionsCard(),
            const SizedBox(height: 14),
            const _PanelCard(
              title: 'EMI Collections (\u20B9L)',
              child: _EmiCollectionsChart(),
            ),
            const SizedBox(height: 14),
            const _PanelCard(
              title: 'Revenue Breakdown',
              child: _RevenueBreakdownContent(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E1E1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.88,
        children: [
          _QuickActionItem(
            icon: Icons.edit_note_rounded,
            label: 'Journal\nEntry',
            color: const Color(0xFFFF5B73),
          ),
          _QuickActionItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Cash\nMgmt',
            color: const Color(0xFF24B4B0),
          ),
          _QuickActionItem(
            icon: Icons.account_balance_rounded,
            label: 'Budgeting',
            color: const Color(0xFF7A4FE8),
          ),
          _QuickActionItem(
            icon: Icons.apartment_rounded,
            label: 'Fixed\nAssets',
            startColor: const Color(0xFF8C6803),
            endColor: const Color(0xFFD2C31B),
          ),
          _QuickActionItem(
            icon: Icons.receipt_long_rounded,
            label: 'Tax\nCenter',
            color: const Color(0xFFE860B5),
          ),
          _QuickActionItem(
            icon: Icons.bar_chart_rounded,
            label: 'Profit &\nLoss',
            startColor: const Color(0xFF017A15),
            endColor: const Color(0xFF30C549),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color startColor;
  final Color endColor;

  _QuickActionItem({
    required this.icon,
    required this.label,
    Color? color,
    Color? startColor,
    Color? endColor,
  }) : startColor = startColor ?? color!,
       endColor = endColor ?? color!;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [startColor, endColor],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.text1,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String label;
  final String value;
  final String trend;
  final IconData icon;
  final Color startColor;
  final Color endColor;

  const _OverviewCard({
    required this.label,
    required this.value,
    required this.trend,
    required this.icon,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 10,
            offset: const Offset(1, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                height: 1,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              trend,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _PanelCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E3E3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }
}

class _EmiCollectionsChart extends StatelessWidget {
  const _EmiCollectionsChart();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chartHeight = screenWidth * 0.34;

    return SizedBox(
      height: chartHeight.clamp(120.0, 170.0),
      width: double.infinity,
      child: CustomPaint(painter: _EmiChartPainter(screenWidth: screenWidth)),
    );
  }
}

class _RevenueBreakdownContent extends StatelessWidget {
  const _RevenueBreakdownContent();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chartSize = (screenWidth * 0.26).clamp(96.0, 122.0);
    final panelHeight = (screenWidth * 0.42).clamp(150.0, 185.0);
    final leftInset = (screenWidth * 0.02).clamp(6.0, 10.0);
    final rightInset = (screenWidth * 0.03).clamp(8.0, 12.0);
    final topInset = (screenWidth * 0.055).clamp(16.0, 22.0);
    final bottomInset = (screenWidth * 0.06).clamp(18.0, 24.0);

    return SizedBox(
      height: panelHeight,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: chartSize,
              height: chartSize,
              child: CustomPaint(
                painter: const _DonutChartPainter(
                  values: [60, 40, 80, 50],
                  colors: [
                    Color(0xFF0C5065),
                    Color(0xFFF7A91A),
                    Color(0xFFD4E23C),
                    Color(0xFF2B9A86),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: leftInset,
            top: topInset,
            child: const _ChartTag(
              percent: '50%',
              label: 'Product Sales',
              color: Color(0xFF2B9A86),
              lineDirection: _LineDirection.rightDown,
              textAlign: TextAlign.right,
            ),
          ),
          Positioned(
            right: rightInset,
            top: topInset - 4,
            child: const _ChartTag(
              percent: '60%',
              label: 'Services',
              color: Color(0xFF0C5065),
              lineDirection: _LineDirection.leftDown,
              textAlign: TextAlign.left,
            ),
          ),
          Positioned(
            left: leftInset + 2,
            bottom: bottomInset,
            child: const _ChartTag(
              percent: '80%',
              label: 'Subscriptions',
              color: Color(0xFFD4E23C),
              lineDirection: _LineDirection.rightUp,
              textAlign: TextAlign.right,
            ),
          ),
          Positioned(
            right: rightInset + 2,
            bottom: bottomInset + 6,
            child: const _ChartTag(
              percent: '40%',
              label: 'Licenses',
              color: Color(0xFFF7A91A),
              lineDirection: _LineDirection.leftUp,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

enum _LineDirection { rightDown, leftDown, rightUp, leftUp }

class _ChartTag extends StatelessWidget {
  final String percent;
  final String label;
  final Color color;
  final _LineDirection lineDirection;
  final TextAlign textAlign;

  const _ChartTag({
    required this.percent,
    required this.label,
    required this.color,
    required this.lineDirection,
    required this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final lineWidth = (screenWidth * 0.075).clamp(20.0, 28.0);
    final tagWidth = (screenWidth * 0.18).clamp(58.0, 74.0);
    final percentFont = (screenWidth * 0.022).clamp(8.0, 9.5);
    final labelFont = (screenWidth * 0.025).clamp(9.0, 10.5);

    return SizedBox(
      width: tagWidth,
      child: Column(
        crossAxisAlignment: textAlign == TextAlign.right
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            percent,
            style: TextStyle(
              fontSize: percentFont,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF454545),
              height: 1,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: labelFont,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          CustomPaint(
            size: Size(lineWidth, 12),
            painter: _TagLinePainter(color: color, direction: lineDirection),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }
}

class _TagLinePainter extends CustomPainter {
  final Color color;
  final _LineDirection direction;

  const _TagLinePainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    late Offset dotOffset;
    if (direction == _LineDirection.rightDown) {
      path
        ..moveTo(0, 2)
        ..lineTo(size.width * 0.6, 2)
        ..lineTo(size.width, size.height - 1);
      dotOffset = const Offset(0, 2);
    } else if (direction == _LineDirection.leftDown) {
      path
        ..moveTo(size.width, 2)
        ..lineTo(size.width * 0.4, 2)
        ..lineTo(0, size.height - 1);
      dotOffset = Offset(size.width, 2);
    } else if (direction == _LineDirection.rightUp) {
      path
        ..moveTo(0, size.height - 1)
        ..lineTo(size.width * 0.6, size.height - 1)
        ..lineTo(size.width, 2);
      dotOffset = Offset(0, size.height - 1);
    } else {
      path
        ..moveTo(size.width, size.height - 1)
        ..lineTo(size.width * 0.4, size.height - 1)
        ..lineTo(0, 2);
      dotOffset = Offset(size.width, size.height - 1);
    }
    canvas.drawPath(path, paint);
    canvas.drawCircle(dotOffset, 1.8, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EmiChartPainter extends CustomPainter {
  final double screenWidth;

  const _EmiChartPainter({required this.screenWidth});

  @override
  void paint(Canvas canvas, Size size) {
    const labels = ['JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY'];
    const barColors = [
      Color(0xFFE92E61),
      Color(0xFF6F32C9),
      Color(0xFFC43BA9),
      Color(0xFF178F87),
      Color(0xFFAE930C),
    ];
    final barHeights = [
      size.height * 0.20,
      size.height * 0.42,
      size.height * 0.56,
      size.height * 0.76,
      size.height * 1.00,
    ];

    final labelFontSize = (screenWidth * 0.0095).clamp(4.0, 6.0);
    final chartBottom = size.height - 14;
    final chartLeft = screenWidth * 0.01;
    final chartWidth = size.width - chartLeft * 2;
    final groupWidth = chartWidth / labels.length;
    final barWidth = groupWidth * 0.42;
    final labelPainter = TextPainter(textDirection: TextDirection.ltr);

    for (var i = 0; i < labels.length; i++) {
      final barLeft = chartLeft + groupWidth * i + (groupWidth - barWidth) / 2;
      final rect = Rect.fromLTWH(
        barLeft,
        chartBottom - barHeights[i],
        barWidth,
        barHeights[i],
      );
      canvas.drawRect(rect, Paint()..color = barColors[i]);

      labelPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          fontSize: labelFontSize,
          color: const Color(0xFF555555),
          fontWeight: FontWeight.w700,
        ),
      );
      labelPainter.layout(maxWidth: groupWidth + 8);
      labelPainter.paint(
        canvas,
        Offset(
          chartLeft + groupWidth * i + (groupWidth - labelPainter.width) / 2,
          size.height - 8,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DonutChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;


  const _DonutChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold(0.0, (a, b) => a + b);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 6;
    final thickness = size.width * 0.23;
    var startAngle = -2.45;

    for (var i = 0; i < values.length; i++) {
      final sweep = 2 * math.pi * values[i] / total;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }

    canvas.drawCircle(
      center,
      radius - thickness / 2,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
