import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LocationPermissionDialog extends StatelessWidget {
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;
  final bool isPermanent;
  final bool isServiceDisabled;

  const LocationPermissionDialog({
    super.key,
    required this.onAllow,
    required this.onOpenSettings,
    this.isPermanent = false,
    this.isServiceDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFF26A69A).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 48.r,
                color: const Color(0xFF26A69A),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              isServiceDisabled 
                  ? 'Location Services Disabled'
                  : 'Location Access Required',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              isServiceDisabled
                  ? 'Your device location (GPS) is turned off. Please enable it to use features like attendance marking and tracking.'
                  : (isPermanent
                      ? 'Location permissions are permanently denied. Please enable them in settings to continue using the app features like attendance and distance tracking.'
                      : 'We need your location to provide accurate services like attendance marking, field visits, and proximity-based features. Please allow access to continue.'),
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Maybe Later',
                      style: GoogleFonts.outfit(
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (isPermanent) {
                        onOpenSettings();
                      } else {
                        onAllow();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      isServiceDisabled ? 'Open GPS Settings' : (isPermanent ? 'Open Settings' : 'Allow Access'),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
