import 'package:erp_smart/CRM-ERP-main/lib/Models/schedule_api.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Services/follow_up_api_service.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Services/lead_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Models/lead_api.dart';
import '../../widgets/call_confirmation_popup.dart';
import '../../widgets/responsive_layout.dart';
import '../../widgets/lead_row_card.dart';
import '../Leads/add_lead_screen.dart';
import '../Leads/call_outcome_screen.dart';
import '../../Models/follow_up_api.dart';
import '../../Models/meeting_api.dart';
import '../Lead_Information/enquiry_tabs_view.dart';
import '../../widgets/meeting_details_popup.dart';

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = false;
  List<dynamic> _enquiries = [];
  List<dynamic> _followUps = [];
  List<dynamic> _schedules = [];
  List<dynamic> _meetings = [];
  List<dynamic> _displayEnquiries = []; // Cached for UI
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        LeadService.fetchLeads(enquiryType: '2'),
        FollowUpApiService.fetchFollowUps(),
        ScheduleApi.fetchSchedules(enquiryType: 'Enquiry'),
        MeetingApi.fetchMeetings(enquiryType: 'Enquiry'),
      ]);

      if (!mounted) return;

      final List<dynamic> rawEnquiries = results[0] is List ? results[0] : [];
      final List<dynamic> rawFollowUps = results[1] is List ? results[1] : [];
      final List<dynamic> rawSchedules = results[2] is List ? results[2] : [];
      final List<dynamic> rawMeetings = results[3] is List ? results[3] : [];

      // Filter follow-ups for Enquiry (enquiry_type '2')
      final List<Map<String, dynamic>> processedFollowUps = rawFollowUps
          .where((f) => f != null && f is Map)
          .where((f) => f['enquiry_type']?.toString() == '2')
          .map((f) => Map<String, dynamic>.from(f as Map)..['status'] = 'Follow up')
          .toList();

      setState(() {
        _enquiries = rawEnquiries;
        _followUps = processedFollowUps;
        _schedules = rawSchedules.map((s) => Map<String, dynamic>.from(s as Map)..['status'] = 'Schedule').toList();
        _meetings = rawMeetings.map((m) => Map<String, dynamic>.from(m as Map)..['status'] = 'Meeting').toList();
        _isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      debugPrint("Error refreshing enquiries: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    List<dynamic> base = [];

    final List<Map<String, dynamic>> safeEnquiries = _enquiries
        .where((e) => e != null && e is Map)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    
    if (_selectedFilter == 'All') {
      final nonFollowups = safeEnquiries.where((l) {
        final cusStatus = (l['cus_status'] ?? '').toString().toUpperCase();
        return cusStatus != 'FOLLOW_UP' && cusStatus != 'SCHEDULE' && cusStatus != 'MEETING';
      }).toList();
      base = [...nonFollowups, ..._followUps, ..._schedules, ..._meetings];
    } else if (_selectedFilter == 'Follow up') {
      base = _followUps;
    } else if (_selectedFilter == 'Schedule') {
      base = _schedules;
    } else if (_selectedFilter == 'Meeting') {
      base = _meetings;
    } else {
      base = safeEnquiries.where((l) {
        final cusStatus = (l['cus_status'] ?? '').toString().toUpperCase();
        final s = (l['status'] ?? '').toString().toLowerCase();
        final sClean = s.replaceAll('_', ' ').trim();
        
        if (_selectedFilter == 'New') {
          return cusStatus == 'NEW';
        }
        return sClean == _selectedFilter.toLowerCase();
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      base = base.where((l) {
        final n = (l['le_name'] ?? l['cus_name'] ?? l['contact_person'] ?? '').toString().toLowerCase();
        final p = (l['mobile_1'] ?? l['mobile_2'] ?? '').toString().toLowerCase();
        final id = (l['id'] ?? '').toString().toLowerCase();
        return n.contains(query) || p.contains(query) || id.contains(query);
      }).toList();
    }

    setState(() {
      _displayEnquiries = base;
    });
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
          'Enquiry',
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
                      onChanged: (v) {
                        _searchQuery = v;
                        _applyFilters();
                      },
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
                  ).then((_) => _refreshData()),
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
                : _displayEnquiries.isEmpty
                ? const Center(child: Text("No enquiries found"))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _displayEnquiries.length,
                          itemBuilder: (c, i) {
                            final lead = Map<String, dynamic>.from(_displayEnquiries[i] as Map);
                            return LeadRowCard(
                              lead: lead,
                              showStatus: true,
                              showCall: _selectedFilter != 'All',
                              onCall: () => _confirmCall(context, lead),
                              currentTab: _selectedFilter,
                              enableTap: _selectedFilter != 'All' && _selectedFilter != 'New',
                              onCreateMeeting: _selectedFilter == 'Schedule'
                                  ? () => _createMeeting(context, lead, 'Enquiry')
                                  : null,
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

  void _confirmCall(BuildContext context, Map<String, dynamic> lead) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => CallConfirmationPopup(
        lead: lead,
        onCancel: () => Navigator.pop(c),
        onConfirm: (selectedPhone) async {
          Navigator.pop(c);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => CallOutcomeScreen(
                lead: lead,
                autoCall: true,
                selectedPhone: selectedPhone,
              ),
            ),
          ).then((_) => _refreshData());
        },
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['All', 'New', 'Follow up', 'Schedule', 'Meeting', 'Negotiation'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: filters
            .map(
              (f) => Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: GestureDetector(
                  onTap: () => _handleFilterTap(f),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedFilter == f
                          ? const Color(0xFF26A69A)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(color: const Color(0xFF26A69A)),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: _selectedFilter == f
                            ? Colors.white
                            : const Color(0xFF26A69A),
                        fontWeight: FontWeight.w500,
                        fontSize: 13.sp,
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

  void _handleFilterTap(String filter) {
    _selectedFilter = filter;
    _applyFilters();
  }

  void _createMeeting(BuildContext context, Map<String, dynamic> lead, String type) {
    showDialog(
      context: context,
      builder: (c) => MeetingDetailsPopup(lead: lead, enquiryType: type),
    ).then((val) {
      if (val == true) _refreshData();
    });
  }
}
