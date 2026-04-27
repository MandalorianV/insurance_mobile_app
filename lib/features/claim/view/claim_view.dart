import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:insurance_mobile_app/core/widgets/shimmer_widgets.dart';
import 'package:insurance_mobile_app/features/claim/bloc/claim_bloc.dart';
import 'package:insurance_mobile_app/features/claim/repository/claim_repository.dart';
import 'package:insurance_mobile_app/features/claim/view/claim_view_mixin.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class ClaimView extends StatefulWidget {
  final InsuranceModel insurance;
  const ClaimView({super.key, required this.insurance});

  @override
  State<ClaimView> createState() => _ClaimViewState();
}

class _ClaimViewState extends State<ClaimView> with ClaimViewMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ClaimBloc(ClaimRepository(claimServices!))
            ..add(GetClaimTypesEvent(id: widget.insurance.id)),
      child: BlocListener<ClaimBloc, ClaimState>(
        listener: (context, state) {
          if (state is ClaimTypesError ||
              state is ClaimSubmissionError ||
              state is ClaimRecordsError) {
            final error = switch (state) {
              ClaimTypesError s => s.error,
              ClaimSubmissionError s => s.error,
              ClaimRecordsError s => s.error,
              _ => AppError.unknown,
            };

            context.push('/noInternet', extra: error).then((_) async {
              FocusManager.instance.primaryFocus?.unfocus();
              await Future.delayed(const Duration(milliseconds: 1500));
              if (!context.mounted) return;
              context.read<ClaimBloc>().add(RetryLastEvent());
            });
          }
        },
        child: Scaffold(
          body: BlocBuilder<ClaimBloc, ClaimState>(
            buildWhen: (previous, current) =>
                current is GetClaimTypesState ||
                current is ClaimStepUpState ||
                current is ClaimSubmissionSuccess ||
                current is ClaimSubmitting,
            builder: (context, state) {
              if (state is GetClaimTypesState) {
                claimTypes = state.claimTypes;
              }
              if (state is ClaimStepUpState) {
                step = state.step;
              }
              if (state is ClaimSubmissionSuccess) {
                return _buildSuccessScreen(state.refNo);
              }

              final isSubmitting = state is ClaimSubmitting;

              return Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: step == 1
                          ? _buildStep1()
                          : step == 2
                          ? _buildStep2()
                          : _buildStep3(),
                    ),
                  ),
                  _buildBottomButton(context, isSubmitting),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return switch (widget.insurance.category) {
      'vehicle' => _buildStep2ForVehicle(),
      'health' => _buildStep2ForHealth(),
      'home' => _buildStep2ForHome(),
      'travel' => _buildStep2ForTravel(),
      _ => _buildStep2ForVehicle(),
    };
  }

  Widget _buildHeader() {
    final stepLabels = switch (widget.insurance.category) {
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
                    Text(switch (widget.insurance.category) {
                      'vehicle' => 'claim.title_vehicle'.tr(),
                      'health' => 'claim.title_health'.tr(),
                      'home' => 'claim.title_home'.tr(),
                      'travel' => 'claim.title_travel'.tr(),
                      _ => 'claim.title'.tr(),
                    }, style: context.textTheme.headlineLarge),
                    Text(
                      '${widget.insurance.type} · ${widget.insurance.policyNo}',
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

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(switch (widget.insurance.category) {
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
            if (state is SelectedDamageTypeState) {
              selectedDamageType = state.damageType;
              selectedClaimTypeId = claimTypes
                  .firstWhere((type) => type.label == state.damageType)
                  .id;
            }
            if (claimTypes.isEmpty) {
              return const SingleChildScrollView(
                child: Column(children: [ClaimTypesShimmer()]),
              );
            }

            return Column(
              children: claimTypes.map((ct) {
                final isSelected = selectedClaimTypeId == ct.id;
                return GestureDetector(
                  onTap: () {
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
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStep2ForVehicle() {
    return Form(
      key: formKeyStepTwo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('claim.step2_title'.tr(), style: context.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _formField(
            readOnly: true,
            label: 'claim.field_date'.tr(),
            controller: dateController,
            hint: 'claim.field_date_hint'.tr(),
            onTap: dateTimeSelectionOnTap,
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_date_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'claim.field_location'.tr(),
            controller: locationController,
            hint: 'claim.field_location_hint'.tr(),
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_location_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'claim.field_plate'.tr(),
            controller: plateController,
            hint: 'claim.field_plate_hint'.tr(),
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'claim.field_description'.tr(),
            controller: descController,
            hint: 'claim.field_description_hint'.tr(),
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_desc_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _buildPhotoUpload(context),
        ],
      ),
    );
  }

  Widget _buildStep2ForHealth() {
    return Form(
      key: formKeyStepTwo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'claim.step2_title_health'.tr(),
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _formField(
            readOnly: true,
            label: 'claim.field_date'.tr(),
            controller: dateController,
            hint: 'claim.field_date_hint'.tr(),
            onTap: dateTimeSelectionOnTap,
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_date_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'claim.field_hospital'.tr(),
            controller: hospitalController,
            hint: 'claim.field_hospital_hint'.tr(),
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_hospital_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'claim.field_diagnosis'.tr(),
            controller: diagnosisController,
            hint: 'claim.field_diagnosis_hint'.tr(),
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_diagnosis_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'claim.field_description'.tr(),
            controller: descController,
            hint: 'claim.field_description_hint'.tr(),
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_desc_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _buildPhotoUpload(context),
        ],
      ),
    );
  }

  Widget _buildStep2ForHome() {
    return Form(
      key: formKeyStepTwo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'claim.step2_title_home'.tr(),
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          _formField(
            readOnly: true,
            label: 'claim.field_date'.tr(),
            controller: dateController,
            hint: 'claim.field_date_hint'.tr(),
            onTap: dateTimeSelectionOnTap,
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_date_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'claim.field_address'.tr(),
            controller: addressController,
            hint: 'claim.field_address_hint'.tr(),
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_address_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'claim.field_damage_area'.tr(),
            controller: damageAreaController,
            hint: 'claim.field_damage_area_hint'.tr(),
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_damage_area_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'claim.field_description'.tr(),
            controller: descController,
            hint: 'claim.field_description_hint'.tr(),
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_desc_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _buildPhotoUpload(context),
        ],
      ),
    );
  }

  Widget _buildStep2ForTravel() {
    return Form(
      key: formKeyStepTwo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('claim.step2_title'.tr(), style: context.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _formField(
            readOnly: true,
            label: 'claim.field_date'.tr(),
            controller: dateController,
            hint: 'claim.field_date_hint'.tr(),
            onTap: dateTimeSelectionOnTap,
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_date_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'claim.field_country'.tr(),
            controller: countryController,
            hint: 'claim.field_country_hint'.tr(),
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_country_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _formField(
            label: 'claim.field_description'.tr(),
            controller: descController,
            hint: 'claim.field_description_hint'.tr(),
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_desc_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          _buildPhotoUpload(context),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Form(
      key: formKeyStepThree,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('claim.step3_title'.tr(), style: context.textTheme.bodyMedium),
          const SizedBox(height: 16),
          _formField(
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
                _summaryRow('claim.summary_policy'.tr(), widget.insurance.type),
                const SizedBox(height: 8),
                _summaryRow('claim.summary_type'.tr(), selectedDamageType),
                const SizedBox(height: 8),
                _summaryRow(
                  'claim.summary_date'.tr(),
                  dateController.text.isEmpty ? '-' : dateController.text,
                ),
                const SizedBox(height: 8),
                _summaryRow(
                  switch (widget.insurance.category) {
                    'vehicle' => 'claim.summary_location_vehicle'.tr(),
                    'health' => 'claim.summary_location_health'.tr(),
                    'home' => 'claim.summary_location_home'.tr(),
                    'travel' => 'claim.summary_location_travel'.tr(),
                    _ => 'claim.summary_location'.tr(),
                  },
                  switch (widget.insurance.category) {
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

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: context.textTheme.bodySmall),
        Text(value, style: context.textTheme.labelMedium),
      ],
    );
  }

  Widget _formField({
    FormFieldValidator<String>? validator,
    bool readOnly = false,
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: context.textTheme.titleSmall),
        const SizedBox(height: 6),
        TextFormField(
          validator: validator,
          readOnly: readOnly,
          onTap: onTap,
          onTapUpOutside: (event) => FocusScope.of(context).unfocus(),
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: context.textTheme.bodyLarge,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, bool isSubmitting) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      color: context.appColors.bg,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.appColors.accent, context.appColors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: context.appColors.accent.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isSubmitting ? null : () => stepUpOnPressed(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    step == 3
                        ? switch (widget.insurance.category) {
                            'vehicle' => 'claim.submit_vehicle'.tr(),
                            'health' => 'claim.submit_health'.tr(),
                            'home' => 'claim.submit_home'.tr(),
                            'travel' => 'claim.submit_travel'.tr(),
                            _ => 'common.send'.tr(),
                          }
                        : 'common.continue'.tr(),
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(String refNo) {
    final (title, subtitle, info) = switch (widget.insurance.category) {
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
                  color: context.appColors.success.withOpacity(0.13),
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

  Widget _buildPhotoUpload(BuildContext context) {
    return ValueListenableBuilder<List<XFile>>(
      valueListenable: photosNotifier,
      builder: (context, photoList, _) {
        if (photoList.isEmpty) {
          return GestureDetector(
            onTap: () => addPhotoOnTap(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: context.appColors.card.withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: context.appColors.border,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Text('📷', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    'claim.photo_add'.tr(),
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'claim.photo_helper'.tr(),
                    style: context.textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photoList.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == photoList.length) {
                return GestureDetector(
                  onTap: () => addPhotoOnTap(context),
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: context.appColors.card.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.appColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: context.appColors.textSub,
                      size: 32,
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(photoList[index].path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => removePhoto(index),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
