import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Screens/Lead_Information/enquiry_tabs_view.dart';

class LeadRowCard extends StatelessWidget {
  final Map<String, dynamic> lead;
  final VoidCallback onCall;
  final bool showCall;
  final bool showStatus;

  const LeadRowCard({
    super.key,
    required this.lead,
    required this.onCall,
    this.showCall = true,
    this.showStatus = true,
  });

  @override
  Widget build(BuildContext context) {
    final name = (lead['le_name'] ??
            lead['cus_name'] ??
            lead['contact_person'] ??
            'N/A')
        .toString();
    final p1 = (lead['mobile_1'] ?? '').toString();
    final p2 = (lead['mobile_2'] ?? '').toString();
    final service = (lead['product_service'] ??
            lead['required_project'] ??
            lead['requirement_notes'] ??
            'N/A')
        .toString();
    final email = (lead['email'] ?? '').toString();
    
    // Check for follow-up specific fields
    final nextDate = lead['next_follow_up_date'] ?? '';
    final nextTime = lead['next_follow_up_time'] ?? '';
    final followUpDate = (nextDate != '0000-00-00' && nextDate.isNotEmpty)
        ? "$nextDate $nextTime".trim()
        : (lead['enquiry_date'] ?? lead['entry_date'] ?? '').toString();

    final outcome = lead['call_outcome']?.toString() ?? '';
    final mode = lead['follow_up_mode']?.toString() ?? '';

    final displayStatus = (lead['lead_type'] ??
            lead['lead_status'] ??
            lead['status'] ??
            (outcome.isNotEmpty ? 'Follow up' : 'New'))
        .toString();

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => EnquiryTabsView(lead: lead, status: displayStatus),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 22.r,
                      color: Colors.black,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                if (showStatus)
                  Row(
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        size: 10.r,
                        color: const Color(0xFF2E7D32),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        displayStatus,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            // Phone 1
            if (p1.isNotEmpty) _item(Icons.phone_outlined, p1, const Color(0xFF2E7D32)),
            // Phone 2
            if (p2.isNotEmpty) _item(Icons.phone_outlined, p2, const Color(0xFF2E7D32)),
            // Service
            if (service != 'N/A') _item(Icons.headset_mic_outlined, service, const Color(0xFFEF6C00)),
            
            if (outcome.isNotEmpty) _item(Icons.assignment_turned_in_outlined, "Outcome: $outcome", const Color(0xFFD32F2F)),
            if (mode.isNotEmpty) _item(Icons.shuffle, "Mode: $mode", const Color(0xFF1976D2)),
            
            // Email (hide if empty)
            if (email.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.mail_outline, size: 18.r, color: Colors.black),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      email,
                      style: TextStyle(color: Colors.black, fontSize: 14.sp),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 18.r, color: Colors.black),
                ],
              ),
            if (email.isNotEmpty) SizedBox(height: 8.h),
            
            // Date
            _item(
              (nextDate != '0000-00-00' && nextDate.isNotEmpty) ? Icons.alarm : Icons.calendar_today_outlined, 
              followUpDate, 
              (nextDate != '0000-00-00' && nextDate.isNotEmpty) ? Colors.red : const Color(0xFF3949AB)
            ),
            // Call Button
            if (showCall)
              GestureDetector(
                onTap: onCall,
                child: Container(
                  margin: EdgeInsets.only(top: 12.h),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call, color: Colors.white, size: 18.r),
                      SizedBox(width: 8.w),
                      Text(
                        'Call Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _item(IconData icon, String text, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18.r,
            color: color == Colors.black ? Colors.black : color,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 14.sp,
                fontWeight: color == Colors.black
                    ? FontWeight.normal
                    : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
