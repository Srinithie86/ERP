import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:provider/provider.dart';
import 'TOTAL_ERP/splash/splash_screen.dart';



import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'package:erp_localization/erp_localization.dart'; // import from new package

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize device ID and location for all modules
  try {
    await DeviceService.initDeviceInfo();
  } catch (e) {
    debugPrint("Global Device Init Error: $e");
  }

  final prefs = await SharedPreferences.getInstance();

  // In debug runs you can force-clear the cached menu with:
  // flutter run --dart-define=CLEAR_MENU_CACHE=true
  const bool clearMenuCache =
      bool.fromEnvironment('CLEAR_MENU_CACHE', defaultValue: false);
  if (kDebugMode && clearMenuCache) {
    await prefs.remove('user_menu_data');
  }

  final String? savedPin = prefs.getString('app_pin');
  final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;

  Widget initialScreen;
  if (savedPin != null && savedPin.isNotEmpty) {
    initialScreen = const SecurityPinScreen(
      isSetup: false,
      isAppLock: true,
    );
  } else if (isLoggedIn) {
    initialScreen = const HomeScreen();
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
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
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
