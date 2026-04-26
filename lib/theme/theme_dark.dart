import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'application_theme.dart';
import 'app_colors.dart';

class ThemeDark extends ApplicationTheme {
  static ThemeDark? _instance;
  static ThemeDark get instance {
    _instance ??= ThemeDark._init();
    return _instance!;
  }

  ThemeDark._init();

  static const _c = AppColors.dark;

  @override
  ThemeData? get theme => ThemeData(
        useMaterial3: true,
        fontFamily: 'DM Sans',

        // ── ColorScheme ────────────────────────────────────
        colorScheme: ColorScheme(
          brightness:              Brightness.dark,
          primary:                 _c.accent,
          onPrimary:               _c.textPrimary,
          primaryContainer:        _c.accentSoft,
          onPrimaryContainer:      _c.textPrimary,
          secondary:               _c.indigo,
          onSecondary:             _c.textPrimary,
          secondaryContainer:      const Color(0xFF1E1E40),
          onSecondaryContainer:    _c.textPrimary,
          tertiary:                _c.success,
          onTertiary:              _c.bg,
          tertiaryContainer:       const Color(0xFF0D2E22),
          onTertiaryContainer:     _c.success,
          error:                   _c.danger,
          onError:                 _c.textPrimary,
          errorContainer:          const Color(0xFF4A1010),
          onErrorContainer:        _c.danger,
          surface:                 _c.surface,
          onSurface:               _c.textPrimary,
          surfaceContainerHighest: _c.card,
          outline:                 _c.border,
          outlineVariant:          _c.borderVariant,
          scrim:                   Colors.black,
          inverseSurface:          _c.textPrimary,
          onInverseSurface:        _c.bg,
          inversePrimary:          _c.accentSoft,
        ),

        scaffoldBackgroundColor: _c.bg,

        // ── TextTheme ──────────────────────────────────────
        // displayLarge   → splash / hero               48 w700
        // headlineLarge  → sayfa ana başlığı            24 w700
        // headlineMedium → özet kart başlıkları         20 w700
        // headlineSmall  → section başlıkları           18 w700
        // titleLarge     → kart type/label              15 w600
        // titleMedium    → form label                   14 w600
        // titleSmall     → badge / chip                 12 w600
        // bodyLarge      → ana içerik metni             15 w400
        // bodyMedium     → ikincil metin                13 w400
        // bodySmall      → yardımcı metin               12 w400
        // labelLarge     → buton metni                  15 w700
        // labelMedium    → küçük etiket                 12 w500
        // labelSmall     → muted / hint                 11 w400
        textTheme: TextTheme(
          displayLarge:   TextStyle(fontFamily: 'DM Sans', fontSize: 48, fontWeight: FontWeight.w700, color: _c.textPrimary),
          displayMedium:  TextStyle(fontFamily: 'DM Sans', fontSize: 36, fontWeight: FontWeight.w700, color: _c.textPrimary),
          displaySmall:   TextStyle(fontFamily: 'DM Sans', fontSize: 28, fontWeight: FontWeight.w700, color: _c.textPrimary),
          headlineLarge:  TextStyle(fontFamily: 'DM Sans', fontSize: 24, fontWeight: FontWeight.w700, color: _c.textPrimary),
          headlineMedium: TextStyle(fontFamily: 'DM Sans', fontSize: 20, fontWeight: FontWeight.w700, color: _c.textPrimary),
          headlineSmall:  TextStyle(fontFamily: 'DM Sans', fontSize: 18, fontWeight: FontWeight.w700, color: _c.textPrimary),
          titleLarge:     TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w600, color: _c.textPrimary),
          titleMedium:    TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w600, color: _c.textPrimary),
          titleSmall:     TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w600, color: _c.textPrimary),
          bodyLarge:      TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w400, color: _c.textPrimary),
          bodyMedium:     TextStyle(fontFamily: 'DM Sans', fontSize: 13, fontWeight: FontWeight.w400, color: _c.textSub),
          bodySmall:      TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w400, color: _c.textSub),
          labelLarge:     TextStyle(fontFamily: 'DM Sans', fontSize: 15, fontWeight: FontWeight.w700, color: _c.textPrimary, letterSpacing: 0.3),
          labelMedium:    TextStyle(fontFamily: 'DM Sans', fontSize: 12, fontWeight: FontWeight.w500, color: _c.textSub),
          labelSmall:     TextStyle(fontFamily: 'DM Sans', fontSize: 11, fontWeight: FontWeight.w400, color: _c.textMuted),
        ),

        // ── AppBar ─────────────────────────────────────────
        appBarTheme: AppBarTheme(
          backgroundColor: _c.bg,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: _c.textPrimary),
          titleTextStyle: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _c.textPrimary,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark,
            statusBarIconBrightness: Brightness.light,
          ),
        ),

        // ── Card ───────────────────────────────────────────
        cardTheme: CardThemeData(
          color: _c.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _c.border),
          ),
          margin: EdgeInsets.zero,
        ),

        // ── ElevatedButton ─────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _c.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 24),
            textStyle: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3),
          ),
        ),

        // ── OutlinedButton ─────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _c.textPrimary,
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: _c.border),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 24),
            textStyle: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
        ),

        // ── TextButton ─────────────────────────────────────
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _c.accent,
            textStyle: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ),

        // ── Input ──────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _c.card,
          hintStyle: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: _c.textMuted),
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _c.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _c.accent, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _c.danger)),
          focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _c.danger, width: 1.5)),
          errorStyle: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: _c.danger),
        ),

        // ── Divider ────────────────────────────────────────
        dividerTheme: DividerThemeData(
            color: _c.border, thickness: 1, space: 1),

        // ── SnackBar ───────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: _c.card,
          contentTextStyle: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: _c.textPrimary),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),

        // ── ProgressIndicator ──────────────────────────────
        progressIndicatorTheme:
            ProgressIndicatorThemeData(color: _c.accent),

        // ── Switch / Radio / Checkbox ──────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _c.accent;
            return null;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _c.accentSoft;
            return null;
          }),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _c.accent;
            return null;
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return _c.accent;
            return null;
          }),
        ),

        // ── ListTile ───────────────────────────────────────
        listTileTheme: ListTileThemeData(
          titleTextStyle: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _c.textPrimary),
          subtitleTextStyle: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: _c.textSub),
        ),

        // ── BottomNavigationBar ────────────────────────────
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: _c.surface,
          selectedItemColor: _c.accent,
          unselectedItemColor: _c.textMuted,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),

        // ── Chip ───────────────────────────────────────────
        chipTheme: ChipThemeData(
          backgroundColor: _c.card,
          labelStyle: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              color: _c.textSub),
          side: BorderSide(color: _c.border),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(
              horizontal: 10, vertical: 4),
        ),

        // ── Dialog ─────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: _c.surface,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          titleTextStyle: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _c.textPrimary),
          contentTextStyle: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: _c.textSub),
        ),
      );
}
