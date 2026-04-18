import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'app_theme.dart';
import 'shared_widgets.dart';
import 'models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DashboardScreen({
    super.key,
    this.isEmbedded = false,
    this.scaffoldKey,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _mfgMenus = [];

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
          if (key.trim().toUpperCase() == "MANUFACTURING" || key.trim().toUpperCase() == "MFG") targetKey = key;
        }
        if (targetKey != null && fullMenu[targetKey] is List) {
          setState(() {
            _mfgMenus = List<Map<String, dynamic>>.from(fullMenu[targetKey]);
          });
        }
      }
    } catch (e) {
      debugPrint("Manufacturing Dashboard => Error: $e");
    }
  }

  bool _isVisible(String apiKey) {
    if (_mfgMenus.isEmpty) return true; // Show all by default if no data loaded
    return _mfgMenus.any((item) => item['name'].toString().trim().toUpperCase() == apiKey.trim().toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.isEmbedded
            ? AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leading: Builder(
                  builder: (ctx) => IconButton(
                    icon: const Icon(Icons.menu_rounded, color: Colors.black, size: 28),
                    onPressed: () {
                      if (widget.scaffoldKey?.currentState != null) {
                        widget.scaffoldKey!.currentState!.openDrawer();
                      } else {
                        Scaffold.of(ctx).openDrawer();
                      }
                    },
                  ),
                ),
              )
            : null,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildHeader(sw),
          SizedBox(height: sh * 0.025),
          _buildAlertBanner(sw),
          SizedBox(height: sh * 0.025),
          _buildStatsGrid(sw),
          SizedBox(height: sh * 0.03),
          _buildProductionChart(sw, sh),
          SizedBox(height: sh * 0.03),
          _buildActiveJobs(sw, sh),
          SizedBox(height: sh * 0.03),
          _buildPendingApprovals(sw),
        ]),
      ),
    ),
  );
}

  Widget _buildHeader(double sw) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: sw * 0.005),
      Text('Dashboard', style: TextStyle(
        fontSize: sw * 0.04,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      )),
    ])),
    Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.03, vertical: sw * 0.02),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.025),
        border: Border.all(color: Colors.white),
      ),
      child: Row(children: [
        Icon(Icons.calendar_today_outlined, size: sw * 0.04, color: Colors.grey),
        SizedBox(width: sw * 0.015),
        Text(_today(), style: TextStyle(
          fontSize: sw * 0.032,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        )),
      ]),
    ),
  ]);

  String _today() {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Widget _buildAlertBanner(double sw) => Container(
    padding: EdgeInsets.all(sw * 0.035),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(sw * 0.025),
      border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
    ),
    child: Row(children: [
      Container(
        width: 7, height: 7,
        decoration: BoxDecoration(color: AppColors.warning, borderRadius: BorderRadius.circular(4)),
      ),
      SizedBox(width: sw * 0.025),
      Expanded(child: Text(
        '2 Component Requests pending approval · 1 Work Order delayed',
        style: TextStyle(
          fontSize: sw * 0.032,
          color: AppColors.warning,
          fontWeight: FontWeight.w500,
        ),
      )),
      Icon(Icons.chevron_right, color: AppColors.warning, size: sw * 0.045),
    ]),
  );

  Widget _buildStatsGrid(double sw) {
    final List<Widget> stats = [];

    if (_isVisible('Active Build Plans') || _isVisible('Build Plans')) {
      stats.add(_colorStatCard(
        label: 'Active Build Plans', value: '3',
        icon: Icons.precision_manufacturing_outlined,
        trend: '↑ +1 this week',
        gradientColors: const [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
        sw: sw,
      ));
    }
    
    if (_isVisible('Work Orders')) {
      stats.add(_colorStatCard(
        label: 'Work Orders Today', value: '7',
        icon: Icons.assignment_outlined,
        trend: '↑ +2 today',
        gradientColors: const [Color(0xFF0EA5E9), Color(0xFF38BDF8)],
        sw: sw,
      ));
    }

    if (_isVisible('Pending Approvals') || _isVisible('Approvals')) {
      stats.add(_colorStatCard(
        label: 'Pending Approvals', value: '4',
        icon: Icons.pending_actions_outlined,
        trend: '⚠ Action needed',
        gradientColors: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
        sw: sw,
      ));
    }

    if (_isVisible('QC Pass Rate') || _isVisible('QC')) {
      stats.add(_colorStatCard(
        label: 'QC Pass Rate', value: '96%',
        icon: Icons.verified_outlined,
        trend: '↑ +2% vs last week',
        gradientColors: const [Color(0xFF22C55E), Color(0xFF4ADE80)],
        sw: sw,
      ));
    }

    if (stats.isEmpty) return const SizedBox.shrink();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: sw * 0.03,
      crossAxisSpacing: sw * 0.03,
      childAspectRatio: 1.0,
      children: stats,
    );
  }

  Widget _colorStatCard({
    required String label,
    required String value,
    required IconData icon,
    required String trend,
    required List<Color> gradientColors,
    required double sw,
  }) =>
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(sw * 0.045),
        ),
        padding: EdgeInsets.all(sw * 0.04),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: EdgeInsets.all(sw * 0.02),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(sw * 0.025),
              ),
              child: Icon(icon, size: sw * 0.045, color: Colors.white),
            ),
          ]),
          const Spacer(),
          Text(value, style: TextStyle(
            fontSize: sw * 0.075,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -1,
            height: 1,
          )),
          SizedBox(height: sw * 0.01),
          Text(label, style: TextStyle(
            fontSize: sw * 0.028,
            color: Colors.white.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
          )),
          SizedBox(height: sw * 0.01),
          Text(trend, style: TextStyle(
            fontSize: sw * 0.026,
            color: Colors.white.withValues(alpha: 0.7),
          )),
        ]),
      );

  Widget _buildProductionChart(double sw, double sh) => Container(
    padding: EdgeInsets.all(sw * 0.04),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF22252F), width: 0.5),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SectionHeader(title: 'Production This Week', actionLabel: 'Details'),
      SizedBox(height: sh * 0.025),
      SizedBox(
        height: sh * 0.2,
        child: BarChart(BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(
              showTitles: true, reservedSize: 28,
              getTitlesWidget: (v, _) {
                const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(days[v.toInt()], style: TextStyle(
                    fontSize: sw * 0.028,
                    color: Colors.grey,
                  )),
                );
              },
            )),
          ),
          gridData: FlGridData(
            show: true, drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFF22252F), strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          barGroups: [
            _bar(0, 320, 280), _bar(1, 450, 400), _bar(2, 380, 360),
            _bar(3, 500, 460), _bar(4, 420, 390), _bar(5, 280, 260), _bar(6, 150, 120),
          ],
        )),
      ),
      SizedBox(height: sw * 0.03),
      Row(children: [
        _legend(AppColors.primaryLight, 'Planned', sw),
        SizedBox(width: sw * 0.04),
        _legend(AppColors.primary, 'Actual', sw),
      ]),
    ]),
  );

  BarChartGroupData _bar(int x, double planned, double actual) => BarChartGroupData(
    x: x, barRods: [
    BarChartRodData(toY: planned, color: AppColors.primaryLight, width: 12, borderRadius: BorderRadius.circular(4)),
    BarChartRodData(toY: actual, color: AppColors.primary, width: 12, borderRadius: BorderRadius.circular(4)),
  ], barsSpace: 4,
  );

  Widget _legend(Color color, String label, double sw) => Row(children: [
    Container(
      width: sw * 0.025, height: sw * 0.025,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    ),
    SizedBox(width: sw * 0.015),
    Text(label, style: TextStyle(fontSize: sw * 0.03, color: Colors.grey)),
  ]);

  Widget _buildActiveJobs(double sw, double sh) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionHeader(title: 'Active Work Orders', actionLabel: 'View All'),
    SizedBox(height: sh * 0.015),
    ...SampleData.jobCards.take(3).map((j) => Padding(
      padding: EdgeInsets.only(bottom: sh * 0.012),
      child: Container(
        padding: EdgeInsets.all(sw * 0.04),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF22252F), width: 0.5),
        ),
        child: Column(children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(j.id, style: TextStyle(
                fontSize: sw * 0.03,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              )),
              SizedBox(height: sw * 0.008),
              Text(j.productName, style: TextStyle(
                fontSize: sw * 0.035,
                fontWeight: FontWeight.w700,
                color: Colors.black54,
              )),
            ])),
            StatusBadge(
              label: j.status == 'inprogress' ? 'In Progress' : j.status == 'pending' ? 'Pending' : 'Completed',
              status: j.status,
            ),
          ]),
          SizedBox(height: sw * 0.03),
          Row(children: [
            Icon(Icons.person_outline, size: sw * 0.035, color: Colors.grey),
            SizedBox(width: sw * 0.01),
            Flexible(
              child: Text(j.assignedTo,
                style: TextStyle(fontSize: sw * 0.03, color: Colors.grey),
                overflow: TextOverflow.ellipsis, maxLines: 1,
              ),
            ),
            SizedBox(width: sw * 0.03),
            Icon(Icons.settings_outlined, size: sw * 0.035, color: Colors.grey),
            SizedBox(width: sw * 0.01),
            Flexible(
              child: Text(j.machine,
                style: TextStyle(fontSize: sw * 0.03, color: Colors.grey),
                overflow: TextOverflow.ellipsis, maxLines: 1,
              ),
            ),
            const Spacer(),
            Text('Qty: ${j.qty}', style: TextStyle(
              fontSize: sw * 0.03,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            )),
          ]),
          if (j.status == 'inprogress') ...[
            SizedBox(height: sw * 0.025),
            const ProgressBar(value: 0.45, color: AppColors.primary),
            SizedBox(height: sw * 0.01),
            Text('45% completed', style: TextStyle(
              fontSize: sw * 0.028,
              color: Colors.grey,
            )),
          ],
        ]),
      ),
    )),
  ]);

  Widget _buildPendingApprovals(double sw) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionHeader(title: 'Pending Approvals', actionLabel: 'View All'),
    SizedBox(height: sw * 0.03),
    Container(
      padding: EdgeInsets.all(sw * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF22252F), width: 0.5),
      ),
      child: Column(children: [
        _approvalRow('MR-002', 'Component Request', 'Murugan S', '2 items', sw),
        Divider(color: const Color(0xFF22252F), height: sw * 0.05),
        _approvalRow('JC-004', 'Work Order', 'Suresh M', 'Pending start', sw),
      ]),
    ),
  ]);

  Widget _approvalRow(String id, String type, String by, String note, double sw) => Row(children: [
    Container(
      width: sw * 0.095, height: sw * 0.095,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(sw * 0.02),
      ),
      child: Icon(Icons.pending_outlined, color: AppColors.warning, size: sw * 0.05),
    ),
    SizedBox(width: sw * 0.03),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$id · $type', style: TextStyle(
        fontSize: sw * 0.032,
        fontWeight: FontWeight.w600,
        color: Colors.black54
        ,
      ), overflow: TextOverflow.ellipsis, maxLines: 1),
      Text('$by · $note', style: TextStyle(
        fontSize: sw * 0.03,
        color: Colors.grey,
      ), overflow: TextOverflow.ellipsis, maxLines: 1),
    ])),
    SizedBox(width: sw * 0.02),
    ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: EdgeInsets.symmetric(horizontal: sw * 0.035, vertical: sw * 0.02),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text('Approve', style: TextStyle(fontSize: sw * 0.03)),
    ),
  ]);
}