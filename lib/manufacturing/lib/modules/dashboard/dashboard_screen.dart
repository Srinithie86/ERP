import 'dart:math' as math;
import 'package:flutter/material.dart';

// â”€â”€â”€ Colors â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DashboardColors {
  // Card gradients â€” match screenshot exactly
  static const List<Color> card1 = [Color(0xffF70E37), Color(0xFFFF869B)]; // red
  static const List<Color> card2 = [Color(0xFF3A00CA), Color(0xFF8E60FF)]; // cyan
  static const List<Color> card3 = [Color(0xFF018477), Color(0xFF15F3DD)]; // purple
  static const List<Color> card4 = [Color(0xFFA8076A), Color(0xFFFF7CCD)]; // pink
  static const List<Color> card5 = [Color(0xFFEBF27E), Color(0xFF949E08)]; // yellow

  static const Color teal = Color(0xFF00897B);
  static const Color tealDark = Color(0xFF004D40);

  // Bar chart gradients
  static const List<Color> barGradient1 = [Color(0xffF70E37), Color(0xFFFF869B)];
  static const List<Color> barGradient2 = [Color(0xFF3A00CA), Color(0xFF8E60FF)];
  static const List<Color> barGradient3 = [Color(0xFF018477), Color(0xFF15F3DD)];
  static const List<Color> barGradient4 = [Color(0xFFA8076A), Color(0xFFFF7CCD)];
  static const List<Color> barGradient5 = [Color(0xFFEBF27E), Color(0xFF949E08)];

  // Donut
  static const Color donutGreen = Color(0xFF26A69A);
  static const Color donutRed = Color(0xFFEF5350);
  static const Color donutPurple = Color(0xFFAB47BC);
  static const Color donutBlue = Color(0xFF5C6BC0);
}


