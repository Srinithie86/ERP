import 'package:flutter/material.dart';

class MeetingVisitScreen extends StatelessWidget {
  const MeetingVisitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> meetings = [
      {
        'agent': 'John Smith',
        'client': 'Global Tech',
        'type': 'Google Meet',
        'time': '10:00 AM',
        'date': 'Tomorrow',
        'icon': Icons.video_camera_front_outlined,
        'color': Colors.blue,
      },
      {
        'agent': 'Sarah J.',
        'client': 'Innovate Co',
        'type': 'Physical Visit',
        'time': '02:30 PM',
        'date': 'Oct 15',
        'icon': Icons.location_on_outlined,
        'color': Colors.red,
      },
      {
        'agent': 'Mike Davis',
        'client': 'Skyline Inc',
        'type': 'WhatsApp Video',
        'time': '11:15 AM',
        'date': 'Oct 16',
        'icon': Icons.videocam_outlined,
        'color': Colors.green,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Meetings & Visits',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          return _buildMeetingCard(meeting);
        },
      ),
    );
  }

  Widget _buildMeetingCard(Map<String, dynamic> meeting) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: (meeting['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
                  child: Icon(meeting['icon'] as IconData, color: meeting['color'] as Color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meeting['client'], style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(meeting['type'], style: TextStyle(color: meeting['color'] as Color, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(meeting['time'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(meeting['date'], style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_pin_outlined, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Assigned to ${meeting['agent']}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: (meeting['color'] as Color).withOpacity(0.05),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    meeting['type'] == 'Physical Visit' ? 'Show Map' : 'Join Call',
                    style: TextStyle(color: meeting['color'] as Color, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
