import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_record_model.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_types_model.dart';
import 'package:insurance_mobile_app/features/claim/repository/claim_repository.dart';

part 'claim_event.dart';
part 'claim_state.dart';

class ClaimBloc extends Bloc<ClaimEvent, ClaimState> {
  final ClaimRepository _repository;
  ClaimEvent? _lastEvent; // 👈 class level

  ClaimBloc(this._repository) : super(ClaimInitial()) {
    on<GetClaimTypesEvent>(_onGetClaimTypes);
    on<GetClaimRecordsEvent>(_onGetClaimRecords);
    on<GetClaimDetailEvent>(_onGetClaimDetail);
    on<SelectDamageTypeEvent>(_onSelectDamageType);
    on<ClaimStepUpEvent>(_onStepUp);
    on<SubmitClaimEvent>(_onSubmitClaim);
    on<RetryLastEvent>((event, emit) {
      if (_lastEvent != null) add(_lastEvent!);
    });
  }

  @override // 👈 class level override
  void add(ClaimEvent event) {
    if (event is! RetryLastEvent) {
      _lastEvent = event;
    }
    super.add(event);
  }

  // ... handler'lar

  AppError _mapError(dynamic e) {
    if (e is AppError) return e;
    if (e is DioException && e.error is AppError) return e.error as AppError;
    return AppError.unknown;
  }

  Future<void> _onGetClaimTypes(
    GetClaimTypesEvent event,
    Emitter<ClaimState> emit,
  ) async {
    emit(ClaimTypesLoading());
    try {
      final claimTypes = await _repository.getClaimTypes(event.id);
      emit(GetClaimTypesState(claimTypes: claimTypes));
    } catch (e) {
      emit(ClaimTypesError(error: _mapError(e)));
    }
  }

  Future<void> _onGetClaimRecords(
    GetClaimRecordsEvent event,
    Emitter<ClaimState> emit,
  ) async {
    emit(ClaimRecordsLoading());
    try {
      final records = await _repository.getClaimRecords(event.policyNo);
      emit(GetClaimRecords(records: records));
    } catch (e) {
      emit(ClaimRecordsError(error: _mapError(e)));
    }
  }

  Future<void> _onGetClaimDetail(
    GetClaimDetailEvent event,
    Emitter<ClaimState> emit,
  ) async {
    emit(ClaimDetailLoading());
    try {
      final record = await _repository.getClaimDetail(event.refNo);
      emit(GetClaimDetail(record: record));
    } catch (e) {
      emit(ClaimDetailError(error: _mapError(e)));
    }
  }

  void _onSelectDamageType(
    SelectDamageTypeEvent event,
    Emitter<ClaimState> emit,
  ) {
    emit(SelectedDamageTypeState(damageType: event.damageType));
  }

  void _onStepUp(ClaimStepUpEvent event, Emitter<ClaimState> emit) {
    emit(ClaimStepUpState(step: event.step));
  }

  Future<void> _onSubmitClaim(
    SubmitClaimEvent event,
    Emitter<ClaimState> emit,
  ) async {
    if (state is ClaimSubmitting) return; // double submit koruması
    emit(ClaimSubmitting());
    try {
      final refNo = await _repository.submitClaim(event.claimData);
      emit(ClaimSubmissionSuccess(refNo: refNo));
    } catch (e) {
      emit(ClaimSubmissionError(error: _mapError(e)));
    }
  }
}
