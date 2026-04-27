import 'package:crm/Services/lead_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:crm/Models/lead_api.dart';
import '../../widgets/call_confirmation_popup.dart';
import '../../Widgets/responsive_layout.dart';
import '../Leads/add_lead_screen.dart';
import '../Leads/call_outcome_screen.dart';
import '../../Models/follow_up_api.dart';
import '../../Models/meeting_api.dart';
import '../Lead_Information/enquiry_tabs_view.dart';
import '../../Widgets/lead_row_card.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = false;
  List<dynamic> _referrals = [];
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    try {
      final res = await LeadService.fetchLeads(enquiryType: 'Referral');
      final List<FollowUpModel> followUpLeads = await FollowUpApi.fetchFollowUpLeads(enquiryType: '3');
      final List<MeetingModel> meetings = await MeetingApi.fetchMeetings();
      
      final followUpDids = followUpLeads
          .where((f) => f.did != null)
          .map((f) => f.did.toString())
          .toSet();

      if (mounted) {
        setState(() {
          _referrals = res.map((l) {
            final leadMap = Map<String, dynamic>.from(l as Map);
            final id = leadMap['id'].toString();
            final outcome = (leadMap['call_outcome'] ?? '').toString();
            final leadStatus = (leadMap['lead_status'] ?? leadMap['status'] ?? '').toString().toLowerCase();
            
            // Find follow-up for this referral (type 3 use did)
            final fInfo = followUpLeads.firstWhere(
              (f) => f.did.toString() == id,
              orElse: () => FollowUpModel(),
            );

            bool hasFollowUp = fInfo.id != null || outcome.isNotEmpty || leadStatus.contains('follow') || leadStatus == 'interest';
            
            // Find meeting data for this lead if it exists
            final meetingEntry = meetings.firstWhere(
              (m) => m.uid.toString() == id,
              orElse: () => MeetingModel(),
            );
            
            bool isMeeting = meetingEntry.id != null;
            bool isNegotiation = leadStatus.contains('negotiation') || leadStatus == '2';
            
            final finalMap = <String, dynamic>{
              ...leadMap,
              if (fInfo.id != null) ...fInfo.toMap(),
              if (isMeeting) ...meetingEntry.toMap(),
              'hasFollowUp': hasFollowUp,
              'isMeeting': isMeeting,
              'isNegotiation': isNegotiation,
              'status': isMeeting ? 'Meeting' : (isNegotiation ? 'Negotiation' : (hasFollowUp ? 'Follow up' : 'New')),
            };
            return finalMap;
          }).toList();

          // Sort by ID descending (newest first)
          _referrals.sort((a, b) {
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

  List<dynamic> get _filteredReferrals {
    List<dynamic> base = _referrals;
    
    if (_selectedFilter != 'All') {
      base = base.where((l) {
        final s = l['status'].toString().toLowerCase();
        return s == _selectedFilter.toLowerCase();
      }).toList();
    }

    if (_searchQuery.isEmpty) return base;
    return base.where((l) {
      final n = (l['le_name'] ?? l['cus_name'] ?? l['contact_person'] ?? '').toString().toLowerCase();
      final p = (l['mobile_1'] ?? l['mobile_2'] ?? '').toString().toLowerCase();
      final req = (l['requirement_notes'] ?? '').toString().toLowerCase();
      final id = (l['id'] ?? '').toString().toLowerCase();
      final uid = (l['uid'] ?? '').toString().toLowerCase();
      return n.contains(_searchQuery.toLowerCase()) || 
             p.contains(_searchQuery.toLowerCase()) || 
             req.contains(_searchQuery.toLowerCase()) ||
             id.contains(_searchQuery.toLowerCase()) ||
             uid.contains(_searchQuery.toLowerCase());
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
          'Referral',
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
                      builder: (c) => const AddLeadScreen(isReferral: true),
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
                : _filteredReferrals.isEmpty
                ? const Center(child: Text("No referrals found"))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _filteredReferrals.length,
                          itemBuilder: (c, i) {
                            final lead = Map<String, dynamic>.from(_filteredReferrals[i] as Map);
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
    final filters = ['All', 'New', 'Follow up', 'Meeting', 'Negotiation'];
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
    setState(() => _selectedFilter = filter);
  }
}
