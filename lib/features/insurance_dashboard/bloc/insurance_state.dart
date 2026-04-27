part of 'insurance_bloc.dart';

@immutable
sealed class InsuranceState {}

final class InsuranceInitial extends InsuranceState {}

// ── Loading ──────────────────────────────────────────────────
final class LoadingListState extends InsuranceState {}

final class LoadingRecordListState extends InsuranceState {}

// ── Success ──────────────────────────────────────────────────
final class GetInsuranceListState extends InsuranceState {
  final List<InsuranceModel> insuranceList;
  GetInsuranceListState({required this.insuranceList});
}

final class GetInsuranceRecordsListState extends InsuranceState {
  final List<ClaimRecord> insuranceRecordsList;
  GetInsuranceRecordsListState({required this.insuranceRecordsList});
}

// ── Error ────────────────────────────────────────────────────
final class InsuranceListErrorState extends InsuranceState {
  final AppError error;
  InsuranceListErrorState({required this.error});
}

final class InsuranceListEmptyState extends InsuranceState {}

final class InsuranceRecordsListEmptyState extends InsuranceState {}

final class InsuranceRecordsListErrorState extends InsuranceState {
  final AppError error;
  InsuranceRecordsListErrorState({required this.error});
}
