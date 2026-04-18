import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Toggle states
  bool _pushNotifications  = true;
  bool _emailNotifications = true;
  bool _smsNotifications   = false;
  bool _orderAlerts        = true;
  bool _paymentAlerts      = true;
  bool _stockAlerts        = false;
  bool _biometricLogin     = true;
  bool _autoLock           = true;
  bool _darkMode           = false;
  bool _compactView        = false;
  bool _autoSync           = true;

  String _selectedLanguage = 'English';
  String _selectedCurrency = '₹ INR';
  String _selectedDateFmt  = 'DD/MM/YYYY';

  void _showPicker({
    required String title,
    required List<String> options,
    required String current,
    required void Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _PickerSheet(
        title: title,
        options: options,
        current: current,
        onSelect: (v) {
          onSelect(v);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq     = MediaQuery.of(context);
    final sw     = mq.size.width;
    final isWide = sw >= 600;

    final horizPad   = isWide ? sw * 0.06 : 16.0;
    final cardRadius = isWide ? 20.0 : 16.0;
    final sectionFs  = isWide ? 13.0 : 12.0;
    final titleFs    = isWide ? 15.0 : 14.0;
    final bodyFs     = isWide ? 13.0 : 12.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppTheme.statusBarTeal,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: AppColors.primaryDark,
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: AppTheme.statusBarTeal,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 22),
              ),
              title: Text(
                'Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWide ? 20 : 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                  horizPad, isWide ? 20 : 16, horizPad, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Profile Tile ─────────────────────────────────────────
                  _ProfileTile(
                      isWide: isWide,
                      cardRadius: cardRadius,
                      bodyFs: bodyFs),
                  SizedBox(height: isWide ? 24 : 18),

                  // ── Notifications ────────────────────────────────────────
                  _SectionLabel(
                      label: 'NOTIFICATIONS', fontSize: sectionFs),
                  SizedBox(height: isWide ? 10 : 8),
                  _SettingsCard(
                    radius: cardRadius,
                    children: [
                      _ToggleTile(
                        icon: Icons.notifications_active_rounded,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySurface,
                        title: 'Push Notifications',
                        subtitle: 'Alerts on your device',
                        value: _pushNotifications,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onChanged: (v) =>
                            setState(() => _pushNotifications = v),
                      ),
                      _CardDivider(),
                      _ToggleTile(
                        icon: Icons.mail_outline_rounded,
                        iconColor: const Color(0xFF0045BC),
                        iconBg: const Color(0xFFE3F2FD),
                        title: 'Email Notifications',
                        subtitle: 'Receive updates via email',
                        value: _emailNotifications,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onChanged: (v) =>
                            setState(() => _emailNotifications = v),
                      ),
                      _CardDivider(),
                      _ToggleTile(
                        icon: Icons.sms_outlined,
                        iconColor: const Color(0xFF66BB6A),
                        iconBg: const Color(0xFFE8F5E9),
                        title: 'SMS Notifications',
                        subtitle: 'Get text message alerts',
                        value: _smsNotifications,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onChanged: (v) =>
                            setState(() => _smsNotifications = v),
                      ),
                    ],
                  ),

                  SizedBox(height: isWide ? 24 : 18),
                  _SectionLabel(
                      label: 'ALERT PREFERENCES', fontSize: sectionFs),
                  SizedBox(height: isWide ? 10 : 8),
                  _SettingsCard(
                    radius: cardRadius,
                    children: [
                      _ToggleTile(
                        icon: Icons.shopping_cart_rounded,
                        iconColor: const Color(0xFF26A69A),
                        iconBg: const Color(0xFFE0F7F4),
                        title: 'Order Alerts',
                        subtitle: 'New orders & status updates',
                        value: _orderAlerts,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onChanged: (v) =>
                            setState(() => _orderAlerts = v),
                      ),
                      _CardDivider(),
                      _ToggleTile(
                        icon: Icons.payments_rounded,
                        iconColor: const Color(0xFF66BB6A),
                        iconBg: const Color(0xFFE8F5E9),
                        title: 'Payment Alerts',
                        subtitle: 'Received & due payments',
                        value: _paymentAlerts,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onChanged: (v) =>
                            setState(() => _paymentAlerts = v),
                      ),
                      _CardDivider(),
                      _ToggleTile(
                        icon: Icons.inventory_2_outlined,
                        iconColor: const Color(0xFFEF5350),
                        iconBg: const Color(0xFFFFEBEE),
                        title: 'Stock Alerts',
                        subtitle: 'Low inventory warnings',
                        value: _stockAlerts,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onChanged: (v) =>
                            setState(() => _stockAlerts = v),
                      ),
                    ],
                  ),

                  SizedBox(height: isWide ? 24 : 18),

                  // ── Security ─────────────────────────────────────────────
                  _SectionLabel(label: 'SECURITY', fontSize: sectionFs),
                  SizedBox(height: isWide ? 10 : 8),
                  _SettingsCard(
                    radius: cardRadius,
                    children: [
                      _ToggleTile(
                        icon: Icons.fingerprint_rounded,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySurface,
                        title: 'Biometric Login',
                        subtitle: 'Fingerprint / Face ID',
                        value: _biometricLogin,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onChanged: (v) =>
                            setState(() => _biometricLogin = v),
                      ),
                      _CardDivider(),
                      _ToggleTile(
                        icon: Icons.lock_outline_rounded,
                        iconColor: const Color(0xFFFFA726),
                        iconBg: const Color(0xFFFFF8E1),
                        title: 'Auto Lock',
                        subtitle: 'Lock after 5 min inactivity',
                        value: _autoLock,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onChanged: (v) =>
                            setState(() => _autoLock = v),
                      ),
                      _CardDivider(),
                      _NavTile(
                        icon: Icons.key_rounded,
                        iconColor: const Color(0xFFAB47BC),
                        iconBg: const Color(0xFFF3E5F5),
                        title: 'Change Password',
                        subtitle: 'Last changed 30 days ago',
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onTap: () {},
                      ),
                      _CardDivider(),
                      _NavTile(
                        icon: Icons.devices_outlined,
                        iconColor: const Color(0xFF0045BC),
                        iconBg: const Color(0xFFE3F2FD),
                        title: 'Manage Devices',
                        subtitle: '2 active sessions',
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: isWide ? 24 : 18),

                  // ── Appearance ───────────────────────────────────────────
                  _SectionLabel(label: 'APPEARANCE', fontSize: sectionFs),
                  SizedBox(height: isWide ? 10 : 8),
                  _SettingsCard(
                    radius: cardRadius,
                    children: [
                      _ToggleTile(
                        icon: Icons.dark_mode_outlined,
                        iconColor: const Color(0xFF5C6BC0),
                        iconBg: const Color(0xFFEDE7F6),
                        title: 'Dark Mode',
                        subtitle: 'Use dark theme',
                        value: _darkMode,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onChanged: (v) =>
                            setState(() => _darkMode = v),
                      ),
                      _CardDivider(),
                      _ToggleTile(
                        icon: Icons.view_compact_outlined,
                        iconColor: const Color(0xFF26A69A),
                        iconBg: const Color(0xFFE0F7F4),
                        title: 'Compact View',
                        subtitle: 'Show more items on screen',
                        value: _compactView,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onChanged: (v) =>
                            setState(() => _compactView = v),
                      ),
                    ],
                  ),

                  SizedBox(height: isWide ? 24 : 18),

                  // ── Preferences ──────────────────────────────────────────
                  _SectionLabel(
                      label: 'PREFERENCES', fontSize: sectionFs),
                  SizedBox(height: isWide ? 10 : 8),
                  _SettingsCard(
                    radius: cardRadius,
                    children: [
                      _PickerTile(
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFF0045BC),
                        iconBg: const Color(0xFFE3F2FD),
                        title: 'Language',
                        value: _selectedLanguage,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onTap: () => _showPicker(
                          title: 'Language',
                          options: ['English', 'Hindi', 'Tamil', 'Telugu',
                            'Kannada', 'Marathi'],
                          current: _selectedLanguage,
                          onSelect: (v) =>
                              setState(() => _selectedLanguage = v),
                        ),
                      ),
                      _CardDivider(),
                      _PickerTile(
                        icon: Icons.currency_rupee_rounded,
                        iconColor: const Color(0xFF66BB6A),
                        iconBg: const Color(0xFFE8F5E9),
                        title: 'Currency',
                        value: _selectedCurrency,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onTap: () => _showPicker(
                          title: 'Currency',
                          options: ['₹ INR', '\$ USD', '€ EUR', '£ GBP'],
                          current: _selectedCurrency,
                          onSelect: (v) =>
                              setState(() => _selectedCurrency = v),
                        ),
                      ),
                      _CardDivider(),
                      _PickerTile(
                        icon: Icons.calendar_today_outlined,
                        iconColor: const Color(0xFFFFA726),
                        iconBg: const Color(0xFFFFF8E1),
                        title: 'Date Format',
                        value: _selectedDateFmt,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onTap: () => _showPicker(
                          title: 'Date Format',
                          options: ['DD/MM/YYYY', 'MM/DD/YYYY', 'YYYY-MM-DD'],
                          current: _selectedDateFmt,
                          onSelect: (v) =>
                              setState(() => _selectedDateFmt = v),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isWide ? 24 : 18),

                  // ── Data & Sync ──────────────────────────────────────────
                  _SectionLabel(label: 'DATA & SYNC', fontSize: sectionFs),
                  SizedBox(height: isWide ? 10 : 8),
                  _SettingsCard(
                    radius: cardRadius,
                    children: [
                      _ToggleTile(
                        icon: Icons.sync_rounded,
                        iconColor: AppColors.primary,
                        iconBg: AppColors.primarySurface,
                        title: 'Auto Sync',
                        subtitle: 'Sync data every 15 minutes',
                        value: _autoSync,
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onChanged: (v) =>
                            setState(() => _autoSync = v),
                      ),
                      _CardDivider(),
                      _NavTile(
                        icon: Icons.cloud_download_outlined,
                        iconColor: const Color(0xFF0045BC),
                        iconBg: const Color(0xFFE3F2FD),
                        title: 'Export Data',
                        subtitle: 'Download all your data',
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onTap: () {},
                      ),
                      _CardDivider(),
                      _NavTile(
                        icon: Icons.delete_sweep_outlined,
                        iconColor: AppColors.red,
                        iconBg: const Color(0xFFFFEBEE),
                        title: 'Clear Cache',
                        subtitle: 'Free up 24.3 MB',
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: isWide ? 24 : 18),

                  // ── Danger Zone ──────────────────────────────────────────
                  _SectionLabel(label: 'ACCOUNT', fontSize: sectionFs),
                  SizedBox(height: isWide ? 10 : 8),
                  _SettingsCard(
                    radius: cardRadius,
                    children: [
                      _NavTile(
                        icon: Icons.logout_rounded,
                        iconColor: const Color(0xFFFFA726),
                        iconBg: const Color(0xFFFFF8E1),
                        title: 'Sign Out',
                        subtitle: 'Sign out of your account',
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        onTap: () => _confirmSignOut(context),
                      ),
                      _CardDivider(),
                      _NavTile(
                        icon: Icons.person_remove_outlined,
                        iconColor: AppColors.red,
                        iconBg: const Color(0xFFFFEBEE),
                        title: 'Delete Account',
                        subtitle: 'Permanently delete all data',
                        titleFs: titleFs,
                        bodyFs: bodyFs,
                        titleColor: AppColors.red,
                        onTap: () {},
                      ),
                    ],
                  ),

                  SizedBox(height: isWide ? 20 : 16),
                  _VersionFooter(bodyFs: bodyFs),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out',
            style: TextStyle(fontFamily: 'Poppins',
                fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?',
            style: TextStyle(fontFamily: 'Poppins', fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(fontFamily: 'Poppins',
                    color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out',
                style: TextStyle(fontFamily: 'Poppins',
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Profile Tile ─────────────────────────────────────────────────────────────
class _ProfileTile extends StatelessWidget {
  final bool isWide;
  final double cardRadius;
  final double bodyFs;
  const _ProfileTile(
      {required this.isWide,
        required this.cardRadius,
        required this.bodyFs});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(isWide ? 18 : 14),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.primaryDark, AppColors.primary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(cardRadius),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.30),
          blurRadius: 12, offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: isWide ? 28 : 24,
          backgroundColor: Colors.white.withOpacity(0.20),
          child: Text(
            'RK',
            style: TextStyle(
              color: Colors.white,
              fontSize: isWide ? 16 : 14,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        SizedBox(width: isWide ? 14 : 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rajesh Kumar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWide ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                'rajesh.kumar@acmecorp.in',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: bodyFs - 1,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Sales Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: bodyFs - 2,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.edit_outlined,
            color: Colors.white70, size: isWide ? 20 : 18),
      ],
    ),
  );
}

// ─── Settings Card ────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final double radius;
  const _SettingsCard({required this.children, required this.radius});

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: AppColors.divider),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(children: children),
  );
}

// ─── Toggle Tile ─────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool value;
  final double titleFs;
  final double bodyFs;
  final void Function(bool) onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.titleFs,
    required this.bodyFs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    child: Row(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: titleFs,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  )),
              Text(subtitle,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: bodyFs - 1,
                    fontFamily: 'Poppins',
                  )),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    ),
  );
}

// ─── Nav Tile ─────────────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final double titleFs;
  final double bodyFs;
  final VoidCallback onTap;
  final Color? titleColor;

  const _NavTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.titleFs,
    required this.bodyFs,
    required this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: titleColor ?? AppColors.textDark,
                      fontSize: titleFs,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    )),
                Text(subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: bodyFs - 1,
                      fontFamily: 'Poppins',
                    )),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 18),
        ],
      ),
    ),
  );
}

