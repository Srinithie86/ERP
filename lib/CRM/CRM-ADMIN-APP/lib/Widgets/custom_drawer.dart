import 'package:flutter/material.dart';
import 'package:crm/Screens/Home/dashboard_screen.dart';

class CrmAdminDrawer extends StatelessWidget {
  const CrmAdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  label: 'Dashboard',
                  isActive: true,
                  onTap: () => Navigator.pop(context),
                ),
                _buildDrawerItem(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'Leads',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.business_center_outlined,
                  label: 'Opportunities',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.people_alt_outlined,
                  label: 'Contacts',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.bar_chart_outlined,
                  label: 'Reports',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.people_outline,
                  label: 'CRM Customer',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DashboardScreen(),
                      ),
                    );
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {},
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {},
                ),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      color: Colors.white,
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: Color(0xFFE0F2F1),
            child: Icon(Icons.person, color: Color(0xFF26A69A), size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CRM Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'admin@smartcrm.com',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? const Color(0xFF26A69A) : Colors.grey.shade700,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? const Color(0xFF26A69A) : Colors.grey.shade800,
          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      tileColor: isActive ? const Color(0xFFE0F2F1).withValues(alpha: 0.5) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      onTap: onTap,
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 10),
          Text(
            'Version 1.0.0',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
