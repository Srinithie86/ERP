import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E234E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E234E)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Mark all read',
              style: GoogleFonts.outfit(
                color: const Color(0xFF26A69A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('TODAY'),
          _buildNotificationItem(
            icon: Icons.inventory_2_rounded,
            color: Colors.redAccent,
            title: 'Low Stock Alert',
            message: '8 products in the category "Engine Parts" are running low on stock.',
            time: '2h ago',
            isUnread: true,
          ),
          _buildNotificationItem(
            icon: Icons.payments_rounded,
            color: Colors.green,
            title: 'Payment Received',
            message: 'Payment of ₹45,000 received from Hariharan Distributors.',
            time: '5h ago',
            isUnread: true,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('YESTERDAY'),
          _buildNotificationItem(
            icon: Icons.local_shipping_rounded,
            color: Colors.blue,
            title: 'Order Dispatched',
            message: 'Order #ORD-2026-452 has been dispatched to Kumar Enterprises.',
            time: '1d ago',
            isUnread: false,
          ),
          _buildNotificationItem(
            icon: Icons.person_add_rounded,
            color: Colors.purple,
            title: 'New Dealer Request',
            message: 'A new dealer registration request from "Global Traders" is pending approval.',
            time: '1d ago',
            isUnread: false,
          ),
          _buildNotificationItem(
            icon: Icons.analytics_outlined,
            color: Colors.orange,
            title: 'Monthly Report Ready',
            message: 'The sales performance report for March 2026 is now available for download.',
            time: '1d ago',
            isUnread: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[400],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? color.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnread ? color.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E234E),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
