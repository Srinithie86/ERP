import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Services/lead_service.dart';
import '../../Widgets/lead_row_card.dart';
import '../../Widgets/call_confirmation_popup.dart';
import 'call_outcome_screen.dart';

class NegotiationLeadScreen extends StatefulWidget {
  const NegotiationLeadScreen({super.key});
  @override
  State<NegotiationLeadScreen> createState() => _NegotiationLeadScreenState();
}

class _NegotiationLeadScreenState extends State<NegotiationLeadScreen> {
  bool _isLoading = false;
  List<dynamic> _leads = [];

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
          _leads = res
              .where(
                (l) => (l['lead_status'] ?? l['status'] ?? '')
                    .toString()
                    .toLowerCase()
                    .contains('negotiation'),
              )
              .toList();

          // Sort by ID descending (newest first)
          _leads.sort((a, b) {
            int idA = int.tryParse(a['id']?.toString() ?? '0') ?? 0;
            int idB = int.tryParse(b['id']?.toString() ?? '0') ?? 0;
            return idB.compareTo(idA);
          });
        });
      }
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
          'Negotiation Leads',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                    child: const TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Search...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF26A69A)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
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
