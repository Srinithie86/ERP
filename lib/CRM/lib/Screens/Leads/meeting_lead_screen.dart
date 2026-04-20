import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/lead_service.dart';
import '../../Widgets/call_confirmation_popup.dart';
import '../../Widgets/lead_row_card.dart';
import 'add_lead_screen.dart';
import 'call_outcome_screen.dart';
import 'new_lead_screen.dart';
import 'follow_up_lead_screen.dart';

class MeetingLeadScreen extends StatefulWidget {
  const MeetingLeadScreen({super.key});

  @override
  State<MeetingLeadScreen> createState() => _MeetingLeadScreenState();
}

class _MeetingLeadScreenState extends State<MeetingLeadScreen> {
  bool _isLoading = false;
  List<dynamic> _leads = [];
  final TextEditingController _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final res = await LeadService.fetchLeads(enquiryType: 'Lead');
      if (mounted) {
        setState(() {
          // In a real app, you'd filter by status 'Meeting'
          _leads = res
              .where(
                (l) => (l['lead_status'] ?? l['status'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains('meeting'),
              )
              .toList();
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
                : _leads.isEmpty
                ? const Center(child: Text("No meeting leads found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _leads.length,
                    itemBuilder: (c, i) => LeadRowCard(
                      lead: _leads[i] as Map<String, dynamic>,
                      showStatus: false,
                      onCall: () => _confirmCall(
                        context,
                        _leads[i] as Map<String, dynamic>,
                      ),
                    ),
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
                      Navigator.pop(context);
                    } else if (f == 'New')
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
          final p =
              lead['mobile_1']?.toString().replaceAll(RegExp(r'[^\d+]'), '') ??
              '';
          if (p.isNotEmpty) {
            final uri = Uri.parse('tel:$p');
            if (await canLaunchUrl(uri)) await launchUrl(uri);
            // Navigate to CallOutcomeScreen instead of showing a popup
            Future.delayed(
              const Duration(seconds: 2),
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (c) => CallOutcomeScreen(lead: lead),
                ),
              ).then((_) => _fetch()),
            );
          }
        },
      ),
    );
  }
}
