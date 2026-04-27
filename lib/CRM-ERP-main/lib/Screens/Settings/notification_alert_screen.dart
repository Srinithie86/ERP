import 'package:flutter/material.dart';

class NotificationAlertScreen extends StatefulWidget {
  const NotificationAlertScreen({super.key});

  @override
  State<NotificationAlertScreen> createState() =>
      _NotificationAlertScreenState();
}

class _NotificationAlertScreenState extends State<NotificationAlertScreen> {
  bool leadUpdates = true;
  bool reportAlerts = true;
  bool systemUpdates = false;
  bool accountSecurity = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF26A69A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Notification & Alert',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification & Alerts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).textTheme.titleLarge?.color ??
                    Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You\'ll receive alerts here about important updates — from new leads to task reminders. Customize your preferences in Settings.',
              style: TextStyle(
                fontSize: 14,
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
            _buildToggleItem(
              'Lead Updates',
              leadUpdates,
              (val) => setState(() => leadUpdates = val),
              showTick: true,
            ),
            const SizedBox(height: 16),
            _buildToggleItem(
              'Report Alerts',
              reportAlerts,
              (val) => setState(() => reportAlerts = val),
              showTick: true,
            ),
            const SizedBox(height: 16),
            _buildToggleItem(
              'System Updates',
              systemUpdates,
              (val) => setState(() => systemUpdates = val),
            ),
            const SizedBox(height: 16),
            _buildToggleItem(
              'Account & Security Alerts',
              accountSecurity,
              (val) => setState(() => accountSecurity = val),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged, {
    bool showTick = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFF26A69A),
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey.shade300,
          thumbIcon: showTick && value
              ? WidgetStateProperty.all(
                  const Icon(Icons.check, color: Color(0xFF26A69A), size: 16),
                )
              : null,
        ),
      ),
    );
  }
}
