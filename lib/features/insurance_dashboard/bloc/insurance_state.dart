part of 'insurance_bloc.dart';

@immutable
sealed class InsuranceState {}

final class InsuranceInitial extends InsuranceState {}

final class LoadingListState extends InsuranceState {}

final class GetInsuranceListState extends InsuranceState {
  final List<InsuranceModel> insuranceList;

  GetInsuranceListState({required this.insuranceList});
}
