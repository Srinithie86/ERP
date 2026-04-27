import 'package:flutter/material.dart';
import 'package:crm/core/theme/app_theme.dart';

class EmailSmsCampaignScreen extends StatefulWidget {
  const EmailSmsCampaignScreen({super.key});

  @override
  State<EmailSmsCampaignScreen> createState() => _EmailSmsCampaignScreenState();
}

class _EmailSmsCampaignScreenState extends State<EmailSmsCampaignScreen> {
  int _activeTabIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Dashboard', 'icon': Icons.dashboard, 'count': null},
    {'title': 'Campaigns', 'icon': Icons.campaign, 'count': '8'},
    {'title': 'Templates', 'icon': Icons.layers, 'count': '12'},
    {'title': 'Analytics', 'icon': Icons.analytics, 'count': null},
    {'title': 'Audience', 'icon': Icons.group, 'count': '1.2K'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildTabs(),
            const SizedBox(height: 24),
            _buildMetricsGrid(),
            const SizedBox(height: 32),
            _buildRecentCampaigns(context),
            const SizedBox(height: 32),
            _buildCampaignPerformance(context),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email & SMS Campaign Dashboard',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.indigo.shade700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage, track, and analyze your communication campaigns',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Campaign'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.indigo.shade600,
                  side: BorderSide(color: Colors.indigo.shade600),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final tab = _tabs[index];
            final isActive = index == _activeTabIndex;
            return GestureDetector(
              onTap: () => setState(() => _activeTabIndex = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isActive ? Colors.indigo.shade500 : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      tab['icon'],
                      size: 16,
                      color: isActive ? Colors.white : Colors.blueGrey.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      tab['title'],
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.blueGrey.shade800,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    if (tab['count'] != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        tab['count'],
                        style: TextStyle(
                          color: isActive ? Colors.indigo.shade100 : Colors.blueGrey.shade400,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _topMetricCard(
                '1,245',
                'Email Campaigns Sent',
                Icons.email,
                Colors.indigo.shade400,
                Colors.indigo.shade50,
                '+12% increase from last month',
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _topMetricCard(
                '892',
                'SMS Campaigns Sent',
                Icons.sms,
                Colors.cyan.shade400,
                Colors.cyan.shade50,
                '+8% increase from last month',
                true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _topMetricCard(
                '24.7%',
                'Average Engagement Rate',
                Icons.touch_app,
                Colors.deepPurple.shade400,
                Colors.deepPurple.shade50,
                '+3.2% increase from last month',
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _topMetricCard(
                '8.9',
                'Campaign Performance Score',
                Icons.show_chart,
                Colors.orange.shade400,
                Colors.orange.shade50,
                '-0.3 decrease from last week',
                false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _topMetricCard(
    String value,
    String label,
    IconData icon,
    Color color,
    Color bgColor,
    String trendText,
    bool isPositiveSegment,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: color, width: 4),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          value,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(fontSize: 11, color: Colors.blueGrey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    isPositiveSegment ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isPositiveSegment ? Colors.green : Colors.pink,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      trendText,
                      style: TextStyle(
                        fontSize: 10,
                        color: isPositiveSegment ? Colors.green : Colors.pink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCampaigns(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Campaigns',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildFilterDropdown('All Types')),
            const SizedBox(width: 12),
            Expanded(child: _buildFilterDropdown('All Statuses')),
          ],
        ),
        const SizedBox(height: 16),
        _campaignListCard(
          type: 'EMAIL',
          status: 'Active',
          date: 'Oct 20, 2023',
          title: 'Summer Sale Announcement',
          subtitle: 'Promote summer sale with exclusive discounts for subscribers',
          sent: '1,245',
          openRate: '32%',
          clickRate: '39%',
          action3: 'Analyze',
          action3Icon: Icons.analytics,
        ),
        _campaignListCard(
          type: 'SMS',
          status: 'Active',
          date: 'Oct 18, 2023',
          title: 'Appointment Reminders',
          subtitle: 'Send SMS reminders for upcoming appointments',
          sent: '892',
          openRate: '88%',
          clickRate: '31%',
          action3: 'Analyze',
          action3Icon: Icons.analytics,
        ),
        _campaignListCard(
          type: 'EMAIL',
          status: 'Scheduled',
          date: 'Oct 25, 2023',
          title: 'New Feature Launch',
          subtitle: 'Announce new platform features to premium users',
          sent: '0',
          openRate: '0%',
          clickRate: '0%',
          action3: 'Analyze',
          action3Icon: Icons.analytics,
        ),
        _campaignListCard(
          type: 'EMAIL',
          status: 'Draft',
          date: 'Nov 15, 2023',
          title: 'Black Friday Preview',
          subtitle: 'Early preview of Black Friday deals for loyal customers',
          sent: '0',
          openRate: '0%',
          clickRate: '0%',
          action3: 'Schedule',
          action3Icon: Icons.schedule,
        ),
        _campaignListCard(
          type: 'EMAIL',
          status: 'Completed',
          date: 'Oct 1, 2023',
          title: 'Monthly Newsletter',
          subtitle: 'Monthly newsletter with industry insights and updates',
          sent: '2,100',
          openRate: '35%',
          clickRate: '40%',
          action3: 'Analyze',
          action3Icon: Icons.analytics,
          isActiveHighlight: true, // The purple border highlight from the screen
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 13)),
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          items: const [],
          onChanged: (value) {},
        ),
      ),
    );
  }

  Widget _campaignListCard({
    required String type,
    required String status,
    required String date,
    required String title,
    required String subtitle,
    required String sent,
    required String openRate,
    required String clickRate,
    bool isActiveHighlight = false,
    required String action3,
    required IconData action3Icon,
  }) {
    Color typeColor = type == 'EMAIL' ? Colors.indigo.shade600 : Colors.cyan.shade600;
    Color typeBgColor = type == 'EMAIL' ? Colors.indigo.shade100 : Colors.cyan.shade100;

    Color statusColor;
    Color statusBgColor;
    if (status == 'Active') {
      statusColor = Colors.green.shade700;
      statusBgColor = Colors.green.shade100;
    } else if (status == 'Scheduled') {
      statusColor = Colors.orange.shade700;
      statusBgColor = Colors.orange.shade100;
    } else if (status == 'Completed') {
      statusColor = Colors.blue.shade700;
      statusBgColor = Colors.blue.shade100;
    } else {
      statusColor = Colors.grey.shade600;
      statusBgColor = Colors.grey.shade200;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActiveHighlight ? Colors.indigo.shade400 : Colors.grey.shade200,
          width: isActiveHighlight ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: typeBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: TextStyle(color: typeColor, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.blueGrey.shade400),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade600),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _statColumn('Sent', sent),
              _statColumn('Open Rate', openRate),
              _statColumn('Click Rate', clickRate),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _actionButton(Icons.visibility, 'View')),
              const SizedBox(width: 8),
              Expanded(child: _actionButton(Icons.edit, 'Edit')),
              const SizedBox(width: 8),
              Expanded(child: _actionButton(action3Icon, action3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.blueGrey.shade400),
        ),
      ],
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, size: 14, color: Colors.black87),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildCampaignPerformance(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Campaign Performance',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildFilterDropdown('Last 7 Days'),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart, size: 40, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'Engagement Rate Chart Placeholder',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _performanceStatRow('Open Rate', 'Email campaigns only', '32.5%', Colors.indigo.shade600),
        const Divider(height: 24),
        _performanceStatRow('Click Rate', 'Email campaigns only', '12.8%', Colors.indigo.shade600),
        const Divider(height: 24),
        _performanceStatRow('Response Rate', 'SMS campaigns only', '18.4%', Colors.purple.shade600),
        const Divider(height: 24),
        _performanceStatRow('Conversion Rate', 'All campaigns', '4.7%', Colors.orange.shade600),
      ],
    );
  }

  Widget _performanceStatRow(String title, String subtitle, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 13),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
