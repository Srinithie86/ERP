import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isExpanded) ...[
          _buildItem(null, const Color(0xFF26A69A), () {}, assetPath: 'assets/icons/what.png'),
          const SizedBox(height: 12),
          _buildItem(Icons.email_outlined, const Color(0xFF26A69A), () {}),
          const SizedBox(height: 12),
          _buildItem(Icons.phone_outlined, const Color(0xFF26A69A), () {}),
          const SizedBox(height: 12),
          _buildItem(Icons.message_outlined, const Color(0xFF673AB7), () {}),
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
                  color: Colors.black.withValues(alpha: 0.2),
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
              color: Colors.black.withValues(alpha: 0.1),
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
