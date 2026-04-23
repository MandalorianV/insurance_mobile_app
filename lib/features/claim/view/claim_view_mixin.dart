import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/core/network/client/dio_interceptor.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_types_model.dart';
import 'package:insurance_mobile_app/features/claim/services/claim_services.dart';
import 'package:insurance_mobile_app/features/claim/view/claim_view.dart';

mixin ClaimViewMixin on State<ClaimView> {
  int step = 1;
  String? selectedClaimTypeId;
  bool submitted = false;
  final dio = DioClient().instance;

  // 2. Servisi oluştur (Dio bağımlılığını veriyoruz)
  ClaimServices? claimServices;

  final formKey2 = GlobalKey<FormState>();
  final formKey3 = GlobalKey<FormState>();

  final dateController = TextEditingController();
  final locationController = TextEditingController();
  final plateController = TextEditingController();
  final descController = TextEditingController();
  final phoneController = TextEditingController();
  bool step2Attempted = false;
  bool step3Attempted = false;

  List<ClaimType> claimTypes = [];

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
    super.dispose();
  }
}
