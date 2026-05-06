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

    final List<dynamic> displayData = callSummaryData;

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
                  color: Colors.grey.withOpacity(0.3),
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
      (e) => e['follow_up_mode'].toString() == '3',
      orElse: () => null,
    );

    // Filter displayData to exclude the spotlighted virtual meeting from the regular list
    final List<dynamic> regularListData = lastVirtual != null
        ? displayData.where((e) {
            final String currentId =
                (e['id'] ?? e['history_id'] ?? '').toString();
            final String virtualId =
                (lastVirtual['id'] ?? lastVirtual['history_id'] ?? '')
                    .toString();
            return currentId != virtualId;
          }).toList()
        : displayData;

    return Stack(
      children: [
        Positioned(
          left: 47.w,
          top: lastVirtual != null ? 180.h : 0,
          bottom: 0,
          child: Container(
            width: 1.5.w,
            color: primaryColor.withOpacity(0.1),
          ),
        ),
        ListView(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          children: [
            if (lastVirtual != null) _buildVirtualMeetingSpotlight(lastVirtual),
            ...regularListData.map(
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
    final clientName = meeting['cus_name'] ?? 'N/A';
    final status = (meeting['type_status'] ?? 'Active').toString();
    final date = meeting['call_date'] ?? 'N/A';
    final time = meeting['call_time'] ?? 'N/A';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      // child: Column(
      //   children: [
      //     Container(
      //       padding: EdgeInsets.all(20.r),
      //       decoration: BoxDecoration(
      //         gradient: const LinearGradient(
      //           colors: [Color(0xFF26A69A), Color(0xFF00796B)],
      //           begin: Alignment.topLeft,
      //           end: Alignment.bottomRight,
      //         ),
      //         borderRadius: BorderRadius.circular(28.r),
      //       ),
      //       child: Column(
      //         children: [
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               Row(
      //                 children: [
      //                   Container(
      //                     padding: EdgeInsets.all(8.r),
      //                     decoration: BoxDecoration(
      //                       color: Colors.white.withOpacity(0.2),
      //                       shape: BoxShape.circle,
      //                     ),
      //                     child: Icon(
      //                       Icons.videocam_rounded,
      //                       color: Colors.white,
      //                       size: 24.r,
      //                     ),
      //                   ),
      //                   SizedBox(width: 12.w),
      //                   Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     children: [
      //                       Text(
      //                         'VIRTUAL CONNECTION',
      //                         style: TextStyle(
      //                           color: Colors.white.withOpacity(0.8),
      //                           fontSize: 9.sp,
      //                           fontWeight: FontWeight.bold,
      //                           letterSpacing: 1.5,
      //                         ),
      //                       ),
      //                       Text(
      //                         'Premium Meeting',
      //                         style: TextStyle(
      //                           color: Colors.white,
      //                           fontSize: 13.sp,
      //                           fontWeight: FontWeight.w600,
      //                         ),
      //                       ),
      //                     ],
      //                   ),
      //                 ],
      //               ),
      //               Container(
      //                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      //                 decoration: BoxDecoration(
      //                   color: Colors.white.withOpacity(0.2),
      //                   borderRadius: BorderRadius.circular(12.r),
      //                   border: Border.all(color: Colors.white.withOpacity(0.3)),
      //                 ),
      //                 child: Column(
      //                   children: [
      //                     Text(date, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
      //                     Text(time, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 9.sp)),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //           SizedBox(height: 24.h),
      //           Row(
      //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //             children: [
      //               Expanded(
      //                 child: Column(
      //                   crossAxisAlignment: CrossAxisAlignment.start,
      //                   children: [
      //                     _buildDetailRow('Customer', clientName),
      //                     _buildDetailRow('Status', status),
      //                     _buildDetailRow('Date', date),
      //                     _buildDetailRow('Time', time),
      //                   ],
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ],
      //       ),
      //     ),
      //   ],
      // ),
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

    // Outcome Mapping & Color Selection
    String outcomeVal = (call['call_outcome'] ?? 'N/A').toString();
    String outcome = outcomeVal;
    Color outcomeColor = primaryColor;

    // Support numeric IDs from new API 3016/3032
    if (outcomeVal == '1' || outcomeVal.toLowerCase() == 'interested') {
      outcome = 'Interested';
      outcomeColor = const Color(0xFF2E7D32); // Green
    } else if (outcomeVal == '2' || outcomeVal.toLowerCase() == 'busy') {
      outcome = 'Busy';
      outcomeColor = const Color(0xFFEF6C00); // Orange
    } else if (outcomeVal == '3' || outcomeVal.toLowerCase() == 'no response') {
      outcome = 'No Response';
      outcomeColor = const Color(0xFFC62828); // Red
    }

    final summary = (call['call_summary'] ?? '').toString();
    final clientName =
        (call['cus_name'] ?? lead?['le_name'] ?? lead?['cus_name'] ?? 'N/A')
            .toString();
    final projectName = (call['required_project'] ??
            lead?['product_service'] ??
            lead?['required_project'] ??
            'General Inquiry')
        .toString();

    final rawBudget =
        (call['customer_budget'] ?? lead?['budget'] ?? '').toString();
    final budget =
        rawBudget.isEmpty || rawBudget == '0' ? 'N/A' : '₹$rawBudget';

    final modeVal = (call['follow_up_mode'] ?? '1').toString();
    String meetingType = 'Call';
    if (modeVal == '2' || modeVal.toLowerCase() == 'meeting')
      meetingType = 'Direct Meeting';
    else if (modeVal == '3' || modeVal.toLowerCase() == 'virtual')
      meetingType = 'Virtual Meeting';

    // Map lead_status IDs to Text
    String statusId = (call['lead_status'] ?? '').toString();
    String statusText = statusId;
    if (statusId == '1')
      statusText = 'New';
    else if (statusId == '2')
      statusText = 'Negotiation';
    else if (statusId == '3')
      statusText = 'Schedule';
    else if (statusId.toLowerCase() == 'hot') statusText = 'Hot';

    final location = (call['location'] ?? '').toString();
    final meetingLink = (call['meeting_link'] ?? '').toString();

    final nextMode =
        (call['next_followup_mode'] ?? call['follow_up_mode'] ?? 'Call')
            .toString();
    final nextDate = (call['next_follow_up_date'] ?? '').toString();
    final nextTime = (call['next_follow_up_time'] ?? '').toString();

    IconData headerIcon = Icons.call_outlined;
    String modeName = 'Voice Call';

    if (meetingType == 'Direct Meeting') {
      headerIcon = Icons.location_on_outlined;
      modeName = 'Direct Meeting';
    } else if (meetingType == 'Virtual Meeting') {
      headerIcon = Icons.videocam_outlined;
      modeName = 'Virtual Meeting';
    }

    return Padding(
      padding: EdgeInsets.only(left: 32.w, right: 16.w, bottom: 28.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20.h),
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 2.w),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.1),
                  blurRadius: 8.r,
                ),
              ],
            ),
            child: Icon(headerIcon, size: 16.r, color: primaryColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20.r)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            modeName.toUpperCase(),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 9.sp,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: outcomeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            outcome.toUpperCase(),
                            style: TextStyle(
                              color: outcomeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 8.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Customer', clientName),
                        _buildDetailRow('Outcome', outcome),
                        _buildDetailRow('Product', projectName),
                        _buildDetailRow('Status', statusText),
                        if (summary.isNotEmpty)
                          _buildDetailRow('Summary', summary),
                        if ((call['other_required'] ??
                                call['requirement_notes'] ??
                                lead?['requirement_notes'] ??
                                '')
                            .toString()
                            .isNotEmpty)
                          _buildDetailRow(
                              'Other Req',
                              (call['other_required'] ??
                                      call['requirement_notes'] ??
                                      lead?['requirement_notes'] ??
                                      '')
                                  .toString()),
                        if ((call['other_summary'] ?? '').toString().isNotEmpty)
                          _buildDetailRow('Additional Summary',
                              (call['other_summary'] ?? '').toString()),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            _buildInfoMiniChip(Icons.payments_outlined, budget),
                            if (meetingType != 'Call') ...[
                              SizedBox(width: 8.w),
                              _buildInfoMiniChip(
                                meetingType == 'Direct Meeting'
                                    ? Icons.place_outlined
                                    : Icons.link_outlined,
                                meetingType == 'Direct Meeting'
                                    ? location
                                    : 'Meeting Link',
                              ),
                            ],
                          ],
                        ),
                        if (nextDate.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F8E9),
                              borderRadius: BorderRadius.circular(12.r),
                              border:
                                  Border.all(color: const Color(0xFFC5E1A5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NEXT FOLLOW-UP',
                                  style: TextStyle(
                                    color: const Color(0xFF33691E),
                                    fontSize: 8.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    _buildNextFollowUpSmall('Mode', nextMode),
                                    SizedBox(width: 16.w),
                                    _buildNextFollowUpSmall('Date', nextDate),
                                    SizedBox(width: 16.w),
                                    _buildNextFollowUpSmall('Time', nextTime),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMiniChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: Colors.grey.shade600),
          SizedBox(width: 4.w),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextFollowUpSmall(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 7.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.bold),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildFollowUpSmallInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF26A69A).withOpacity(0.6),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
