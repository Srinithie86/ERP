import 'package:crm/Services/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:crm/Screens/Home/dashboard_screen.dart';
import 'package:crm/Screens/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize Push Notifications
  await NotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(
    NotificationService.firebaseMessagingBackgroundHandler,
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ThemeProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'CRM App',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF26A69A),
              primary: const Color(0xFF26A69A),
              surface: Colors.white,
            ),
            useMaterial3: true,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF26A69A),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF26A69A),
              primary: const Color(0xFF26A69A),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E),
            ),
            useMaterial3: true,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: const Color(0xFF121212),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
              ),
            ),
            listTileTheme: const ListTileThemeData(
              textColor: Colors.white,
              subtitleTextStyle: TextStyle(color: Colors.white70),
            ),
          ),
          home: const DashboardScreen(),
        );
      },
    );
  }
}
