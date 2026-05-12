import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import '../../models/attendance_api.dart';

class AttendanceTimelineScreen extends StatefulWidget {
  final String? date;
  const AttendanceTimelineScreen({super.key, this.date});

  @override
  State<AttendanceTimelineScreen> createState() =>
      _AttendanceTimelineScreenState();
}

class _AttendanceTimelineScreenState extends State<AttendanceTimelineScreen> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _timelineData;
  late String _displayDate;

  @override
  void initState() {
    super.initState();
    _displayDate =
        widget.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    _fetchTimeline();
  }

  Future<void> _fetchTimeline() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final cid = prefs.getString('cid') ?? "";
      final uid =
          prefs.getString('login_cus_id') ?? prefs.getString('uid') ?? "";
      final deviceId = prefs.getString('device_id') ?? "123456";

      Position? position;
      try {
        position = await Geolocator.getLastKnownPosition();
      } catch (_) {}

      final response = await AttendanceApi.fetchOneDayTimeline(
        cid: cid,
        uid: uid,
        date: _displayDate,
        deviceId: deviceId,
        lat: position?.latitude.toString() ?? "0.0",
        lng: position?.longitude.toString() ?? "0.0",
      );

      if (response["error"] == false) {
        setState(() {
          _timelineData = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response["error_msg"] ?? "Failed to fetch timeline";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _isLoading = false;
      });
    }
  }

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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF26A69A)))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!,
                          style: GoogleFonts.poppins(color: Colors.red)),
                      ElevatedButton(
                        onPressed: _fetchTimeline,
                        child: const Text("Retry"),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchTimeline,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildProfessionalHeader(),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 32.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.history_toggle_off_rounded,
                                      size: 20.sp,
                                      color: const Color(0xFF26A69A)),
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
                ),
    );
  }

  Widget _buildProfessionalHeader() {
    final summary = _timelineData?['summary'] ?? {};
    final formattedDate =
        DateFormat('EEEE, d MMMM yyyy').format(DateTime.parse(_displayDate));

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
            formattedDate,
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
              _buildSummaryBox("Work Duration",
                  summary['total_work_hours'] ?? "00:00", Icons.timer_outlined),
              _buildSummaryBox(
                  "Client Visits",
                  "${summary['marketing_visits'] ?? 0} Visits",
                  Icons.location_on_outlined),
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
    final data = _timelineData?['data'] ?? {};
    final checkins = data['checkin'] as List? ?? [];
    final marketings = data['marketing'] as List? ?? [];
    final tasks = data['tasks'] as List? ?? [];

    // Combine and sort activities by time if possible, but for now we'll just list them.
    // Based on the user response, we usually show checkins.

    if (checkins.isEmpty && marketings.isEmpty && tasks.isEmpty) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Center(
          child: Text("No activities recorded for this day",
              style: GoogleFonts.poppins(color: Colors.grey)),
        ),
      );
    }

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
          ...checkins.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == checkins.length - 1 &&
                marketings.isEmpty &&
                tasks.isEmpty;

            return _buildTimelineItem(
              title:
                  "Session ${index + 1}: ${item['status']?.toString().toUpperCase() ?? 'CHECK IN'}",
              time:
                  "${item['in_time'] ?? '--'} - ${item['out_time'] ?? 'Active'}",
              description:
                  "Location: ${item['location'] ?? 'Not specified'}\nWork Mode: ${item['work_mode'] ?? 'office'}",
              icon: item['status'] == 'check out'
                  ? Icons.logout_rounded
                  : Icons.login_rounded,
              isLast: isLast,
              statusColor: item['status'] == 'check out'
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF10B981),
            );
          }),
          ...marketings.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == marketings.length - 1 && tasks.isEmpty;
            return _buildTimelineItem(
              title: "Marketing Visit: ${item['client_name'] ?? 'Unknown'}",
              time: item['visit_time'] ?? '--',
              description: item['purpose'] ?? '',
              icon: Icons.location_on_outlined,
              isLast: isLast,
              statusColor: const Color(0xFF6366F1),
            );
          }),
          ...tasks.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == tasks.length - 1;
            return _buildTimelineItem(
              title: "Task: ${item['title'] ?? 'Task'}",
              time: item['completion_time'] ?? '',
              description: item['status'] ?? '',
              icon: Icons.task_alt_rounded,
              isLast: isLast,
              statusColor: const Color(0xFFF59E0B),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String time,
    String? description,
    required IconData icon,
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
                  if (description != null && description.isNotEmpty) ...[
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
