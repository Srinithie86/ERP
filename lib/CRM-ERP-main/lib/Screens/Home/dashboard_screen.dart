import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Screens/Leads/leads_screen.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Screens/Home/notification_screen.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Screens/Deals/deals_screen.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Screens/Follows/follow_up_screen.dart';

import 'package:erp_smart/CRM-ERP-main/lib/Screens/Meeting/add_meeting_screen.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Screens/Meeting/meeting_screen.dart';
export '../Deals/deals_screen.dart';
export '../Follows/follow_up_screen.dart';
export '../Meeting/meeting_screen.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Services/profile_service.dart';
import '../../Widgets/custom_bottom_nav.dart';
import '../../Widgets/drawer_screen.dart';
import '../EnquiryScreen/enquiry_screen.dart';
import '../ReferralScreen/referral_screen.dart';
import '../Leads/add_lead_screen.dart';
import '../../Services/preference_service.dart';
import '../Settings/account_setting_screen.dart';
import 'package:erp_smart/utils/app_navigation.dart';
import 'package:erp_smart/utils/widgets/dynamic_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  final int initialIndex;
  final int followUpInitialIndex;
  final bool isEmbedded;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  final Widget? drawer;

  const DashboardScreen({
    super.key,
    this.initialIndex = 0,
    this.followUpInitialIndex = 0,
    this.isEmbedded = false,
    this.scaffoldKey,
    this.drawer,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  List<bool> _activatedTabs = [true, false, false, false];
  bool _isFabExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
      if (_isFabExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    if (_currentIndex >= 0 && _currentIndex < _activatedTabs.length) {
      _activatedTabs[_currentIndex] = true;
    }
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
    _loadMenuData();
  }

  List<Map<String, dynamic>> _crmMenus = [];

  Future<void> _loadMenuData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('user_menu_data');
      if (saved != null) {
        final decoded = json.decode(saved);
        Map<String, dynamic> menuData = {};
        if (decoded is Map && decoded.containsKey('menu')) {
          menuData = Map<String, dynamic>.from(decoded['menu']);
        } else if (decoded is Map) {
          menuData = Map<String, dynamic>.from(decoded);
        }

        String? crmKey;
        for (final key in menuData.keys) {
          if (key.trim().toUpperCase() == "CRM") crmKey = key;
        }
        if (crmKey != null && menuData[crmKey] is List) {
          if (mounted) {
            setState(() {
              _crmMenus = List<Map<String, dynamic>>.from(menuData[crmKey]);
            });
          }
        }
      }
    } catch (e) {
      debugPrint("CRM Dashboard => Load Error: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: widget.isEmbedded ? widget.scaffoldKey : null,
      drawer: widget.drawer ?? const DynamicDrawer(moduleName: "CRM"),
      appBar: _currentIndex == 0
          ? AppBar(
              backgroundColor: const Color(0xFF26A69A),
              elevation: 0,
              toolbarHeight: 0,
            )
          : null,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              _DashboardContent(
                crmMenus: _crmMenus,
                scaffoldKey: widget.scaffoldKey,
              ),
              _activatedTabs[1]
                  ? FollowUpScreen(
                      initialIndex: widget.followUpInitialIndex,
                      onBack: () => setState(() => _currentIndex = 0),
                    )
                  : const SizedBox.shrink(),
              _activatedTabs[2]
                  ? MeetingVisitScreen(
                      onBack: () => setState(() => _currentIndex = 0),
                    )
                  : const SizedBox.shrink(),
              _activatedTabs[3]
                  ? DealsScreen(onBack: () => setState(() => _currentIndex = 0))
                  : const SizedBox.shrink(),
            ],
          ),
          if (_currentIndex == 0)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _expandAnimation,
                builder: (context, child) {
                  return Stack(
                    children: [
                      if (_isFabExpanded)
                        GestureDetector(
                          onTap: _toggleFab,
                          behavior: HitTestBehavior.opaque,
                          child: Container(color: Colors.transparent),
                        ),
                      if (_expandAnimation.value > 0) ...[
                        // Meeting - Top Right
                        Positioned(
                          bottom: 16.0 +
                              (screenWidth * 0.015) +
                              (screenWidth * 0.25) * _expandAnimation.value,
                          right: 16.0 + (screenWidth * 0.015),
                          child: Opacity(
                            opacity: _expandAnimation.value,
                            child: Transform.scale(
                              scale: _expandAnimation.value,
                              child: _buildFabAction(
                                icon: Icons.groups,
                                label: 'Meeting',
                                color: const Color(0xFF26A69A),
                                onTap: () {
                                  _toggleFab();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddMeetingScreen(),
                                    ),
                                  );
                                },
                                screenWidth: screenWidth,
                              ),
                            ),
                          ),
                        ),
                        // Lead - Top Left
                        Positioned(
                          bottom: 16.0 +
                              (screenWidth * 0.015) +
                              (screenWidth * 0.25) * _expandAnimation.value,
                          right: 16.0 +
                              (screenWidth * 0.015) +
                              (screenWidth * 0.22) * _expandAnimation.value,
                          child: Opacity(
                            opacity: _expandAnimation.value,
                            child: Transform.scale(
                              scale: _expandAnimation.value,
                              child: _buildFabAction(
                                icon: Icons.person_add_alt_1,
                                label: 'Lead',
                                color: const Color(0xFF26A69A),
                                onTap: () {
                                  _toggleFab();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AddLeadScreen(isEnquiry: false),
                                    ),
                                  );
                                },
                                screenWidth: screenWidth,
                              ),
                            ),
                          ),
                        ),
                        // Enquiry - Bottom Left
                        Positioned(
                          bottom: 16.0 + (screenWidth * 0.015),
                          right: 16.0 +
                              (screenWidth * 0.015) +
                              (screenWidth * 0.25) * _expandAnimation.value,
                          child: Opacity(
                            opacity: _expandAnimation.value,
                            child: Transform.scale(
                              scale: _expandAnimation.value,
                              child: _buildFabAction(
                                icon: Icons.headset_mic,
                                label: 'Enquiry',
                                color: const Color(0xFF26A69A),
                                onTap: () {
                                  _toggleFab();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const AddLeadScreen(isEnquiry: true),
                                    ),
                                  );
                                },
                                screenWidth: screenWidth,
                              ),
                            ),
                          ),
                        ),
                      ],
                      // Main Button
                      Positioned(
                        bottom: 16.0,
                        right: 16.0,
                        child: SizedBox(
                          height: screenWidth * 0.16,
                          width: screenWidth * 0.16,
                          child: FloatingActionButton(
                            onPressed: _toggleFab,
                            backgroundColor: const Color(0xFF26A69A),
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: Transform.rotate(
                              angle: _expandAnimation.value *
                                  (3.14159 / 4), // Rotate 45 degrees
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: screenWidth * 0.08,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _activatedTabs[index] = true;
          });
        },
      ),
    );
  }

  Widget _buildFabAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double screenWidth,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenWidth * 0.13,
        width: screenWidth * 0.13,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: screenWidth * 0.04),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.02,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatefulWidget {
  final List<Map<String, dynamic>> crmMenus;
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const _DashboardContent({required this.crmMenus, this.scaffoldKey});

  @override
  State<_DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<_DashboardContent> {
  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final cachedName = await PreferenceService.getName();
    if (mounted && cachedName != null) {
      setState(() {
        _userName = cachedName;
      });
    }

    final profileData = await ProfileService.fetchProfileData();
    if (mounted && profileData != null) {
      setState(() {
        _userName = profileData['name'] ?? _userName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Header (Fixed/Sticky)
        Container(
          padding: EdgeInsets.only(bottom: 8.h),
          decoration: const BoxDecoration(
            color: Color(0xFF26A69A),
          ),
          child: Column(
            children: [
              // Top Custom App Bar
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0.h),
                child: Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.menu, color: Colors.white, size: 28),
                      onPressed: () {
                        if (widget.scaffoldKey != null) {
                          widget.scaffoldKey!.currentState?.openDrawer();
                        } else {
                          Scaffold.of(context).openDrawer();
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'CRM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Scrollable Body Content
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard',
                              style: GoogleFonts.outfit(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF26A69A),
                              ),
                            ),
                            Text(
                              'Customer Management Hub',
                              style: GoogleFonts.outfit(
                                fontSize: 16.sp,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF26A69A),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today,
                                color: Colors.white, size: 16.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Sort by Date',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Management Hub Icons (Prioritize Lead, Enquiry, Referral)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      _buildMainActionCard(
                        context: context,
                        label: 'Lead',
                        icon: Icons.person,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF5263), Color(0xFFFF8A95)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LeadsScreen())),
                      ),
                      SizedBox(width: 12.w),
                      _buildMainActionCard(
                        context: context,
                        label: 'Enquiry',
                        icon: Icons.forum,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6200EA), Color(0xFF9575CD)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const EnquiryScreen())),
                      ),
                      SizedBox(width: 12.w),
                      _buildMainActionCard(
                        context: context,
                        label: 'Referral',
                        icon: Icons.group_add,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00BFA5), Color(0xFF64FFDA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReferralScreen())),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Today Follow-up Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    'Today Follow-up',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      _buildFollowUpVibrantCard(
                        title: 'Today',
                        count: '30',
                        subtitle: 'Follow up',
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8A80), Color(0xFFFF5252)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        iconPath: 'assets/icons/today.png',
                        icon: Icons.calendar_month,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const FollowUpScreen(initialIndex: 0))),
                      ),
                      SizedBox(width: 12.w),
                      _buildFollowUpVibrantCard(
                        title: 'Missed',
                        count: '30',
                        subtitle: 'Follow up',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9575CD), Color(0xFF673AB7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        iconPath: 'assets/icons/missed.png',
                        icon: Icons.notifications_paused,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FollowUpScreen(
                                    initialIndex: 1, isMissed: true))),
                      ),
                      SizedBox(width: 12.w),
                      _buildFollowUpVibrantCard(
                        title: 'New',
                        count: '30',
                        subtitle: 'Follow up',
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4DB6AC), Color(0xFF00897B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        iconPath: 'assets/icons/new.png',
                        icon: Icons.person_search,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const FollowUpScreen(initialIndex: 2))),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),



                // Lead Pipeline Status Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'January Month Lead Pipeline Status',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildProgressItem(
                          label: 'New Leads',
                          percentage: 40,
                          color: const Color(0xFF4285F4),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressItem(
                          label: 'In Progress',
                          percentage: 25,
                          color: const Color(0xFFFFCA28),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressItem(
                          label: 'Won Deals',
                          percentage: 20,
                          color: const Color(0xFF66BB6A),
                        ),
                        const SizedBox(height: 16),
                        _buildProgressItem(
                          label: 'Lost Deals',
                          percentage: 15,
                          color: const Color(0xFFEF5350),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionCard({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 115.h,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 35.sp, color: Colors.white),
              SizedBox(height: 12.h),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpVibrantCard({
    required String title,
    required String count,
    required String subtitle,
    required Gradient gradient,
    required String iconPath,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 100.h,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle),
                  child: icon != null
                      ? Icon(icon, color: Colors.white, size: 14.sp)
                      : Image.asset(iconPath,
                          height: 14.h, width: 14.w, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp)),
                    const Spacer(),
                    Text(count,
                        style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: GoogleFonts.outfit(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 11.sp)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem({
    required String label,
    required int percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10.w,
              height: 10.h,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black54,
                ),
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8.h,
          ),
        ),
      ],
    );
  }
}
