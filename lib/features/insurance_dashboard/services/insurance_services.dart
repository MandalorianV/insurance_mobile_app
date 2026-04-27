import 'package:dio/dio.dart';

class InsuranceServices {
  final Dio _dio;
  InsuranceServices(this._dio);

  Future<List<dynamic>> getActiveInsurances() async {
    final response = await _dio.get('/api/insurances');
    return response.data;
  }

  Future<List<dynamic>> getInsuranceRecords(String policyNo) async {
    final response = await _dio.get(
      '/api/insurance-records',
      data: {'policyNo': policyNo},
    );
    return response.data;
  }
}
