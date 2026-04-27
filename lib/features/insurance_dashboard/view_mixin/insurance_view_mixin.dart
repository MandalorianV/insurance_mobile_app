import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view/insurance_view.dart';

mixin InsuranceViewMixin on State<InsuranceView> {
  @override
  void initState() {
    super.initState();
    context.read<InsuranceBloc>().add(GetInsuranceListEvent());
  }

  Future<void> onRefresh() async {
    context.read<InsuranceBloc>().add(GetInsuranceListEvent());
  }

  void onInsuranceTap(BuildContext context, insurance) {
    context.push('/insuranceDetails', extra: insurance);
  }
}
