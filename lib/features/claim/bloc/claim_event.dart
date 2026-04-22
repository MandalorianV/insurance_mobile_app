part of 'claim_bloc.dart';

@immutable
sealed class ClaimEvent {}

class GetClaimTypesEvent extends ClaimEvent {}
