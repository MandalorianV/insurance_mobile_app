import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'claim_event.dart';
part 'claim_state.dart';

class ClaimBloc extends Bloc<ClaimEvent, ClaimState> {
  ClaimBloc() : super(ClaimInitial()) {
    on<ClaimEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
