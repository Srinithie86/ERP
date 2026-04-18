import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_details_sheet.dart';

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
    const tealColor = Color(0xFF26A69A);
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
            if (showBackButton)
              IconButton(
                onPressed: onBackTap ?? () => Navigator.of(context).pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 20.sp,
                ),
              )
            else
              SizedBox(width: 8.w), // Replaced menu button with small spacing
            
            SizedBox(width: 12.w),
            
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
                      fontSize: 18.sp,
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
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                ],
              ),
            ),
            
            // Render custom actions first
            if (actions != null)
              ...?actions
            else 
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: isDark ? Colors.white : Colors.black87,
                  size: 26.sp,
                ),
                onPressed: () {},
              ),

            // Profile Icon (Profile Details Trigger) - ALWAYS VISIBLE
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onProfileTap ?? () => showProfileDetailsSheet(context, isDark: isDark),
              child: CircleAvatar(
                radius: 16.r,
                backgroundColor: tealColor.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person_rounded,
                  color: tealColor,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h);
}

