import 'package:flutter/material.dart';
import '../../Models/meeting_api.dart';

class EnquiryMeetingTab extends StatefulWidget {
  final Map<String, dynamic>? lead;
  const EnquiryMeetingTab({super.key, this.lead});

  @override
  State<EnquiryMeetingTab> createState() => _EnquiryMeetingTabState();
}

class _EnquiryMeetingTabState extends State<EnquiryMeetingTab> {
  bool _isLoading = false;
  List<dynamic> _meetings = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    try {
      final uid = (widget.lead?['id'] ?? widget.lead?['uid'] ?? '').toString();
      if (uid.isNotEmpty) {
        final res = await MeetingApi.fetchMeetings();
        if (mounted) {
          setState(() {
            _meetings = res
                .where((m) => m.uid.toString() == uid)
                .map((m) => m.toMap())
                .toList();
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching meetings in tab: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF26A69A)),
      );
    }

    if (_meetings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_rounded,
              size: 64,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No meetings found',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _meetings.length,
      itemBuilder: (context, index) {
        final meeting = _meetings[index];
        return _buildMeetingCard(meeting);
      },
    );
  }

  Widget _buildMeetingCard(Map<String, dynamic> meeting) {
    final date = meeting['meet_date'] ?? meeting['dtime'] ?? 'N/A';
    final mode = meeting['mode_of_meet'] ?? 'N/A';
    final location = meeting['loc'] ?? meeting['address'] ?? 'N/A';
    final feedback = meeting['feedback'] ?? '';
    final attendedBy = meeting['attended_by'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2F1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mode.toString().toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF26A69A),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  date.toString(),
                  style: const TextStyle(
                    color: Color(0xFF26A69A),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.location_on_outlined, 'Location', location),
                if (attendedBy.toString().isNotEmpty)
                  _buildInfoRow(Icons.person_outline, 'Attended By', attendedBy),
                if (feedback.toString().isNotEmpty)
                  _buildInfoRow(Icons.feedback_outlined, 'Feedback', feedback),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF26A69A)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
