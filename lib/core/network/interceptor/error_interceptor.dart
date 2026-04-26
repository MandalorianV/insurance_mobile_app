import 'package:dio/dio.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final error = switch (err.type) {
      DioExceptionType.connectionError => AppError.noInternet,
      DioExceptionType.connectionTimeout => AppError.timeout,
      DioExceptionType.receiveTimeout => AppError.timeout,
      DioExceptionType.sendTimeout => AppError.timeout,
      DioExceptionType.badResponse => AppError.serverError,
      _ => AppError.unknown,
    };
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: error,
        type: err.type,
      ),
    );
  }
}
