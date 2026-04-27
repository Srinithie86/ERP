import 'package:flutter/material.dart';
import 'Screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRM Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF26A69A),
          primary: const Color(0xFF26A69A),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const DashboardScreen(),
    );
  }
}
