import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class AppPreferenceScreen extends StatefulWidget {
  const AppPreferenceScreen({super.key});

  @override
  State<AppPreferenceScreen> createState() => _AppPreferenceScreenState();
}

class _AppPreferenceScreenState extends State<AppPreferenceScreen> {
  bool notificationPrefs = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'App Preference',
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
              'App Preference',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            _buildCard([
              _buildToggleItem(
                'Dark / Light Mode',
                'Switch app theme',
                isDark,
                (val) {
                  themeProvider.toggleTheme(val);
                },
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Language & Region',
                'Set language and timezone',
              ),
              const Divider(height: 1),
              _buildToggleItem(
                'Notification Preferences',
                'Manage alerts',
                notificationPrefs,
                (val) {
                  setState(() => notificationPrefs = val);
                },
              ),
              const Divider(height: 1),
              _buildNavigationItem(
                'Dashboard Customization',
                'Choose widgets & layout',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.black54,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: const Color(0xFF26A69A),
      ),
    );
  }

  Widget _buildNavigationItem(String title, String subtitle) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.black54,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black54),
      onTap: () {},
    );
  }
}
