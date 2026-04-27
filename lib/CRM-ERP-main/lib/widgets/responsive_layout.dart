import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? laptop;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.laptop,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isLaptop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024 &&
      MediaQuery.of(context).size.width < 1440;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1440;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1440) {
          return desktop ?? laptop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 1024) {
          return laptop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
