import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/lead_service.dart';
import '../../Widgets/call_confirmation_popup.dart';
import '../../widgets/lead_row_card.dart';
import 'add_lead_screen.dart';
import 'call_outcome_screen.dart';
import '../../Models/meeting_api.dart';
import 'new_lead_screen.dart';
import 'follow_up_lead_screen.dart';

class MeetingLeadScreen extends StatefulWidget {
  const MeetingLeadScreen({super.key});

  @override
  State<MeetingLeadScreen> createState() => _MeetingLeadScreenState();
}

class _MeetingLeadScreenState extends State<MeetingLeadScreen> {
  bool _isLoading = false;
  List<Map<String, dynamic>> _leads = [];
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final meetings = await MeetingApi.fetchMeetings();
      debugPrint("Fetched ${meetings.length} meetings");

      if (mounted) {
        setState(() {
          _leads = meetings.map((m) {
            final map = m.toMap();
            return {
              // Use meeting fields directly — cus_name and mobile_1 are stored in meeting
              'id': map['id'],
              'uid': map['uid'],
              'cid': map['cid'],
              'aid': map['aid'],
              'cus_name': map['cus_name'] ?? '',
              'le_name': map['cus_name'] ?? '',
              'mobile_1': map['mobile_1'] ?? '',
              'mobile_2': map['mobile_2'] ?? '',
              'meet_date': map['meet_date'] ?? '',
              'time': map['time'] ?? '',
              'loc': map['loc'] ?? '',
              'address': map['address'] ?? '',
              'mode_of_meet': map['mode_of_meet'] ?? '',
              'attended_by': map['attended_by'] ?? '',
              'dtime': map['dtime'] ?? '',
              'status': 'Meeting',
              'lead_status': 'Meeting',
            };
          }).toList();

          // Sort by meeting id descending (newest first)
          _leads.sort((a, b) {
            int idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
            int idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
            return idB.compareTo(idA);
          });

          debugPrint("Meeting screen showing ${_leads.length} records");
        });
      }
    } catch (e) {
      debugPrint("Error fetching meetings: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<dynamic> get _filteredLeads {
    final q = _ctrl.text.toLowerCase();
    if (q.isEmpty) return _leads;
    return _leads.where((l) {
      final name = (l['cus_name'] ?? '').toString().toLowerCase();
      final phone = (l['mobile_1'] ?? '').toString().toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        title: const Text(
          'Meeting',
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
                      onChanged: (v) => setState(() {}),
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
                ? const Center(child: Text("No meeting leads found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredLeads.length,
                    itemBuilder: (c, i) {
                      final meetingData = (_filteredLeads[i] as Map).cast<String, dynamic>();
                      return LeadRowCard(
                        lead: {...meetingData, 'status': 'Meeting'},
                        showStatus: true,
                        onCall: () => _confirmCall(
                          context,
                          meetingData,
                        ),
                      );
                    },
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
                    if (f == 'All')
                      Navigator.pop(context);
                    else if (f == 'New')
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const NewLeadScreen(),
                        ),
                      );
                    else if (f == 'Follow up')
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (c) => const FollowUpLeadScreen(),
                        ),
                      );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: f == 'Meeting'
                          ? const Color(0xFF26A69A)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: const Color(0xFF26A69A)),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: f == 'Meeting'
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
