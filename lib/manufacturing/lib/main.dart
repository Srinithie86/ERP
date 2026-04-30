import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:manufacturing_erp/core/app_theme.dart';
import 'package:manufacturing_erp/core/main_shell.dart';

void main() => runApp(const ManufacturingErpApp());

class ManufacturingErpApp extends StatelessWidget {
  const ManufacturingErpApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Manufacturing ERP',
          theme: AppTheme.theme,
          debugShowCheckedModeBanner: false,
          home: child,
        );
      },
      child: const MainShell(),
    );
  }
}