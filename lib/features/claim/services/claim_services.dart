import 'package:dio/dio.dart';

class ClaimServices {
  final Dio _dio;
  ClaimServices(this._dio);

  Future<List<dynamic>> getClaimTypes() async {
    try {
      final response = await _dio.get('/api/claim-types');
      return response.data;
    } on DioException catch (e) {
      // Burada hata yönetimi yapılabilir
      rethrow;
    }
  }
}
