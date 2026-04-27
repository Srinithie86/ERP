import 'package:flutter/material.dart';
import '../../Widgets/quick_action_button.dart';

class EnquiryInformationTab extends StatelessWidget {
  final Map<String, dynamic>? lead;
  const EnquiryInformationTab({super.key, this.lead});

  @override
  Widget build(BuildContext context) {
    if (lead == null) return const Center(child: Text('No lead info'));

    final projectValue = (lead?['customer_budget'] ?? lead?['project_value'] ?? '₹20,00,00').toString();
    final name = (lead?['le_name'] ?? lead?['cus_name'] ?? 'Ganesh').toString();
    final leadNo = (lead?['le_no'] ?? lead?['lead_no'] ?? lead?['led_no'] ?? 'L001').toString();
    final phone = (lead?['mobile_1'] ?? '7894561231').toString();
    final whatsapp = (lead?['mobile_1'] ?? '7894561231').toString();
    final email = (lead?['email'] ?? 'Ganesh@gmail.com').toString();
    final dateCreated = (lead?['entry_date'] ?? '05 December 2025 - 10:45 AM').toString();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField('Project Value', projectValue),
                    _buildField('Name', name),
                    _buildField('Lead No', leadNo),
                    _buildField('Phone No', phone),
                    _buildField('WhatsApp No', whatsapp),
                    _buildField('Email ID', email),
                    _buildField('Date Created', dateCreated),
                  ],
                ),
              ),
              const SizedBox(height: 100), // Space for Quick button
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: QuickActionButton(lead: lead),
        ),
      ],
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
