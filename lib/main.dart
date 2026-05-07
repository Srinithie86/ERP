import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'TOTAL_ERP/splash/splash_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'l10n/app_localizations.dart';
import 'utils/device_service.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';
import 'providers/menu_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'TOTAL_ERP/home/home.dart';
import 'TOTAL_ERP/home/security_pin_screen.dart';
import 'TOTAL_ERP/splash/walkthrough_screen.dart';
import 'package:erp_localization/erp_localization.dart';
import 'package:hrm/utils/background_fetch_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DeviceService.initDeviceInfo();
  } catch (e) {
    debugPrint("Global Device Init Error: $e");
  }

  try {
    BackgroundFetchService.init();
  } catch (e) {
    debugPrint("Workmanager Init Error: $e");
  }

  final prefs = await SharedPreferences.getInstance();
  final String? savedPin = prefs.getString('app_pin');
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  Widget initialScreen;
  if (isLoggedIn) {
    initialScreen = const HomeScreen();
  } else if (savedPin != null && savedPin.isNotEmpty) {
    initialScreen = const SecurityPinScreen(
      isSetup: false,
      isAppLock: true,
    );
  } else {
    initialScreen = const WalkthroughScreen();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()..loadFromPrefs()),
      ],
      child: MyApp(initialScreen: initialScreen),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        return ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (_, Locale currentLocale, __) {
            return MaterialApp(
              title: 'Global Erp',
              debugShowCheckedModeBanner: false,
              themeMode: themeProvider.themeMode,
              locale: currentLocale,
              supportedLocales: const [
                Locale('en'), // English
                Locale('ta'), // Tamil
                Locale('hi'), // Hindi
              ],
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              home: initialScreen,
            );
          },
        );
      },
    );
  }
}