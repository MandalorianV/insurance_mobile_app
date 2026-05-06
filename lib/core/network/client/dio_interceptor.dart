import 'package:dio/dio.dart';
import 'package:insurance_mobile_app/core/network/interceptor/error_interceptor.dart';
import 'package:insurance_mobile_app/core/network/interceptor/mock_interceptor.dart';

class DioClient {
  DioClient({
    this.baseUrl = 'https://api.insuranceapp.com',
    this.languageCode = 'tr',
    this.enableLogging = true,
    this.useMockInterceptor = true,
  }) {
    _dio = _createDio();
  }

  final String baseUrl;
  final String languageCode;
  final bool enableLogging;
  final bool useMockInterceptor;

  late final Dio _dio;

  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),

        headers: {'Accept-Language': languageCode},
      ),
    );

    if (useMockInterceptor) {
      dio.interceptors.add(MockInterceptor());
    }

    dio.interceptors.add(ErrorInterceptor());

    if (enableLogging) {
      dio.interceptors.add(
        LogInterceptor(responseBody: true, requestBody: true),
      );
    }

    return dio;
  }

  Dio get instance => _dio;

  void setLocale(String languageCode) {
    _dio.options.headers['Accept-Language'] = languageCode;
  }

  void close({bool force = false}) {
    _dio.close(force: force);
  }
}
