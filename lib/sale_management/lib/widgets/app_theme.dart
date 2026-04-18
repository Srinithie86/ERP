import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  AppColors._();

  // Primary Teal
  static const primary        = Color(0xFF26A69A);
  static const primaryDark    = Color(0xFF1A7A72);
  static const primaryDeep    = Color(0xFF00695C);
  static const primaryLight   = Color(0xFF4DB6AC);
  static const primarySurface = Color(0xFFE0F2F1);

  // Background (White)
  static const bgDark         = Color(0xFFF5F7FA);
  static const bgCard         = Color(0xFFFFFFFF);
  static const bgCardAlt      = Color(0xFFF8FAFB);
  static const bgElevated     = Color(0xFFFFFFFF);
  static const divider        = Color(0xFFE8EDF2);

  // Accent Colors
  static const amber          = Color(0xFFFFA726);
  static const amberDark      = Color(0xFFE65100);
  static const red            = Color(0xFFEF5350);
  static const redDark        = Color(0xFFC62828);
  static const green          = Color(0xFF26A69A);
  static const greenDark      = Color(0xFF00796B);
  static const blue           = Color(0xFF0045BC);
  static const blueDark       = Color(0xFF1565C0);
  static const purple         = Color(0xFFAB47BC);
  static const purpleDark     = Color(0xFF6A1B9A);
  static const orange         = Color(0xFFFF7043);

  // Text
  static const textWhite      = Color(0xFFFFFFFF);
  static const textDark       = Color(0xFF1A2332);
  static const textLight      = Color(0xFF546E7A);
  static const textMuted      = Color(0xFF90A4AE);
  static const textFaint      = Color(0xFFB0BEC5);
}

class AppTextStyles {
  AppTextStyles._();

  static const heading1 = TextStyle(
    color: AppColors.textDark,
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    fontFamily: 'Poppins',
  );

  static const heading2 = TextStyle(
    color: AppColors.textDark,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    fontFamily: 'Poppins',
  );

  static const heading3 = TextStyle(
    color: AppColors.textDark,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  static const sectionTitle = TextStyle(
    color: AppColors.textDark,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
  );

  static const label = TextStyle(
    color: AppColors.textLight,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    fontFamily: 'Poppins',
  );

  static const caption = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
  );

  static const badge = TextStyle(
    color: AppColors.textWhite,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    fontFamily: 'Poppins',
  );

  static const statValue = TextStyle(
    color: AppColors.textDark,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.5,
    fontFamily: 'Poppins',
  );

  static const statLabel = TextStyle(
    color: AppColors.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    fontFamily: 'Poppins',
  );
}

class AppDecorations {
  AppDecorations._();

  static BoxDecoration card = BoxDecoration(
    color: AppColors.bgCard,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.divider, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration cardAlt = BoxDecoration(
    color: AppColors.bgCardAlt,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.divider, width: 1),
  );

  static BoxDecoration elevated = BoxDecoration(
    color: AppColors.bgElevated,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.divider, width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static LinearGradient primaryGradient = const LinearGradient(
    colors: [AppColors.primary, AppColors.primary, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient headerGradient = const LinearGradient(
    colors: [AppColors.primary, AppColors.primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        surface: AppColors.bgCard,
        error: AppColors.red,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: AppColors.primary,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Poppins',
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.bgCard,
        scrimColor: Colors.black38,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 0,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.textMuted,
        size: 22,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 4,
      ),
    );
  }

  static const SystemUiOverlayStyle statusBarTeal = SystemUiOverlayStyle(
    statusBarColor: AppColors.primary,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
}