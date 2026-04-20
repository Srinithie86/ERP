import 'package:crm/Meeting/meeting_screen.dart';
import 'package:flutter/material.dart';
import 'package:crm/Reports/report_screen.dart';
import 'package:crm/services/profile_service.dart';
import 'package:crm_admin_app/Screens/dashboard_screen.dart' as admin_app;
import '../Home/dashboard_screen.dart';
import '../Settings/account_setting_screen.dart';
import '../Settings/setting_screen.dart';
import '../Leads/leads_screen.dart';
import '../Deals/deal_lost.dart';
import '../Deals/deal_won.dart';
import '../utils/preference_service.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  bool _isFollowUpExpanded = false;
  bool _isDealsExpanded = false;

  String _name = 'Loading...';
  String _email = '...';
  String _mobile = '...';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Load from cache first for instant UI response
    final String? cachedName = await PreferenceService.getName();
    final String? cachedEmail = await PreferenceService.getEmail();
    final String? cachedMobile = await PreferenceService.getMobile();

    if (mounted) {
      setState(() {
        if (cachedName != null) _name = cachedName;
        if (cachedEmail != null) _email = cachedEmail;
        if (cachedMobile != null) _mobile = cachedMobile;
      });
    }

    // Then fetch from API for updates
    final profileData = await ProfileService.fetchProfileData();

    if (mounted && profileData != null) {
      setState(() {
        _name = profileData['name']?.toString() ?? _name;
        _email = profileData['email']?.toString() ?? _email;
        _mobile = profileData['mobile']?.toString() ?? _mobile;
      });
      debugPrint("DrawerScreen: Profile updated from API: $_name");
    } else if (profileData == null) {
      debugPrint("DrawerScreen: Profile fetch returned null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 30,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF26A69A),
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(100),
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                          'assets/images/user_avatar.png',
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccountSettingScreen(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit_note,
                            color: Color(0xFF26A69A),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                  ),
                ),
                Text(
                  _mobile,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Image.asset(
                    'assets/icons/leads.png',
                    color: const Color(0xFF26A69A),
                  ),
                  title: 'Leads',
                ),
                _buildDivider(),
                _buildDrawerItem(
                  icon: Image.asset(
                    'assets/icons/follows.png',
                    color: const Color(0xFF26A69A),
                  ),
                  title: 'Follow Up',
                  hasTrailing: true,
                  isExpanded: _isFollowUpExpanded,
                  onTap: () {
                    setState(() {
                      _isFollowUpExpanded = !_isFollowUpExpanded;
                    });
                  },
                ),
                if (_isFollowUpExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        _buildSubMenuItem(
                          icon: Image.asset(
                            'assets/icons/follows.png',
                            color: const Color(0xFF26A69A),
                          ),
                          title: 'Today Follow up',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(
                                  initialIndex: 1,
                                  followUpInitialIndex: 0,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSubMenuItem(
                          icon: Image.asset(
                            'assets/icons/missed1.png',
                            color: const Color(0xFF26A69A),
                          ),
                          title: 'Missed Follow up',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(
                                  initialIndex: 1,
                                  followUpInitialIndex: 3,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),
                        _buildSubMenuItem(
                          icon: Image.asset(
                            'assets/icons/upcoming.png',
                            color: const Color(0xFF26A69A),
                          ),
                          title: 'Upcoming Follow up',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(
                                  initialIndex: 1,
                                  followUpInitialIndex: 2,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSubMenuItem(
                          icon: Image.asset(
                            'assets/icons/reshedule.png',
                            color: const Color(0xFF26A69A),
                          ),
                          title: 'Re Follow up',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DashboardScreen(
                                  initialIndex: 1,
                                  followUpInitialIndex: 1,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                _buildDivider(),
                _buildDrawerItem(
                  icon: Image.asset(
                    'assets/icons/meeting1.png',
                    color: const Color(0xFF26A69A),
                  ),
                  title: 'Meeting / Visit',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MeetingVisitScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildDrawerItem(
                  icon: Image.asset(
                    'assets/icons/deals1.png',
                    color: const Color(0xFF26A69A),
                  ),
                  title: 'Deals',
                  hasTrailing: true,
                  isExpanded: _isDealsExpanded,
                  onTap: () {
                    setState(() {
                      _isDealsExpanded = !_isDealsExpanded;
                    });
                  },
                ),
                if (_isDealsExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Column(
                      children: [
                        _buildSubMenuItem(
                          icon: Image.asset(
                            'assets/icons/deals1.png',
                            color: const Color(0xFF26A69A),
                          ),
                          title: 'Deal Won',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DealWonScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSubMenuItem(
                          icon: Image.asset(
                            'assets/icons/deal-lost.png',
                            color: const Color(0xFF26A69A),
                          ),
                          title: 'Deal lost',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const DealLostScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                _buildDivider(),
                _buildDrawerItem(
                  icon: Image.asset(
                    'assets/icons/reports.png',
                    color: const Color(0xFF26A69A),
                  ),
                  title: 'Report',
                ),
                _buildDivider(),
                _buildDrawerItem(
                  icon: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Color(0xFF26A69A),
                  ),
                  title: 'CRM Admin',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const admin_app.DashboardScreen(),
                      ),
                    );
                  },
                ),
                _buildDivider(),
                _buildDrawerItem(
                  icon: Image.asset(
                    'assets/icons/settings.png',
                    color: const Color(0xFF26A69A),
                  ),
                  title: 'Settings',
                ),
                _buildDivider(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required Widget icon,
    required String title,
    bool hasTrailing = false,
    bool isExpanded = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: SizedBox(width: 24, height: 24, child: icon),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyLarge?.color,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: hasTrailing
          ? Icon(
              isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
              color: const Color(0xFF26A69A),
            )
          : null,
      onTap:
          onTap ??
          () {
            if (title == 'Leads') {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeadsScreen()),
              );
            } else if (title == 'Deal Won') {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DealWonScreen()),
              );
            } else if (title == 'Deal lost') {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DealLostScreen()),
              );
            } else if (title == 'Meeting / Visit') {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeetingVisitScreen()),
              );
            } else if (title == 'Settings') {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingScreen()),
              );
            } else if (title == 'Report') {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportScreen()),
              );
            }
          },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
    );
  }

  Widget _buildSubMenuItem({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: SizedBox(width: 24, height: 24, child: icon),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: Theme.of(context).dividerColor,
      height: 1,
      thickness: 1,
      indent: 24,
      endIndent: 24,
    );
  }
}
