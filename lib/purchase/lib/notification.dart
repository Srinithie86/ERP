import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;

    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF26A69A), Color(0xFF26A69A)],
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "Notification",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: width * 0.05,
        ),

        child: Column(
          children: [
            NotificationCard(
              icon: Icons.info_outline,
              iconColor: Colors.blue,
              title: "Invoice Due soon",
              message: "Invoice INV004 is due in 3 days",
              time: "3 hours ago",
            ),

            SizedBox(height: width * 0.04),

            NotificationCard(
              icon: Icons.close,
              iconColor: Colors.red,
              title: "PR Rejected",
              message: "PR105 has been rejected.",
              time: "5 hours ago",
            ),

            SizedBox(height: width * 0.04),

            NotificationCard(
              icon: Icons.access_time,
              iconColor: Colors.deepPurple,
              title: "Delivery Scheduled",
              message: "Item for PO198 will be delivered on march 10,26",
              time: "1 day ago",
            ),

            SizedBox(height: width * 0.04),

            NotificationCard(
              icon: Icons.check,
              iconColor: Colors.green,
              title: "Payment Processed",
              message: "Payment for Invoice INV001 has been completed",
              time: "1 day ago",
            ),

            SizedBox(height: width * 0.04),

            NotificationCard(
              icon: Icons.info_outline,
              iconColor: Colors.blue,
              title: "Pending Approval",
              message: "You have 3 purchase requests pending approval",
              time: "2 days ago",
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String message;
  final String time;

  const NotificationCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(width * 0.04),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),

        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: width * 0.08,
            height: width * 0.08,

            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 2),
            ),

            child: Icon(icon, size: width * 0.045, color: iconColor),
          ),

          SizedBox(width: width * 0.04),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: width * 0.042,
                        ),
                      ),
                    ),

                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: width * 0.032,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: width * 0.01),

                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: width * 0.035,
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

