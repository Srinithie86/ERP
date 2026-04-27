import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _allNotifications = [];

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedFilter == 'All') return _allNotifications;
    return _allNotifications
        .where((notif) => notif['type'] == _selectedFilter)
        .toList();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF26A69A)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      // Logic to filter by date could go here
    }
  }

  Future<void> _makeCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''),
    );
    try {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch dialer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Follow-up'),
                _buildFilterChip('Deal'),
                _buildFilterChip('Meeting'),
                _buildFilterChip('Missed'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Latest Notification Header & Pick Date
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Latest Notification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      'Sort by Date ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF26A69A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Pick Date',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Notification List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredNotifications.length,
              itemBuilder: (context, index) {
                final notif = _filteredNotifications[index];
                return _buildNotificationCard(
                  title: notif['title'],
                  description: notif['description'],
                  time: notif['time'],
                  showPhone: notif['showPhone'] ?? false,
                  onCallTap: () {
                    if (notif['phone'] != null) {
                      _makeCall(notif['phone']);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF26A69A) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF26A69A)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF26A69A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String description,
    required String time,
    bool showPhone = false,
    VoidCallback? onCallTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9EFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD1C4E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555555),
                    height: 1.4,
                  ),
                ),
              ),
              if (showPhone)
                GestureDetector(
                  onTap: onCallTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.call,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
