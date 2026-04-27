import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:path_provider/path_provider.dart';

class MockInterceptor extends Interceptor {
  static const _fileName = 'mock_claim_records.json';

  String _locale(RequestOptions options) {
    final lang = options.headers['Accept-Language'] as String?;
    return (lang == 'tr' || lang == 'en') ? lang! : 'tr';
  }

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<dynamic>> _readAll() async {
    final file = await _getFile();
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    return jsonDecode(content);
  }

  Future<void> _writeAll(List<dynamic> data) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(data));
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final locale = _locale(options);

    if (options.path == '/api/insurances') {
      await Future.delayed(const Duration(milliseconds: 1000));
      final String response = await rootBundle.loadString(
        'assets/mock_data/$locale/mock_insurance_dashboard.json',
      );
      final data = jsonDecode(response);
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: data),
      );
    }

    if (options.path == '/api/insurance-records') {
      await Future.delayed(const Duration(milliseconds: 1000));
      String policyNo = options.data['policyNo'] ?? "";
      final existing = await _readAll();
      final filtered = existing
          .where((c) => c['policy_no'] == policyNo)
          .toList();
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: filtered),
      );
    }

    if (options.path == '/api/claim-types') {
      await Future.delayed(const Duration(milliseconds: 1000));
      final String response = await rootBundle.loadString(
        'assets/mock_data/$locale/mock_data_claim_types.json',
      );
      int id = options.data['id'] ?? 1;
      Map<String, dynamic> data = jsonDecode(response);
      dynamic responseData = data[id.toString()];
      if (id == 2) {
        // TEST SCENARIO: Sağlık sigortası claim types — unknown error
        return handler.reject(
          DioException(requestOptions: options, error: AppError.unknown),
        );
      }
      return handler.resolve(
        Response(requestOptions: options, data: responseData, statusCode: 200),
      );
    }

    if (options.path == '/api/claims' && options.method == 'POST') {
      await Future.delayed(const Duration(milliseconds: 800));
      final existing = await _readAll();
      final now = DateTime.now();
      final newClaim = {
        ...options.data,
        'ref_no':
            'HDR-${now.year}-${now.millisecondsSinceEpoch.toString().substring(7)}',
        'created_at':
            '${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year}',
        'status': 'in_progress',
      };
      existing.add(newClaim);
      await _writeAll(existing);
      int id = options.data['id'] ?? 1;
      if (id == 3) {
        // TEST SCENARIO: Konut sigortası submit — server error
        return handler.reject(
          DioException(requestOptions: options, error: AppError.serverError),
        );
      }
      return handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true, 'claim': newClaim},
        ),
      );
    }

    if (options.path == '/api/claims' && options.method == 'GET') {
      await Future.delayed(const Duration(milliseconds: 600));
      final existing = await _readAll();
      final policyNo = options.queryParameters['policy_no'];
      final filtered = policyNo != null
          ? existing.where((c) => c['policy_no'] == policyNo).toList()
          : existing;
      return handler.resolve(
        Response(requestOptions: options, statusCode: 200, data: filtered),
      );
    }

    handler.next(options);
  }
}
