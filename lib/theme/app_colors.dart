import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppColorTokens  — abstract interface
//
// View'da context.appColors.accent şeklinde tip güvenli erişim sağlar.
// Yeni bir token eklemek için buraya ekle, ThemeLightColors ve
// ThemeDarkColors'a implement et — derleyici eksik olanı söyler.
// ─────────────────────────────────────────────────────────────────────────────
abstract class AppColorTokens {
  // Arka planlar
  Color get bg;
  Color get surface;
  Color get card;

  // Marka
  Color get accent;
  Color get accentSoft;
  Color get indigo;

  // Semantik
  Color get success;
  Color get warning;
  Color get danger;

  // Metin
  Color get textPrimary;
  Color get textSub;
  Color get textMuted;

  // Çizgi
  Color get border;
  Color get borderVariant;
}

// ─────────────────────────────────────────────────────────────────────────────
// ThemeDarkColors
// ─────────────────────────────────────────────────────────────────────────────
class ThemeDarkColors implements AppColorTokens {
  const ThemeDarkColors();

  @override Color get bg           => const Color(0xFF0A0E1A);
  @override Color get surface      => const Color(0xFF111827);
  @override Color get card         => const Color(0xFF161D2E);

  @override Color get accent       => const Color(0xFF4F8EF7);
  @override Color get accentSoft   => const Color(0xFF1E3A6E);
  @override Color get indigo       => const Color(0xFF6366F1);

  @override Color get success      => const Color(0xFF22D3A5);
  @override Color get warning      => const Color(0xFFF59E0B);
  @override Color get danger       => const Color(0xFFEF4444);

  @override Color get textPrimary  => const Color(0xFFF1F5F9);
  @override Color get textSub      => const Color(0xFF94A3B8);
  @override Color get textMuted    => const Color(0xFF475569);

  @override Color get border       => const Color(0xFF1E293B);
  @override Color get borderVariant => const Color(0xFF2D3748);
}

// ─────────────────────────────────────────────────────────────────────────────
// ThemeLightColors
// ─────────────────────────────────────────────────────────────────────────────
class ThemeLightColors implements AppColorTokens {
  const ThemeLightColors();

  @override Color get bg           => const Color(0xFFF8FAFC);
  @override Color get surface      => const Color(0xFFFFFFFF);
  @override Color get card         => const Color(0xFFF1F5F9);

  @override Color get accent       => const Color(0xFF2563EB);
  @override Color get accentSoft   => const Color(0xFFDBEAFE);
  @override Color get indigo       => const Color(0xFF4F46E5);

  @override Color get success      => const Color(0xFF059669);
  @override Color get warning      => const Color(0xFFD97706);
  @override Color get danger       => const Color(0xFFDC2626);

  @override Color get textPrimary  => const Color(0xFF0F172A);
  @override Color get textSub      => const Color(0xFF475569);
  @override Color get textMuted    => const Color(0xFF94A3B8);

  @override Color get border       => const Color(0xFFE2E8F0);
  @override Color get borderVariant => const Color(0xFFCBD5E1);
}

// ─────────────────────────────────────────────────────────────────────────────
// AppColors  — statik erişim noktası
//
// Kullanım:
//   AppColors.dark.accent   → dark token
//   AppColors.light.accent  → light token
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const AppColorTokens dark  = ThemeDarkColors();
  static const AppColorTokens light = ThemeLightColors();
}
