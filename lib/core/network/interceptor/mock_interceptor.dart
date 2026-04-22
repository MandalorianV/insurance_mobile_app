import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

class MockInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path == '/api/insurances') {
      final String response = await rootBundle.loadString(
        'assets/mock_data/mock_insurance_dashboard.json',
      );
      final data = jsonDecode(response);
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: data),
      );
    }
    if (options.path == '/api/claim-types') {
      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Hafif bir gecikme iyidir
      final String response = await rootBundle.loadString(
        'assets/mock_data/mock_data_claim_types.json',
      );
      return handler.resolve(
        Response(
          requestOptions: options,
          data: json.decode(response),
          statusCode: 200,
        ),
      );
    }
  }
}
