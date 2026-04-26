part of 'claim_bloc.dart';

@immutable
sealed class ClaimEvent {}

class GetClaimTypesEvent extends ClaimEvent {
  final int id;
  GetClaimTypesEvent({required this.id});
}

class GetClaimRecordsEvent extends ClaimEvent {
  final String policyNo;
  GetClaimRecordsEvent({required this.policyNo});
}

class GetClaimDetailEvent extends ClaimEvent {
  final String refNo;
  GetClaimDetailEvent({required this.refNo});
}

class SelectDamageTypeEvent extends ClaimEvent {
  final String damageType;
  SelectDamageTypeEvent({required this.damageType});
}

class ClaimStepUpEvent extends ClaimEvent {
  final int step;
  ClaimStepUpEvent({required this.step});
}

class SubmitClaimEvent extends ClaimEvent {
  final Map<String, dynamic> claimData;
  SubmitClaimEvent({required this.claimData});
}

class RetryLastEvent extends ClaimEvent {}
