import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'Screens/technician_dashboard.dart';

import 'core/app_colors.dart';
import 'core/size_utils.dart';
import 'Screens/login/login_screen.dart';
import 'screens/splash_screen.dart';

class ServiceTicketApp extends StatefulWidget {
  const ServiceTicketApp({super.key});

  @override
  State<ServiceTicketApp> createState() => _ServiceTicketAppState();
}

class _ServiceTicketAppState extends State<ServiceTicketApp> {
  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Service Ticket Technician',
      builder: (context, child) {
        SizeConfig.init(context);
        return child ?? const SizedBox.shrink();
      },
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: AppColors.bg,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: AppColors.textDark,
              displayColor: AppColors.textDark,
            ),
      ),
      home: const SplashScreen(),
    );
  }
}
