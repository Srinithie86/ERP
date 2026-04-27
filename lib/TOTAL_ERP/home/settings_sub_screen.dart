import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import 'security_pin_screen.dart';
import 'package:erp_localization/erp_localization.dart';
import '../login/sign_in_screen.dart';
import 'switch_account_screen.dart';
import '../../theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsSubScreen extends StatefulWidget {
  const SettingsSubScreen({super.key});

  @override
  State<SettingsSubScreen> createState() => _SettingsSubScreenState();
}

class _SettingsSubScreenState extends State<SettingsSubScreen> {
  bool _pinEnabled = false;
  String _userName = 'SMM POWER SOLUTION';
  String _userEmail = 'smmpower@gmail.com';
  String _profilePhoto = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pinEnabled = prefs.getString('app_pin') != null;
      _userName = prefs.getString('name') ?? 'SMM POWER SOLUTION';
      _userEmail = prefs.getString('email') ?? (prefs.getString('username') ?? 'smmpower@gmail.com');
      _profilePhoto = prefs.getString('profile_photo') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // const tealHeaderColor = Color(0xFF006D5B); // Deep teal from image
    const tealHeaderColor = Color(0xFF00796B); // A slightly brighter teal for premium look
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

    return Material(
      color: backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32.r),
            bottomLeft: Radius.circular(32.r),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // Header Section
            _buildHeader(tealHeaderColor),
  
            // Settings List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Group
                    _buildSectionTitle(AppLocalization.of('Account')),
                    SizedBox(height: 12.h),
                    _buildSettingsGroup([
                      _buildSettingsTile(
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFFFFE0E0),
                        iconFgColor: const Color(0xFFFF5252),
                        title: AppLocalization.of('Personal Information'),
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.lock_outline_rounded,
                        iconColor: const Color(0xFFE8F5E9),
                        iconFgColor: const Color(0xFF4CAF50),
                        title: AppLocalization.of('App Lock Pin'),
                        isSwitch: true,
                        switchValue: _pinEnabled,
                        onSwitchChanged: (val) async {
                          if (val) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SecurityPinScreen(isSetup: true),
                              ),
                            );
                            if (result == true) { setState(() => _pinEnabled = true); }
                          } else {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SecurityPinScreen(isTurningOff: true),
                              ),
                            );
                            if (result == false) { setState(() => _pinEnabled = false); }
                          }
                        },
                      ),
                    ]),
  
                    SizedBox(height: 24.h),
  
                    // Preference Group
                    _buildSectionTitle(AppLocalization.of('Preference')),
                    SizedBox(height: 12.h),
                    _buildSettingsGroup([
                      _buildSettingsTile(
                        icon: Icons.dark_mode_outlined,
                        iconColor: const Color(0xFFF5F5F5),
                        iconFgColor: const Color(0xFF616161),
                        title: AppLocalization.of('Dark Mode'),
                        isSwitch: true,
                        switchValue: context.watch<ThemeProvider>().isDarkMode,
                        onSwitchChanged: (val) {
                          context.read<ThemeProvider>().toggleTheme();
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFFFFF9C4),
                        iconFgColor: const Color(0xFFFBC02D),
                        title: AppLocalization.of('Language'),
                        trailingText: _getLangName(localeNotifier.value.languageCode),
                        onTap: _showLanguagePicker,
                      ),
                    ]),
  
                    SizedBox(height: 24.h),
  
                    // Support Group
                    _buildSectionTitle(AppLocalization.of('Support')),
                    SizedBox(height: 12.h),
                    _buildSettingsGroup([
                      _buildSettingsTile(
                        icon: Icons.help_outline_rounded,
                        iconColor: const Color(0xFFE1F5FE),
                        iconFgColor: const Color(0xFF03A9F4),
                        title: AppLocalization.of('Help Center'),
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildSettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        iconColor: const Color(0xFFE8EAF6),
                        iconFgColor: const Color(0xFF3F51B5),
                        title: AppLocalization.of('Term & Policies'),
                        onTap: () {},
                      ),
                    ]),
  
                    SizedBox(height: 40.h),
  
                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _handleLogout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2D2D),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: Colors.red.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          AppLocalization.of('Logout'),
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color bgColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, MediaQuery.of(context).padding.top + 20.h, 24.w, 30.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(0.r)),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 35.r,
                  backgroundColor: Colors.white,
                  backgroundImage: _profilePhoto.isNotEmpty ? NetworkImage(_profilePhoto) : null,
                  child: _profilePhoto.isEmpty
                      ? Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Image.asset('assets/images/logo.png', fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(Icons.business, color: bgColor, size: 25.sp),
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(width: 16.w),
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _userName.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      _userEmail,
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 6.h),
                     InkWell(
                      onTap: () {
                        _showSwitchAccountPopup(context);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppLocalization.of('Switch Account'),
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 18.sp),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Close button for drawer
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: Colors.white, size: 28.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconFgColor,
    required String title,
    String? trailingText,
    bool isSwitch = false,
    bool switchValue = false,
    ValueChanged<bool>? onSwitchChanged,
    VoidCallback? onTap,
  }) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: isSwitch ? null : onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(icon, color: iconFgColor, size: 20.sp),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      trailing: isSwitch
          ? Transform.scale(
              scale: 0.8,
              child: Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeColor: Colors.white,
                activeTrackColor: Colors.black87,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (trailingText != null)
                  Text(
                    trailingText,
                    style: GoogleFonts.outfit(
                      color: Colors.grey,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                SizedBox(width: 8.w),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey.shade400, size: 14.sp),
              ],
            ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60.w,
      endIndent: 16.w,
      color: Colors.grey.withValues(alpha: 0.1),
    );
  }

  void _showSwitchAccountPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: const SwitchAccountPopup(isModal: true),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalization.of('Select Language'),
                style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              _buildLangItem('English', 'en'),
              _buildLangItem('Tamil (தமிழ்)', 'ta'),
              _buildLangItem('Hindi (हिन्दी)', 'hi'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLangItem(String name, String code) {
    return ListTile(
      title: Text(name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
      trailing: localeNotifier.value.languageCode == code 
          ? const Icon(Icons.check_circle, color: Color(0xFF00796B)) 
          : null,
      onTap: () {
        localeNotifier.value = Locale(code);
        Navigator.pop(context);
        setState(() {});
      },
    );
  }

  String _getLangName(String code) {
    switch (code) {
      case 'ta': return 'Tamil';
      case 'hi': return 'Hindi';
      default: return 'English';
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
        (route) => false,
      );
    }
  }
}
