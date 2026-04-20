import 'package:crm/Settings/account_setting_screen.dart';
import 'package:crm/Settings/notification_alert_screen.dart';
import 'package:crm/Settings/help_support_screen.dart';
import 'package:crm/Settings/security_settings_screen.dart';
import 'package:crm/Settings/app_preference_screen.dart';
import 'package:crm/SignIn/splash.dart';
import 'package:crm/services/profile_service.dart';
import 'package:crm/utils/preference_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SettingScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const SettingScreen({super.key, this.onBack});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String _name = 'Loading...';
  String _email = '...';
  String _location = 'Fetching location...';
  bool _isLoading = true;
  bool _isDarkMode = false;
  bool _isAppLockEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load from cache first for instant UI
    final cachedName = await PreferenceService.getName();
    final cachedEmail = await PreferenceService.getEmail();

    if (mounted) {
      setState(() {
        if (cachedName != null) _name = cachedName;
        if (cachedEmail != null) _email = cachedEmail ?? 'No Email';
      });
    }

    // 2. Refresh from API
    final profileData = await ProfileService.fetchProfileData();
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        if (profileData != null) {
          _name = profileData['name'] ?? _name;
          _email = profileData['email'] ?? _email;
        }

        // Get coordinates
        String lt = SplashScreen.lt ?? prefs.getString('lt') ?? '';
        String ln = SplashScreen.ln ?? prefs.getString('ln') ?? '';

        if (lt.isNotEmpty && ln.isNotEmpty) {
          _reverseGeocode(lt, ln);
        } else {
          _location = prefs.getString('com_address') ?? 'N/A';
          _isLoading = false;
        }
      });
    }
  }

  Future<void> _reverseGeocode(String lat, String lng) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
        ),
        headers: {'User-Agent': 'CRM_App'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'] ?? 'Unknown Location';
        if (mounted) {
          setState(() {
            _location = address;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _location = "Lat: $lat, Lng: $lng";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Reverse geocoding error: $e");
      if (mounted) {
        setState(() {
          _location = "Lat: $lat, Lng: $lng";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00796B)),
            )
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    children: [
                      _buildSectionTitle('Account'),
                      _buildSettingsCard([
                        _buildSettingItem(
                          icon: Icons.person_outline,
                          title: 'Personal Information',
                          iconBgColor: const Color(0xFFEDE7F6),
                          iconColor: const Color(0xFF673AB7),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AccountSettingScreen()),
                          ),
                        ),
                        _buildSettingItem(
                          icon: Icons.lock_outline,
                          title: 'App Lock Pin',
                          iconBgColor: const Color(0xFFE8F5E9),
                          iconColor: const Color(0xFF4CAF50),
                          trailing: Switch(
                            value: _isAppLockEnabled,
                            activeColor: Colors.black,
                            onChanged: (val) => setState(() => _isAppLockEnabled = val),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Preference'),
                      _buildSettingsCard([
                        _buildSettingItem(
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          iconBgColor: const Color(0xFFF5F5F5),
                          iconColor: const Color(0xFF616161),
                          trailing: Switch(
                            value: _isDarkMode,
                            activeColor: Colors.black,
                            onChanged: (val) => setState(() => _isDarkMode = val),
                          ),
                        ),
                        _buildSettingItem(
                          icon: Icons.language_outlined,
                          title: 'Language',
                          iconBgColor: const Color(0xFFFFF8E1),
                          iconColor: const Color(0xFFFFB300),
                          subtitle: 'English',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AppPreferenceScreen()),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      _buildSectionTitle('Support'),
                      _buildSettingsCard([
                        _buildSettingItem(
                          icon: Icons.help_outline,
                          title: 'Help Center',
                          iconBgColor: const Color(0xFFE0F7FA),
                          iconColor: const Color(0xFF00BCD4),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                          ),
                        ),
                        _buildSettingItem(
                          icon: Icons.shield_outlined,
                          title: 'Term & Policies',
                          iconBgColor: const Color(0xFFE8EAF6),
                          iconColor: const Color(0xFF3F51B5),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 40),
                      _buildLogoutButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF00796B),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(
                'assets/images/user_avatar.png',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.person, size: 40, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: const [
                      Text(
                        'Switch Account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Color iconBgColor,
    required Color iconColor,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF44336),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