// ─── Picker Tile ─────────────────────────────────────────────────────────────
class _PickerTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String value;
  final double titleFs;
  final double bodyFs;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.titleFs,
    required this.bodyFs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(4),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: TextStyle(
                  color: AppColors.textDark,
                  fontSize: titleFs,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                )),
          ),
          Text(value,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: bodyFs,
                fontFamily: 'Poppins',
              )),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 18),
        ],
      ),
    ),
  );
}

// ─── Picker Sheet ─────────────────────────────────────────────────────────────
class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> options;
  final String current;
  final void Function(String) onSelect;

  const _PickerSheet({
    required this.title,
    required this.options,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36, height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              title,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          ...options.map((opt) => ListTile(
            title: Text(opt,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                )),
            trailing: opt == current
                ? const Icon(Icons.check_rounded,
                color: AppColors.primary)
                : null,
            onTap: () => onSelect(opt),
          )),
        ],
      ),
    ),
  );
}

// ─── Section Label ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final double fontSize;
  const _SectionLabel({required this.label, required this.fontSize});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      color: AppColors.textMuted,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.6,
      fontFamily: 'Poppins',
    ),
  );
}

class _CardDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
    height: 1, thickness: 1,
    color: AppColors.divider,
    indent: 16, endIndent: 16,
  );
}

class _VersionFooter extends StatelessWidget {
  final double bodyFs;
  const _VersionFooter({required this.bodyFs});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      'Sale Management · v2.4.1 · © 2026',
      style: TextStyle(
        color: AppColors.textFaint,
        fontSize: bodyFs - 1,
        fontFamily: 'Poppins',
      ),
    ),
  );
}