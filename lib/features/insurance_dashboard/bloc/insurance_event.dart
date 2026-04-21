part of 'insurance_bloc.dart';

@immutable
sealed class InsuranceEvent {}

class GetInsuranceListEvent extends InsuranceEvent {}
