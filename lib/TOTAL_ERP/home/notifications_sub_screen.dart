import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationsSubScreen extends StatelessWidget {
  const NotificationsSubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSectionTitle('TODAY').animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),
          _buildNotificationCard(
            context: context,
            title: 'Leave Request Approved',
            subtitle: 'Your leave request for Mar 15 has been approved by HR.',
            time: '10:00 AM',
            icon: Icons.check_circle_rounded,
            iconBgColor: const Color(0xFFE0F2F1),
            iconColor: const Color(0xFF00897B),
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            context: context,
            title: 'Meeting Reminder',
            subtitle: 'Sales team meeting starts in 15 minutes on Zoom.',
            time: '09:45 AM',
            icon: Icons.videocam_rounded,
            iconBgColor: const Color(0xFFE8EAF6),
            iconColor: const Color(0xFF3F51B5),
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            context: context,
            title: 'Invoice Generated',
            subtitle: 'New invoice #INV-2024-001 has been generated.',
            time: '08:30 AM',
            icon: Icons.receipt_long_rounded,
            iconBgColor: const Color(0xFFFCE4EC),
            iconColor: const Color(0xFFD81B60),
          ),
          const SizedBox(height: 32),
          _buildSectionTitle('YESTERDAY').animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
          const SizedBox(height: 16),
          _buildNotificationCard(
            context: context,
            title: 'System Maintenance',
            subtitle: 'ERP System will be down for 2 hours tonight for updates.',
            time: 'Mar 9',
            icon: Icons.warning_rounded,
            iconBgColor: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFEF6C00),
          ),
          const SizedBox(height: 12),
          _buildNotificationCard(
            context: context,
            title: 'New Policy Update',
            subtitle: 'The remote work policy has been updated. Please review.',
            time: 'Mar 9',
            icon: Icons.security_rounded,
            iconBgColor: const Color(0xFFECEFF1),
            iconColor: const Color(0xFF455A64),
          ),
          const SizedBox(height: 100),
        ].animate(interval: 100.ms).fadeIn(duration: 500.ms).slideY(begin: 0.05).toList(),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: Colors.grey.shade500,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon with subtle gradient or shadow
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
