import 'package:flutter/material.dart';
import 'package:crm/core/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              style: const TextStyle(
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
                  child: const Text('Edit', style: TextStyle(fontSize: 11, color: AppTheme.primaryTeal)),
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
