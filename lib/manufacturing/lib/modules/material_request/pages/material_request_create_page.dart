import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../../core/shared_widgets.dart';
import '../widgets/material_request_widgets.dart';

class MRCreatePage extends StatelessWidget {
  final String? preselectedJobId;
  const MRCreatePage({super.key, this.preselectedJobId});

  static const _jobItems = [
    'JC-001 · Solar Panel 400W Mono',
    'JC-002 · Solar Panel 400W Mono',
    'JC-003 · Solar Street Light 60W',
    'JC-004 · Steel Frame Structure',
  ];

  String? get _initialValue {
    if (preselectedJobId == null) return null;
    try {
      return _jobItems.firstWhere((e) => e.startsWith(preselectedJobId!));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isSteelFrame = preselectedJobId == 'JC-004';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildMRAppBar(
        title: 'New Intent Request',
        showBack: true,
        context: context,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(sw * 0.05),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (isSteelFrame)
            Container(
              margin: EdgeInsets.only(bottom: sw * 0.04),
              padding: EdgeInsets.all(sw * 0.04),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2F1),
                borderRadius: BorderRadius.circular(sw * 0.03),
                border: Border.all(color: mrTeal.withOpacity(0.3)),
              ),
              child: Row(children: [
                Icon(Icons.architecture, color: mrTeal, size: sw * 0.05),
                SizedBox(width: sw * 0.025),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Steel Frame Structure – JC-004',
                            style: TextStyle(
                                fontSize: sw * 0.033,
                                fontWeight: FontWeight.w700,
                                color: mrTeal)),
                        Text(
                            'Materials will be auto-fetched for steel fabrication',
                            style: TextStyle(
                                fontSize: sw * 0.027,
                                color: AppColors.textSecondary)),
                      ]),
                ),
              ]),
            ),
          AppDropdown(
            label: 'Job Card',
            items: _jobItems,
            initialValue: _initialValue,
            onChanged: _noop,
          ),
          SizedBox(height: sw * 0.035),
          const AppTextField(
              label: 'Requested By',
              hint: 'Your name',
              prefixIcon: Icons.person_outline),
          SizedBox(height: sw * 0.035),
          const AppTextField(
              label: 'Notes',
              hint: 'Any special instructions...',
              maxLines: 2),
          SizedBox(height: sw * 0.05),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: mrTeal, foregroundColor: Colors.white),
              child: Text('Create & Auto-fetch Materials',
                  style: TextStyle(fontSize: sw * 0.035)),
            ),
          ),
        ]),
      ),
    );
  }

  static void _noop(dynamic _) {}
}
