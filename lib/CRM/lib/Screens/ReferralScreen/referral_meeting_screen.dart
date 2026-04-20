import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Services/lead_service.dart';
import '../../Widgets/lead_row_card.dart';
import '../../Widgets/call_confirmation_popup.dart';
import '../../Widgets/responsive_layout.dart';
import 'referral_new_screen.dart';
import 'referral_followup_screen.dart';

class ReferralMeetingScreen extends StatefulWidget {
  const ReferralMeetingScreen({super.key});

  @override
  State<ReferralMeetingScreen> createState() => _ReferralMeetingScreenState();
}

class _ReferralMeetingScreenState extends State<ReferralMeetingScreen> {
  bool _isLoading = false;
  List<dynamic> _referrals = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final res = await LeadService.fetchLeads(enquiryType: 'Referral');
      if (mounted) {
        setState(() {
          _referrals = res.where((e) {
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
          'Meeting Referral',
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
          _buildFilters(),
          SizedBox(height: 16.h),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF26A69A)),
                  )
                : _referrals.isEmpty
                    ? const Center(child: Text("No meeting referrals found"))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            child: Text(
                              'Meeting Referral (${_referrals.length})',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: _referrals.length,
                              itemBuilder: (c, i) => LeadRowCard(
                                lead: _referrals[i],
                                showStatus: false,
                                onCall: () => _confirmCall(context, _referrals[i]),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
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
                            builder: (c) => const ReferralNewScreen()),
                      );
                    }
                    if (f == 'Follow up') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const ReferralFollowUpScreen()),
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
        onCancel: () => Navigator.pop(c),
        onConfirm: () async {
          Navigator.pop(c);
        },
      ),
    );
  }
}
