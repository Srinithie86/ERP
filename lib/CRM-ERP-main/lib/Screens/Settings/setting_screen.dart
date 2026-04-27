import 'package:crm/Screens/Settings/account_setting_screen.dart';
import 'package:crm/Screens/Settings/notification_alert_screen.dart';
import 'package:crm/Screens/Settings/help_support_screen.dart';
import 'package:crm/Screens/Settings/security_settings_screen.dart';
import 'package:crm/Screens/Settings/app_preference_screen.dart';
import 'package:crm/Services/profile_service.dart';
import 'package:crm/Services/preference_service.dart';
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
  String _mobile = '...';
  String _location = 'Fetching location...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Load from cache first for instant UI
    final cachedName = await PreferenceService.getName();
    final cachedMobile = await PreferenceService.getMobile();

    if (mounted) {
      setState(() {
        if (cachedName != null) _name = cachedName;
        if (cachedMobile != null) _mobile = cachedMobile;
      });
    }

    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // Get coordinates from PreferenceService
        String lt = prefs.getString('lt') ?? '';
        String ln = prefs.getString('ln') ?? '';

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
      // backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack ?? () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF26A69A)),
            )
          : Column(
              children: [
                // Profile Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Color(0xFF465583)),
                  child: Row(
                    children: [
                      // Profile Image
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF871A1A),
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: AssetImage('assets/images/user_avatar.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // User Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AccountSettingScreen(
                                              isEditing: true,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Row(
                                    children: [
                                      Text(
                                        'Edit',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(
                                        Icons.edit,
                                        color: Colors.white70,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _mobile,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _location,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                              ),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AccountSettingScreen(
                                              isEditing: false,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'View Full Profile',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Active Badge (now specifically placed here)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Active',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor),

                // Settings List
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildSettingItem(
                        icon: 'assets/icons/acc_setting.png',
                        title: 'Account Setting',
                        iconColor: const Color(0xFF26A69A),
                      ),
                      _buildSettingItem(
                        icon: 'assets/icons/noti.png',
                        title: 'Notification & Alerts',
                        iconColor: Colors.orange,
                      ),
                      _buildSettingItem(
                        icon: 'assets/icons/help.png',
                        title: 'Help & Support',
                        iconColor: Colors.blue,
                      ),
                      _buildSettingItem(
                        icon: 'assets/icons/security.png',
                        title: 'Security & Settings',
                        iconColor: Colors.orangeAccent,
                      ),
                      _buildSettingItem(
                        icon: Icons.settings_applications_outlined,
                        title: 'App Preference',
                        iconColor: const Color(0xFF26A69A),
                        isLastItem: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }



  Widget _buildSettingItem({
    required dynamic icon,
    required String title,
    required Color iconColor,
    bool isLastItem = false,
  }) {
    Widget leadingWidget;
    if (icon is IconData) {
      leadingWidget = Icon(icon, color: iconColor, size: 26);
    } else if (icon is String) {
      leadingWidget = Image.asset(icon, width: 26, height: 26);
    } else if (icon is ImageProvider) {
      leadingWidget = Image(image: icon, width: 26, height: 26);
    } else {
      leadingWidget = Icon(Icons.error, color: iconColor, size: 26);
    }

    return Column(
      children: [
        ListTile(
          leading: leadingWidget,
          title: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          onTap: () {
            if (title == 'Account Setting') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AccountSettingScreen()),
              );
            } else if (title == 'Notification & Alerts') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationAlertScreen(),
                ),
              );
            } else if (title == 'Help & Support') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
              );
            } else if (title == 'Security & Settings') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SecuritySettingsScreen(),
                ),
              );
            } else if (title == 'App Preference') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AppPreferenceScreen()),
              );
            }
          },
        ),
        Divider(
          height: 1,
          thickness: 1,
          indent: 20,
          endIndent: 20,
          color: Theme.of(context).dividerColor,
        ),
      ],
    );
  }
}
