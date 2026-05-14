import 'package:erp_smart/CRM-ERP-main/lib/Services/follow_up_api_service.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Services/lead_service.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Screens/EnquiryScreen/enquiry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Models/lead_api.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Models/follow_up_api.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Models/meeting_api.dart';
import 'package:erp_smart/CRM-ERP-main/lib/Models/schedule_api.dart';
import '../../widgets/call_confirmation_popup.dart';
import '../../widgets/responsive_layout.dart';
import 'add_lead_screen.dart';
import 'call_outcome_screen.dart';
import 'new_lead_screen.dart';
import 'follow_up_lead_screen.dart';
import 'meeting_lead_screen.dart';
import 'negotiation_lead_screen.dart';
import '../Lead_Information/enquiry_tabs_view.dart';
import '../../widgets/lead_row_card.dart';
import '../../widgets/meeting_details_popup.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = false;
  List<dynamic> _allLeads = [];
  List<dynamic> _displayLeads = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _followUps = [];
  List<dynamic> _schedules = [];
  List<dynamic> _meetings = [];

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
        LeadService.fetchLeads(enquiryType: '1'),
        FollowUpApiService.fetchFollowUps(),
        ScheduleApi.fetchSchedules(enquiryType: 'Lead'),
        MeetingApi.fetchMeetings(enquiryType: 'Lead'),
      ]);
      
      if (!mounted) return;

      final List<dynamic> rawLeads = results[0] is List ? results[0] : [];
      final List<dynamic> rawFollowUps = results[1] is List ? results[1] : [];
      final List<dynamic> rawSchedules = results[2] is List ? results[2] : [];
      final List<dynamic> rawMeetings = results[3] is List ? results[3] : [];

      // Safely process follow-ups
      final List<Map<String, dynamic>> processedFollowUps = rawFollowUps
          .where((f) => f != null && f is Map)
          .where((f) {
            final eType = f['enquiry_type']?.toString();
            return eType == '1' || eType == null || eType == '';
          })
          .map((f) => Map<String, dynamic>.from(f as Map)..['status'] = 'Follow up')
          .toList();

      setState(() {
        _allLeads = rawLeads;
        _followUps = processedFollowUps;
        _schedules = rawSchedules.map((s) => Map<String, dynamic>.from(s as Map)..['status'] = 'Schedule').toList();
        _meetings = rawMeetings.map((m) => Map<String, dynamic>.from(m as Map)..['status'] = 'Meeting').toList();
        _isLoading = false;
      });
      
      _applyFilters();
    } catch (e) {
      debugPrint("Error refreshing leads: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    if (!mounted) return;
    List<dynamic> base = [];

    final List<Map<String, dynamic>> safeLeads = _allLeads
        .where((l) => l != null && l is Map)
        .map((l) => Map<String, dynamic>.from(l as Map))
        .toList();

    if (_selectedFilter == 'All') {
      final nonFollowups = safeLeads.where((l) {
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
      base = safeLeads.where((l) {
        final cusStatus = (l['cus_status'] ?? '').toString().toUpperCase();
        final s = (l['lead_status'] ?? l['status'] ?? '').toString().toLowerCase();
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
        final req = (l['requirement_notes'] ?? '').toString().toLowerCase();
        final p = (l['mobile_1'] ?? l['mobile_2'] ?? '').toString().toLowerCase();
        final id = (l['id'] ?? '').toString().toLowerCase();
        return n.contains(query) || p.contains(query) || req.contains(query) || id.contains(query);
      }).toList();
    }

    setState(() {
      _displayLeads = base;
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
          'Lead',
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
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month_outlined,
                color: Colors.white, size: 24.r),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar + + icon (no "Add Lead" text) ──────────────────
          Container(
            color: const Color(0xFF26A69A),
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38.h, // ✅ reduced height
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
                        prefixIcon:
                            Icon(Icons.search, color: Colors.grey, size: 18.r),
                        hintText: 'Search...',
                        hintStyle:
                            TextStyle(fontSize: 13.sp, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 11.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                // ✅ Small square with + icon only
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const AddLeadScreen(isEnquiry: false),
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

          // ── Lead list ──────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF26A69A)))
                : _displayLeads.isEmpty
                    ? const Center(child: Text('No leads found'))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _displayLeads.length,
                        itemBuilder: (ctx, i) {
                          final lead =
                              Map<String, dynamic>.from(_displayLeads[i] as Map);
                          final status = (lead['lead_status'] ?? lead['status'] ?? 'New').toString();
                          
                          return LeadRowCard(
                            lead: lead,
                            showCall: _selectedFilter != 'All',
                            showStatus: _selectedFilter == 'All',
                            onCall: () => _confirmCall(context, lead),
                            currentTab: _selectedFilter,
                            enableTap: _selectedFilter != 'All' && _selectedFilter != 'New',
                            onCreateMeeting: _selectedFilter == 'Schedule'
                                ? () => _createMeeting(context, lead, 'Lead')
                                : null,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips ──────────────────────────────────────────────────────
  Widget _buildFilters() {
    final filters = [
      'All',
      'New',
      'Follow up',
      'Schedule',
      'Meeting',
      'Negotiation'
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: filters
            .map(
              (f) => Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: GestureDetector(
                  onTap: () {
                    _selectedFilter = f;
                    _applyFilters();
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
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
  // ── Call confirmation ────────────────────────────────────────────────
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

  void _createMeeting(BuildContext context, Map<String, dynamic> lead, String type) {
    showDialog(
      context: context,
      builder: (c) => MeetingDetailsPopup(lead: lead, enquiryType: type),
    ).then((val) {
      if (val == true) _refreshData();
    });
  }
}
