import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view/insurance_view_details.dart';

mixin InsuranceViewDetailsMixin on State<InsuranceViewDetails> {
  @override
  void initState() {
    super.initState();
    context.read<InsuranceBloc>().add(
      GetInsuranceRecordsEvent(policyNo: widget.insurance.policyNo),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
