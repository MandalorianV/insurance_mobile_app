part of 'insurance_bloc.dart';

@immutable
sealed class InsuranceState {}

final class InsuranceInitial extends InsuranceState {}

final class LoadingListState extends InsuranceState {}

final class GetInsuranceListState extends InsuranceState {
  final List<InsuranceModel> insuranceList;
  GetInsuranceListState({required this.insuranceList});
}

final class InsuranceListError extends InsuranceState {
  final String message;
  InsuranceListError({required this.message});
}

final class InsuranceEmptyState extends InsuranceState {}
