import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/lead_service.dart';
import '../../Models/follow_up_api.dart';
import '../../Models/meeting_api.dart';
import '../../widgets/call_confirmation_popup.dart';
import '../../Widgets/lead_row_card.dart';
import 'add_lead_screen.dart';
import 'call_outcome_screen.dart';
import 'follow_up_lead_screen.dart';
import 'meeting_lead_screen.dart';

class NewLeadScreen extends StatefulWidget {
  const NewLeadScreen({super.key});

  @override
  State<NewLeadScreen> createState() => _NewLeadScreenState();
}

class _NewLeadScreenState extends State<NewLeadScreen> {
  bool _isLoading = false;
  List<dynamic> _leads = [];
  String _searchQuery = '';
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  List<dynamic> get _filteredLeads {
    if (_searchQuery.isEmpty) return _leads;
    return _leads.where((l) {
      final n = (l['le_name'] ??
              l['cus_name'] ??
              l['contact_person'] ??
              '')
          .toString()
          .toLowerCase();
      final p = (l['mobile_1'] ?? l['mobile_2'] ?? '').toString().toLowerCase();
      final id = (l['id'] ?? '').toString().toLowerCase();
      final uid = (l['uid'] ?? '').toString().toLowerCase();
      return n.contains(_searchQuery.toLowerCase()) ||
          p.contains(_searchQuery.toLowerCase()) ||
          id.contains(_searchQuery.toLowerCase()) ||
          uid.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final res = await LeadService.fetchLeads(enquiryType: 'Lead');
      final List<FollowUpModel> followUpLeads = await FollowUpApi.fetchFollowUpLeads(enquiryType: '1');
      final List<MeetingModel> meetings = await MeetingApi.fetchMeetings();
      
      final followUpAids = followUpLeads
          .where((f) => f.aid != null)
          .map((f) => f.aid.toString())
          .toSet();

      final meetingUids = meetings
          .map((m) => m.uid.toString())
          .toSet();

      if (mounted) {
        setState(() {
          _leads = res.where((l) {
            final id = l['id'].toString();
            final status = (l['lead_status'] ?? l['status'] ?? '').toString().toLowerCase();
            final outcome = (l['call_outcome'] ?? '').toString();
            final name = (l['le_name'] ?? l['cus_name'] ?? '').toString().toLowerCase().trim();
            final phone = (l['mobile_1'] ?? l['mobile_2'] ?? '').toString().trim();
            
            // 1. Check if this exact lead is already in the Follow-up list
            bool alreadyInFollowUp = followUpAids.contains(id) || followUpLeads.any((f) {
              final fName = f.cusName?.toLowerCase().trim() ?? '';
              return fName == name && name.isNotEmpty;
            });

            // 2. Check if in meeting list
            bool alreadyInMeeting = meetingUids.contains(id);

            // 2. Check internal flags
            bool hasOutcome = outcome.isNotEmpty && outcome != '0' && outcome != 'null';
            bool hasFollowUpStatus = status.contains('follow') || status == '1' || status == 'interest';
            
            // A lead is NEW only if it's NOT in follow-up/meeting and has no signals
            return !alreadyInFollowUp && !alreadyInMeeting && !hasOutcome && !hasFollowUpStatus;
          }).toList();

          // Sort by ID descending (newest first)
          _leads.sort((a, b) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        title: const Text(
          'New',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            color: const Color(0xFF26A69A),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      controller: _ctrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: 'Search...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const AddLeadScreen(isEnquiry: false),
                    ),
                  ).then((_) => _fetch()),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3F3D56),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Add\nLead',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Chips
          _buildFilterChips(),
          const SizedBox(height: 16),
          // List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF26A69A)),
                  )
                : _filteredLeads.isEmpty
                ? const Center(child: Text("No leads match search"))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredLeads.length,
                          itemBuilder: (c, i) {
                            final leadData =
                                (_filteredLeads[i] as Map).cast<String, dynamic>();
                            return LeadRowCard(
                              lead: leadData,
                              showStatus: false,
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

  Widget _buildFilterChips() {
    final filters = ['All', 'New', 'Follow up', 'Meeting'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters
            .map(
              (f) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () {
                    if (f == 'All') {
                      Navigator.pop(context); // Go back to All Leads
                    } else if (f == 'Follow up') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const FollowUpLeadScreen(),
                        ),
                      );
                    } else if (f == 'Meeting') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const MeetingLeadScreen(),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: f == 'New'
                          ? const Color(0xFF26A69A)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF26A69A)),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: f == 'New'
                            ? Colors.white
                            : const Color(0xFF26A69A),
                        fontWeight: FontWeight.w500,
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
            MaterialPageRoute(
              builder: (c) => CallOutcomeScreen(lead: lead, autoCall: true),
            ),
          ).then((_) => _fetch());
        },
      ),
    );
  }
}
