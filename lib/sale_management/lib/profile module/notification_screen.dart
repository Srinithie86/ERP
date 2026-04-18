import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool emailNotif = true;
  bool orderUpdates = true;
  bool paymentAlerts = true;
  bool lowStockAlerts = true;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    final items = [
      {
        'icon': Icons.email_outlined,
        'title': 'Email Notifications',
        'subtitle': 'Receive notifications via email',
        'value': emailNotif,
        'onChanged': (val) => setState(() => emailNotif = val),
      },
      {
        'icon': Icons.shopping_cart_outlined,
        'title': 'Order Updates',
        'subtitle': 'Get notified about order status changes',
        'value': orderUpdates,
        'onChanged': (val) => setState(() => orderUpdates = val),
      },
      {
        'icon': Icons.payments_outlined,
        'title': 'Payment Alerts',
        'subtitle': 'Receive alerts for new payments',
        'value': paymentAlerts,
        'onChanged': (val) => setState(() => paymentAlerts = val),
      },
      {
        'icon': Icons.inventory_2_outlined,
        'title': 'Low Stock Alerts',
        'subtitle': 'Get notified when stock is low',
        'value': lowStockAlerts,
        'onChanged': (val) => setState(() => lowStockAlerts = val),
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.bgCard,
      appBar: AppBar(
        title: const Text('Notification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.05,
          vertical: h * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage your notification settings',
              style: AppTextStyles.heading2,
            ),
            SizedBox(height: h * 0.03),
            ...items.map(
                  (item) => Padding(
                padding: EdgeInsets.only(bottom: h * 0.02),
                child: _buildNotifCard(
                  context,
                  icon: item['icon'] as IconData,
                  title: item['title'] as String,
                  subtitle: item['subtitle'] as String,
                  value: item['value'] as bool,
                  onChanged: item['onChanged'] as Function(bool),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required bool value,
        required Function(bool) onChanged,
      }) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: w * 0.04,
        vertical: h * 0.018,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: w * 0.11,
            height: w * 0.11,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: w * 0.055),
          ),
          SizedBox(width: w * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.sectionTitle),
                SizedBox(height: h * 0.004),
                Text(subtitle, style: AppTextStyles.label),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (val) => onChanged(val),
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}