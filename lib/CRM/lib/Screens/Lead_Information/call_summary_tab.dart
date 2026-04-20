import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Widgets/quick_action_button.dart';

class EnquirySummaryTab extends StatelessWidget {
  final Map<String, dynamic>? lead;
  final List<dynamic> callSummaryData;
  final bool isLoading;
  final String? selectedStatus;

  const EnquirySummaryTab({
    super.key,
    this.lead,
    required this.callSummaryData,
    required this.isLoading,
    this.selectedStatus,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: const Color(0xFF26A69A),
          strokeWidth: 3.w,
        ),
      );
    }

    // App Signature Color (Teal)
    const Color primaryColor = Color(0xFF26A69A);

    // Dynamic Mock Data bound to the current lead
    final String currentClient =
        (lead?['le_name'] ?? lead?['cus_name'] ?? 'Client').toString();
    final String currentProject =
        (lead?['product_service'] ??
                lead?['required_project'] ??
                'General Inquiry')
            .toString();
    final String currentBudget = (lead?['budget'] ?? '₹0').toString();

    final List<dynamic> mockData = [
      {
        'call_date': '21 March 2026',
        'call_time': '02:30 PM',
        'call_outcome_name': 'Connected',
        'client_name': currentClient,
        'project_name': currentProject,
        'project_budget': currentBudget,
        'meeting_type': 'Virtual Meeting',
        'meeting_link': 'https://meet.google.com/abc-defg-hij',
        'call_summary':
            'Discussed the primary requirements for $currentProject. The client is satisfied with the initial demo and budget alignment.',
        'next_followup_mode': 'Video Call',
        'next_followup_date': '24 March 2026',
        'next_followup_time': '10:30 AM',
        'client_status': 'Follow-up',
      },
      {
        'call_date': '19 March 2026',
        'call_time': '11:00 AM',
        'call_outcome_name': 'Interested',
        'client_name': currentClient,
        'project_name': currentProject,
        'project_budget': currentBudget,
        'meeting_type': 'Call',
        'call_summary':
            'Initial discovery call to understand the project scope and timeline for $currentProject.',
        'next_followup_mode': 'Physical Meet',
        'next_followup_date': '22 March 2026',
        'next_followup_time': '02:00 PM',
        'client_status': 'New',
      },
    ];

    final List<dynamic> displayData = [...callSummaryData, ...mockData];

    if (displayData.isEmpty) {
      return Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history_edu_rounded,
                  size: 64.r,
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
                SizedBox(height: 16.h),
                Text(
                  'No interaction history',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Insights will appear as you engage with this lead.',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24.h,
            right: 24.w,
            child: QuickActionButton(lead: lead),
          ),
        ],
      );
    }

    // Find the latest virtual meeting for the spotlight
    final lastVirtual = displayData.firstWhere(
      (e) => e['meeting_type'] == 'Virtual Meeting',
      orElse: () => null,
    );

    return Stack(
      children: [
        Positioned(
          left: 47.w,
          top: lastVirtual != null ? 180.h : 0,
          bottom: 0,
          child: Container(
            width: 1.5.w,
            color: primaryColor.withValues(alpha: 0.1),
          ),
        ),
        ListView(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          children: [
            if (lastVirtual != null) _buildVirtualMeetingSpotlight(lastVirtual),
            ...displayData.map(
              (call) => _buildProfessionalCallCard(context, call),
            ),
          ],
        ),
        Positioned(
          bottom: 24.h,
          right: 24.w,
          child: QuickActionButton(lead: lead),
        ),
      ],
    );
  }

  Widget _buildVirtualMeetingSpotlight(Map<String, dynamic> meeting) {
    const Color primaryColor = Color(0xFF26A69A);
    final clientName = meeting['client_name'] ?? 'N/A';
    final status = meeting['client_status'] ?? 'Active';
    final date = meeting['call_date'] ?? 'N/A';
    final time = meeting['call_time'] ?? 'N/A';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.08),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // High-Intensity Header Card
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF26A69A), Color(0xFF00796B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28.r),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 12.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.videocam_rounded,
                            color: Colors.white,
                            size: 24.r,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VIRTUAL',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              'CONNECT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Glass Box for Date & Time (2 lines)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 12.r,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                date,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_filled,
                                color: Colors.white,
                                size: 12.r,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                time,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                // Client Spotlight Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        clientName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4.r),
                        ],
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalCallCard(
    BuildContext context,
    Map<String, dynamic> call,
  ) {
    const Color primaryColor = Color(0xFF26A69A);
    const Color lightTeal = Color(0xFFE0F2F1);

    final date = (call['call_date'] ?? 'N/A').toString();
    final time = (call['call_time'] ?? '').toString();
    final outcome = (call['call_outcome_name'] ?? call['call_outcome'] ?? 'N/A')
        .toString();
    final summary = (call['call_summary'] ?? '').toString();
    final clientName =
        (call['client_name'] ?? lead?['le_name'] ?? lead?['cus_name'] ?? 'N/A')
            .toString();
    final projectName =
        (lead?['product_service'] ??
                lead?['required_project'] ??
                'General Inquiry')
            .toString();

    // Budget Detail
    final budget = (call['project_budget'] ?? lead?['budget'] ?? '₹0')
        .toString();

    final meetingType = (call['meeting_type'] ?? 'Call').toString();
    final location = (call['location'] ?? '').toString();
    final meetingLink = (call['meeting_link'] ?? '').toString();

    // Next Follow-up Data
    final nextMode = (call['next_followup_mode'] ?? 'Video Call').toString();
    final nextDate = (call['next_followup_date'] ?? '').toString();
    final nextTime = (call['next_followup_time'] ?? '').toString();

    IconData headerIcon = Icons.call_rounded;
    String modeName = 'Voice Call';

    if (meetingType == 'Direct Meeting') {
      headerIcon = Icons.holiday_village_rounded;
      modeName = 'Direct Meeting';
    } else if (meetingType == 'Virtual Meeting') {
      headerIcon = Icons.videocam_rounded;
      modeName = 'Virtual Meeting';
    }

    return Padding(
      padding: EdgeInsets.only(left: 32.w, right: 16.w, bottom: 24.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Marker
          Container(
            margin: EdgeInsets.only(top: 18.h),
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 10.r,
                  spreadRadius: 2.r,
                ),
              ],
            ),
            child: Icon(headerIcon, size: 14.r, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          // Clean Professional Card
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 15.r,
                    offset: Offset(0, 5.h),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: Column(
                  children: [
                    // Lightweight Header - FIXED OVERFLOW
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      color: lightTeal,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              modeName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 9.sp,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_month_rounded,
                                  size: 14.r,
                                  color: primaryColor,
                                ),
                                SizedBox(width: 4.w),
                                Flexible(
                                  child: Text(
                                    date,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                ),
                                if (time.isNotEmpty) ...[
                                  Flexible(
                                    child: Text(
                                      " @ $time",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: primaryColor.withValues(
                                          alpha: 0.6,
                                        ),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            clientName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            projectName,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          // Project Budget Highlight
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.amber.shade200),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "PROJECT BUDGET: ",
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.amber.shade900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  budget,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.h),
                          // Logistics Block
                          if (meetingType != 'Call')
                            Container(
                              padding: EdgeInsets.all(10.r),
                              margin: EdgeInsets.only(bottom: 16.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    meetingType == 'Direct Meeting'
                                        ? Icons.place_rounded
                                        : Icons.sensors_rounded,
                                    size: 14.r,
                                    color: primaryColor,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      meetingType == 'Direct Meeting'
                                          ? location
                                          : meetingLink,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Key Summary
                          Text(
                            summary,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey.shade700,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          // NEXT FOLLOW-UP SECTION
                          if (nextDate.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'SCHEDULED FOLLOW-UP',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildFollowUpSmallInfo('MODE', nextMode),
                                      _buildFollowUpSmallInfo('DATE', nextDate),
                                      _buildFollowUpSmallInfo('TIME', nextTime),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(height: 20.h),
                          // Centered Outcome Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(30.r),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.2),
                                  blurRadius: 8.r,
                                  offset: Offset(0, 4.h),
                                ),
                              ],
                            ),
                            child: Text(
                              outcome.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9.sp,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpSmallInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF26A69A).withValues(alpha: 0.6),
            fontSize: 7.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
