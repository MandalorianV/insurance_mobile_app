part of 'claim_bloc.dart';

@immutable
sealed class ClaimState {}

// ── Loading — field yok, Equatable gereksiz ──────────────────
final class ClaimInitial extends ClaimState {}

final class ClaimTypesLoading extends ClaimState {}

final class ClaimRecordsLoading extends ClaimState {}

final class ClaimDetailLoading extends ClaimState {}

final class ClaimSubmitting extends ClaimState {}

// ── Success ──────────────────────────────────────────────────
final class GetClaimTypesState extends ClaimState with EquatableMixin {
  final List<ClaimType> claimTypes;
  GetClaimTypesState({required this.claimTypes});

  @override
  List<Object?> get props => [claimTypes];
}

final class GetClaimRecords extends ClaimState with EquatableMixin {
  final List<ClaimRecord> records;
  GetClaimRecords({required this.records});

  @override
  List<Object?> get props => [records];
}

final class GetClaimDetail extends ClaimState with EquatableMixin {
  final ClaimRecord record;
  GetClaimDetail({required this.record});

  @override
  List<Object?> get props => [record];
}

final class SelectedDamageTypeState extends ClaimState with EquatableMixin {
  final String damageType;
  SelectedDamageTypeState({required this.damageType});

  @override
  List<Object?> get props => [damageType];
}

final class ClaimStepUpState extends ClaimState with EquatableMixin {
  final int step;
  ClaimStepUpState({required this.step});

  @override
  List<Object?> get props => [step];
}

final class ClaimSubmissionSuccess extends ClaimState with EquatableMixin {
  final String refNo;
  ClaimSubmissionSuccess({required this.refNo});

  @override
  List<Object?> get props => [refNo];
}

// ── Error ────────────────────────────────────────────────────
final class ClaimTypesError extends ClaimState with EquatableMixin {
  final AppError error;
  ClaimTypesError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class ClaimRecordsError extends ClaimState with EquatableMixin {
  final AppError error;
  ClaimRecordsError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class ClaimDetailError extends ClaimState with EquatableMixin {
  final AppError error;
  ClaimDetailError({required this.error});

  @override
  List<Object?> get props => [error];
}

final class ClaimSubmissionError extends ClaimState with EquatableMixin {
  final AppError error;
  ClaimSubmissionError({required this.error});

  @override
  List<Object?> get props => [error];
}
