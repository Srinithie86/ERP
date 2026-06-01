import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_colors.dart';

class AppStatusBarWrapper extends StatelessWidget {
  const AppStatusBarWrapper({
    super.key,
    required this.child,
    this.statusBarColor = AppColors.primary,
  });

  final Widget child;
  final Color statusBarColor;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Material(
      color: Colors.white,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Column(
          children: [
            Container(height: topInset, color: statusBarColor),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
