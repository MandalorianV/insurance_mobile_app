import 'package:dio/dio.dart';

class ClaimServices {
  final Dio _dio;
  ClaimServices(this._dio);

  Future<List<dynamic>> getClaimTypes(int id) async {
    final response = await _dio.get('/api/claim-types', data: {'id': id});
    return response.data;
  }

  Future<List<dynamic>> getClaimRecords(String policyNo) async {
    final response = await _dio.get(
      '/api/claims',
      queryParameters: {'policy_no': policyNo},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getClaimDetail(String refNo) async {
    final response = await _dio.get('/api/claims/$refNo');
    return response.data;
  }

  Future<Map<String, dynamic>> submitClaim(
    Map<String, dynamic> claimData,
  ) async {
    final response = await _dio.post('/api/claims', data: claimData);
    return response.data;
  }
}
