import 'package:flutter/material.dart';
import 'package:erp_localization/erp_localization.dart';

class LanguageSelector extends StatelessWidget {
  final Color? iconColor;
  const LanguageSelector({super.key, this.iconColor});

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalization.of('Language')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _languageOption(context, 'English', const Locale('en')),
            _languageOption(context, 'தமிழ்', const Locale('ta')),
            _languageOption(context, 'हिन्दी', const Locale('hi')),
          ],
        ),
      ),
    );
  }

  Widget _languageOption(BuildContext context, String label, Locale locale) {
    final bool isSelected = localeNotifier.value.languageCode == locale.languageCode;
    return ListTile(
      title: Text(label),
      trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF26A69A)) : null,
      onTap: () {
        localeNotifier.value = locale;
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.translate, color: iconColor ?? Colors.white),
      onPressed: () => _showLanguageDialog(context),
      tooltip: AppLocalization.of('Language'),
    );
  }
}
