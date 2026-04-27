import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'campaign_request.dart';
import 'lead_upload.dart';

class CampaignCenterScreen extends StatelessWidget {
  const CampaignCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = [
      {
        'title': 'Campaign Request',
        'desc': 'Initiate new marketing campaign requests',
        'icon': Icons.add_to_photos_rounded,
        'color': const Color(0xFF26A69A),
        'onTap': () {
         Navigator.push(context, MaterialPageRoute(builder: (_) => const CampaignRequestScreen()));
        },
      },
      {
        'title': 'Lead Upload',
        'desc': 'Upload bulk leads from CSV or Excel files',
        'icon': Icons.cloud_upload_rounded,
        'color': Colors.blue.shade600,
        'onTap': () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const LeadUploadScreen()));
        },
      },
      {
        'title': 'Leads List',
        'desc': 'View and manage all campaign leads',
        'icon': Icons.people_alt_rounded,
        'color': Colors.orange.shade600,
        'onTap': () {
          // TODO: Navigate to Leads List Screen
          // Navigator.push(context, MaterialPageRoute(builder: (_) => const LeadsListScreen()));
        },
      },
      {
        'title': 'Email / SMS Campaign',
        'desc': 'Schedule and send mass email/SMS blasts',
        'icon': Icons.send_rounded,
        'color': Colors.indigo.shade600,
        'onTap': () {
          // TODO: Navigate to Email/SMS Campaign Screen
          // Navigator.push(context, MaterialPageRoute(builder: (_) => const EmailSmsCampaignScreen()));
        },
      },
      {
        'title': 'SMS / Email Log',
        'desc': 'Track all sent messages and delivery statuses',
        'icon': Icons.analytics_rounded,
        'color': Colors.purple.shade600,
        'onTap': () {
          // TODO: Navigate to SMS/Email Log Screen
          // Navigator.push(context, MaterialPageRoute(builder: (_) => const SmsEmailLogScreen()));
        },
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        toolbarHeight: 60,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Campaign Center',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF1A1A1A), size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildPremiumRectangleItem(
            item['title'],
            item['desc'],
            item['icon'],
            item['color'],
            index,
            item['onTap'],
          );
        },
      ),
    );
  }

  Widget _buildPremiumRectangleItem(
    String title,
    String desc,
    IconData icon,
    Color color,
    int index,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey.shade300,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}
