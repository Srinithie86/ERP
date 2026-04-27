import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFFEFF6FF);
  static const primaryDark = Color(0xFF1D4ED8);
  static const secondary = Color(0xFF7C3AED);
  static const success = Color(0xFF16A34A);
  static const successLight = Color(0xFFF0FDF4);
  static const warning = Color(0xFFD97706);
  static const warningLight = Color(0xFFFFFBEB);
  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFFEF2F2);
  static const info = Color(0xFF0891B2);
  static const infoLight = Color(0xFFECFEFF);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8FAFC);
  static const cardBg = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textHint = Color(0xFF94A3B8);
  static const sidebarBg = Color(0xFF0F172A);
  static const sidebarActive = Color(0xFF2563EB);
  static const sidebarText = Color(0xFFCBD5E1);
  static const sidebarTextActive = Color(0xFFFFFFFF);
  static const pending = Color(0xFFF59E0B);
  static const pendingLight = Color(0xFFFFFBEB);
  static const inProgress = Color(0xFF3B82F6);
  static const inProgressLight = Color(0xFFEFF6FF);
  static const completed = Color(0xFF10B981);
  static const completedLight = Color(0xFFF0FDF4);
  static const rejected = Color(0xFFEF4444);
  static const rejectedLight = Color(0xFFFEF2F2);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),
    cardTheme: CardThemeData(
      color: AppColors.cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

class StatusBadge extends StatelessWidget {
  final String label;
  final String status;
  const StatusBadge({super.key, required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    Color bg, fg;
    switch (status) {
      case 'pending':
        bg = AppColors.pendingLight; fg = AppColors.pending; break;
      case 'inprogress':
        bg = AppColors.inProgressLight; fg = AppColors.inProgress; break;
      case 'completed':
        bg = AppColors.completedLight; fg = AppColors.completed; break;
      case 'rejected':
        bg = AppColors.rejectedLight; fg = AppColors.rejected; break;
      default:
        bg = AppColors.border; fg = AppColors.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: sw * 0.025, vertical: sw * 0.01),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(sw * 0.05)),
      child: Text(label, style: TextStyle(
        color: fg,
        fontSize: sw * 0.028,
        fontWeight: FontWeight.w600,
      )),
    );
  }
}