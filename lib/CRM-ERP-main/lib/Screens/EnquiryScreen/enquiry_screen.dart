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

class EnquiryScreen extends StatefulWidget {
  const EnquiryScreen({super.key});

  @override
  State<EnquiryScreen> createState() => _EnquiryScreenState();
}

class _EnquiryScreenState extends State<EnquiryScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = false;
  List<dynamic> _enquiries = [];
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
        LeadService.fetchLeads(enquiryType: 'Enquiry'),
        FollowUpApi.fetchFollowUpLeads(enquiryType: '2'),
        MeetingApi.fetchMeetings(enquiryType: '2'),
      ]);

      final List res = results[0] as List;
      final List<FollowUpModel> followUpLeads = results[1] as List<FollowUpModel>;
      final List<MeetingModel> meetings = (results[2] as List).cast<MeetingModel>();
      
      if (mounted) {
        // Create Maps for O(1) lookup
        final Map<String, FollowUpModel> followUpMap = {};
        for (var f in followUpLeads) {
          if (f.bid != null) followUpMap[f.bid.toString()] = f;
        }

        final Map<String, MeetingModel> meetingMap = {};
        for (var m in meetings) {
          if (m.bid != null) meetingMap[m.bid.toString()] = m;
        }

        _enquiries = res.map((l) {
          final leadMap = Map<String, dynamic>.from(l as Map);
          final id = leadMap['id'].toString();
          final outcome = (leadMap['call_outcome'] ?? '').toString();
          final leadStatus = (leadMap['lead_status'] ?? leadMap['status'] ?? '').toString().toLowerCase();
          
          final fInfo = followUpMap[id];
          final meetingEntry = meetingMap[id];
          
          bool isMissed = leadStatus.contains('missed');
          bool hasFollowUp = (fInfo != null && fInfo.id != null) || outcome.isNotEmpty || (leadStatus.contains('follow') && !isMissed) || leadStatus == 'interest';
          bool isMeeting = meetingEntry != null;
          bool isNegotiation = leadStatus.contains('negotiation') || leadStatus == '2';
          bool isSchedule = leadStatus.contains('schedule') || leadStatus == '3';
          
          String currentStatus = 'New';
          if (isMissed) {
            currentStatus = 'New';
          } else if (isMeeting) {
            currentStatus = 'Meeting';
          } else if (isNegotiation) {
            currentStatus = 'Negotiation';
          } else if (isSchedule) {
            currentStatus = 'Schedule';
          } else if (hasFollowUp) {
            currentStatus = 'Follow up';
          }
          
          return {
            ...leadMap,
            if (fInfo != null && fInfo.id != null) ...fInfo.toMap(),
            if (isMeeting) ...meetingEntry!.toMap(),
            'hasFollowUp': hasFollowUp,
            'isMeeting': isMeeting,
            'isNegotiation': isNegotiation,
            'isSchedule': isSchedule,
            'status': currentStatus,
          }.cast<String, dynamic>();
        }).toList();

        _enquiries.sort((a, b) {
          int idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
          int idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
          return idB.compareTo(idA);
        });

        _applyFilters();
      }
    } catch (e) {
      debugPrint("Enquiry refresh error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<dynamic> base = _enquiries;
    
    if (_selectedFilter != 'All') {
      base = base.where((l) {
        final s = l['status'].toString().toLowerCase();
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
        final p = (l['mobile_1'] ?? l['mobile_2'] ?? '').toString().toLowerCase();
        final id = (l['id'] ?? '').toString().toLowerCase();
        return n.contains(query) || p.contains(query) || id.contains(query);
      }).toList();
    }

    if (mounted) {
      setState(() {
        _displayEnquiries = base;
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
                            final lead = _displayEnquiries[i] as Map<String, dynamic>;
                            return LeadRowCard(
                              lead: lead,
                              showStatus: true,
                              showCall: _selectedFilter != 'All',
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
}
