import 'package:dio/dio.dart';

class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Mock response for a specific endpoint
    if (options.path == '/api/insurances') {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'insuranceList': ['Insurance A', 'Insurance B', 'Insurance C'],
          },
        ),
      );
    } else {
      // For other endpoints, proceed with the request
      handler.next(options);
    }
  }
}
