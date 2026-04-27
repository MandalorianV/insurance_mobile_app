import 'package:dio/dio.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_record_model.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/services/insurance_services.dart';

abstract class InsuranceRepositoryInterface {
  Future<List<InsuranceModel>> getActivePolicies();
  Future<List<ClaimRecord>> getInsuranceRecords(String policyNo);
}

class InsuranceRepository implements InsuranceRepositoryInterface {
  final InsuranceServices _service;
  InsuranceRepository(this._service);
  @override
  Future<List<InsuranceModel>> getActivePolicies() async {
    try {
      final List<dynamic> rawData = await _service.getActiveInsurances();
      return rawData.map((json) => InsuranceModel.fromJson(json)).toList();
    } on DioException catch (dioError) {
      throw _mapDioError(dioError);
    } catch (_) {
      throw AppError.unknown;
    }
  }

  @override
  Future<List<ClaimRecord>> getInsuranceRecords(String policyNo) async {
    try {
      final List<dynamic> rawData = await _service.getInsuranceRecords(
        policyNo,
      );
      return rawData.map((json) => ClaimRecord.fromJson(json)).toList();
    } on DioException catch (dioError) {
      throw _mapDioError(dioError);
    } catch (_) {
      throw AppError.unknown;
    }
  }

  AppError _mapDioError(DioException e) {
    if (e.error is AppError) return e.error as AppError;
    return switch (e.type) {
      DioExceptionType.connectionError => AppError.noInternet,
      DioExceptionType.connectionTimeout => AppError.noInternet,
      DioExceptionType.receiveTimeout => AppError.timeout,
      DioExceptionType.sendTimeout => AppError.timeout,
      DioExceptionType.badResponse => AppError.serverError,
      _ => AppError.unknown,
    };
  }
}
