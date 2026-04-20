import '../Leads/leads_screen.dart';
import '../Deals/deals_screen.dart';
import '../Follows/follow_up_screen.dart';
import '../Deals/deal_won.dart';
import '../Deals/deal_lost.dart';
import '../Meeting/add_meeting_screen.dart';
import '../Meeting/meeting_screen.dart';
import '../services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:erp_smart/utils/widgets/dynamic_drawer.dart';
import '../core/theme/app_theme.dart';
import '../Settings/setting_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import '../Leads/enquiry_screen.dart';
import '../Leads/referral_screen.dart';
import '../Leads/add_lead_screen.dart';
import '../utils/preference_service.dart';
import 'package:crm_admin_app/Screens/dashboard_screen.dart' as admin_app;
import '../Reports/report_screen.dart';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  final int followUpInitialIndex;
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const DashboardScreen({
    super.key,
    this.initialIndex = 0,
    this.followUpInitialIndex = 0,
    this.isEmbedded = false,
    this.scaffoldKey,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  String _userName = 'Loading...';
  int _currentIndex = 0;
  bool _isFabExpanded = false;
  List<Map<String, dynamic>> _crmMenus = [];
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  List<Map<String, dynamic>> get crmMenus => _crmMenus;

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
    _loadName();
    _loadMenuData();
  }

  Future<void> _loadMenuData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('user_menu_data');
      if (saved != null) {
        final Map<String, dynamic> fullMenu = json.decode(saved);
        String? crmKey;
        for (final key in fullMenu.keys) {
          if (key.trim().toUpperCase() == "CRM") crmKey = key;
        }
        if (crmKey != null && fullMenu[crmKey] is List) {
          setState(() {
            _crmMenus = List<Map<String, dynamic>>.from(fullMenu[crmKey]);
          });
        }
      }
    } catch (e) {
      debugPrint("CRM Dashboard => Error: $e");
    }
  }

  Future<void> _loadName() async {
    final cachedName = await PreferenceService.getName();
    if (mounted && cachedName != null) {
      setState(() {
        _userName = cachedName;
      });
    }

    final profileData = await ProfileService.fetchProfileData();
    if (mounted && profileData != null) {
      setState(() {
        _userName = profileData['name'] ?? _userName;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _getCurrentScreen() {
    return const _DashboardContent();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        } else {
          Navigator.of(context).maybePop();
        }
      },
      child: Scaffold(
        endDrawer: widget.isEmbedded ? null : const DynamicDrawer(moduleName: "CRM"),
        appBar: AppBar(
          backgroundColor: const Color(0xFF26A69A),
          elevation: 0,
          titleSpacing: 20,
          title: Text(
            'CRM Management',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            Builder(
              builder: (context) => GestureDetector(
                onTap: () {
                  if (widget.scaffoldKey?.currentState != null) {
                    widget.scaffoldKey!.currentState!.openEndDrawer();
                  } else {
                    Scaffold.of(context).openEndDrawer();
                  }
                },
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      body: Stack(
        children: [
          _getCurrentScreen(),
          if (_currentIndex == 0)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      if (_isFabExpanded)
                        GestureDetector(
                          onTap: _toggleFab,
                          behavior: HitTestBehavior.opaque,
                          child: Container(color: Colors.transparent),
                        ),
                      if (_expandAnimation.value > 0) ...[
                        // Meeting - Top Right
                        if (crmMenus.any((m) => m['name'] == "Meeting and Visit"))
                        Positioned(
                          bottom:
                              16.0 +
                              (screenWidth * 0.015) +
                              (screenWidth * 0.25) * _expandAnimation.value,
                          right: 16.0 + (screenWidth * 0.015),
                          child: Opacity(
                            opacity: _expandAnimation.value,
                            child: Transform.scale(
                              scale: _expandAnimation.value,
                              child: _buildFabAction(
                                icon: Icons.groups,
                                label: 'Meeting',
                                color: const Color(0xFF26A69A),
                                onTap: () {
                                  _toggleFab();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddMeetingScreen(),
                                    ),
                                  );
                                },
                                screenWidth: screenWidth,
                              ),
                            ),
                          ),
                        ),
                        // Lead - Top Left
                        if (crmMenus.any((m) => m['name'] == "Lead/Enquiry"))
                        Positioned(
                          bottom:
                              16.0 +
                              (screenWidth * 0.015) +
                              (screenWidth * 0.25) * _expandAnimation.value,
                          right:
                              16.0 +
                              (screenWidth * 0.015) +
                              (screenWidth * 0.22) * _expandAnimation.value,
                          child: Opacity(
                            opacity: _expandAnimation.value,
                            child: Transform.scale(
                              scale: _expandAnimation.value,
                              child: _buildFabAction(
                                icon: Icons.person_add_alt_1,
                                label: 'Lead',
                                color: const Color(0xFF26A69A),
                                onTap: () {
                                  _toggleFab();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AddLeadScreen(isEnquiry: false),
                                    ),
                                  );
                                },
                                screenWidth: screenWidth,
                              ),
                            ),
                          ),
                        ),
                        // Enquiry - Bottom Left
                        if (crmMenus.any((m) => m['name'] == "Lead/Enquiry"))
                        Positioned(
                          bottom: 16.0 + (screenWidth * 0.015),
                          right:
                              16.0 +
                              (screenWidth * 0.015) +
                              (screenWidth * 0.25) * _expandAnimation.value,
                          child: Opacity(
                            opacity: _expandAnimation.value,
                            child: Transform.scale(
                              scale: _expandAnimation.value,
                              child: _buildFabAction(
                                icon: Icons.headset_mic,
                                label: 'Enquiry',
                                color: const Color(0xFF26A69A),
                                onTap: () {
                                  _toggleFab();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AddLeadScreen(isEnquiry: true),
                                    ),
                                  );
                                },
                                screenWidth: screenWidth,
                              ),
                            ),
                          ),
                        ),
                      ],
                      // Main Button
                      Positioned(
                        bottom: 16.0,
                        right: 16.0,
                        child: SizedBox(
                          height: screenWidth * 0.16,
                          width: screenWidth * 0.16,
                          child: FloatingActionButton(
                            onPressed: _toggleFab,
                            backgroundColor: const Color(0xFF26A69A),
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: Transform.rotate(
                              angle:
                                  _expandAnimation.value *
                                  (3.14159 / 4), // Rotate 45 degrees
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: screenWidth * 0.08,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildFabAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenWidth * 0.13,
        width: screenWidth * 0.13,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: screenWidth * 0.04),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.02,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _titleSection(context),
          const SizedBox(height: 20),
          _metricsSection(context),
          const SizedBox(height: 20),
          _leadPipeline(context),
          const SizedBox(height: 20),
          _conversionRateCard(context),
          const SizedBox(height: 20),
          _recentActivity(context),
          const SizedBox(height: 20),
          _teamPerformance(context),
        ],
      ),
    );
  }

  // ─── Title ────────────────────────────────────────────────────────────────

  Widget _titleSection(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.track_changes, color: Colors.purple, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CRM Dashboard',
                style: Theme.of(context).textTheme.titleLarge,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Sales Management System',
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Metrics ──────────────────────────────────────────────────────────────

  Widget _metricsSection(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                'TOTAL REVENUE', '\$1.2M', '+12.5%', 'vs last month',
                Colors.green, FontAwesomeIcons.sackDollar,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                'ACTIVE LEADS', '246', '+8.2%', 'In pipeline: 67',
                Colors.blue, FontAwesomeIcons.chartLine,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _metricCard(
                'DEALS WON', '156', '+15.3%', 'This quarter: 87%',
                Colors.purple, FontAwesomeIcons.checkDouble,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _metricCard(
                'AVG. CLOSE TIME', '18d', '-2.1%', 'Cycle improving',
                Colors.orange, FontAwesomeIcons.stopwatch,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _metricCard(
    String label,
    String value,
    String trend,
    String footer,
    Color color,
    dynamic icon,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon + Trend row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: icon is IconData
                      ? Icon(icon, color: color, size: 14)
                      : FaIcon(icon, color: color, size: 13),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    trend,
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Label
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            // Value
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            // Footer
            Text(
              footer,
              style: const TextStyle(fontSize: 9, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.7,
                backgroundColor: color.withValues(alpha: 0.12),
                color: color,
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Lead Pipeline ────────────────────────────────────────────────────────

  Widget _leadPipeline(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LEAD PIPELINE',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () {}, child: const Text('View All →')),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 210, child: _kanbanColumn(context, 'New Leads', 3, Colors.blue)),
              const SizedBox(width: 10),
              SizedBox(width: 210, child: _kanbanColumn(context, 'Contacted', 2, Colors.orange)),
              const SizedBox(width: 10),
              SizedBox(width: 210, child: _kanbanColumn(context, 'Qualified', 4, Colors.pink)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kanbanColumn(BuildContext context, String title, int count, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: color, width: 4)),
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 2)],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 11,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(count.toString(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _kanbanCard('Acme Corporation', 'HOT', '\$45,000', 'JS', 'John'),
        _kanbanCard('TechStart Inc', 'WARM', '\$32,000', 'SJ', 'Sarah'),
      ],
    );
  }

  Widget _kanbanCard(String company, String tag, String value, String avatar, String name) {
    final isHot = tag == 'HOT';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    company,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isHot ? Colors.red[50] : Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      color: isHot ? Colors.red : Colors.orange,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.indigo[100],
                  child: Text(avatar, style: const TextStyle(fontSize: 8)),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(name, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                ),
                GestureDetector(
                  onTap: () {},
                  child: Text('Edit', style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Conversion Rate ──────────────────────────────────────────────────────

  Widget _conversionRateCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'CONVERSION RATE',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 90,
                  width: 90,
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                            value: 72,
                            color: AppTheme.primaryTeal,
                            radius: 10,
                            showTitle: false),
                        PieChartSectionData(
                            value: 28,
                            color: Colors.grey[200],
                            radius: 10,
                            showTitle: false),
                      ],
                      centerSpaceRadius: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('72%',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    Text('Success Rate',
                        style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _statRow('Total Leads', '344'),
                      _statRow('Converted', '248', color: Colors.green),
                      _statRow('In Progress', '67', color: Colors.blue),
                      _statRow('Lost', '29', color: Colors.red),
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

  Widget _statRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // ─── Recent Activity ──────────────────────────────────────────────────────

  Widget _recentActivity(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT ACTIVITY',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _activityItem(Icons.call, '15 calls completed', '2h ago'),
            _activityItem(Icons.calendar_today, 'Meeting with Client XYZ', '4h ago'),
            _activityItem(Icons.attach_money, 'Deal won - \$45,000', '5h ago'),
            _activityItem(Icons.assignment, '8 tasks assigned', '6h ago'),
          ],
        ),
      ),
    );
  }

  Widget _activityItem(IconData icon, String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppTheme.primaryTeal),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  // ─── Team Performance ─────────────────────────────────────────────────────

  Widget _teamPerformance(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TEAM PERFORMANCE',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            TextButton(onPressed: () {}, child: const Text('View Details →')),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _perfCard('JS', 'John Smith', '89%', '145', '23', '\$345K'),
              const SizedBox(width: 10),
              _perfCard('SJ', 'Sarah Johnson', '85%', '132', '19', '\$289K'),
              const SizedBox(width: 10),
              _perfCard('MD', 'Mike Davis', '78%', '98', '15', '\$234K'),
              const SizedBox(width: 10),
              _perfCard('EC', 'Emily Chen', '72%', '87', '12', '\$198K', isSelected: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _perfCard(
    String avatar,
    String name,
    String percent,
    String calls,
    String deals,
    String revenue, {
    bool isSelected = false,
  }) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppTheme.primaryTeal, width: 2)
            : Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: Colors.deepPurple[400],
                child: Text(avatar,
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              percent,
              style: const TextStyle(
                  color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _perfStat('CALLS', calls),
              _perfStat('DEALS', deals),
              _perfStat('REV', revenue),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.8,
              color: Colors.green,
              backgroundColor: Colors.grey[100],
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _perfStat(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

