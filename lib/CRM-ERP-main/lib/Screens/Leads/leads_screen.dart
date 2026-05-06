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

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = false;
  List<dynamic> _allLeads = [];
  List<dynamic> _displayLeads = []; // Cached list for UI
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
        LeadService.fetchLeads(enquiryType: 'Lead'),
        FollowUpApi.fetchFollowUpLeads(enquiryType: '1'),
        MeetingApi.fetchMeetings(),
        ScheduleApi.fetchSchedules(),
      ]);

      final List leads = results[0] as List;
      final List<FollowUpModel> followUpLeads = results[1] as List<FollowUpModel>;
      final List<MeetingModel> meetings = results[2] as List<MeetingModel>;
      final List<ScheduleModel> schedules = results[3] as List<ScheduleModel>;

      if (mounted) {
        // Create maps for O(1) lookup
        final Map<String, MeetingModel> meetingMap = {};
        for (var m in meetings) {
          if (m.aid != null) meetingMap[m.aid.toString()] = m;
          if (m.leCode != null && m.leCode!.isNotEmpty) meetingMap[m.leCode!] = m;
        }

        final Map<String, ScheduleModel> scheduleMap = {};
        for (var s in schedules) {
          if (s.aid != null) scheduleMap[s.aid.toString()] = s;
          if (s.leCode != null && s.leCode!.isNotEmpty) scheduleMap[s.leCode!] = s;
        }

        final Map<String, FollowUpModel> followUpMap = {};
        for (var f in followUpLeads) {
          if (f.aid != null) followUpMap[f.aid.toString()] = f;
          if (f.leCode != null && f.leCode!.isNotEmpty) followUpMap[f.leCode!] = f;
        }

        final matchedFollowUpIds = <int>{};
        final matchedMeetingIds = <int>{};
        final matchedScheduleIds = <int>{};

        final List<Map<String, dynamic>> processedLeads = leads.map((l) {
          final id = l['id'].toString();
          final leCode = (l['le_code'] ?? '').toString();
          final lStatus = (l['lead_status'] ?? l['status'] ?? '').toString().toLowerCase();

          // 1. Check Meetings
          MeetingModel? mInfo = meetingMap[id] ?? (leCode.isNotEmpty ? meetingMap[leCode] : null);
          
          // 2. Check Schedules
          ScheduleModel? sInfo = scheduleMap[id] ?? (leCode.isNotEmpty ? scheduleMap[leCode] : null);

          bool isMeeting = mInfo != null && mInfo.id != null;
          bool isSchedule = (sInfo != null && sInfo.id != null) || lStatus.contains('schedule') || lStatus == '3';
          bool isNegotiation = lStatus.contains('negotiation') || lStatus == '2';

          // 3. Check Follow-ups
          FollowUpModel? fInfo = followUpMap[id] ?? (leCode.isNotEmpty ? followUpMap[leCode] : null);
          
          bool hasInternalFollowUp = (lStatus.contains('follow') && !lStatus.contains('missed')) || lStatus == '1' || lStatus == 'interest';

          String currentStatus = 'New';
          if (isMeeting) {
            currentStatus = 'Meeting';
          } else if (isSchedule) {
            currentStatus = 'Schedule';
          } else if ((fInfo != null && fInfo.id != null) || hasInternalFollowUp) {
            currentStatus = 'Follow up';
          } else if (isNegotiation) {
            currentStatus = 'Negotiation';
          }

          final Map<String, dynamic> merged = Map<String, dynamic>.from(l as Map);

          if (fInfo != null && fInfo.id != null) {
            matchedFollowUpIds.add(fInfo.id!);
            fInfo.toMap().forEach((key, value) {
              if (value != null && value.toString().isNotEmpty && value.toString() != 'null') {
                merged[key] = value;
              }
            });
          }

          if (isMeeting) {
            matchedMeetingIds.add(mInfo!.id!);
            mInfo.toMap().forEach((key, value) {
              if (value != null && value.toString().isNotEmpty && value.toString() != 'null') {
                merged[key] = value;
              }
            });
          }

          if (sInfo != null && sInfo.id != null) {
            matchedScheduleIds.add(sInfo.id!);
            sInfo.toMap().forEach((key, value) {
              if (value != null && value.toString().isNotEmpty && value.toString() != 'null') {
                merged[key] = value;
              }
            });
          }

          merged['status'] = currentStatus;
          merged['lead_status'] = currentStatus;
          merged['isMeeting'] = isMeeting;
          merged['isNegotiation'] = isNegotiation;
          merged['isSchedule'] = isSchedule;

          return merged;
        }).toList();

        // Add unmatched records
        for (var f in followUpLeads) {
          if (f.id != null && !matchedFollowUpIds.contains(f.id)) {
            final Map<String, dynamic> fMap = f.toMap();
            fMap['status'] = 'Follow up';
            fMap['lead_status'] = 'Follow up';
            processedLeads.add(fMap);
          }
        }

        for (var m in meetings) {
          if (m.id != null && !matchedMeetingIds.contains(m.id)) {
            final Map<String, dynamic> mMap = m.toMap();
            mMap['status'] = 'Meeting';
            mMap['lead_status'] = 'Meeting';
            processedLeads.add(mMap);
          }
        }

        for (var s in schedules) {
          if (s.id != null && !matchedScheduleIds.contains(s.id)) {
            final Map<String, dynamic> sMap = s.toMap();
            sMap['status'] = 'Schedule';
            sMap['lead_status'] = 'Schedule';
            processedLeads.add(sMap);
          }
        }

        _allLeads = processedLeads;
        _allLeads.sort((a, b) {
          int idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
          int idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
          return idB.compareTo(idA);
        });

        _applyFilters();
      }
    } catch (e) {
      debugPrint("Leads fetch error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<dynamic> base = _allLeads;

    if (_selectedFilter != 'All') {
      base = base.where((l) {
        final s = (l['lead_status'] ?? l['status'] ?? '').toString().toLowerCase();
        final sClean = s.replaceAll('_', ' ').trim();

        if (_selectedFilter == 'New') {
          return sClean == 'new' || sClean == '' || sClean == 'missed followup';
        }
        if (_selectedFilter == 'Follow up') {
          return sClean == 'follow up';
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

    if (mounted) {
      setState(() {
        _displayLeads = base;
      });
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
                              _displayLeads[i] as Map<String, dynamic>;
                          final status = (lead['lead_status'] ?? lead['status'] ?? 'New').toString();
                          
                          return LeadRowCard(
                            lead: lead,
                            showCall: _selectedFilter != 'All',
                            showStatus: _selectedFilter == 'All',
                            onCall: () => _confirmCall(context, lead),
                            isAllTab: _selectedFilter == 'All',
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
        onConfirm: () async {
          Navigator.pop(c);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => CallOutcomeScreen(lead: lead),
            ),
          ).then((_) => _refreshData());
        },
      ),
    );
  }
}
