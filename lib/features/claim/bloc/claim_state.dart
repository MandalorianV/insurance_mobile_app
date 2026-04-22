part of 'claim_bloc.dart';

@immutable
sealed class ClaimState {}

final class ClaimInitial extends ClaimState {}

final class GetClaimTypes extends ClaimState {
  final List<ClaimType> claimTypes;
  GetClaimTypes({required this.claimTypes});
}
