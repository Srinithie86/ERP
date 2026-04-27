import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


class MainDrawer extends StatelessWidget {
  const MainDrawer({super.key});

  Future<Map<String, String>> _getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name') ?? 'Smart ERP User',
      'email': prefs.getString('employee_code') ?? 'User ID: ${prefs.getString('uid') ?? "N/A"}',
      'profile_photo': prefs.getString('profile_photo') ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    const tealColor = Color(0xFF26A69A);
    
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          FutureBuilder<Map<String, String>>(
            future: _getUserData(),
            builder: (context, snapshot) {
              final data = snapshot.data ?? {'name': 'Loading...', 'email': '', 'profile_photo': ''};
              return _buildHeader(context, tealColor, data['name']!, data['email']!, data['profile_photo']!);
            },
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  label: 'Smart ERP Home',
                  isActive: true,
                  onTap: () => Navigator.pop(context),
                  tealColor: tealColor,
                ),
                _buildDrawerItem(
                  icon: Icons.account_circle_outlined,
                  label: 'My Profile',
                  onTap: () {},
                  tealColor: tealColor,
                ),
                _buildDrawerItem(
                  icon: Icons.business_outlined,
                  label: 'Company Information',
                  onTap: () {},
                  tealColor: tealColor,
                ),
                _buildDrawerItem(
                  icon: Icons.security_outlined,
                  label: 'Privacy & Security',
                  onTap: () {},
                  tealColor: tealColor,
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Global Settings',
                  onTap: () {},
                  tealColor: tealColor,
                ),
                _buildDrawerItem(
                  icon: Icons.help_outline_rounded,
                  label: 'Help Center',
                  onTap: () {},
                  tealColor: tealColor,
                ),
              ],
            ),
          ),
          _buildFooter(context, tealColor),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color tealColor, String name, String email, String photo) {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: BoxDecoration(
        color: tealColor,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE0F2F1),
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty ? const Icon(Icons.person_rounded, color: Color(0xFF26A69A), size: 36) : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
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
    required Color tealColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? tealColor : Colors.grey.shade600,
        size: 26,
      ),
      title: Text(
        label,
        style: GoogleFonts.outfit(
          color: isActive ? tealColor : Colors.grey.shade800,
          fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
          fontSize: 16,
        ),
      ),
      tileColor: isActive ? tealColor.withValues(alpha: 0.05) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      onTap: onTap,
    );
  }

  Widget _buildFooter(BuildContext context, Color tealColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout_rounded,
            label: 'Logout Session',
            onTap: () {},
            tealColor: Colors.redAccent,
          ),
          const SizedBox(height: 12),
          Text(
            'Smart ERP v1.0.2',
            style: GoogleFonts.outfit(
              color: Colors.grey.shade400,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
