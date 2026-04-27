import 'package:flutter/material.dart';

class FollowUpScreen extends StatelessWidget {
  const FollowUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> followUps = [
      {
        'client': 'Global Tech',
        'stage': 'Proposal Sent',
        'budget': '\$12,000',
        'lastTalk': 'Discussed enterprise pricing and features.',
        'situation': 'Waiting for director\'s final approval.',
        'color': Colors.blue,
      },
      {
        'client': 'Innovate Co',
        'stage': 'Negotiation',
        'budget': '\$45,000',
        'lastTalk': 'Requested a 10% discount on 2-year plan.',
        'situation': 'Offer pending under review by management.',
        'color': Colors.orange,
      },
      {
        'client': 'Skyline Inc',
        'stage': 'Interested',
        'budget': '\$8,500',
        'lastTalk': 'Highly impressed with the demo session.',
        'situation': 'Requested a second demo for technical team.',
        'color': Colors.green,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Lead Follow-up',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: followUps.length,
        itemBuilder: (context, index) {
          final follow = followUps[index];
          return _buildFollowUpCard(follow);
        },
      ),
    );
  }

  Widget _buildFollowUpCard(Map<String, dynamic> follow) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  follow['client'],
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: Color(0xFF1A1A1A)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: (follow['color'] as Color).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    follow['stage'],
                    style: TextStyle(color: follow['color'] as Color, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.attach_money_rounded, 'Client Budget:', follow['budget'], Colors.green),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.comment_outlined, 'Last Discussion:', follow['lastTalk'], Colors.blueGrey),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.info_outline_rounded, 'Current Situation:', follow['situation'], Colors.redAccent),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF26A69A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Update Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                   padding: const EdgeInsets.all(8),
                   decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                   child: Icon(Icons.history_rounded, size: 20, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(fontSize: 13, color: Color(0xFF1F1F1F), fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
