import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Screens/Lead_Information/enquiry_tabs_view.dart';

class LeadRowCard extends StatelessWidget {
  final Map<String, dynamic> lead;
  final VoidCallback onCall;
  final bool showCall;
  final bool showStatus;
  final bool enableTap;
  final bool isAllTab; // Added to handle All tab specific UI

  const LeadRowCard({
    super.key,
    this.lead = const {},
    required this.onCall,
    this.showCall = true,
    this.showStatus = true,
    this.enableTap = true,
    this.isAllTab = false,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return const Color(0xFF00C853); // Vibrant Green
      case 'follow up':
        return const Color(0xFF2979FF); // Bright Blue
      case 'meeting':
        return const Color(0xFFFF6D00); // Deep Orange
      case 'negotiation':
        return const Color(0xFF6200EA); // Deep Purple
      case 'schedule':
        return const Color(0xFF00B8D4); // Cyan
      case 'missed':
        return const Color(0xFFD50000); // Red
      default:
        return const Color(0xFF26A69A); // Teal
    }
  }

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
    
    String _formatStatus(String s) {
      if (s == '1' || s.toLowerCase() == 'interest' || s.toLowerCase() == 'follow up') return 'Follow up';
      if (s == '2' || s.toLowerCase().contains('negotiation')) return 'Negotiation';
      if (s == '3' || s.toLowerCase().contains('schedule')) return 'Schedule';
      if (s == 'missed_followup') return 'Missed';
      return s;
    }

    final leadStatus = (lead['lead_status'] ?? '').toString();
    final manualStatus = (lead['status'] ?? '').toString();
    final rawStatus = (leadStatus.isNotEmpty
            ? leadStatus
            : (manualStatus.isNotEmpty
                ? manualStatus
                : (outcome.isNotEmpty ? 'Follow up' : 'New')))
        .toString();
    final status = _formatStatus(rawStatus);
    final outcomeText = _formatStatus(outcome);
    
    final email = (lead['email'] ?? lead['email_id'] ?? '').toString();
    final isFollowUp = status == 'Follow up' || manualStatus.toLowerCase().contains('follow');
    final displayProject = (project.isNotEmpty && project != 'N/A') ? project : company;
    final accentColor = _statusColor(status);

    return GestureDetector(
      onTap: enableTap ? () {
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
      } : null,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              // Vertical accent bar using Positioned.fill to avoid IntrinsicHeight
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 5.w,
                  color: accentColor,
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.fromLTRB(16.w + 5.w, 16.h, 16.w, 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Status Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        if (showStatus)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: accentColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    
                    // Contact Info Section
                    Row(
                      children: [
                        _buildCompactInfo(Icons.phone_iphone_rounded, p1, accentColor),
                        if (p2.isNotEmpty && p2 != p1) ...[
                          SizedBox(width: 12.w),
                          _buildCompactInfo(Icons.phone_enabled_rounded, p2, accentColor),
                        ],
                      ],
                    ),
                    
                    Divider(height: 24.h, color: Colors.grey.withOpacity(0.1)),

                    // Project / Product Info
                    if (displayProject.isNotEmpty && displayProject != 'N/A')
                      _buildDetailRow(Icons.layers_outlined, "Product", displayProject, const Color(0xFF6200EA)),

                    // Email Info
                    if (email.isNotEmpty && email != 'null' && email != '')
                      _buildDetailRow(Icons.alternate_email_rounded, "Email", email, const Color(0xFF555555)),

                    // Date Info
                    if (date.isNotEmpty && date != '0000-00-00')
                      _buildDetailRow(Icons.event_available_outlined, "Timeline", date, const Color(0xFF2979FF)),

                    // Follow up specific details
                    if (isFollowUp) ...[
                      if (outcome.isNotEmpty && outcome != 'N/A')
                        _buildDetailRow(Icons.call_missed_outgoing_rounded, "Outcome", outcomeText, const Color(0xFFE91E63)),
                      if (budget.isNotEmpty && budget != '0' && budget != '0.0')
                        _buildDetailRow(Icons.account_balance_wallet_outlined, "Budget", "₹$budget", const Color(0xFF2E7D32)),
                      if (summary.isNotEmpty && summary != 'N/A')
                        _buildDetailRow(Icons.description_outlined, "Summary", summary, Colors.black54),
                    ],

                    if (showCall) ...[
                      SizedBox(height: 16.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onCall,
                            borderRadius: BorderRadius.circular(24.r),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accentColor, accentColor.withOpacity(0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(24.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 16.r),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Call Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      ),
    );
  }

  Widget _buildCompactInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.r, color: color.withOpacity(0.7)),
        SizedBox(width: 4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            color: const Color(0xFF444444),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14.r, color: color.withOpacity(0.8)),
          SizedBox(width: 8.w),
          Expanded(
            child: RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF666666)),
                children: [
                  TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: value, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
