import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Services/lead_service.dart';
import '../../Widgets/lead_row_card.dart';
import '../../Widgets/call_confirmation_popup.dart';
import '../../Widgets/responsive_layout.dart';
import 'referral_new_screen.dart';
import 'referral_meeting_screen.dart';
import '../Leads/call_outcome_screen.dart';
import '../Leads/add_lead_screen.dart';
import '../../Models/follow_up_api.dart';

class ReferralFollowUpScreen extends StatefulWidget {
  const ReferralFollowUpScreen({super.key});

  @override
  State<ReferralFollowUpScreen> createState() => _ReferralFollowUpScreenState();
}

class _ReferralFollowUpScreenState extends State<ReferralFollowUpScreen> {
  bool _isLoading = false;
  List<dynamic> _referrals = [];
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
      final res = await LeadService.fetchLeads(enquiryType: 'Referral');
      final List<FollowUpModel> followUpLeads = await FollowUpApi.fetchFollowUpLeads(enquiryType: '3');
      
      final followUpDids = followUpLeads
          .where((f) => f.did != null)
          .map((f) => f.did.toString())
          .toSet();

      if (mounted) {
        setState(() {
          _referrals = res.where((l) {
            final id = l['id'].toString();
            final outcome = (l['call_outcome'] ?? '').toString();
            final status = (l['lead_status'] ?? l['status'] ?? '').toString().toLowerCase();
            
            return followUpDids.contains(id) || (outcome.isNotEmpty && outcome != '0') || status.contains('follow');
          }).map((l) {
            final id = l['id'].toString();
            final fInfo = followUpLeads.firstWhere(
              (f) => f.did.toString() == id,
              orElse: () => FollowUpModel(),
            );
            return {
              ...l as Map,
              if (fInfo.id != null) ...fInfo.toMap(),
              'status': 'Follow up',
              'lead_status': 'Follow up',
            }.cast<String, dynamic>();
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
          'Follow up Referral',
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
                : _filteredReferrals.isEmpty
                    ? const Center(child: Text("No follow up referrals found"))
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            child: Text(
                              'Follow up Referral (${_filteredReferrals.length})',
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
                              itemCount: _filteredReferrals.length,
                              itemBuilder: (c, i) {
                                final lead = _filteredReferrals[i] as Map<String, dynamic>;
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
                    if (f == 'New') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (c) => const ReferralNewScreen()),
                      );
                    }
                    if (f == 'Meeting') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (c) => const ReferralMeetingScreen()),
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: f == 'Follow up' ? const Color(0xFF26A69A) : Colors.white,
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(color: const Color(0xFF26A69A)),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: f == 'Follow up' ? Colors.white : const Color(0xFF26A69A),
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
