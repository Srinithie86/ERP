import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:service_ticket/core/size_utils.dart';
import '../screens/login/login_screen.dart';
import '../core/app_colors.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({
    super.key,
    required this.profile,
    this.onProfileTap,
    this.onJobsTap,
    this.onSparesTap,
    this.onDispatchTap,
    this.onAllTicketsTap,
    this.onStandbyTap,
    this.onToolkitTap,
    this.onEodTap,
    this.onEvaluationTap,
    this.onAllDispatchTap,
    this.onRatingTap,
    this.onHelpSupportTap,
  });

  final Map<String, dynamic> profile;
  final VoidCallback? onProfileTap;
  final VoidCallback? onJobsTap;
  final VoidCallback? onSparesTap;
  final VoidCallback? onDispatchTap;
  final VoidCallback? onAllTicketsTap;
  final VoidCallback? onStandbyTap;
  final VoidCallback? onToolkitTap;
  final VoidCallback? onEodTap;
  final VoidCallback? onEvaluationTap;
  final VoidCallback? onAllDispatchTap;
  final VoidCallback? onRatingTap;
  final VoidCallback? onHelpSupportTap;

  @override
  Widget build(BuildContext context) {
    final avatarBytes = profile['avatarBytes'] as Uint8List?;
    final name = (profile['name']?.toString() ?? '').isEmpty
        ? 'N/A'
        : profile['name'];
    final phone = (profile['phone']?.toString() ?? '').isEmpty
        ? 'N/A'
        : profile['phone'];

    return Drawer(
      width: 286.w,
      shape: const RoundedRectangleBorder(),
      backgroundColor: Colors.white,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(18.w, 22.h, 18.w, 18.h),
            decoration: const BoxDecoration(
              color: Color(0xFF26A69A),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 68.w,
                        height: 68.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: avatarBytes != null
                              ? Image.memory(avatarBytes, fit: BoxFit.cover)
                              : Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF4F72E8),
                                        Color(0xFF2440A2),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _initialsFromName(name),
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        right: -1.w,
                        bottom: -1.h,
                        child: Container(
                          width: 22.w,
                          height: 22.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2F4FB4),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.remove_red_eye_outlined,
                            size: 11.sp,
                            color: const Color(0xFF2F4FB4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    phone,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _DrawerMenuTile(
                        icon: Icons.person_outline_rounded,
                        label: 'Profile',
                        onTap: onProfileTap,
                      ),
                      _DrawerMenuTile(
                        icon: Icons.work_outline_rounded,
                        label: 'Jobs',
                        onTap: onJobsTap,
                      ),
                      _DrawerMenuTile(
                        icon: Icons.inventory_2_outlined,
                        label: 'Spares',
                        onTap: onSparesTap,
                      ),
                      _DrawerMenuTile(
                        icon: Icons.local_shipping_outlined,
                        label: 'Dispatch',
                        onTap: onDispatchTap,
                      ),
                      _DrawerMenuTile(
                        icon: Icons.assignment_outlined,
                        label: 'All Tickets',
                        onTap: onAllTicketsTap,
                      ),
                      _DrawerMenuTile(
                        icon: Icons.local_shipping_outlined,
                        label: 'All Dispatch',
                        onTap: onAllDispatchTap,
                      ),
                      _DrawerMenuTile(
                        icon: Icons.power_settings_new_rounded,
                        label: 'Standby',
                        onTap: onStandbyTap,
                      ),
                      _DrawerMenuTile(
                        icon: Icons.inventory_2_outlined,
                        label: 'Toolkit',
                        onTap: onToolkitTap,
                      ),
                      _DrawerMenuTile(
                        icon: Icons.analytics_outlined,
                        label: 'EOD',
                        onTap: onEodTap,
                      ),
                      _DrawerMenuTile(
                        icon: Icons.assignment_turned_in_outlined,
                        label: 'Employee Evaluation',
                        onTap: onEvaluationTap,
                      ),
                      // _DrawerMenuTile(
                      //   icon: Icons.star_border_rounded,
                      //   label: 'Rating & Reviews',
                      //   onTap: onRatingTap,
                      // ),
                      _DrawerMenuTile(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        onTap: onHelpSupportTap,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 42.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog<void>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dialogContext),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginScreen(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: const Text(
                                  'Logout',
                                  style: TextStyle(color: Color(0xFFE11D48)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94B61),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                      ),
                      icon: Icon(Icons.logout_rounded, size: 18.sp),
                      label: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuTile extends StatelessWidget {
  const _DrawerMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                SizedBox(
                  width: 22.w,
                  child: Icon(icon, size: 20.sp, color: AppColors.primary),
                ),
                SizedBox(width: 14.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF182033),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 0.8, color: Color(0xFFDADDE6)),
      ],
    );
  }
}

String _initialsFromName(String name) {
  final clean = name.trim().replaceAll(RegExp(r'\s+'), '');
  if (clean.isEmpty) return '--';
  if (clean.length == 1) return clean.toUpperCase();
  return clean.substring(0, 2).toUpperCase();
}
