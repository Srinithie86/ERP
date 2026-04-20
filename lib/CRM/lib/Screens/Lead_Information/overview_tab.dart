import 'package:flutter/material.dart';
import '../../Widgets/quick_action_button.dart';

class EnquiryOverviewDetailView extends StatelessWidget {
  final Map<String, dynamic>? lead;
  const EnquiryOverviewDetailView({super.key, this.lead});

  @override
  Widget build(BuildContext context) {
    if (lead == null) return const Center(child: Text('No lead info'));

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lead Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              _buildMainCard(context, screenWidth),
              const SizedBox(height: 100), // Space for Quick button
            ],
          ),
        ),
        // Quick Menu
        Positioned(bottom: 16, right: 16, child: QuickActionButton(lead: lead)),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, double screenWidth) {
    final name = (lead?['le_name'] ??
            lead?['cus_name'] ??
            lead?['contact_person'] ??
            'N/A')
        .toString();
    final priority = (lead?['priority'] ?? lead?['priority_name'] ?? 'High')
        .toString();
    final currentStatus = (lead?['lead_type'] ??
            lead?['lead_status'] ??
            lead?['status'] ??
            'New')
        .toString();
    final company = (lead?['comany_name'] ??
            lead?['company_name'] ??
            'SGS')
        .toString();
    final email = (lead?['email'] ?? '').toString();
    final phone = (lead?['mobile_1'] ?? '').toString();
    final phone2 = (lead?['mobile_2'] ?? '').toString();
    // final nri = (lead?['is_nri'] ?? 'Yes').toString();

    // Address Info
    final street = (lead?['street'] ?? '210, rto street').toString();
    final city = (lead?['city'] ?? 'Coimbatore').toString();
    final state = (lead?['state'] ?? 'Tamil nadu').toString();
    final pincode = (lead?['pincode'] ?? '641107').toString();

    // Lead Details
    final created = (lead?['enquiry_date'] ?? lead?['entry_date'] ?? '').toString();
    final source = (lead?['lead_source'] ?? lead?['source_name'] ?? 'Walk-in').toString();
    final leadStatus = (lead?['lead_status'] ?? lead?['status'] ?? 'Booked').toString();
    final reqNotes = (lead?['requirement_notes'] ?? '').toString();
    final remarks = (lead?['remarks'] ?? '').toString();
    final budget = (lead?['budget'] ?? '').toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: Color(0xFF1A56A1),
                        fontSize: 16,
                      ),
                      children: [
                        TextSpan(
                          text: name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const TextSpan(
                          text: ' | ',
                          style: TextStyle(color: Color(0xFF1A56A1)),
                        ),
                        const TextSpan(
                          text: 'Priority : ',
                          style: TextStyle(fontSize: 13, color: Colors.black),
                        ),
                        TextSpan(
                          text: priority,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8E6C9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    currentStatus,
                    style: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Basic Info
          _buildIconTextRow(Icons.business_outlined, company),
          _buildIconTextRow(Icons.email_outlined, email),
          _buildIconTextRow(Icons.phone_iphone_outlined, phone),
          _buildIconTextRow(Icons.phone_iphone_outlined, phone2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            // child: Text(
            //   'NRI - $nri',
            //   style: const TextStyle(
            //     color: Color(0xFF1A56A1),
            //     fontSize: 14,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
          ),
          const Divider(height: 32),
          // Address Information
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'Address Information',
              style: TextStyle(
                color: Color(0xFF1A56A1),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          _buildDetailRow('Address', street),
          _buildDetailRow('City', city),
          _buildDetailRow('State', state),
          _buildDetailRow('Pincode', pincode),
          const Divider(height: 32),
          // Lead Details
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Text(
              'Lead Details',
              style: TextStyle(
                color: Color(0xFF1A56A1),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          _buildDetailRow('Created', created),
          _buildDetailRow('Source', source),
          _buildDetailRow('Status', leadStatus, valueColor: Colors.green),
          _buildDetailRow('Budget', budget),
          _buildDetailRow('Requirement', reqNotes),
          _buildDetailRow('Remarks', remarks),
          const Divider(height: 32),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildIconTextRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1A56A1)),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF1A56A1), fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.grey.shade600,
                fontSize: 14,
                fontWeight: valueColor != null
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
