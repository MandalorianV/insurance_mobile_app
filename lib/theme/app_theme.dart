import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF0A0E1A);
  static const surface = Color(0xFF111827);
  static const card = Color(0xFF161D2E);
  static const accent = Color(0xFF4F8EF7);
  static const accentSoft = Color(0xFF1E3A6E);
  static const success = Color(0xFF22D3A5);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const textPrimary = Color(0xFFF1F5F9);
  static const textSub = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF475569);
  static const border = Color(0xFF1E293B);
  static const indigo = Color(0xFF6366F1);
}

class AppTextStyles {
  static const heading = TextStyle(
    fontFamily: 'DM Sans',
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
  );
  static const body = TextStyle(
    fontFamily: 'DM Sans',
    color: AppColors.textPrimary,
  );
  static const sub = TextStyle(
    fontFamily: 'DM Sans',
    color: AppColors.textSub,
  );
  static const muted = TextStyle(
    fontFamily: 'DM Sans',
    color: AppColors.textMuted,
  );
}

ThemeData buildAppTheme() {
  return ThemeData(
    scaffoldBackgroundColor: AppColors.bg,
    fontFamily: 'DM Sans',
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: TextStyle(
        fontFamily: 'DM Sans',
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      hintStyle: AppTextStyles.muted.copyWith(fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    ),
  );
}
