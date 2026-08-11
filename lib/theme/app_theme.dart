import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Global ThemeData for CareerMate. Dark by default — every screen sits on
/// top of the app-wide gradient/glow background (see widgets/app_background)
/// so `scaffoldBackgroundColor` is a plain fallback, not the visible surface.
class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);

    // A sharper, more distinct step between the header sizes every screen
    // already pulls from Theme.of(context).textTheme.* — this is the single
    // highest-leverage typography change: it reaches every screen's header
    // without touching a single screen file.
    final textTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ).copyWith(
      headlineSmall: GoogleFonts.inter(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.2,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.1,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16.5,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bgBottom,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: AppColors.accentIndigo,
        secondary: AppColors.accentCyan,
        surface: AppColors.surface,
        error: AppColors.danger,
      ),
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accentCyan),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1E1B2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.35)),
        ),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          height: 1.45,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
