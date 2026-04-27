import 'package:flutter/material.dart';
import 'package:crm/core/theme/app_theme.dart';

class CommunicationLogScreen extends StatefulWidget {
  const CommunicationLogScreen({super.key});

  @override
  State<CommunicationLogScreen> createState() => _CommunicationLogScreenState();
}

class _CommunicationLogScreenState extends State<CommunicationLogScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          _buildFilterRow(),
          const SizedBox(height: 24),
          _buildDataTable(),
          const SizedBox(height: 24),
          _buildPagination(),
          const SizedBox(height: 48),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Communication Logs – Email & SMS',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'View and manage all communication activities',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('Refresh Data', style: TextStyle(fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade500,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _metricCard(
            '5',
            'Total Emails Sent',
            Icons.email,
            Colors.indigo.shade400,
            Colors.indigo.shade50,
          ),
          const SizedBox(width: 16),
          _metricCard(
            '5',
            'Total SMS Sent',
            Icons.sms,
            Colors.cyan.shade400,
            Colors.cyan.shade50,
          ),
          const SizedBox(width: 16),
          _metricCard(
            '2',
            'Failed Messages',
            Icons.warning_rounded,
            Colors.pink.shade400,
            Colors.pink.shade50,
          ),
          const SizedBox(width: 16),
          _metricCard(
            '4',
            'Today\'s Activity',
            Icons.trending_up,
            Colors.orange.shade400,
            Colors.orange.shade50,
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String value, String label, IconData icon, Color iconColor, Color bgColor) {
    return Container(
      width: 200,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 300,
              child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, email, phone, or message...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryTeal, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildDropdownFilter('All Types'),
          const SizedBox(width: 16),
          _buildDropdownFilter('All Statuses'),
          const SizedBox(width: 16),
          _buildDropdownFilter('All Time'),
        ],
      ),
      ),
    );
  }

  Widget _buildDropdownFilter(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(hint, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 1050, // Exact sum of column widths
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: const Row(
                  children: [
                    SizedBox(width: 120, child: Text('Date & Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    SizedBox(width: 80, child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    SizedBox(width: 150, child: Text('Recipient Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    SizedBox(width: 200, child: Text('Contact', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    SizedBox(width: 300, child: Text('Subject / Message Preview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    SizedBox(width: 80, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    SizedBox(width: 120, child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                  ],
                ),
              ),
              // Data Rows
              _dataRow('Oct 15, 2023\n09:30 AM', 'Email', 'John Smith', 'john.smith@example.com', 'Quarterly Report & Project Updates', 'Sent'),
              _dataRow('Oct 15, 2023\n11:45 AM', 'SMS', 'Emily Davis', '+1 (555) 123-4567', 'Your appointment reminder', 'Sent'),
              _dataRow('Oct 14, 2023\n02:20 PM', 'Email', 'Robert Chen', 'robert.chen@business.com', 'Invoice #INV-2023-0456', 'Pending'),
              _dataRow('Oct 14, 2023\n04:05 PM', 'SMS', 'Michael Brown', '+1 (555) 876-5432', 'Security alert on your account', 'Failed'),
              _dataRow('Oct 13, 2023\n10:15 AM', 'Email', 'Jessica Wilson', 'jessica.wilson@company.org', 'Welcome to Our Platform!', 'Sent', isLast: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dataRow(String date, String type, String name, String contact, String subject, String status, {bool isLast = false}) {
    Color typeColor = type == 'Email' ? Colors.indigo.shade500 : Colors.cyan.shade500;
    Color typeBgColor = type == 'Email' ? Colors.indigo.shade50 : Colors.cyan.shade50;

    Color statusColor;
    Color statusBgColor;
    if (status == 'Sent') {
      statusColor = Colors.green.shade600;
      statusBgColor = Colors.green.shade50;
    } else if (status == 'Pending') {
      statusColor = Colors.amber.shade700;
      statusBgColor = Colors.amber.shade50;
    } else {
      statusColor = Colors.red.shade600;
      statusBgColor = Colors.red.shade50;
    }

    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              date,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
            ),
          ),
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeBgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  type,
                  style: TextStyle(color: typeColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 150,
            child: Text(
              name,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          ),
          SizedBox(
            width: 200,
            child: Text(
              contact,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          ),
          SizedBox(
            width: 300,
            child: Text(
              subject,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 80,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade50,
                foregroundColor: Colors.indigo.shade700,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text('View Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _paginationButton(Icons.chevron_left, false),
        const SizedBox(width: 8),
        _paginationText('1', true),
        const SizedBox(width: 8),
        _paginationText('2', false),
        const SizedBox(width: 8),
        _paginationButton(Icons.chevron_right, false),
      ],
    );
  }

  Widget _paginationButton(IconData icon, bool isActive) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? Colors.indigo.shade500 : Colors.white,
        border: Border.all(color: isActive ? Colors.indigo.shade500 : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 18,
          color: isActive ? Colors.white : Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _paginationText(String text, bool isActive) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? Colors.indigo.shade500 : Colors.white,
        border: Border.all(color: isActive ? Colors.indigo.shade500 : Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        '2026 © Smart Global Solutions',
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
        ),
      ),
    );
  }
}
