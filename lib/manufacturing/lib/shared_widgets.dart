import 'package:flutter/material.dart';
import 'app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  const AppCard({super.key, required this.child, this.padding, this.onTap, this.color});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    ),
  );
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(
          fontSize: sw * 0.04,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        )),
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(actionLabel!, style: TextStyle(
              fontSize: sw * 0.032,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            )),
          ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color iconColor, iconBg;
  final String? trend;
  const StatCard({super.key, required this.label, required this.value,
    required this.icon, required this.iconColor, required this.iconBg, this.trend});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return AppCard(
      padding: EdgeInsets.all(sw * 0.025),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(
              padding: EdgeInsets.all(sw * 0.018),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(sw * 0.02),
              ),
              child: Icon(icon, color: iconColor, size: sw * 0.04),
            ),
            if (trend != null)
              Text(trend!, style: TextStyle(
                fontSize: sw * 0.025,
                fontWeight: FontWeight.w600,
                color: trend!.startsWith('+') ? AppColors.success : AppColors.danger,
              )),
          ]),
          SizedBox(height: sw * 0.02),
          Text(value, style: TextStyle(
            fontSize: sw * 0.045,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          )),
          SizedBox(height: sw * 0.005),
          Text(label,
            style: TextStyle(fontSize: sw * 0.025, color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  final String label, hint;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final bool readOnly;
  final int maxLines;
  const AppTextField({super.key, required this.label, required this.hint,
    this.controller, this.prefixIcon, this.readOnly = false, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(
        fontSize: sw * 0.032,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      )),
      SizedBox(height: sw * 0.015),
      TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        style: TextStyle(fontSize: sw * 0.035, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: sw * 0.035),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: sw * 0.045, color: AppColors.textHint)
              : null,
        ),
      ),
    ]);
  }
}

class AppDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const AppDropdown({super.key, required this.label, this.value,
    required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(
        fontSize: sw * 0.032,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      )),
      SizedBox(height: sw * 0.015),
      DropdownButtonFormField<String>(
        initialValue: value,
        items: items.map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: TextStyle(fontSize: sw * 0.035)),
        )).toList(),
        onChanged: onChanged,
        decoration: const InputDecoration(),
        dropdownColor: AppColors.surface,
        style: TextStyle(fontSize: sw * 0.035, color: AppColors.textPrimary),
      ),
    ]);
  }
}

class EmptyState extends StatelessWidget {
  final String title, subtitle;
  final IconData icon;
  const EmptyState({super.key, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          padding: EdgeInsets.all(sw * 0.05),
          decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          child: Icon(icon, size: sw * 0.1, color: AppColors.primary),
        ),
        SizedBox(height: sw * 0.04),
        Text(title, style: TextStyle(
          fontSize: sw * 0.04,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        )),
        SizedBox(height: sw * 0.015),
        Text(subtitle, style: TextStyle(
          fontSize: sw * 0.032,
          color: AppColors.textSecondary,
        ), textAlign: TextAlign.center),
      ]),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const ProgressBar({super.key, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return ClipRRect(
      borderRadius: BorderRadius.circular(sw * 0.01),
      child: LinearProgressIndicator(
        value: value,
        minHeight: sw * 0.02,
        backgroundColor: AppColors.border,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const InfoRow({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sw * 0.012),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: sw * 0.032, color: AppColors.textSecondary)),
        Text(value, style: TextStyle(
          fontSize: sw * 0.032,
          fontWeight: FontWeight.w600,
          color: valueColor ?? AppColors.textPrimary,
        )),
      ]),
    );
  }
}