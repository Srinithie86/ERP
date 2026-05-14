import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Screens/Leads/call_outcome_screen.dart';
import 'call_confirmation_popup.dart';

class QuickActionButton extends StatefulWidget {
  final Map<String, dynamic>? lead;
  const QuickActionButton({super.key, this.lead});

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton> {
  bool _isExpanded = false;

  void _onToggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _confirmCall() {
    if (widget.lead == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (c) => CallConfirmationPopup(
        lead: widget.lead!,
        onCancel: () => Navigator.pop(c),
        onConfirm: (selectedPhone) async {
          Navigator.pop(c);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => CallOutcomeScreen(
                lead: widget.lead!,
                autoCall: true,
                selectedPhone: selectedPhone,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _launchCall() async {
    _confirmCall();
  }

  Future<void> _launchSMS() async {
    final phone = _getPhone();
    if (phone.isEmpty) {
      _showError('Phone number not found');
      return;
    }
    final sanitizedNumber = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri uri = Uri.parse('sms:$sanitizedNumber');
    try {
      await launchUrl(uri);
    } catch (e) {
      _showError('Could not launch SMS app');
    }
  }

  Future<void> _launchWhatsApp() async {
    final phone = _getPhone();
    if (phone.isEmpty) {
      _showError('Phone number not found');
      return;
    }
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.startsWith('0')) cleanPhone = cleanPhone.substring(1);
    if (cleanPhone.length == 10) cleanPhone = '91$cleanPhone';

    final whatsappUri = Uri.parse("whatsapp://send?phone=$cleanPhone");
    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        final webUri = Uri.parse("https://wa.me/$cleanPhone");
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showError('Could not launch WhatsApp');
    }
  }

  Future<void> _launchEmail() async {
    final email = widget.lead?['email']?.toString() ?? '';
    if (email.isEmpty) {
      _showError('Email address not found');
      return;
    }
    final Uri uri = Uri(scheme: 'mailto', path: email);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      _showError('Could not launch Email app');
    }
  }

  String _getPhone() {
    if (widget.lead == null) return '';
    return (widget.lead!['mobile_1'] ?? 
            widget.lead!['mobile_no'] ?? 
            widget.lead!['cus_mobile'] ?? 
            widget.lead!['contact_no'] ?? 
            widget.lead!['mobile'] ?? 
            '').toString();
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded) ...[
          _buildItem(null, const Color(0xFF26A69A), _launchWhatsApp, assetPath: 'assets/icons/what.png'),
          const SizedBox(height: 12),
          _buildItem(Icons.email_outlined, const Color(0xFF26A69A), _launchEmail),
          const SizedBox(height: 12),
          _buildItem(Icons.phone_outlined, const Color(0xFF26A69A), _launchCall),
          const SizedBox(height: 12),
          _buildItem(Icons.message_outlined, const Color(0xFF673AB7), _launchSMS),
          const SizedBox(height: 12),
        ],
        GestureDetector(
          onTap: _onToggle,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isExpanded ? Colors.grey.shade300 : const Color(0xFF26A69A),
              gradient: _isExpanded
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF1B7BBC), Color(0xFF26A69A)],
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Quick',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(IconData? icon, Color color, VoidCallback onTap, {String? assetPath}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: assetPath != null
              ? Image.asset(assetPath, width: 24, height: 24, color: Colors.white)
              : Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
