import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/core/network/client/dio_interceptor.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';
import 'package:insurance_mobile_app/theme/theme_manager.dart';
import 'package:provider/provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocale = context.locale.languageCode;
    final isDark = context.isDark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildThemeCard(context, isDark),
            const SizedBox(height: 16),
            _buildLanguageCard(context, currentLocale),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.appColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.appColors.border),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.appColors.textPrimary,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text('settings.title'.tr(), style: context.textTheme.headlineLarge),
        ],
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('settings.theme'.tr(), style: context.textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildThemeOption(
              context: context,
              label: 'settings.theme_dark'.tr(),
              icon: '🌙',
              isSelected: isDark,
              onTap: () {
                if (!isDark) {
                  context.read<ThemeManager>().changeTheme(ThemeEnum.dark);
                  context.read<InsuranceBloc>().add(GetInsuranceListEvent());
                  context.go('/');
                }
              },
            ),
            const SizedBox(height: 8),
            _buildThemeOption(
              context: context,
              label: 'settings.theme_light'.tr(),
              icon: '☀️',
              isSelected: !isDark,
              onTap: () {
                if (isDark) {
                  context.read<ThemeManager>().changeTheme(ThemeEnum.light);
                  context.read<InsuranceBloc>().add(GetInsuranceListEvent());
                  context.go('/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appColors.accentSoft
              : context.appColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.appColors.accent
                : context.appColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: context.appColors.accent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context, String currentLocale) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.appColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.appColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'settings.language'.tr(),
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context: context,
              label: 'settings.language_tr'.tr(),
              flag: '🇹🇷',
              locale: 'tr',
              isSelected: currentLocale == 'tr',
            ),
            const SizedBox(height: 8),
            _buildLanguageOption(
              context: context,
              label: 'settings.language_en'.tr(),
              flag: '🇬🇧',
              locale: 'en',
              isSelected: currentLocale == 'en',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String label,
    required String flag,
    required String locale,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: isSelected ? null : () => _changeLocale(context, locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.appColors.accentSoft
              : context.appColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? context.appColors.accent
                : context.appColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: context.appColors.accent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _changeLocale(BuildContext context, String locale) async {
    await context.setLocale(Locale(locale));
    DioClient().setLocale(locale);
    if (!context.mounted) return;
    context.read<InsuranceBloc>().add(GetInsuranceListEvent());
    context.go('/');
  }
}
