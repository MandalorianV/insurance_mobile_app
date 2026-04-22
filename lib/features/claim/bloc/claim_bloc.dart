import 'package:bloc/bloc.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_types_model.dart';
import 'package:insurance_mobile_app/features/claim/repository/claim_repository.dart';
import 'package:meta/meta.dart';

part 'claim_event.dart';
part 'claim_state.dart';

class ClaimBloc extends Bloc<ClaimEvent, ClaimState> {
  ClaimBloc(ClaimRepository claimRepository) : super(ClaimInitial()) {
    on<GetClaimTypesEvent>((event, emit) async {
      List<ClaimType> claimTypes = await claimRepository.getClaimTypes();
      emit(GetClaimTypes(claimTypes: claimTypes));
    });
  }
}
