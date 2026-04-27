import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LeadEnquiryScreen extends StatelessWidget {
  const LeadEnquiryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 60,
          title: const Text(
            'Lead & Enquiry',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A1A), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFF26A69A),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF26A69A).withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'New Leads'),
                  Tab(text: 'Enquiries'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildLeadsList(),
            _buildEnquiriesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadsList() {
    final leads = [
      {'name': 'Robert Fox', 'company': 'Global Tech', 'source': 'Website', 'date': 'Today, 10:30 AM', 'status': 'New'},
      {'name': 'Jane Cooper', 'company': 'Innovate Co', 'source': 'LinkedIn', 'date': 'Yesterday', 'status': 'Contacted'},
      {'name': 'Cody Fisher', 'company': 'Skyline Inc', 'source': 'Phone', 'date': '2 Days ago', 'status': 'Waiting'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: leads.length,
      itemBuilder: (context, index) {
        final lead = leads[index];
        return _buildPremiumDataCard(
          lead['name']!,
          lead['company']!,
          lead['source']!,
          lead['date']!,
          lead['status']!,
          Icons.person_rounded,
          Colors.blue,
          index,
        );
      },
    );
  }

  Widget _buildEnquiriesList() {
    final enquiries = [
      {'name': 'Bessie Cooper', 'subject': 'Product Pricing', 'source': 'Email', 'date': '1 hour ago', 'status': 'Pending'},
      {'name': 'Esther Howard', 'subject': 'Partnership', 'source': 'Contact Form', 'date': '5 hours ago', 'status': 'Closed'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      itemCount: enquiries.length,
      itemBuilder: (context, index) {
        final enq = enquiries[index];
        return _buildPremiumDataCard(
          enq['name']!,
          enq['subject']!,
          enq['source']!,
          enq['date']!,
          enq['status']!,
          Icons.chat_bubble_rounded,
          Colors.orange,
          index,
        );
      },
    );
  }

  Widget _buildPremiumDataCard(
    String name,
    String subtitle,
    String source,
    String date,
    String status,
    IconData icon,
    Color themeColor,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: themeColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (status == 'New' || status == 'Pending') ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: (status == 'New' || status == 'Pending') ? Colors.red : Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(Icons.alternate_email_rounded, source),
                const SizedBox(width: 20),
                _buildInfoItem(Icons.access_time_rounded, date),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade300),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (100 * index).ms).slideY(begin: 0.1, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

