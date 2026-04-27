// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:crm/Models/lead_api.dart';
// import '../../widgets/call_confirmation_popup.dart';
// import '../../Widgets/lead_row_card.dart';
// import '../../Widgets/responsive_layout.dart';
// import 'add_lead_screen.dart';
// import 'call_outcome_screen.dart';
// import 'new_lead_screen.dart';
// import 'follow_up_lead_screen.dart';
// import '../../Models/follow_up_api.dart';
// import 'meeting_lead_screen.dart';
// import 'negotiation_lead_screen.dart';
//
// class LeadsScreen extends StatefulWidget {
//   const LeadsScreen({super.key});
//
//   @override
//   State<LeadsScreen> createState() => _LeadsScreenState();
// }
//
// class _LeadsScreenState extends State<LeadsScreen> {
//
//   String _selectedFilter = 'All';
//   bool _isLoading = false;
//   List<dynamic> _allLeads = [];
//   String _searchQuery = '';
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _refreshData();
//   }
//
//   Future<void> _refreshData() async {
//     setState(() => _isLoading = true);
//     try {
//       final leads = await LeadApi.fetchLeads();
//       final followUpLeads = await FollowUpApi.fetchFollowUpLeads();
//
//       // Create a set of UIDs that have follow-ups
//       final followUpUids = followUpLeads.map((f) => f['uid'].toString()).toSet();
//
//       if (mounted) {
//         setState(() {
//           _allLeads = leads.map((l) {
//             final id = l['id'].toString();
//             if (followUpUids.contains(id)) {
//               final fInfo = followUpLeads.firstWhere((f) => f['uid'].toString() == id);
//               return {
//                 ...l as Map,
//                 ...fInfo as Map,
//                 'status': 'Follow up',
//                 'lead_status': 'Follow up'
//               }.cast<String, dynamic>();
//             }
//             return {
//               ...l as Map,
//               'status': 'New',
//               'lead_status': 'New'
//             }.cast<String, dynamic>();
//           }).toList();
//
//           final existingIds = leads.map((l) => l['id'].toString()).toSet();
//           for (var f in followUpLeads) {
//             if (!existingIds.contains(f['uid'].toString())) {
//               _allLeads.add({
//                 ...f as Map,
//                 'id': f['uid'],
//                 'status': 'Follow up',
//                 'lead_status': 'Follow up'
//               }.cast<String, dynamic>());
//             }
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint("Error: $e");
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   List<dynamic> get _filteredLeads {
//     if (_searchQuery.isEmpty) return _allLeads;
//     return _allLeads.where((l) {
//       final n = (l['le_name'] ??
//               l['cus_name'] ??
//               l['contact_person'] ??
//               '')
//           .toString()
//           .toLowerCase();
//       final req = (l['requirement_notes'] ?? '').toString().toLowerCase();
//       final p = (l['mobile_1'] ?? l['mobile_2'] ?? '').toString().toLowerCase();
//       final id = (l['id'] ?? '').toString().toLowerCase();
//       final uid = (l['uid'] ?? '').toString().toLowerCase();
//       return n.contains(_searchQuery.toLowerCase()) ||
//           p.contains(_searchQuery.toLowerCase()) ||
//           req.contains(_searchQuery.toLowerCase()) ||
//           id.contains(_searchQuery.toLowerCase()) ||
//           uid.contains(_searchQuery.toLowerCase());
//     }).toList();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveLayout(
//       mobile: _buildScaffold(context, isMobile: true),
//       tablet: _buildScaffold(context, isMobile: false),
//     );
//   }
//
//   Widget _buildScaffold(BuildContext context, {required bool isMobile}) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF1F1F1),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF26A69A),
//         elevation: 0,
//         centerTitle: false,
//         title: Text(
//           'Lead',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 20.sp,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         actions: [
//           IconButton(
//             icon: Icon(
//               Icons.calendar_month_outlined,
//               color: Colors.white,
//               size: 24.r,
//             ),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Container(
//             color: const Color(0xFF26A69A),
//             padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Container(
//                     height: 45.h,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                     child: TextField(
//                       controller: _searchController,
//                       onChanged: (v) => setState(() => _searchQuery = v),
//                       style: TextStyle(fontSize: 14.sp),
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(
//                           Icons.search,
//                           color: Colors.grey,
//                           size: 20.r,
//                         ),
//                         hintText: 'Search...',
//                         border: InputBorder.none,
//                         contentPadding: EdgeInsets.symmetric(vertical: 15.h),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 GestureDetector(
//                   onTap: () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (c) => const AddLeadScreen(isEnquiry: false),
//                     ),
//                   ).then((_) => _refreshData()),
//                   child: Container(
//                     height: 45.h,
//                     padding: EdgeInsets.symmetric(horizontal: 16.w),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF3131A6),
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                     child: Center(
//                       child: Text(
//                         'Add\nLead',
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 14.sp,
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 16.h),
//           _buildFilters(),
//           SizedBox(height: 16.h),
//           Expanded(
//             child: _isLoading
//                 ? const Center(
//                     child: CircularProgressIndicator(color: Color(0xFF26A69A)),
//                   )
//                 : _filteredLeads.isEmpty
//                 ? const Center(child: Text("No leads found"))
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 16.w,
//                           vertical: 8.h,
//                         ),
//                       ),
//                     ],
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFilters() {
//     final filters = ['All', 'New', 'Follow up', 'Meeting', 'Negotiation'];
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       padding: EdgeInsets.symmetric(horizontal: 16.w),
//       child: Row(
//         children: filters
//             .map(
//               (f) => Padding(
//                 padding: EdgeInsets.only(right: 12.w),
//                 child: GestureDetector(
//                   onTap: () {
//                     if (f == 'New') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (c) => const NewLeadScreen(),
//                         ),
//                       );
//                     } else if (f == 'Follow up') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (c) => const FollowUpLeadScreen(),
//                         ),
//                       );
//                     } else if (f == 'Meeting') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (c) => const MeetingLeadScreen(),
//                         ),
//                       );
//                     } else if (f == 'Negotiation') {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (c) => const NegotiationLeadScreen(),
//                         ),
//                       );
//                     }
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 24.w,
//                       vertical: 8.h,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _selectedFilter == f
//                           ? const Color(0xFF26A69A)
//                           : Colors.white,
//                       borderRadius: BorderRadius.circular(25.r),
//                       border: Border.all(color: const Color(0xFF26A69A)),
//                     ),
//                     child: Text(
//                       f,
//                       style: TextStyle(
//                         color: _selectedFilter == f
//                             ? Colors.white
//                             : const Color(0xFF26A69A),
//                         fontWeight: FontWeight.w500,
//                         fontSize: 14.sp,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//             .toList(),
//       ),
//     );
//   }
//
//   void _confirmCall(BuildContext context, Map<String, dynamic> lead) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       isScrollControlled: true,
//       builder: (c) => CallConfirmationPopup(
//         lead: lead,
//         onCancel: () => Navigator.pop(c),
//         onConfirm: () async {
//           Navigator.pop(c);
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (c) => CallOutcomeScreen(lead: lead, autoCall: true),
//             ),
//           ).then((_) => _refreshData());
//         },
//       ),
//     );
//   }
// }


import 'package:crm/Services/lead_service.dart';
import 'package:crm/Screens/EnquiryScreen/enquiry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:crm/Models/lead_api.dart';
import 'package:crm/Models/follow_up_api.dart';
import 'package:crm/Models/meeting_api.dart';
import 'package:crm/Services/lead_service.dart';
import '../../widgets/call_confirmation_popup.dart';
import '../../Widgets/responsive_layout.dart';
import 'add_lead_screen.dart';
import 'call_outcome_screen.dart';
import 'new_lead_screen.dart';
import 'follow_up_lead_screen.dart';
import 'meeting_lead_screen.dart';
import 'negotiation_lead_screen.dart';
import '../Lead_Information/enquiry_tabs_view.dart';

// ─── Mock data (shown when API unavailable) ────────────────────────────────
final List<Map<String, dynamic>> _mockLeads = [
  {
    'id': '1',
    'le_name': 'Arun Kumar',
    'mobile_1': '98756 32123',
    'mobile_2': '98756 32123',
    'company': 'Micro fin soft',
    'email': 'crmapp@gmail.com',
    'created_at': '16 March 2026',
    'status': 'New',
    'lead_status': 'New',
  },
  {
    'id': '2',
    'le_name': 'Arun Kumar',
    'mobile_1': '98756 32123',
    'mobile_2': '98756 32123',
    'company': 'Micro fin soft',
    'email': 'crmapp@gmail.com',
    'created_at': '16 March 2026',
    'status': 'Follow up',
    'lead_status': 'Follow up',
  },
  {
    'id': '3',
    'le_name': 'Arun Kumar',
    'mobile_1': '98756 32123',
    'mobile_2': '98756 32123',
    'company': 'Micro fin soft',
    'email': 'crmapp@gmail.com',
    'created_at': '16 March 2026',
    'status': 'Meeting',
    'lead_status': 'Meeting',
  },
  {
    'id': '4',
    'le_name': 'Arun Kumar',
    'mobile_1': '98756 32123',
    'mobile_2': '98756 32123',
    'company': 'Micro fin soft',
    'email': 'crmapp@gmail.com',
    'created_at': '16 March 2026',
    'status': 'Deal Won',
    'lead_status': 'Deal Won',
  },
  {
    'id': '5',
    'le_name': 'Arun Kumar',
    'mobile_1': '98756 32123',
    'mobile_2': '98756 32123',
    'company': 'Micro fin soft',
    'email': 'crmapp@gmail.com',
    'created_at': '16 March 2026',
    'status': 'Deal Lost',
    'lead_status': 'Deal Lost',
  },
];

// ─── Status colour helper ──────────────────────────────────────────────────
Color _statusColor(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'new':
      return const Color(0xFF00740C);
    case 'follow up':
    case 'follow-up':
      return const Color(0xFF3B53BD);
    case 'meeting':
    case 'negotiation':
      return const Color(0xFFFF6400);
    case 'deal won':
      return const Color(0xFF00740C);
    case 'deal lost':
      return const Color(0xFF000000);
    default:
      return const Color(0xFF26A69A);
  }
}

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  String _selectedFilter = 'All';
  bool _isLoading = false;
  bool _isApiAvailable = true;
  List<dynamic> _allLeads = [];
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
      List leads = [];
      List<FollowUpModel> followUpLeads = [];
      List<MeetingModel> meetings = [];
      bool apiSuccess = false;

      try {
        leads = await LeadService.fetchLeads(enquiryType: 'Lead');
        followUpLeads = await FollowUpApi.fetchFollowUpLeads(enquiryType: '1');
        meetings = await MeetingApi.fetchMeetings();
        apiSuccess = leads.isNotEmpty || followUpLeads.isNotEmpty || meetings.isNotEmpty;
        
        // Merge Logic
        if (mounted) {
          setState(() {
            _isApiAvailable = true;
            _allLeads = leads.map((l) {
              final id = l['id'].toString();
              final outcome = (l['call_outcome'] ?? '').toString();
              final lStatus = (l['lead_status'] ?? l['status'] ?? '').toString().toLowerCase();

              // 1. Check Meetings first
              final mInfo = meetings.firstWhere(
                (m) => m.uid.toString() == id,
                orElse: () => MeetingModel(),
              );
              
              if (mInfo.id != null) {
                return {
                  ...l as Map,
                  ...mInfo.toMap(),
                  'status': 'Meeting',
                  'lead_status': 'Meeting',
                }.cast<String, dynamic>();
              }

              // 2. Check Follow ups
              final fInfo = followUpLeads.firstWhere(
                (f) => f.aid.toString() == id,
                orElse: () => FollowUpModel(),
              );
              
              bool hasInternalSignal = (outcome.isNotEmpty && outcome != '0') || lStatus.contains('follow') || lStatus.contains('inter');

              if (fInfo.id != null || hasInternalSignal) {
                return {
                  ...l as Map,
                  if (fInfo.id != null) ...fInfo.toMap(),
                  'status': 'Follow up',
                  'lead_status': 'Follow up',
                }.cast<String, dynamic>();
              }

              return {
                ...l as Map,
                'status': 'New',
                'lead_status': (l['lead_status'] ?? 'New').toString(),
              }.cast<String, dynamic>();
            }).toList();

            // Sort by ID descending (newest first)
            _allLeads.sort((a, b) {
              int idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
              int idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
              return idB.compareTo(idA);
            });
          });
        }
      } catch (e) {
        debugPrint("API fetch error: $e");
        apiSuccess = false;
      }

      if (!apiSuccess) {
        if (mounted) {
          setState(() {
            _isApiAvailable = false;
            _allLeads = List<Map<String, dynamic>>.from(_mockLeads);
          });
        }
        return;
      }
    } catch (e) {
      debugPrint("Unexpected error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Filtered leads ─────────────────────────────────────────────────────
  List<dynamic> get _filteredLeads {
    List<dynamic> base = _allLeads;

    if (_selectedFilter != 'All') {
      base = base.where((l) {
        final s =
        (l['lead_status'] ?? l['status'] ?? '').toString().toLowerCase();
        return s == _selectedFilter.toLowerCase();
      }).toList();
    }

    if (_searchQuery.isEmpty) return base;
    return base.where((l) {
      final n = (l['le_name'] ?? l['cus_name'] ?? l['contact_person'] ?? '')
          .toString()
          .toLowerCase();
      final req = (l['requirement_notes'] ?? '').toString().toLowerCase();
      final p =
      (l['mobile_1'] ?? l['mobile_2'] ?? '').toString().toLowerCase();
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
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: TextStyle(fontSize: 13.sp),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey, size: 18.r),
                        hintText: 'Search...',
                        hintStyle: TextStyle(
                            fontSize: 13.sp, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 11.h),
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
                      builder: (c) =>
                      const AddLeadScreen(isEnquiry: false),
                    ),
                  ).then((_) => _refreshData()),
                  child: Container(
                    width: 38.w,
                    height: 38.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3131A6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child:
                    Icon(Icons.add, color: Colors.white, size: 22.r),
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
                child: CircularProgressIndicator(
                    color: Color(0xFF26A69A)))
                : _filteredLeads.isEmpty
                ? const Center(child: Text('No leads found'))
                : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _filteredLeads.length,
              itemBuilder: (ctx, i) {
                final lead =
                _filteredLeads[i] as Map<String, dynamic>;
                // ✅ All tab → full card with email + arrow + wide call button
                // ✅ Other tabs → compact card, call icon beside number, no email, no arrow
                return _selectedFilter == 'All'
                    ? _buildAllTabCard(lead)
                    : _buildNewTabCard(lead);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // ALL TAB CARD
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildAllTabCard(Map<String, dynamic> lead) {
    final name = (lead['cus_name'] ??
        lead['le_name'] ??
        lead['contact_person'] ??
        'Unknown')
        .toString();
    final phone1 = (lead['mobile_1'] ?? lead['mobile'] ?? lead['phone'] ?? lead['cid'] ?? '').toString();
    final phone2 = (lead['mobile_2'] ?? '').toString();
    final company =
    (lead['company'] ?? lead['requirement_notes'] ?? lead['other_required'] ?? '').toString();
    final email = (lead['email'] ?? lead['email_id'] ?? '').toString();
    final date =
    (lead['created_at'] ?? lead['follow_up_date'] ?? lead['dtime'] ?? '').toString();

    final budget = (lead['customer_budget'] ?? lead['budget'] ?? '').toString();
    final project = (lead['required_project'] ?? lead['required_project_name'] ?? lead['project'] ?? '').toString();
    final summary = (lead['call_summary'] ?? lead['feedback'] ?? lead['requirement_notes'] ?? '').toString();

    final status =
    (lead['lead_status'] ?? lead['status'] ?? 'New').toString();
    final statusCol = _statusColor(status);

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
        margin: EdgeInsets.only(bottom: 12.h),
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
              // Name + status + arrow
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 15.r, color: Colors.black87),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      name,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black, // ✅ black
                      ),
                    ),
                  ),
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

              // Phone 1
              _infoRow(Icons.phone_outlined, phone1,
                  const Color(0xFF00740C)), // ✅ green
              SizedBox(height: 3.h),

              // Phone 2
              if (phone2.isNotEmpty && phone2 != phone1) ...[
                _infoRow(Icons.phone_outlined, phone2,
                    const Color(0xFF00740C)),
                SizedBox(height: 3.h),
              ],

              // Company ✅ orange
              if (company.isNotEmpty) ...[
                _infoRow(Icons.business_outlined, company,
                    const Color(0xFFFF6400)),
                SizedBox(height: 3.h),
              ],


              // Date — blue
              if (date.isNotEmpty)
                _infoRow(Icons.calendar_month, date,
                    const Color(0xFF1565C0)),

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
              // Summary
              if (summary.isNotEmpty && summary != 'N/A') ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.notes, summary, Colors.black54),
              ],
              // ✅ NO Call button in All tab
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════
  // NEW / FOLLOW UP / MEETING / NEGOTIATION TAB CARD
  // ══════════════════════════════════════════════════════════════════════
  Widget _buildNewTabCard(Map<String, dynamic> lead) {
    final name = (lead['cus_name'] ??
        lead['le_name'] ??
        lead['contact_person'] ??
        'Unknown')
        .toString();
    final phone1 = (lead['mobile_1'] ?? lead['mobile'] ?? lead['phone'] ?? lead['cid'] ?? '').toString();
    final phone2 = (lead['mobile_2'] ?? '').toString();
    final company =
    (lead['company'] ?? lead['requirement_notes'] ?? lead['other_required'] ?? '').toString();
    final date =
    (lead['created_at'] ?? lead['follow_up_date'] ?? lead['dtime'] ?? '').toString();

    final budget = (lead['customer_budget'] ?? lead['budget'] ?? '').toString();
    final project = (lead['required_project'] ?? lead['required_project_name'] ?? lead['project'] ?? '').toString();
    final summary = (lead['call_summary'] ?? lead['feedback'] ?? lead['requirement_notes'] ?? '').toString();
    final status = (lead['lead_status'] ?? lead['status'] ?? 'New').toString();

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
        margin: EdgeInsets.only(bottom: 10.h),
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
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name only — no arrow, no status badge
              Row(
                children: [
                  Icon(Icons.person_outline,
                      size: 14.r, color: Colors.black87),
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
                ],
              ),

              SizedBox(height: 5.h),

              // Phone 1 + call icon
              _phoneRowWithCallIcon(phone1, lead),

              // Phone 2 + call icon
              if (phone2.isNotEmpty && phone2 != phone1) ...[
                SizedBox(height: 2.h),
                _phoneRowWithCallIcon(phone2, lead),
              ],

              // Company
              if (company.isNotEmpty) ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.business_outlined, company,
                    const Color(0xFFFF6400)),
              ],

              // Date
              if (date.isNotEmpty) ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.calendar_today_outlined, date,
                    const Color(0xFF1565C0)),
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
              // Summary
              if (summary.isNotEmpty && summary != 'N/A') ...[
                SizedBox(height: 3.h),
                _infoRow(Icons.notes, summary, Colors.black54),
              ],

              const SizedBox(height: 12),
              // ✅ Small Call Now Button aligned to the right
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 110.w,
                  height: 32.h,
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmCall(context, lead),
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
                      backgroundColor: const Color(0xFF00740C), // Green
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r), // More rounded
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Phone row with small call icon container on right ─────────────────
  Widget _phoneRowWithCallIcon(String phone, Map<String, dynamic> lead) {
    return Row(
      children: [
        Icon(Icons.phone_outlined,
            size: 13.r, color: const Color(0xFF00740C)),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            phone,
            style: TextStyle(
              fontSize: 11.sp,
              color: const Color(0xFF00740C), // ✅ green
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // ✅ Small call icon box beside number
      ],
    );
  }

  // ── Generic info row ──────────────────────────────────────────────────
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

  // ── Filter chips ──────────────────────────────────────────────────────
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
                  onTap: () {
                    setState(() => _selectedFilter = f);
                    // Removed navigation to separate screens to stay on this screen as requested
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: _selectedFilter == f
                          ? const Color(0xFF26A69A)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25.r),
                      border:
                      Border.all(color: const Color(0xFF26A69A)),
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
            ).toList(),
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
              builder: (c) =>
                  CallOutcomeScreen(lead: lead, autoCall: true),
            ),
          ).then((_) => _refreshData());
        },
      ),
    );
  }
}
