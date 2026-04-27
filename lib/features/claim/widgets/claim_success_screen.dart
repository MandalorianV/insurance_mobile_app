import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class ClaimSuccessScreen extends StatelessWidget {
  final InsuranceModel insurance;
  final String refNo;

  const ClaimSuccessScreen({
    super.key,
    required this.insurance,
    required this.refNo,
  });

  @override
  Widget build(BuildContext context) {
    final (title, subtitle, info) = switch (insurance.category) {
      'vehicle' => (
        'claim.success_title_vehicle'.tr(),
        'claim.success_subtitle_vehicle'.tr(),
        'claim.success_info'.tr(),
      ),
      'health' => (
        'claim.success_title_health'.tr(),
        'claim.success_subtitle_health'.tr(),
        'claim.success_info_health'.tr(),
      ),
      'home' => (
        'claim.success_title_home'.tr(),
        'claim.success_subtitle_home'.tr(),
        'claim.success_info_home'.tr(),
      ),
      'travel' => (
        'claim.success_title_travel'.tr(),
        'claim.success_subtitle_travel'.tr(),
        'claim.success_info_travel'.tr(),
      ),
      _ => (
        'claim.success_title'.tr(),
        'claim.success_subtitle'.tr(),
        'claim.success_info'.tr(),
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.success.withValues(alpha: 0.13),
                  border: Border.all(
                    color: context.appColors.success,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: context.appColors.success,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: context.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.appColors.textSub,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('#$refNo', style: context.textTheme.headlineSmall),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: context.appColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.appColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.appColors.accentSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('⏱', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(info, style: context.textTheme.bodyMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.appColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'claim.back_to_policies'.tr(),
                    style: context.textTheme.titleLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
