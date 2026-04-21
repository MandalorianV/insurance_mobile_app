import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view/insurance_view.dart';

mixin InsuranceViewMixin on State<InsuranceView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> onRefresh() async {
    await Future.delayed(Duration(seconds: 2));
  }
}
