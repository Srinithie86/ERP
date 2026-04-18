import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_theme.dart';
import '../Sales_Module/sale_dashboard.dart';

// ─── ENTRY POINT ──────────────────────────────────────────────────────────────
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Status bar teal color on launch
  SystemChrome.setSystemUIOverlayStyle(AppTheme.statusBarTeal);

  // Lock to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SalesApp());
}

// ─── ROOT APP ─────────────────────────────────────────────────────────────────
class SalesApp extends StatelessWidget {
  const SalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SalesFlow ERP',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // DashboardPage is the home — it carries its own
      // Scaffold (with Drawer + BottomNavBar) inside.
      home: const DashboardPage(),
    );
  }
}