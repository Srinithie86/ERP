import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  // Purchase Activities toggles
  bool _prApproval = true;
  bool _poGenerated = true;
  bool _rfqReceived = true;
  bool _invoiceStatus = true;
  bool _generalUpdates = true;

  // Help Center toggles
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotification = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    return Scaffold(
      backgroundColor: Colors.white,
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notification Settings",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.025,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Purchase Activities", width),
              SizedBox(height: height * 0.012),
              _buildSettingsCard([
                _buildNotificationItem(
                  icon: Icons.assignment_outlined,
                  title: "PR Approval",
                  value: _prApproval,
                  onChanged: (val) => setState(() => _prApproval = val),
                  width: width,
                ),
                _buildNotificationItem(
                  icon: Icons.shopping_cart_outlined,
                  title: "PO Generated",
                  value: _poGenerated,
                  onChanged: (val) => setState(() => _poGenerated = val),
                  width: width,
                ),
                _buildNotificationItem(
                  icon: Icons.description_outlined,
                  title: "RFQ Received",
                  value: _rfqReceived,
                  onChanged: (val) => setState(() => _rfqReceived = val),
                  width: width,
                ),
                _buildNotificationItem(
                  icon: Icons.receipt_long_outlined,
                  title: "Invoice Status",
                  value: _invoiceStatus,
                  onChanged: (val) => setState(() => _invoiceStatus = val),
                  width: width,
                ),
                _buildNotificationItem(
                  icon: Icons.history,
                  title: "General Updates",
                  value: _generalUpdates,
                  onChanged: (val) => setState(() => _generalUpdates = val),
                  width: width,
                  isLast: true,
                ),
              ]),

              SizedBox(height: height * 0.035),

              _buildSectionHeader("Help Center", width),
              SizedBox(height: height * 0.012),
              _buildSettingsCard([
                _buildNotificationItem(
                  icon: Icons.notifications_outlined,
                  title: "Push Notifications",
                  value: _pushNotifications,
                  onChanged: (val) =>
                      setState(() => _pushNotifications = val),
                  width: width,
                ),
                _buildNotificationItem(
                  icon: Icons.mail_outline,
                  title: "Email Notifications",
                  value: _emailNotifications,
                  onChanged: (val) =>
                      setState(() => _emailNotifications = val),
                  width: width,
                ),
                _buildNotificationItem(
                  icon: Icons.sms_outlined,
                  title: "SMS Notification",
                  value: _smsNotification,
                  onChanged: (val) =>
                      setState(() => _smsNotification = val),
                  width: width,
                  isLast: true,
                ),
              ]),

              SizedBox(height: height * 0.04),

              // Note box
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: width * 0.04,
                  vertical: height * 0.018,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: width * 0.035,
                      height: 1.5,
                    ),
                    children: const [
                      TextSpan(
                        text: "Note: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text:
                            "Important system notifications cannot be disabled for security and compliance reasons",
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: height * 0.03),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, double width) {
    return Text(
      title,
      style: TextStyle(
        fontSize: width * 0.045,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Column(children: items),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required double width,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: [
              // Circular purple icon container
              Container(
                width: width * 0.1,
                height: width * 0.1,
                decoration: const BoxDecoration(
                  color: Color(0xFF26A69A),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: width * 0.052,
                ),
              ),
              SizedBox(width: width * 0.04),
              // Title
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: width * 0.04,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Purple Toggle Switch
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF26A69A),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade300,
                  trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: Colors.black12,
          ),
      ],
    );
  }
}

