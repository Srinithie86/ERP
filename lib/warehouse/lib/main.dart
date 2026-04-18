import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/warehouse_provider.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WarehouseProvider()),
      ],
      child: const WarehouseApp(),
    ),
  );
}
class WarehouseApp extends StatelessWidget {
  const WarehouseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Warehouse Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const MainScreen(),
    );
  }
}
