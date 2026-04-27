import 'package:flutter/material.dart';
import 'package:manufacturing_erp/core/app_theme.dart';
import 'package:manufacturing_erp/core/main_shell.dart';

void main() => runApp(const ManufacturingErpApp());

class ManufacturingErpApp extends StatelessWidget {
  const ManufacturingErpApp({super.key});
  
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Manufacturing ERP',
    theme: AppTheme.theme,
    debugShowCheckedModeBanner: false,
    home: const MainShell(),
  );
}