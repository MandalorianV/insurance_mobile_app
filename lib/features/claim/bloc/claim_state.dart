part of 'claim_bloc.dart';

@immutable
sealed class ClaimState {}

final class ClaimInitial extends ClaimState {}

// ── Loading ──────────────────────────────────────────────────
final class ClaimTypesLoading extends ClaimState {}

final class ClaimRecordsLoading extends ClaimState {}

final class ClaimDetailLoading extends ClaimState {}

final class ClaimSubmitting extends ClaimState {}

// ── Success ──────────────────────────────────────────────────
final class GetClaimTypesState extends ClaimState {
  final List<ClaimType> claimTypes;
  GetClaimTypesState({required this.claimTypes});
}

final class GetClaimRecords extends ClaimState {
  final List<ClaimRecord> records;
  GetClaimRecords({required this.records});
}

final class GetClaimDetail extends ClaimState {
  final ClaimRecord record;
  GetClaimDetail({required this.record});
}

final class SelectedDamageTypeState extends ClaimState {
  final String damageType;
  SelectedDamageTypeState({required this.damageType});
}

final class ClaimStepUpState extends ClaimState {
  final int step;
  ClaimStepUpState({required this.step});
}

final class ClaimSubmissionSuccess extends ClaimState {
  final String refNo;
  ClaimSubmissionSuccess({required this.refNo});
}

// ── Error ────────────────────────────────────────────────────
final class ClaimTypesError extends ClaimState {
  final AppError error;
  ClaimTypesError({required this.error});
}

final class ClaimRecordsError extends ClaimState {
  final AppError error;
  ClaimRecordsError({required this.error});
}

final class ClaimDetailError extends ClaimState {
  final AppError error;
  ClaimDetailError({required this.error});
}

final class ClaimSubmissionError extends ClaimState {
  final AppError error;
  ClaimSubmissionError({required this.error});
}
