import 'package:dio/dio.dart';

class InsuranceServices {
  final Dio _dio;
  InsuranceServices(this._dio);

  Future<List<dynamic>> getActiveInsurances() async {
    try {
      final response = await _dio.get('/api/insurances');
      return response.data;
    } on DioException catch (e) {
      // Burada hata yönetimi yapılabilir
      rethrow;
    }
  }
}
