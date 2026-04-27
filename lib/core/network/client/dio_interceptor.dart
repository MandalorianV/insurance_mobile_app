import 'package:dio/dio.dart';
import 'package:insurance_mobile_app/core/network/interceptor/error_interceptor.dart';
import 'package:insurance_mobile_app/core/network/interceptor/mock_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._init();
  factory DioClient() => _instance;

  late final Dio _dio;

  DioClient._init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.insuranceapp.com',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
        headers: {
          'Accept-Language': 'tr', // default
        },
      ),
    );

    _dio.interceptors.addAll([
      MockInterceptor(),
      ErrorInterceptor(),
      LogInterceptor(responseBody: true, requestBody: true),
    ]);
  }

  Dio get instance => _dio;

  // Dil değişince çağır
  void setLocale(String languageCode) {
    _dio.options.headers['Accept-Language'] = languageCode;
  }
}
