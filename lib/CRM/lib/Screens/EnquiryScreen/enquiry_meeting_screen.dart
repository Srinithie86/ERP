import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Services/lead_service.dart';
import '../../Widgets/lead_row_card.dart';
import '../../Widgets/call_confirmation_popup.dart';
import '../../Widgets/responsive_layout.dart';
import 'enquiry_new_screen.dart';
import 'enquiry_followup_screen.dart';

class EnquiryMeetingScreen extends StatefulWidget {
  const EnquiryMeetingScreen({super.key});

  @override
  State<EnquiryMeetingScreen> createState() => _EnquiryMeetingScreenState();
}

class _EnquiryMeetingScreenState extends State<EnquiryMeetingScreen> {
  bool _isLoading = false;
  List<dynamic> _enquiries = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final res = await LeadService.fetchLeads(enquiryType: 'Enquiry');
      if (mounted) {
        setState(() {
          _enquiries = res.where((e) {
            String status =
                (e['lead_status'] ?? e['status'] ?? '').toString().toLowerCase();
            return status.contains('meeting');
          }).toList();

        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: _buildScaffold(context, isMobile: true),
      tablet: _buildScaffold(context, isMobile: false),
    );
  }

  Widget _buildScaffold(BuildContext context, {required bool isMobile}) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        title: Text(
          'Meeting Enquiry',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          _buildFilterChips(),
          SizedBox(height: 16.h),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF26A69A)),
                  )
                : _enquiries.isEmpty
                    ? const Center(child: Text("No meeting enquiries found"))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _enquiries.length,
                        itemBuilder: (c, i) => LeadRowCard(
                          lead: _enquiries[i],
                          showStatus: false,
                          onCall: () => _confirmCall(context, _enquiries[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'New', 'Follow up', 'Meeting'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: filters
            .map(
              (f) => Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: GestureDetector(
                  onTap: () {
                    if (f == 'All') Navigator.pop(context);
                    if (f == 'New') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const EnquiryNewScreen()),
                      );
                    }
                    if (f == 'Follow up') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const EnquiryFollowUpScreen()),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          f == 'Meeting' ? const Color(0xFF26A69A) : Colors.white,
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(color: const Color(0xFF26A69A)),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color:
                            f == 'Meeting' ? Colors.white : const Color(0xFF26A69A),
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _confirmCall(BuildContext context, Map<String, dynamic> lead) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => CallConfirmationPopup(
        lead: lead,
        onConfirm: () async {
          Navigator.pop(c);
        },
        onCancel: () => Navigator.pop(c),
      ),
    );
  }
}
