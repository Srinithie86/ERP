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
    final name = (lead['cus_name'] ??
            lead['le_name'] ??
            lead['contact_person'] ??
            'Unknown')
        .toString();
    final p1 = (lead['mobile_1'] ?? lead['mobile'] ?? lead['phone'] ?? lead['cid'] ?? '').toString();
    final p2 = (lead['mobile_2'] ?? '').toString();
    final company = (lead['company'] ?? lead['requirement_notes'] ?? lead['other_required'] ?? '').toString();
    
    final nextDate = (lead['next_follow_up_date'] ?? lead['meet_date'] ?? '').toString();
    final nextTime = (lead['next_follow_up_time'] ?? lead['time'] ?? '').toString();
    
    final date = (nextDate != '0000-00-00' && nextDate.isNotEmpty)
        ? "$nextDate $nextTime".trim()
        : (lead['enquiry_date'] ?? lead['entry_date'] ?? lead['created_at'] ?? lead['dtime'] ?? '').toString();

    final outcome = lead['call_outcome']?.toString() ?? '';
    final summary = (lead['call_summary'] ?? lead['feedback'] ?? lead['requirement_notes'] ?? lead['other_sumary'] ?? '').toString();
    final project = (lead['required_project'] ?? lead['required_project_name'] ?? lead['project'] ?? '').toString();
    final budget = (lead['customer_budget'] ?? lead['budget'] ?? '').toString();
    
    final modeOfMeet = (lead['mode_of_meet'] ?? lead['meeting_mode'] ?? '').toString();
    final loc = (lead['loc'] ?? lead['location'] ?? '').toString();
    final address = (lead['address'] ?? '').toString();
    
    final status = (lead['lead_status'] ?? lead['status'] ?? (outcome.isNotEmpty ? 'Follow up' : 'New')).toString();

    // Debugging to catch missing fields
    debugPrint("--- RENDERING LEAD CARD: $name ---");
    debugPrint("Data: $lead");
    debugPrint("Extracted -> Budget: $budget, Project: $project, Summary: $summary");

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => EnquiryTabsView(
              lead: lead,
              status: status,
              initialIndex: 1,
            ),
          ),
        );
      },
      child: Container(
        width: 300.w,
        constraints: BoxConstraints(minHeight: 90.h),
        margin: EdgeInsets.only(bottom: 12.h, left: 16.w, right: 16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFD4D4D4), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 4,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(10.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name row
              Row(
                children: [
                  Icon(Icons.person_outline, size: 15.r, color: Colors.black87),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  if (showStatus)
                    Text(
                      '• $status',
                      style: TextStyle(
                        color: const Color(0xFF109B1E),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
              SizedBox(height: 5.h),
              // Phone numbers
              _infoRow(Icons.phone_outlined, p1, const Color(0xFF00740C)),
              if (p2.isNotEmpty && p2 != p1) ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.phone_outlined, p2, const Color(0xFF00740C)),
              ],
              // Company
              if (company.isNotEmpty && company != 'N/A' && company.toLowerCase() != 'nil') ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.business_outlined, company, const Color(0xFFFF6400)),
              ],
              // Date
              if (date.isNotEmpty && date != '0000-00-00') ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.calendar_month, "Next: $date", const Color(0xFF1565C0)),
              ],
              // Budget
              if (budget.isNotEmpty && budget != '0' && budget != '0.0') ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.payments_outlined, "Budget: ₹$budget", const Color(0xFF2E7D32)),
              ],
              // Project
              if (project.isNotEmpty && project != 'N/A') ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.assignment_outlined, "Project: $project", const Color(0xFF673AB7)),
              ],
              
              // Meeting Info
              if (modeOfMeet.isNotEmpty) ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.meeting_room_outlined, "Mode: $modeOfMeet", Colors.brown),
              ],
              if (loc.isNotEmpty) ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.location_on_outlined, "Location: $loc", Colors.redAccent),
              ],
              if (address.isNotEmpty) ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.map_outlined, "Address: $address", Colors.blueGrey),
              ],
              
              // Summary
              if (summary.isNotEmpty && summary != 'N/A') ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.notes, summary, Colors.black54),
              ],
              
              if (showCall) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 110.w,
                    height: 32.h,
                    child: ElevatedButton.icon(
                      onPressed: onCall,
                      icon: Icon(Icons.phone, color: Colors.white, size: 14.r),
                      label: Text(
                        'Call Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00740C),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 13.r, color: color),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
