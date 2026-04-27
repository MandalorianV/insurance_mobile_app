import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurance_mobile_app/core/widgets/shimmer_widgets.dart';
import 'package:insurance_mobile_app/features/claim/bloc/claim_bloc.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_types_model.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class ClaimStep1 extends StatelessWidget {
  final InsuranceModel insurance;
  final List<ClaimType> claimTypes;
  final String? selectedClaimTypeId;
  final ValueNotifier<bool> showStep1Error;
  final void Function(String damageType) onDamageTypeSelected;

  const ClaimStep1({
    super.key,
    required this.insurance,
    required this.claimTypes,
    required this.selectedClaimTypeId,
    required this.showStep1Error,
    required this.onDamageTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(switch (insurance.category) {
          'vehicle' => 'claim.step1_title_vehicle'.tr(),
          'health' => 'claim.step1_title_health'.tr(),
          'home' => 'claim.step1_title_home'.tr(),
          'travel' => 'claim.step1_title_travel'.tr(),
          _ => 'claim.step1_title'.tr(),
        }, style: context.textTheme.bodyMedium),
        const SizedBox(height: 16),
        BlocBuilder<ClaimBloc, ClaimState>(
          buildWhen: (previous, current) => current is SelectedDamageTypeState,
          builder: (context, state) {
            String? resolvedSelectedId = selectedClaimTypeId;
            if (state is SelectedDamageTypeState) {
              resolvedSelectedId = claimTypes
                  .firstWhere((type) => type.label == state.damageType)
                  .id;
            }

            if (claimTypes.isEmpty) {
              return const SingleChildScrollView(
                child: Column(children: [ClaimTypesShimmer()]),
              );
            }

            return Column(
              children: [
                ...claimTypes.map((ct) {
                  final isSelected = resolvedSelectedId == ct.id;
                  return GestureDetector(
                    onTap: () {
                      showStep1Error.value = false;
                      onDamageTypeSelected(ct.label);
                      context.read<ClaimBloc>().add(
                        SelectDamageTypeEvent(damageType: ct.label),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.appColors.accentSoft
                            : context.appColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? context.appColors.accent
                              : context.appColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(ct.emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              ct.label,
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
                }),
                ValueListenableBuilder<bool>(
                  valueListenable: showStep1Error,
                  builder: (context, hasError, _) {
                    if (!hasError) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: context.appColors.danger,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'claim.validation_select_type'.tr(),
                            style: context.textTheme.labelSmall?.copyWith(
                              color: context.appColors.danger,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
