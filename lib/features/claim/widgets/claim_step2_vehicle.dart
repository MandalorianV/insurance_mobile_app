import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_form_field.dart';
import 'package:insurance_mobile_app/features/claim/widgets/claim_photo_upload.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class ClaimStep2Vehicle extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController dateController;
  final TextEditingController locationController;
  final TextEditingController plateController;
  final TextEditingController descController;
  final ValueNotifier<List<XFile>> photosNotifier;
  final VoidCallback onAddPhoto;
  final void Function(int) onRemovePhoto;
  final VoidCallback onDateTap;

  const ClaimStep2Vehicle({
    super.key,
    required this.formKey,
    required this.dateController,
    required this.locationController,
    required this.plateController,
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
          Text('claim.step2_title'.tr(), style: context.textTheme.bodyMedium),
          const SizedBox(height: 16),
          ClaimFormField(
            key: const Key('claim_date_field'),
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
            key: const Key('claim_location_field'),
            label: 'claim.field_location'.tr(),
            controller: locationController,
            hint: 'claim.field_location_hint'.tr(),
            validator: (v) => v == null || v.isEmpty
                ? 'claim.validation_location_required'.tr()
                : null,
          ),
          const SizedBox(height: 14),
          ClaimFormField(
            key: const Key('claim_plate_field'),
            label: 'claim.field_plate'.tr(),
            controller: plateController,
            hint: 'claim.field_plate_hint'.tr(),
          ),
          const SizedBox(height: 14),
          ClaimFormField(
            key: const Key('claim_description_field'),
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
