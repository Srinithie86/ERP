import 'package:flutter/material.dart';
import '../Widgets/custom_bottom_bar.dart';
import '../Widgets/custom_drawer.dart';
import 'MenuManagement/menumanagement.dart';
import 'TaskManagement/task_management.dart';
import 'ProfileSection/admin_profile.dart';

class DashboardScreen extends StatefulWidget {
  final bool isEmbedded;
  const DashboardScreen({super.key, this.isEmbedded = false});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF7F9FC),
      drawer: const CrmAdminDrawer(),
      appBar: widget.isEmbedded ? null : AppBar(
        toolbarHeight: 70,
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu_open_rounded, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentIndex == 0 
                  ? 'Admin Dashboard' 
                  : (_currentIndex == 1 ? 'Menu Management' : (_currentIndex == 2 ? 'Tasks Hub' : 'Admin Profile')),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'CRM Enterprise Suite',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          _buildNotificationIcon(),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: const CircleAvatar(
              backgroundColor: Colors.white24,
              radius: 18,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: Colors.white,
          ),
        ),
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            height: 9,
            width: 9,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeView();
      case 1:
        return _buildMenusView();
      case 2:
        return const TaskManagementView();
      case 3:
        return const AdminProfileView();
      default:
        return const Center(child: Text('Under Development'));
    }
  }

  Widget _buildHomeView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHorizontalStats(),
          const SizedBox(height: 24),
          _buildSectionHeader('Lead Pipeline', 'View All'),
          _buildPipelineKanban(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildConversionCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildRecentActivitySmall()),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Team Performance', 'View Details'),
          _buildTeamPerformanceList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildMenusView() {
    return const MenuManagementView();
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
            ),
          ),
          Text(
            actionText,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF26A69A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalStats() {
    return SizedBox(
      height: 145,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildStatCardMini(
            'Revenue',
            '\$1.2M',
            Icons.attach_money,
            Colors.green,
            '+12.5%',
          ),
          _buildStatCardMini(
            'Active Leads',
            '246',
            Icons.group_outlined,
            Colors.blue,
            '+8.2%',
          ),
          _buildStatCardMini(
            'Deals Won',
            '156',
            Icons.check_circle_outline,
            Colors.orange,
            '+15.2%',
          ),
          _buildStatCardMini(
            'Average Time',
            '18d',
            Icons.access_time,
            Colors.purple,
            '-2.1%',
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardMini(
    String title,
    String value,
    IconData icon,
    Color color,
    String trend,
  ) {
    final bool isPositive = trend.startsWith('+');
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
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
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: (isPositive ? Colors.green : Colors.red).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  trend,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineKanban() {
    return SizedBox(
      height: 180,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildPipelineColumn('New Leads', '12', Colors.blue, [
            'Acme Corp',
            'TechStart Inc',
          ]),
          _buildPipelineColumn('Contacted', '8', Colors.orange, [
            'Innovate Solutions',
            'Prime Logistics',
          ]),
          _buildPipelineColumn('Qualified', '5', Colors.green, [
            'DataFlow Systems',
            'CloudNine Ltd',
          ]),
        ],
      ),
    );
  }

  Widget _buildPipelineColumn(
    String title,
    String count,
    Color color,
    List<String> companies,
  ) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...companies
              .map(
                (company) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: color.withOpacity(0.1),
                        child: Text(
                          company[0],
                          style: TextStyle(
                            fontSize: 8,
                            color: color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          company,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              ,
        ],
      ),
    );
  }

  Widget _buildConversionCard() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Conversion',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 80,
                width: 80,
                child: CircularProgressIndicator(
                  value: 0.72,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF26A69A),
                  ),
                ),
              ),
              const Column(
                children: [
                  Text(
                    '72%',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Rate',
                    style: TextStyle(fontSize: 8, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          const Text(
            'Lead to Deal',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySmall() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activity',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildActivityItem('15 calls made', '2h ago'),
          _buildActivityItem('Meeting set', '4h ago'),
          _buildActivityItem('Deal won!', '5h ago'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Color(0xFF26A69A)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamPerformanceList() {
    final team = [
      {'name': 'John Smith', 'perf': '89%', 'calls': '145', 'deals': '23'},
      {'name': 'Sarah J.', 'perf': '85%', 'calls': '132', 'deals': '19'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: team
            .map(
              (member) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF26A69A).withOpacity(0.1),
                      child: Text(
                        member['name']![0],
                        style: const TextStyle(
                          color: Color(0xFF26A69A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                member['name']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                member['perf']!,
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: LinearProgressIndicator(
                              value:
                                  double.parse(
                                    member['perf']!.replaceAll('%', ''),
                                  ) /
                                  100,
                              backgroundColor: Colors.grey.shade100,
                              color: Colors.green,
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${member['calls']} calls | ${member['deals']} deals',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
