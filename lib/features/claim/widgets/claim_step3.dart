import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_form_field.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_summary_row.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class ClaimStep3 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController dateController;
  final TextEditingController locationController;
  final TextEditingController hospitalController;
  final TextEditingController addressController;
  final TextEditingController countryController;
  final InsuranceModel insurance;
  final String selectedDamageType;

  const ClaimStep3({
    super.key,
    required this.formKey,
    required this.phoneController,
    required this.dateController,
    required this.locationController,
    required this.hospitalController,
    required this.addressController,
    required this.countryController,
    required this.insurance,
    required this.selectedDamageType,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('claim.step3_title'.tr(), style: context.textTheme.bodyMedium),
          const SizedBox(height: 16),
          ClaimFormField(
            key: const Key('claim_phone_field'),
            label: 'claim.field_phone'.tr(),
            controller: phoneController,
            hint: 'claim.field_phone_hint'.tr(),
            keyboardType: TextInputType.phone,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'claim.validation_phone_required'.tr();
              }
              final digits = v.replaceAll(RegExp(r'\D'), '');
              final normalized = digits.startsWith('90') ? digits : '90$digits';
              if (!RegExp(r'^905[0-9]{9}$').hasMatch(normalized)) {
                return 'claim.validation_phone_invalid'.tr();
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Container(
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
                  'claim.summary_title'.tr(),
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ClaimSummaryRow(
                  label: 'claim.summary_policy'.tr(),
                  value: insurance.type,
                ),
                const SizedBox(height: 8),
                ClaimSummaryRow(
                  label: 'claim.summary_type'.tr(),
                  value: selectedDamageType,
                ),
                const SizedBox(height: 8),
                ClaimSummaryRow(
                  label: 'claim.summary_date'.tr(),
                  value: dateController.text.isEmpty
                      ? '-'
                      : dateController.text,
                ),
                const SizedBox(height: 8),
                ClaimSummaryRow(
                  label: switch (insurance.category) {
                    'vehicle' => 'claim.summary_location_vehicle'.tr(),
                    'health' => 'claim.summary_location_health'.tr(),
                    'home' => 'claim.summary_location_home'.tr(),
                    'travel' => 'claim.summary_location_travel'.tr(),
                    _ => 'claim.summary_location'.tr(),
                  },
                  value: switch (insurance.category) {
                    'vehicle' =>
                      locationController.text.isEmpty
                          ? '-'
                          : locationController.text,
                    'health' =>
                      hospitalController.text.isEmpty
                          ? '-'
                          : hospitalController.text,
                    'home' =>
                      addressController.text.isEmpty
                          ? '-'
                          : addressController.text,
                    'travel' =>
                      countryController.text.isEmpty
                          ? '-'
                          : countryController.text,
                    _ => '-',
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
