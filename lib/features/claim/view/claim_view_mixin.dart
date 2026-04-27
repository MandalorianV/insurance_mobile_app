import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insurance_mobile_app/core/network/client/dio_interceptor.dart';
import 'package:insurance_mobile_app/features/claim/bloc/claim_bloc.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_types_model.dart';
import 'package:insurance_mobile_app/features/claim/services/claim_services.dart';
import 'package:insurance_mobile_app/features/claim/view/claim_view.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

mixin ClaimViewMixin on State<ClaimView> {
  int step = 1;
  String? selectedClaimTypeId;
  String selectedDamageType = "";
  String submittedRefNo = '';
  final dio = DioClient().instance;

  // 2. Servisi oluştur (Dio bağımlılığını veriyoruz)
  ClaimServices? claimServices;

  final dateController = TextEditingController();
  final locationController = TextEditingController();
  final plateController = TextEditingController();
  final descController = TextEditingController();
  final phoneController = TextEditingController();

  // Sağlık için
  final hospitalController = TextEditingController();
  final diagnosisController = TextEditingController();

  // Konut için
  final addressController = TextEditingController();
  final damageAreaController = TextEditingController();

  // Seyahat için
  final countryController = TextEditingController();
  final List<XFile> photos = [];

  ValueNotifier<List<XFile>> photosNotifier = ValueNotifier([]);

  List<ClaimType> claimTypes = [];

  // Form keys for validation

  final formKeyStepTwo = GlobalKey<FormState>();

  final formKeyStepThree = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    claimServices = ClaimServices(dio);
  }

  @override
  void dispose() {
    dateController.dispose();
    locationController.dispose();
    plateController.dispose();
    descController.dispose();
    phoneController.dispose();
    hospitalController.dispose();
    diagnosisController.dispose();
    addressController.dispose();
    damageAreaController.dispose();
    countryController.dispose();
    super.dispose();
  }

  void addPhotoOnTap(BuildContext context) async {
    final surfaceColor = context.appColors.surface;
    final style = context.textTheme.titleMedium;
    final photoAddText = 'claim.photo_add'.tr();
    final galleryText = 'claim.photo_gallery'.tr();
    final cameraText = 'claim.photo_camera'.tr();

    ImageSource? source = await showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          spacing: 10,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 10),
            Text(photoAddText, style: style),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    child: Text(galleryText),
                    onPressed: () =>
                        Navigator.of(context).pop(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    child: Text(cameraText),
                    onPressed: () =>
                        Navigator.of(context).pop(ImageSource.camera),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );

    if (source is! ImageSource) return;
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      photos.add(pickedFile);
      photosNotifier.value = List.from(photos);
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void removePhoto(int index) {
    photos.removeAt(index);
    photosNotifier.value = List.from(photos); // 👈 rebuild tetikle
  }

  void dateTimeSelectionOnTap() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (!mounted) return;
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final formattedDate =
            '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${time.format(context)}';
        dateController.text = formattedDate;
      }
    }
  }

  void stepUpOnPressed(BuildContext context) {
    if (selectedClaimTypeId == null && step == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('claim.validation_select_type'.tr())),
      );
      return;
    }
    if (step == 2 && !formKeyStepTwo.currentState!.validate()) {
      return;
    }

    if (step < 3) {
      context.read<ClaimBloc>().add(ClaimStepUpEvent(step: step + 1));
      return;
    }
    if (formKeyStepThree.currentState!.validate()) {
      context.read<ClaimBloc>().add(
        SubmitClaimEvent(
          claimData: {
            'id': widget.insurance.id,
            'policy_no': widget.insurance.policyNo,
            'claim_type_id': selectedClaimTypeId,
            'claim_type_label': claimTypes
                .firstWhere((ct) => ct.id == selectedClaimTypeId)
                .label,
            'claim_type_emoji': claimTypes
                .firstWhere((ct) => ct.id == selectedClaimTypeId)
                .emoji,
            'incident_date': dateController.text,
            'description': descController.text,
            'phone': phoneController.text,
            'email': null,
            'status': 'in_progress',
            'photos': photos.map((f) => f.path).toList(),
            if (widget.insurance.category == 'vehicle') ...{
              'location': locationController.text,
              'plate': plateController.text.isEmpty
                  ? null
                  : plateController.text,
            },
            if (widget.insurance.category == 'health') ...{
              'hospital': hospitalController.text,
              'diagnosis': diagnosisController.text,
            },
            if (widget.insurance.category == 'home') ...{
              'address': addressController.text,
              'damage_area': damageAreaController.text,
            },
            if (widget.insurance.category == 'travel') ...{
              'country': countryController.text,
            },
          },
        ),
      );
      return;
    }
  }
}
