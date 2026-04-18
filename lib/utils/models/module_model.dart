import 'package:flutter/material.dart';

class ModuleItem {
  final String title;
  final String imagePath;
  final Color bgColor;
  final IconData fallbackIcon;
  final WidgetBuilder? screenBuilder;

  const ModuleItem({
    required this.title,
    required this.imagePath,
    required this.bgColor,
    required this.fallbackIcon,
    this.screenBuilder,
  });
}
