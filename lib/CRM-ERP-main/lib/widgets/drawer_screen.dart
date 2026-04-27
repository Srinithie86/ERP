import 'package:crm/Screens/Meeting/meeting_screen.dart';
import 'package:crm_admin_app/Screens/dashboard_screen.dart' as admin_app;
import 'package:crm_admin_app/Screens/MenuManagement/Campaign_center/campaign_center.dart';
import 'package:crm_admin_app/Screens/MenuManagement/LeadManagement/lead_enquiry.dart';
import 'package:crm_admin_app/Screens/MenuManagement/AssignManagement/assign_to.dart';
import 'package:crm_admin_app/Screens/MenuManagement/CallManagement/call_summary.dart';
import 'package:crm_admin_app/Screens/MenuManagement/MeetingManagement/meeting_visit.dart' as admin_meeting;
import 'package:crm_admin_app/Screens/MenuManagement/FollowupManagement/follow_up.dart' as admin_followup;
import 'package:flutter/material.dart';
import 'package:crm/Screens/Reports/report_screen.dart';
import 'package:crm/Services/profile_service.dart';
import '../Screens/Home/dashboard_screen.dart';
import '../Screens/Settings/account_setting_screen.dart';
import '../Screens/Settings/setting_screen.dart';
import '../Screens/Leads/leads_screen.dart';
import '../Screens/Deals/deal_lost.dart';
import '../Screens/Deals/deal_won.dart';
import '../Services/preference_service.dart';

class DrawerScreen extends StatefulWidget {
  const DrawerScreen({super.key});

  @override
  State<DrawerScreen> createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  bool _isFollowUpExpanded = false;
  bool _isDealsExpanded = false;
  bool _isAdminExpanded = false;

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
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Teal Header matching the design image
          Container(
            width: double.infinity,
            height: 100,
            padding: const EdgeInsets.fromLTRB(20, 40, 10, 0),
            color: const Color(0xFF26A69A),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL CRM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Drawer Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(
                  icon: Image.asset(
                    'assets/icons/leads.png',
                    color: const Color(0xFF26A69A),
                  ),
                  title: 'Leads',
                ),
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
                    padding: const EdgeInsets.only(left: 16),
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
                    padding: const EdgeInsets.only(left: 16),
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
                _buildDrawerItem(
                  icon: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Color(0xFF26A69A),
                  ),
                  title: 'CRM Admin',
                  hasTrailing: true,
                  isExpanded: _isAdminExpanded,
                  onTap: () {
                    setState(() {
                      _isAdminExpanded = !_isAdminExpanded;
                    });
                  },
                ),
                if (_isAdminExpanded) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      children: [
                        _buildSubMenuItem(
                          icon: const Icon(
                            Icons.dashboard_outlined,
                            color: Color(0xFF26A69A),
                          ),
                          title: 'Admin Dashboard',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const admin_app.DashboardScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSubMenuItem(
                          icon: const Icon(
                            Icons.person_add_alt_1_outlined,
                            color: Color(0xFF26A69A),
                          ),
                          title: 'Leads',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LeadEnquiryScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSubMenuItem(
                          icon: const Icon(
                            Icons.business_center_outlined,
                            color: Color(0xFF26A69A),
                          ),
                          title: 'Opportunities',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CampaignCenterScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSubMenuItem(
                          icon: const Icon(
                            Icons.people_alt_outlined,
                            color: Color(0xFF26A69A),
                          ),
                          title: 'Contacts',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AssignToScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSubMenuItem(
                          icon: const Icon(
                            Icons.bar_chart_outlined,
                            color: Color(0xFF26A69A),
                          ),
                          title: 'Reports',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CallSummaryScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSubMenuItem(
                          icon: const Icon(
                            Icons.groups_outlined,
                            color: Color(0xFF26A69A),
                          ),
                          title: 'Admin Meetings',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const admin_meeting.MeetingVisitScreen(),
                              ),
                            );
                          },
                        ),
                        _buildSubMenuItem(
                          icon: const Icon(
                            Icons.replay_circle_filled_outlined,
                            color: Color(0xFF26A69A),
                          ),
                          title: 'Admin Follow-ups',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const admin_followup.FollowUpScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
                _buildDrawerItem(
                  icon: Image.asset(
                    'assets/icons/reports.png',
                    color: const Color(0xFF26A69A),
                  ),
                  title: 'Report',
                ),
                _buildDrawerItem(
                  icon: Image.asset(
                    'assets/icons/settings.png',
                    color: const Color(0xFF26A69A),
                  ),
                  title: 'Settings',
                ),
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
    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: SizedBox(width: 22, height: 22, child: icon),
      ),
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
