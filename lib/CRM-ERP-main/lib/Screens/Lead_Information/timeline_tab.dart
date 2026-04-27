import 'package:flutter/material.dart';
import '../../Widgets/quick_action_button.dart';

class EnquiryTimelineTab extends StatelessWidget {
  final List<dynamic> timelineData;
  final bool isLoading;
  final VoidCallback? onAddActivity;
  final ValueChanged<bool>? onEditModeChanged;

  final Map<String, dynamic>? lead;

  const EnquiryTimelineTab({
    super.key,
    this.lead,
    required this.timelineData,
    required this.isLoading,
    this.onAddActivity,
    this.onEditModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Hardcoded example data as requested
    final List<Map<String, dynamic>> displayData = timelineData.isNotEmpty
        ? timelineData.cast<Map<String, dynamic>>()
        : [
            {
              'call_date': '2025-12-08',
              'call_time': '11:30 AM',
              'call_outcome_name': 'Follow-up Meeting made',
              'user_name': 'Rajesh Kumar',
              'call_summary': 'Customer showed interest',
            },
            {
              'call_date': '2025-12-05',
              'call_time': '10:30 AM',
              'call_outcome_name': 'Follow-up call made',
              'user_name': 'Rajesh Kumar',
              'call_summary': 'Customer showed interest',
            },
            {
              'call_date': '2025-12-05',
              'call_time': '09:00 AM',
              'call_outcome_name': 'Email sent',
              'user_name': 'System',
              'call_summary': 'Welcome email with property details',
            },
            {
              'call_date': '2025-12-05',
              'call_time': '08:45 AM',
              'call_outcome_name': 'Enquiry created',
              'user_name': 'Website',
              'call_summary': 'Lead captured from website form',
            },
          ];

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header for adding activity
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_circle,
                      color: Color(0xFF26A69A),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Add Activity',
                        style: TextStyle(
                          color: Color(0xFF90EE90),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.edit_note,
                      color: Color(0xFF2E7D32),
                      size: 28,
                    ),
                  ],
                ),
              ),
              // Timeline List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayData.length,
                itemBuilder: (context, index) {
                  final activity = displayData[index];
                  return _buildTimelineItem(
                    context,
                    activity,
                    index == displayData.length - 1,
                  );
                },
              ),
              const SizedBox(height: 100), // Space for Quick button
            ],
          ),
        ),
        Positioned(bottom: 16, right: 16, child: QuickActionButton(lead: lead)),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    Map<String, dynamic> activity,
    bool isLast,
  ) {
    final date = (activity['call_date'] ?? '').toString();
    final time = (activity['call_time'] ?? '').toString();
    final action =
        (activity['call_outcome_name'] ?? activity['call_outcome'] ?? '')
            .toString();
    final user = (activity['user_name'] ?? '').toString();
    final summary = (activity['call_summary'] ?? '').toString();

    // Determine colors based on action type
    Color actionColor = const Color(0xFF26A69A); // Default teal

    if (action.toLowerCase().contains('meeting')) {
      actionColor = const Color(0xFF90EE90); // Green
    } else if (action.toLowerCase().contains('call')) {
      actionColor = const Color(0xFFAB47BC); // Purple
    } else if (action.toLowerCase().contains('email')) {
      actionColor = const Color(0xFF00ACC1); // Teal/Cyan
    } else if (action.toLowerCase().contains('enquiry created')) {
      actionColor = const Color(0xFF7E57C2); // Deep Purple
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 8),
          Column(
            children: [
              const Icon(
                Icons.access_time_outlined,
                color: Color(0xFF26A69A),
                size: 24,
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: isLast ? Colors.transparent : const Color(0xFF26A69A),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      children: _buildActionSpans(action, actionColor),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$date $time',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildActionSpans(String action, Color highlightColor) {
    List<String> parts = action.split(' ');
    List<TextSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      String part = parts[i];
      bool isHighlight = false;

      // Identify key words for coloring
      if (part.toLowerCase().contains('meeting') ||
          part.toLowerCase().contains('call') ||
          part.toLowerCase().contains('email') ||
          part.toLowerCase().contains('created')) {
        isHighlight = true;
      }

      spans.add(
        TextSpan(
          text: part + (i == parts.length - 1 ? '' : ' '),
          style: TextStyle(color: isHighlight ? highlightColor : Colors.black),
        ),
      );
    }

    return spans;
  }
}
