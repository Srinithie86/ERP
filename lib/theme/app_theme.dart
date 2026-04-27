import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Brand Colors
  static const Color primaryColor = Color(0xFF26A69A); // Deep Teal
  static const Color secondaryColor = Color(0xFF5C6BC0); // Indigo
  static const Color accentColor = Color(0xFFFFA726); // Orange

  // Light Theme Colors
  static const Color lightBg = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1A1C1E);
  static const Color lightTextSecondary = Color(0xFF42474E);

  // Dark Theme Colors
  static const Color darkBg = Color(0xFF0F1113);
  static const Color darkSurface = Color(0xFF1A1C1E);
  static const Color darkTextPrimary = Color(0xFFE2E2E6);
  static const Color darkTextSecondary = Color(0xFFC4C6D0);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightSurface,
      background: lightBg,
      onPrimary: Colors.white,
      onSurface: lightTextPrimary,
      tertiary: accentColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme().copyWith(
      bodyLarge: TextStyle(color: lightTextPrimary),
      bodyMedium: TextStyle(color: lightTextSecondary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkSurface,
      background: darkBg,
      onPrimary: Colors.white,
      onSurface: darkTextPrimary,
      tertiary: accentColor,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).copyWith(
      bodyLarge: TextStyle(color: darkTextPrimary),
      bodyMedium: TextStyle(color: darkTextSecondary),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121416),
      foregroundColor: darkTextPrimary,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
