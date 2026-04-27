import 'package:flutter/material.dart';

class CallSummaryScreen extends StatelessWidget {
  const CallSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> logs = [
      {'agent': 'John Smith', 'client': 'Global Tech', 'duration': '15m 20s', 'time': '10:15 AM', 'status': 'Interested'},
      {'agent': 'Sarah J.', 'client': 'Innovate Co', 'duration': '08m 45s', 'time': '11:45 AM', 'status': 'Follow-up'},
      {'agent': 'Mike Davis', 'client': 'Skyline Inc', 'duration': '02m 10s', 'time': '01:20 PM', 'status': 'Busy'},
      {'agent': 'Emily Chen', 'client': 'NextGen Solutions', 'duration': '12m 30s', 'time': '03:40 PM', 'status': 'Converted'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Call Summary',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.calendar_month_outlined, color: Colors.black)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Call Logs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return _buildCallLogCard(log);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallLogCard(Map<String, dynamic> log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.call_made_rounded, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(log['agent'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('Spoke with ${log['client']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              Text(
                log['duration'],
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF26A69A), fontSize: 14),
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
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 6),
                  Text(log['time'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF0F4F4), borderRadius: BorderRadius.circular(8)),
                child: Text(
                  log['status'],
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF26A69A)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
