import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_details_sheet.dart';
import '../../theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'language_selector.dart';
import 'location_indicator.dart';

class UniversalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final VoidCallback? onProfileTap;
  final List<Widget>? actions;
  final bool isDark;
  final VoidCallback? onMenuPressed;

  const UniversalAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBackTap,
    this.onProfileTap,
    this.actions,
    this.isDark = false,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1F71);
    
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            if (showBackButton) ...[
              IconButton(
                onPressed: onBackTap ?? () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 8.w),
            ],
            
            Expanded(
              child: GestureDetector(
                onTap: onMenuPressed,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      height: 32.h,
                      errorBuilder: (_, __, ___) => Icon(Icons.business, size: 30.sp, color: const Color(0xFF26A69A)),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.outfit(
                              color: titleColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 16.sp,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle ?? '',
                              style: GoogleFonts.outfit(
                                color: Colors.grey,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            LocationIndicator(isDark: isDark),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h);
}
