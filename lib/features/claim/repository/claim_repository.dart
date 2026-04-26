import 'package:dio/dio.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_record_model.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_types_model.dart';
import 'package:insurance_mobile_app/features/claim/services/claim_services.dart';

abstract class ClaimRepositoryInterface {
  Future<List<ClaimType>> getClaimTypes(int id);
  Future<List<ClaimRecord>> getClaimRecords(String policyNo);
  Future<ClaimRecord> getClaimDetail(String refNo);
  Future<String> submitClaim(Map<String, dynamic> claimData);
}

class ClaimRepository implements ClaimRepositoryInterface {
  final ClaimServices _service;
  ClaimRepository(this._service);

  @override
  Future<List<ClaimType>> getClaimTypes(int id) async {
    try {
      final raw = await _service.getClaimTypes(id);
      return raw.map((json) => ClaimType.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw AppError.unknown;
    }
  }

  @override
  Future<List<ClaimRecord>> getClaimRecords(String policyNo) async {
    try {
      final raw = await _service.getClaimRecords(policyNo);
      return raw.map((json) => ClaimRecord.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw AppError.unknown;
    }
  }

  @override
  Future<ClaimRecord> getClaimDetail(String refNo) async {
    try {
      final raw = await _service.getClaimDetail(refNo);
      return ClaimRecord.fromJson(raw);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (_) {
      throw AppError.unknown;
    }
  }

  @override
  Future<String> submitClaim(Map<String, dynamic> claimData) async {
    try {
      final raw = await _service.submitClaim(claimData);
      return raw['claim']['ref_no'] as String;
    } on DioException catch (e) {
      throw _mapDioError(e);
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
