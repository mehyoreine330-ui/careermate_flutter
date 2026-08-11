import 'package:flutter/material.dart';

/// Single source of truth for the CareerMate dark palette — deep slate
/// background, electric indigo + neon cyan accents, and the glass fill/border
/// tones every glassmorphic surface in the app pulls from.
class AppColors {
  const AppColors._();

  // Background gradient (top -> bottom).
  static const Color bgTop = Color(0xFF0F172A);
  static const Color bgBottom = Color(0xFF020617);

  // Accents.
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentCyan = Color(0xFF22D3EE);

  static const Color surface = Color(0xFF111827);

  // Text.
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Semantic.
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgBottom],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [accentIndigo, accentCyan],
  );
}
