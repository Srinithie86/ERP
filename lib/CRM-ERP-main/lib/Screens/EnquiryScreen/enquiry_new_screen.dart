import 'package:crm/Services/lead_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:crm/Models/lead_api.dart';
import '../../widgets/call_confirmation_popup.dart';
import '../../Widgets/responsive_layout.dart';
import 'enquiry_followup_screen.dart';
import 'enquiry_meeting_screen.dart';
import '../../Widgets/lead_row_card.dart';
import '../Leads/add_lead_screen.dart';
import '../Leads/call_outcome_screen.dart';
import 'package:crm/Models/follow_up_api.dart';
import 'package:crm/Models/meeting_api.dart';

class EnquiryNewScreen extends StatefulWidget {
  const EnquiryNewScreen({super.key});

  @override
  State<EnquiryNewScreen> createState() => _EnquiryNewScreenState();
}

class _EnquiryNewScreenState extends State<EnquiryNewScreen> {
  bool _isLoading = false;
  List<dynamic> _enquiries = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final res = await LeadService.fetchLeads(enquiryType: 'Enquiry');
      final List<FollowUpModel> followUpLeads = await FollowUpApi.fetchFollowUpLeads(enquiryType: '2');
      final List<MeetingModel> meetings = await MeetingApi.fetchMeetings();
      
      final followUpBids = followUpLeads
          .where((f) => f.bid != null)
          .map((f) => f.bid.toString())
          .toSet();

      final meetingUids = meetings
          .map((m) => m.uid.toString())
          .toSet();

      if (mounted) {
        setState(() {
          _enquiries = res.where((l) {
            final id = l['id'].toString();
            final status = (l['lead_status'] ?? l['status'] ?? '').toString().toLowerCase();
            final outcome = (l['call_outcome'] ?? '').toString();

            bool hasFollowUpRecord = followUpBids.contains(id);
            bool hasMeetingRecord = meetingUids.contains(id);
            bool isAlreadyActioned = status.contains('follow') || status.contains('meeting') || outcome.isNotEmpty && outcome != '0';

            return !hasFollowUpRecord && !hasMeetingRecord && !isAlreadyActioned;
          }).toList();

          // Sort by ID descending (newest first)
          _enquiries.sort((a, b) {
            int idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
            int idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
            return idB.compareTo(idA);
          });
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredEnquiries {
    List<dynamic> base = _enquiries;
    if (_searchQuery.isEmpty) return base;
    return base.where((l) {
      final n = (l['le_name'] ?? l['cus_name'] ?? l['contact_person'] ?? '').toString().toLowerCase();
      final p = (l['mobile_1'] ?? l['mobile_2'] ?? '').toString().toLowerCase();
      return n.contains(_searchQuery.toLowerCase()) || p.contains(_searchQuery.toLowerCase());
    }).toList();
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
        centerTitle: false,
        title: Text(
          'New Enquiry',
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
          Container(
            color: const Color(0xFF26A69A),
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: TextStyle(fontSize: 13.sp),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18.r),
                        hintText: 'Search...',
                        hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 11.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const AddLeadScreen(isEnquiry: true),
                    ),
                  ).then((_) => _fetch()),
                  child: Container(
                    width: 38.w,
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3131A6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 22.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          _buildFilters(),
          SizedBox(height: 12.h),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF26A69A)),
                  )
                : _filteredEnquiries.isEmpty
                    ? const Center(child: Text("No new enquiries today"))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            child: Text(
                              'Today Enquiry (${_filteredEnquiries.length})',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: _filteredEnquiries.length,
                              itemBuilder: (c, i) {
                                final lead = _filteredEnquiries[i] as Map<String, dynamic>;
                                return LeadRowCard(
                                  lead: lead,
                                  showStatus: false,
                                  showCall: true,
                                  onCall: () => _confirmCall(context, lead),
                                );
                              },
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
                    if (f == 'Follow up') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (c) => const EnquiryFollowUpScreen()),
                      );
                    }
                    if (f == 'Meeting') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (c) => const EnquiryMeetingScreen()),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: f == 'New' ? const Color(0xFF26A69A) : Colors.white,
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(color: const Color(0xFF26A69A)),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: f == 'New' ? Colors.white : const Color(0xFF26A69A),
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (c) => CallOutcomeScreen(lead: lead, autoCall: true)),
          ).then((_) => _fetch());
        },
      ),
    );
  }
}
