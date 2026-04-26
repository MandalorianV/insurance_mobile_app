import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_manager.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BuildContext Extensions
//
// ── Temel erişim ─────────────────────────────────────────────────────────────
//   context.appColors          → AppColorTokens  (tip güvenli, reactive)
//   context.appColors.accent   → Color
//   context.appColors.success  → Color
//
// ── ColorScheme kısayolları ───────────────────────────────────────────────────
//   context.colors.primary     → ColorScheme'den
//   context.textTheme.bodyMedium
//
// ── Durum & semantik ─────────────────────────────────────────────────────────
//   context.isDark             → bool
//   context.colorSuccess       → Color  (ColorScheme.tertiary ile aynı)
//   context.colorWarning       → Color
//   context.colorDanger        → Color  (ColorScheme.error ile aynı)
// ─────────────────────────────────────────────────────────────────────────────
extension ThemeContextExtension on BuildContext {
  // ── Reactive ThemeData ────────────────────────────────────
  ThemeData get theme => read<ThemeManager>().currentTheme;

  // ── ColorScheme & TextTheme ───────────────────────────────
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // ── Aktif tema token'ları (tip güvenli) ───────────────────
  AppColorTokens get appColors => isDark ? AppColors.dark : AppColors.light;

  // ── Tema durumu ───────────────────────────────────────────
  bool get isDark => read<ThemeManager>().currentThemeEnum == ThemeEnum.dark;

  // ── Semantik renk kısayolları ─────────────────────────────
  // ColorScheme'de tertiary/error olarak da mevcut,
  // ama doğrudan isimle erişmek isteyenler için:
  Color get colorSuccess => appColors.success;
  Color get colorWarning => appColors.warning;
  Color get colorDanger => appColors.danger;
  Color get colorCard => appColors.card;
  Color get colorBorder => appColors.border;
  Color get colorAccentSoft => appColors.accentSoft;
  Color get colorBg => appColors.bg;
  Color get colorTextSub => appColors.textSub;
  Color get colorTextMuted => appColors.textMuted;
}
