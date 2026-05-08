import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AttendanceTimelineScreen extends StatelessWidget {
  const AttendanceTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Work Progress",
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Header Section
            _buildProfessionalHeader(),

            // Timeline Content
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.history_toggle_off_rounded,
                          size: 20.sp, color: const Color(0xFF26A69A)),
                      SizedBox(width: 8.w),
                      Text(
                        "Activity Timeline",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  _buildModernTimeline(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
      decoration: BoxDecoration(
        color: const Color(0xFF26A69A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tuesday, 3 March 2026",
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryBox("Day Duration", "08h 05m", Icons.timer_outlined),
              _buildSummaryBox(
                  "Client Visits", "10 Visits", Icons.location_on_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String label, String value, IconData icon) {
    return Container(
      width: 160.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.sp, color: Colors.white70),
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTimeline() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTimelineItem(
            title: "Office Checkout",
            time: "06:00 PM",
            icon: Icons.logout_rounded,
            isFirst: true,
            statusColor: const Color(0xFFEF4444),
          ),
          _buildTimelineItem(
            title: "Poster Designs",
            time: "02:30 PM - 06:00 PM",
            description: "Directory Poster Design Finalization",
            icon: Icons.palette_outlined,
            statusColor: const Color(0xFF6366F1),
          ),
          _buildTimelineItem(
            title: "HRM APP Development",
            time: "10:30 AM - 01:00 PM",
            description: "Marketing Module UI Implementation",
            icon: Icons.code_rounded,
            statusColor: const Color(0xFF26A69A),
          ),
          _buildTimelineItem(
            title: "Daily Day Poster",
            time: "09:00 AM - 10:00 AM",
            description: "March 3 Special Day Creative",
            icon: Icons.brush_outlined,
            statusColor: const Color(0xFFF59E0B),
          ),
          _buildTimelineItem(
            title: "Office Check-in",
            time: "08:45 AM",
            icon: Icons.login_rounded,
            isLast: true,
            statusColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    String? description,
    required IconData icon,
    bool isFirst = false,
    bool isLast = false,
    required Color statusColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor, width: 2.w),
                ),
                child: Icon(icon, size: 18.sp, color: statusColor),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: Colors.grey.shade200,
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 32.h, top: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12.sp, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Text(
                        time,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (description != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      description,
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
