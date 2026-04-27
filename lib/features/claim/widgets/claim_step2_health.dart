import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_form_field.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_photo_upload.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class ClaimStep2Health extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController dateController;
  final TextEditingController hospitalController;
  final TextEditingController diagnosisController;
  final TextEditingController descController;
  final ValueNotifier<List<XFile>> photosNotifier;
  final VoidCallback onAddPhoto;
  final void Function(int) onRemovePhoto;
  final VoidCallback onDateTap;

  const ClaimStep2Health({
    super.key,
    required this.formKey,
    required this.dateController,
    required this.hospitalController,
    required this.diagnosisController,
    required this.descController,
    required this.photosNotifier,
    required this.onAddPhoto,
    required this.onRemovePhoto,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'claim.step2_title_health'.tr(),
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ClaimFormField(
            readOnly: true,
            label: 'claim.field_date'.tr(),
            controller: dateController,
            hint: 'claim.field_date_hint'.tr(),
            onTap: onDateTap,
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_date_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          ClaimFormField(
            label: 'claim.field_hospital'.tr(),
            controller: hospitalController,
            hint: 'claim.field_hospital_hint'.tr(),
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_hospital_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          ClaimFormField(
            label: 'claim.field_diagnosis'.tr(),
            controller: diagnosisController,
            hint: 'claim.field_diagnosis_hint'.tr(),
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_diagnosis_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          ClaimFormField(
            label: 'claim.field_description'.tr(),
            controller: descController,
            hint: 'claim.field_description_hint'.tr(),
            maxLines: 4,
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_desc_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          ClaimPhotoUpload(
            photosNotifier: photosNotifier,
            onAddPhoto: onAddPhoto,
            onRemovePhoto: onRemovePhoto,
          ),
        ],
      ),
    );
  }
}
