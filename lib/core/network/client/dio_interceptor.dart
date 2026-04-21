import 'package:dio/dio.dart';
import 'package:insurance_mobile_app/core/network/interceptor/mock_interceptor.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.insuranceapp.com', // Fake bir base url
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    // Sadece debug modunda veya test için MockInterceptor ekliyoruz
    _dio.interceptors.add(MockInterceptor());

    // Logları konsolda görmek için (Opsiyonel)
    _dio.interceptors.add(
      LogInterceptor(responseBody: true, requestBody: true),
    );
  }

  Dio get instance => _dio;
}
