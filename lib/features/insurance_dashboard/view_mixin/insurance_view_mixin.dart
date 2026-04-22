import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view/insurance_view.dart';

mixin InsuranceViewMixin on State<InsuranceView> {
  @override
  void initState() {
    super.initState();
    context.read<InsuranceBloc>().add(GetInsuranceListEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> onRefresh() async {
    context.read<InsuranceBloc>().add(GetInsuranceListEvent());
  }
}
