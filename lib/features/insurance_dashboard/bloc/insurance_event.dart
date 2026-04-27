part of 'insurance_bloc.dart';

@immutable
sealed class InsuranceEvent {}

class GetInsuranceListEvent extends InsuranceEvent {}

class GetInsuranceRecordsEvent extends InsuranceEvent {
  final String policyNo;
  GetInsuranceRecordsEvent({required this.policyNo});
}

class RetryLastEvent extends InsuranceEvent {}
