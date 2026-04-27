import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class ClaimHeader extends StatelessWidget {
  final InsuranceModel insurance;
  final int step;

  const ClaimHeader({super.key, required this.insurance, required this.step});

  @override
  Widget build(BuildContext context) {
    final stepLabels = switch (insurance.category) {
      'vehicle' => [
        'claim.step1_label_vehicle'.tr(),
        'claim.step2_label_vehicle'.tr(),
        'claim.step3_label'.tr(),
      ],
      'health' => [
        'claim.step1_label_health'.tr(),
        'claim.step2_label_health'.tr(),
        'claim.step3_label'.tr(),
      ],
      'home' => [
        'claim.step1_label_home'.tr(),
        'claim.step2_label_home'.tr(),
        'claim.step3_label'.tr(),
      ],
      'travel' => [
        'claim.step1_label_travel'.tr(),
        'claim.step2_label_travel'.tr(),
        'claim.step3_label'.tr(),
      ],
      _ => [
        'claim.step1_label'.tr(),
        'claim.step2_label'.tr(),
        'claim.step3_label'.tr(),
      ],
    };

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(switch (insurance.category) {
                      'vehicle' => 'claim.title_vehicle'.tr(),
                      'health' => 'claim.title_health'.tr(),
                      'home' => 'claim.title_home'.tr(),
                      'travel' => 'claim.title_travel'.tr(),
                      _ => 'claim.title'.tr(),
                    }, style: context.textTheme.headlineLarge),
                    Text(
                      '${insurance.type} · ${insurance.policyNo}',
                      style: context.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: index < 2 ? 6 : 0),
                    decoration: BoxDecoration(
                      color: index < step
                          ? context.appColors.accent
                          : context.appColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Text(
              'claim.step_indicator'.tr(
                namedArgs: {'step': '$step', 'label': stepLabels[step - 1]},
              ),
              style: context.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
