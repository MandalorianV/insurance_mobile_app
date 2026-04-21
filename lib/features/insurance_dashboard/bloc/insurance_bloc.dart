import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/repository/insurance_repository.dart';

part 'insurance_event.dart';
part 'insurance_state.dart';

class InsuranceBloc extends Bloc<InsuranceEvent, InsuranceState> {
  InsuranceBloc(InsuranceRepository insuranceRepository)
    : super(InsuranceInitial()) {
    on<InsuranceEvent>((event, emit) {});
    on<GetInsuranceListEvent>((event, emit) async {
      emit(LoadingListState());
      List<InsuranceModel> insuranceList = await insuranceRepository
          .getActivePolicies();
      emit(GetInsuranceListState(insuranceList: insuranceList));
    });
  }
}