// â”€â”€â”€ Dashboard Screen â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class DashboardScreen extends StatelessWidget {
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DashboardScreen({
    super.key,
    this.isEmbedded = false,
    this.scaffoldKey,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: sw * 0.04,
          vertical: sh * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(sw, sh),
            SizedBox(height: sh * 0.025),
            _buildQuickActions(sw, sh),
            SizedBox(height: sh * 0.025),
            _buildReportsBanner(sw, sh),
            SizedBox(height: sh * 0.025),
            _buildSalesOverview(sw, sh),
            SizedBox(height: sh * 0.025),
            _buildDonutChart(sw, sh),
            SizedBox(height: sh * 0.03),
          ],
        ),
      ),
    );
  }

  // â”€â”€ 4-card stats grid â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildStatsGrid(double sw, double sh) => GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: sw * 0.03,
    crossAxisSpacing: sw * 0.03,
    childAspectRatio: 1.45,
    children: [
      _gradientStatCard(
        label: 'Active Build Plans',
        value: '3',
        icon: Icons.precision_manufacturing_outlined,
        trend: '+1% this week',
        trendUp: true,
        colors: _DashboardColors.card1,
        sw: sw,
      ),
      _gradientStatCard(
        label: 'Work Orders Today',
        value: '7',
        icon: Icons.assignment_outlined,
        trend: '+2% today',
        trendUp: true,
        colors: _DashboardColors.card2,
        sw: sw,
      ),
      _gradientStatCard(
        label: 'Pending Approvals',
        value: '4',
        icon: Icons.pending_actions_outlined,
        trend: 'Action Needed',
        trendUp: false,
        colors: _DashboardColors.card3,
        sw: sw,
      ),
      _gradientStatCard(
        label: 'QC Pass Rate',
        value: '96%',
        icon: Icons.verified_outlined,
        trend: '+2% Last Week',
        trendUp: true,
        colors: _DashboardColors.card4,
        sw: sw,
      ),
    ],
  );

  Widget _gradientStatCard({
    required String label,
    required String value,
    required IconData icon,
    required String trend,
    required bool trendUp,
    required List<Color> colors,
    required double sw,
  }) =>
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(sw * 0.04),
          boxShadow: [
            BoxShadow(
              color: colors[0].withOpacity(0.38),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(sw * 0.03),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Label + icon row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: sw * 0.03,
                      color: Colors.white.withOpacity(0.92),
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: sw * 0.01),
                Container(
                  padding: EdgeInsets.all(sw * 0.015),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(sw * 0.02),
                  ),
                  child: Icon(icon, size: sw * 0.04, color: Colors.white),
                ),
              ],
            ),
            // Value + trend
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: sw * 0.07,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
                ),
                SizedBox(height: sw * 0.006),
                Row(
                  children: [
                    Icon(
                      trendUp
                          ? Icons.arrow_upward_rounded
                          : Icons.warning_amber_rounded,
                      size: sw * 0.028,
                      color: Colors.white.withOpacity(0.85),
                    ),
                    SizedBox(width: sw * 0.006),
                    Flexible(
                      child: Text(
                        trend,
                        style: TextStyle(
                          fontSize: sw * 0.025,
                          color: Colors.white.withOpacity(0.85),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );

  // â”€â”€ Quick Actions with Container â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildQuickActions(double sw, double sh) => Container(
    padding: EdgeInsets.all(sw * 0.045),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(sw * 0.04),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: sw * 0.043,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: sh * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _qaButton(
              icon: Icons.person_add_outlined,
              label: 'Add\nDealer',
              colors: _DashboardColors.card1,
              sw: sw,
            ),
            _qaButton(
              icon: Icons.check_circle_outline,
              label: 'Approve\n',
              colors: _DashboardColors.card3,
              sw: sw,
            ),
            _qaButton(
              icon: Icons.add_shopping_cart_outlined,
              label: 'Create\nOrder',
              colors: _DashboardColors.card2,
              sw: sw,
            ),
            _qaButton(
              icon: Icons.receipt_long_outlined,
              label: 'Invoice\n',
              colors: _DashboardColors.card4,
              sw: sw,
            ),
          ],
        ),
      ],
    ),
  );

  Widget _qaButton({
    required IconData icon,
    required String label,
    required List<Color> colors,
    required double sw,
  }) {
    final double buttonSize = sw * 0.16;

    return SizedBox(
      width: buttonSize + 10,
      child: Column(
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: sw * 0.07),
          ),
          SizedBox(height: sw * 0.012),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sw * 0.026,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // â”€â”€ Reports Banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildReportsBanner(double sw, double sh) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: sw * 0.05,
      vertical: sh * 0.02,
    ),
    decoration: BoxDecoration(
      color: const Color(0xff26A69A),
      borderRadius: BorderRadius.circular(sw * 0.035),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Reports & Analytics',
          style: TextStyle(
            color: Colors.white,
            fontSize: sw * 0.044,
            fontWeight: FontWeight.w700,
          ),
        ),
        Icon(Icons.chevron_right, color: Colors.white, size: sw * 0.07),
      ],
    ),
  );

  // â”€â”€ Sales Overview with Gradient Bars â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildSalesOverview(double sw, double sh) {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY'];
    final values = [0.55, 0.45, 0.75, 0.92, 0.78];
    // Using gradient colors for bars
    final gradientColors = [
      _DashboardColors.barGradient1,
      _DashboardColors.barGradient2,
      _DashboardColors.barGradient3,
      _DashboardColors.barGradient4,
      _DashboardColors.barGradient5,
    ];
    final maxH = sh * 0.2;

    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
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
              Text(
                'Sales Overview',
                style: TextStyle(
                  fontSize: sw * 0.043,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Text(
                'â‚¹2.85M',
                style: TextStyle(
                  fontSize: sw * 0.043,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: sh * 0.022),
          SizedBox(
            height: maxH + sw * 0.1,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(months.length, (i) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: sw * 0.11,
                      height: maxH * values[i],
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors[i],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(sw * 0.025),
                      ),
                    ),
                    SizedBox(height: sw * 0.022),
                    Text(
                      months[i],
                      style: TextStyle(
                        fontSize: sw * 0.029,
                        fontWeight: FontWeight.w600,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€ Donut Chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildDonutChart(double sw, double sh) {
    final segments = [
      _DonutSegment('Rejected', 10, _DashboardColors.donutRed),
      _DonutSegment('Completed', 40, _DashboardColors.donutGreen),
      _DonutSegment('Pending', 15, _DashboardColors.donutPurple),
      _DonutSegment('Process', 35, _DashboardColors.donutBlue),
    ];

    return Container(
      padding: EdgeInsets.all(sw * 0.045),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Donut Chart
          SizedBox(
            width: sw * 0.4,
            height: sw * 0.4,
            child: CustomPaint(
              painter: _DonutPainter(segments: segments, sw: sw),
            ),
          ),
          // Legend - Use Flexible to prevent overflow
          Flexible(
            child: Wrap(
              spacing: sw * 0.03,
              runSpacing: sw * 0.02,
              alignment: WrapAlignment.end,
              children: segments.map((s) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: sw * 0.032,
                      height: sw * 0.032,
                      decoration: BoxDecoration(
                        color: s.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: sw * 0.015),
                    Text(
                      '${s.label}: ${s.percent.toInt()}%',
                      style: TextStyle(
                        fontSize: sw * 0.03,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€ Donut Segment Model â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DonutSegment {
  final String label;
  final double percent;
  final Color color;
  const _DonutSegment(this.label, this.percent, this.color);
}

// â”€â”€â”€ Donut Custom Painter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final double sw;
  const _DonutPainter({required this.segments, required this.sw});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width * 0.46;
    final innerR = size.width * 0.27;
    const double gap = 0.04; // radians between slices

    double startAngle = -math.pi / 2; // start from 12 o'clock
    final total = segments.fold(0.0, (s, e) => s + e.percent);

    for (final seg in segments) {
      final sweep = (seg.percent / total) * 2 * math.pi - gap;
      final arcStart = startAngle + gap / 2;

      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = seg.color;

      final path = Path();
      path.moveTo(
        cx + innerR * math.cos(arcStart),
        cy + innerR * math.sin(arcStart),
      );
      path.lineTo(
        cx + outerR * math.cos(arcStart),
        cy + outerR * math.sin(arcStart),
      );
      path.arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: outerR),
        arcStart,
        sweep,
        false,
      );
      path.lineTo(
        cx + innerR * math.cos(arcStart + sweep),
        cy + innerR * math.sin(arcStart + sweep),
      );
      path.arcTo(
        Rect.fromCircle(center: Offset(cx, cy), radius: innerR),
        arcStart + sweep,
        -sweep,
        false,
      );
      path.close();
      canvas.drawPath(path, paint);

      // Percentage label at mid-arc
      final midAngle = arcStart + sweep / 2;
      final labelR = (outerR + innerR) / 2;
      final lx = cx + labelR * math.cos(midAngle);
      final ly = cy + labelR * math.sin(midAngle);

      final tp = TextPainter(
        text: TextSpan(
          text: '${seg.percent.toInt()}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: sw * 0.024,
            fontWeight: FontWeight.w700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));

      startAngle += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
