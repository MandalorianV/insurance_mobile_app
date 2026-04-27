part of 'insurance_bloc.dart';

@immutable
sealed class InsuranceState {}

// ── Loading — field yok, Equatable gereksiz ──────────────────
final class InsuranceInitial extends InsuranceState {}

final class LoadingListState extends InsuranceState {}

final class LoadingRecordListState extends InsuranceState {}

final class InsuranceListEmptyState extends InsuranceState {}

final class InsuranceRecordsListEmptyState extends InsuranceState {}

// ── Success ──────────────────────────────────────────────────
final class GetInsuranceListState extends InsuranceState with EquatableMixin {
  final List<InsuranceModel> insuranceList;
  GetInsuranceListState({required this.insuranceList});

  @override
  List<Object?> get props => [insuranceList];
}

final class GetInsuranceRecordsListState extends InsuranceState
    with EquatableMixin {
  final List<ClaimRecord> insuranceRecordsList;
  GetInsuranceRecordsListState({required this.insuranceRecordsList});

  @override
  List<Object?> get props => [insuranceRecordsList];
}

// ── Error ────────────────────────────────────────────────────
final class InsuranceListErrorState extends InsuranceState with EquatableMixin {
  final AppError error;
  InsuranceListErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}

final class InsuranceRecordsListErrorState extends InsuranceState
    with EquatableMixin {
  final AppError error;
  InsuranceRecordsListErrorState({required this.error});

  @override
  List<Object?> get props => [error];
}
