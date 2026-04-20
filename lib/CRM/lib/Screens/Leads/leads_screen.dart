import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crm/Models/lead_api.dart';
import '../../widgets/call_confirmation_popup.dart';
import '../../Widgets/lead_row_card.dart';
import '../../Widgets/responsive_layout.dart';
import 'add_lead_screen.dart';
import 'call_outcome_screen.dart';
import 'new_lead_screen.dart';
import 'follow_up_lead_screen.dart';
import '../../Models/follow_up_api.dart';
import 'meeting_lead_screen.dart';
import 'negotiation_lead_screen.dart';

class LeadsScreen extends StatefulWidget {
  const LeadsScreen({super.key});

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  final String _selectedFilter = 'All';
  bool _isLoading = false;
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
      final leads = await LeadApi.fetchLeads();
      final followUpLeads = await FollowUpApi.fetchFollowUpLeads();
      
      // Create a set of UIDs that have follow-ups
      final followUpUids = followUpLeads.map((f) => f['uid'].toString()).toSet();

      if (mounted) {
        setState(() {
          _allLeads = leads.map((l) {
            final id = l['id'].toString();
            if (followUpUids.contains(id)) {
              final fInfo = followUpLeads.firstWhere((f) => f['uid'].toString() == id);
              return {
                ...l as Map,
                ...fInfo as Map,
                'status': 'Follow up',
                'lead_status': 'Follow up'
              }.cast<String, dynamic>();
            }
            return {
              ...l as Map,
              'status': 'New',
              'lead_status': 'New'
            }.cast<String, dynamic>();
          }).toList();
          
          final existingIds = leads.map((l) => l['id'].toString()).toSet();
          for (var f in followUpLeads) {
            if (!existingIds.contains(f['uid'].toString())) {
              _allLeads.add({
                ...f as Map,
                'id': f['uid'],
                'status': 'Follow up',
                'lead_status': 'Follow up'
              }.cast<String, dynamic>());
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredLeads {
    if (_searchQuery.isEmpty) return _allLeads;
    return _allLeads.where((l) {
      final n = (l['le_name'] ??
              l['cus_name'] ??
              l['contact_person'] ??
              '')
          .toString()
          .toLowerCase();
      final req = (l['requirement_notes'] ?? '').toString().toLowerCase();
      final p = (l['mobile_1'] ?? l['mobile_2'] ?? '').toString().toLowerCase();
      return n.contains(_searchQuery.toLowerCase()) ||
          p.contains(_searchQuery.toLowerCase()) ||
          req.contains(_searchQuery.toLowerCase());
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
            icon: Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
              size: 24.r,
            ),
            onPressed: () {},
          ),
        ],
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
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: TextStyle(fontSize: 14.sp),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20.r,
                        ),
                        hintText: 'Search...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: const Color(0xFF26A69A),
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 12.w),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const AddLeadScreen(isEnquiry: false),
                    ),
                  ).then((_) => _refreshData()),
                  child: Container(
                    height: 50.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F3D56),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        'Add\nLead',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _buildFilters(),
          SizedBox(height: 16.h),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF26A69A)),
                  )
                : _filteredLeads.isEmpty
                ? const Center(child: Text("No leads found"))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        child: Text(
                          'All Lead',
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
                          itemCount: _filteredLeads.length,
                          itemBuilder: (c, i) {
                            final leadData = (_filteredLeads[i] as Map).cast<String, dynamic>();
                            return LeadRowCard(
                              lead: leadData,
                              showStatus: true,
                              showCall: false,
                              onCall: () => _confirmCall(
                                context,
                                leadData,
                              ),
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
    final filters = ['All', 'New', 'Follow up', 'Meeting', 'Negotiation'];
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
                    if (f == 'New') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const NewLeadScreen(),
                        ),
                      );
                    } else if (f == 'Follow up') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const FollowUpLeadScreen(),
                        ),
                      );
                    } else if (f == 'Meeting') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const MeetingLeadScreen(),
                        ),
                      );
                    } else if (f == 'Negotiation') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const NegotiationLeadScreen(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
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
          final String phone =
              lead['mobile_1']?.toString().replaceAll(RegExp(r'[^\d+]'), '') ??
              '';
          if (phone.isNotEmpty) {
            final Uri launchUri = Uri(scheme: 'tel', path: phone);
            try {
              if (await canLaunchUrl(launchUri)) {
                await launchUrl(launchUri);
                Future.delayed(const Duration(seconds: 2), () {
                  if (mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => CallOutcomeScreen(lead: lead),
                      ),
                    ).then((_) => _refreshData());
                  }
                });
              }
            } catch (e) {
              debugPrint('Error: $e');
            }
          }
        },
      ),
    );
  }
}
