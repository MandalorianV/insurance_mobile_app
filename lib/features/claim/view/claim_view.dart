import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:insurance_mobile_app/features/claim/bloc/claim_bloc.dart';
import 'package:insurance_mobile_app/features/claim/repository/claim_repository.dart';
import 'package:insurance_mobile_app/features/claim/view/claim_view_mixin.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_bottom_button.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_header.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_step1.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_step2_health.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_step2_home.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_step2_travel.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_step2_vehicle.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_step3.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_success_screen.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';

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
                return ClaimSuccessScreen(
                  refNo: state.refNo,
                  insurance: widget.insurance,
                );
              }

              final isSubmitting = state is ClaimSubmitting;

              return Column(
                children: [
                  ClaimHeader(insurance: widget.insurance, step: step),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: _buildStep(),
                    ),
                  ),
                  ClaimBottomButton(
                    step: step,
                    isSubmitting: isSubmitting,
                    insurance: widget.insurance,
                    onPressed: () => stepUpOnPressed(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    return switch (step) {
      1 => ClaimStep1(
        insurance: widget.insurance,
        claimTypes: claimTypes,
        showStep1Error: showStep1Error,
        selectedClaimTypeId: selectedClaimTypeId,
        onDamageTypeSelected: (label) {
          // ← onSelectType değil
          selectedClaimTypeId = claimTypes
              .firstWhere((ct) => ct.label == label)
              .id;
        },
      ),
      2 => _buildStep2(),
      3 => ClaimStep3(
        formKey: formKeyStepThree,
        phoneController: phoneController,
        dateController: dateController,
        locationController: locationController,
        hospitalController: hospitalController,
        addressController: addressController,
        countryController: countryController,
        insurance: widget.insurance,
        selectedDamageType: selectedDamageType,
      ),
      _ => const SizedBox(),
    };
  }

  Widget _buildStep2() {
    return switch (widget.insurance.category) {
      'vehicle' => ClaimStep2Vehicle(
        formKey: formKeyStepTwo,
        dateController: dateController,
        locationController: locationController,
        plateController: plateController,
        descController: descController,
        photosNotifier: photosNotifier,
        onAddPhoto: () => addPhotoOnTap(context),
        onRemovePhoto: removePhoto,
        onDateTap: dateTimeSelectionOnTap,
      ),
      'health' => ClaimStep2Health(
        formKey: formKeyStepTwo,
        dateController: dateController,
        hospitalController: hospitalController,
        diagnosisController: diagnosisController,
        descController: descController,
        photosNotifier: photosNotifier,
        onAddPhoto: () => addPhotoOnTap(context),
        onRemovePhoto: removePhoto,
        onDateTap: dateTimeSelectionOnTap,
      ),
      'home' => ClaimStep2Home(
        formKey: formKeyStepTwo,
        dateController: dateController,
        addressController: addressController,
        damageAreaController: damageAreaController,
        descController: descController,
        photosNotifier: photosNotifier,
        onAddPhoto: () => addPhotoOnTap(context),
        onRemovePhoto: removePhoto,
        onDateTap: dateTimeSelectionOnTap,
      ),
      'travel' => ClaimStep2Travel(
        formKey: formKeyStepTwo,
        dateController: dateController,
        countryController: countryController,
        descController: descController,
        photosNotifier: photosNotifier,
        onAddPhoto: () => addPhotoOnTap(context),
        onRemovePhoto: removePhoto,
        onDateTap: dateTimeSelectionOnTap,
      ),
      _ => ClaimStep2Vehicle(
        formKey: formKeyStepTwo,
        dateController: dateController,
        locationController: locationController,
        plateController: plateController,
        descController: descController,
        photosNotifier: photosNotifier,
        onAddPhoto: () => addPhotoOnTap(context),
        onRemovePhoto: removePhoto,
        onDateTap: dateTimeSelectionOnTap,
      ),
    };
  }
}
