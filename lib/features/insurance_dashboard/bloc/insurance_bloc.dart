import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_record_model.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/repository/insurance_repository.dart';

part 'insurance_event.dart';
part 'insurance_state.dart';

class InsuranceBloc extends Bloc<InsuranceEvent, InsuranceState> {
  final InsuranceRepositoryInterface _insuranceRepository;
  InsuranceEvent? _lastEvent;
  InsuranceBloc(this._insuranceRepository) : super(InsuranceInitial()) {
    on<GetInsuranceListEvent>(_getInsuranceList);
    on<GetInsuranceRecordsEvent>(_getInsuranceRecords);
    on<RetryLastEvent>((event, emit) {
      if (_lastEvent != null) add(_lastEvent!);
    });
  }
  @override
  void add(InsuranceEvent event) {
    if (event is! RetryLastEvent) {
      _lastEvent = event;
    }
    super.add(event);
  }

  AppError _mapError(dynamic e) {
    if (e is AppError) return e;
    if (e is DioException && e.error is AppError) return e.error as AppError;
    return AppError.unknown;
  }

  Future<void> _getInsuranceList(
    GetInsuranceListEvent event,
    Emitter<InsuranceState> emit,
  ) async {
    emit(LoadingListState());
    try {
      final insuranceList = await _insuranceRepository.getActivePolicies();
      if (insuranceList.isEmpty) {
        emit(InsuranceListEmptyState());
      } else {
        emit(GetInsuranceListState(insuranceList: insuranceList));
      }
    } catch (e) {
      emit(InsuranceListErrorState(error: _mapError(e)));
    }
  }

  Future<void> _getInsuranceRecords(
    GetInsuranceRecordsEvent event,
    Emitter<InsuranceState> emit,
  ) async {
    try {
      emit(LoadingRecordListState());
      final insuranceRecordsList = await _insuranceRepository
          .getInsuranceRecords(event.policyNo);
      if (insuranceRecordsList.isEmpty) {
        emit(InsuranceRecordsListEmptyState());
      } else {
        emit(
          GetInsuranceRecordsListState(
            insuranceRecordsList: insuranceRecordsList,
          ),
        );
      }
    } catch (e) {
      emit(InsuranceRecordsListErrorState(error: _mapError(e)));
    }
  }
}
