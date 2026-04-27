import 'package:flutter/material.dart';
import 'Campaign_center/campaign_center.dart';
import 'LeadManagement/lead_enquiry.dart';
import 'AssignManagement/assign_to.dart';
import 'CallManagement/call_summary.dart';
import 'MeetingManagement/meeting_visit.dart';
import 'FollowupManagement/follow_up.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MenuManagementView extends StatelessWidget {
  const MenuManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Campaign Center',
        'subtitle': 'Marketing & Leads',
        'icon': Icons.campaign_rounded,
        'gradient': [const Color(0xFF64B5F6), const Color(0xFF1976D2)],
        'screen': const CampaignCenterScreen(),
      },
      {
        'title': 'Lead & Enquiry',
        'subtitle': 'New Opportunities',
        'icon': Icons.person_add_rounded,
        'gradient': [const Color(0xFFFFB74D), const Color(0xFFF57C00)],
        'screen': const LeadEnquiryScreen(),
      },
      {
        'title': 'Assign To',
        'subtitle': 'Team Distribution',
        'icon': Icons.assignment_ind_rounded,
        'gradient': [const Color(0xFF4DB6AC), const Color(0xFF00796B)],
        'screen': const AssignToScreen(),
      },
      {
        'title': 'Call Summary',
        'subtitle': 'Communication logs',
        'icon': Icons.call_rounded,
        'gradient': [const Color(0xFF81C784), const Color(0xFF388E3C)],
        'screen': const CallSummaryScreen(),
      },
      {
        'title': 'Meeting & Visit',
        'subtitle': 'On-field tracking',
        'icon': Icons.groups_rounded,
        'gradient': [const Color(0xFFBA68C8), const Color(0xFF7B1FA2)],
        'screen': const MeetingVisitScreen(),
      },
      {
        'title': 'Follow Up',
        'subtitle': 'Active Engagements',
        'icon': Icons.replay_circle_filled_rounded,
        'gradient': [const Color(0xFFFFD54F), const Color(0xFFFFA000)],
        'screen': const FollowUpScreen(),
      },
      {
        'title': 'Schedule List',
        'subtitle': 'Upcoming Tasks',
        'icon': Icons.event_note_rounded,
        'gradient': [const Color(0xFF7986CB), const Color(0xFF303F9F)],
      },
      {
        'title': 'Negotiation',
        'subtitle': 'Deal Finalization',
        'icon': Icons.handshake_rounded,
        'gradient': [const Color(0xFFE57373), const Color(0xFFD32F2F)],
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Access',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1A1A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Manage your sales workflow',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.tune_rounded, color: Colors.grey.shade700),
              ),
            ],
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
          const SizedBox(height: 30),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              final item = menuItems[index];
              return _MenuCard(
                title: item['title'],
                subtitle: item['subtitle'],
                icon: item['icon'],
                gradient: item['gradient'],
                onTap: () {
                  if (item['screen'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => item['screen']),
                    );
                  }
                },
              ).animate().fadeIn(delay: (100 * index).ms).scale(begin: const Offset(0.9, 0.9));
            },
          ),
          const SizedBox(height: 40),
          // Additional Section: Analytics Shortcut
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF26A69A), Color(0xFF00695C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26A69A).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sales Intelligence',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI-powered insights for your team',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF00695C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('View Insights', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(Icons.auto_graph_rounded, color: Colors.white.withOpacity(0.3), size: 80),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[1].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
