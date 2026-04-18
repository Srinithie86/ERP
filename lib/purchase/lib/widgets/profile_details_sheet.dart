import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void showProfileDetailsSheet(BuildContext context, {bool isDark = false}) async {
  const primaryTeal = Color(0xFF26A69A);
  final prefs = await SharedPreferences.getInstance();
  
  final name = prefs.getString('name') ?? 'Smart ERP User';
  final email = prefs.getString('email') ?? (prefs.getString('username') ?? 'N/A');
  final uid = prefs.getString('uid') ?? 'N/A';
  final cid = prefs.getString('cid') ?? 'N/A';
  final photo = prefs.getString('profile_photo') ?? '';
  final phone = prefs.getString('mobile') ?? 'N/A';

  if (!context.mounted) { return; }

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 24.h),
          
          // Profile Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryTeal.withValues(alpha: 0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 45.r,
              backgroundColor: primaryTeal.withValues(alpha: 0.1),
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty 
                ? Icon(Icons.person_rounded, color: primaryTeal, size: 45.sp)
                : null,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            name,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF1A1F71),
            ),
          ),
          Text(
            email,
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 32.h),
          
          // Details List
          _buildDetailItem(context, Icons.badge_outlined, 'User ID', uid, isDark),
          _buildDetailItem(context, Icons.business_outlined, 'Company ID', cid, isDark),
          _buildDetailItem(context, Icons.phone_outlined, 'Phone', phone, isDark),
          
          SizedBox(height: 24.h),
          
          // Close Button
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Close',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDetailItem(BuildContext context, IconData icon, String label, String value, bool isDark) {
  return Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF26A69A).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: const Color(0xFF26A69A), size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 11.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 15.sp,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
