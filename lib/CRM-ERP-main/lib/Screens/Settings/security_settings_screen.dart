import 'package:crm/Services/biometric_service.dart';
import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool securityAlert = true;
  bool dataSharing = true;
  bool biometricEnabled = false;

  @override
  void initState() {
    super.initState();
   // _loadBiometricStatus();
  }

  // Future<void> _loadBiometricStatus() async {
  //   bool enabled = await BiometricService.isEnabled();
  //   setState(() {
  //     biometricEnabled = enabled;
  //   });
  // }

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
        title: const Text(
          'Security & setting',
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
            _buildSectionHeader('Account Security'),
            _buildItem('Change Password', 'Update your Login Password'),
            const SizedBox(height: 12),
            _buildItem(
              'Two Factor Authentication',
              'Enable extra login protection',
            ),
            const SizedBox(height: 12),
            _buildItem('Active Sessions', 'View logged-in devices'),
            const SizedBox(height: 12),
            _buildToggleItem(
              'Security Alert',
              'Get notified of suspicious activity',
              securityAlert,
              (val) => setState(() => securityAlert = val),
            ),
            const SizedBox(height: 12),
            // _buildToggleItem(
            //   'Biometric Lock',
            //   'Unlock app with Fingerprint, Face ID or PIN',
            //   biometricEnabled,
            //   (val) async {
            //     if (val) {
            //       bool available =
            //           await BiometricService.isBiometricAvailable();
            //       if (!available) {
            //         if (mounted) {
            //           ScaffoldMessenger.of(context).showSnackBar(
            //             const SnackBar(
            //               content: Text(
            //                 'Biometric authentication not available on this device',
            //               ),
            //             ),
            //           );
            //         }
            //         return;
            //       }
            //     }
            //     await BiometricService.setEnabled(val);
            //     setState(() => biometricEnabled = val);
            //   },
            // ),
            const SizedBox(height: 24),
            _buildSectionHeader('Privacy Setting'),
            _buildItem(
              'Profile Visibility',
              'Control who can see your profile',
            ),
            const SizedBox(height: 12),
            _buildToggleItem(
              'Data Sharing',
              'Manage third-party access',
              dataSharing,
              (val) => setState(() => dataSharing = val),
            ),
            const SizedBox(height: 12),
            _buildItem('Export My Data', 'Download a copy of your data'),
            const SizedBox(height: 12),
            _buildItem(
              'Delete My Data',
              'Permanently remove your data',
              textColor: Colors.red,
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Backup & Recovery'),
            _buildItem(
              'Data Backup',
              'Schedule automatic backups',
              trailingInfo: 'Daily',
            ),
            const SizedBox(height: 12),
            _buildItem('Restore Data', 'Track activity history'),
            const SizedBox(height: 12),
            _buildItem('Audit Logs', 'Download a copy of your data'),
            const SizedBox(height: 30),
            _buildActionItem('Deactivate Account', Colors.red),
            const SizedBox(height: 16),
            _buildActionItem('Delete Account', Colors.red),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildItem(
    String title,
    String subtitle, {
    Color? textColor,
    String? trailingInfo,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color:
                textColor ??
                (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color:
                Theme.of(context).textTheme.bodySmall?.color ?? Colors.black54,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingInfo != null)
              Text(
                trailingInfo,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            if (trailingInfo != null) const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color:
                Theme.of(context).textTheme.bodySmall?.color ?? Colors.black54,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: const Color(0xFF26A69A),
        ),
      ),
    );
  }

  Widget _buildActionItem(String title, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black54),
        onTap: () {},
      ),
    );
  }
}
