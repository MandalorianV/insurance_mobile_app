import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_record_model.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_types_model.dart';
import 'package:insurance_mobile_app/features/claim/repository/claim_repository.dart';
import 'package:insurance_mobile_app/features/claim/services/claim_services.dart';
import 'package:mocktail/mocktail.dart';

// ── Mock ─────────────────────────────────────────────────────
class MockClaimServices extends Mock implements ClaimServices {}

// ── Fake data ────────────────────────────────────────────────
final _fakeClaimTypeJson = [
  {'id': 'kaza', 'label': 'Trafik Kazası', 'emoji': '💥'},
  {'id': 'hirsizlik', 'label': 'Araç Hırsızlığı', 'emoji': '🔓'},
];

final _fakeClaimRecordJson = [
  {
    'ref_no': 'HDR-2025-00001',
    'policy_no': 'ARC-2024-00812',
    'claim_type_id': 'kaza',
    'claim_type_label': 'Trafik Kazası',
    'claim_type_emoji': '💥',
    'incident_date': '18.04.2025 14:30',
    'location': 'İstanbul, Kadıköy',
    'plate': '34ABC123',
    'description': 'Kavşakta çarpışma',
    'phone': '05321234567',
    'email': null,
    'status': 'in_progress',
    'created_at': '19.04.2025',
  },
];

final _fakeClaimDetailJson = _fakeClaimRecordJson.first;

void main() {
  late MockClaimServices mockServices;
  late ClaimRepository repository;

  setUp(() {
    mockServices = MockClaimServices();
    repository = ClaimRepository(mockServices);
  });

  // ── getClaimTypes ─────────────────────────────────────────
  group('getClaimTypes', () {
    test('servisten veri gelince ClaimType listesi döner', () async {
      when(
        () => mockServices.getClaimTypes(1),
      ).thenAnswer((_) async => _fakeClaimTypeJson);

      final result = await repository.getClaimTypes(1);

      expect(result, isA<List<ClaimType>>());
      expect(result.length, 2);
      expect(result.first.id, 'kaza');
      expect(result.first.label, 'Trafik Kazası');
    });

    test(
      'DioException — connectionError → AppError.noInternet fırlatır',
      () async {
        when(() => mockServices.getClaimTypes(1)).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.connectionError,
          ),
        );

        expect(() => repository.getClaimTypes(1), throwsA(AppError.noInternet));
      },
    );

    test(
      'DioException — badResponse → AppError.serverError fırlatır',
      () async {
        when(() => mockServices.getClaimTypes(1)).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.badResponse,
          ),
        );

        expect(
          () => repository.getClaimTypes(1),
          throwsA(AppError.serverError),
        );
      },
    );

    test('beklenmedik hata → AppError.unknown fırlatır', () async {
      when(
        () => mockServices.getClaimTypes(1),
      ).thenThrow(Exception('unexpected'));

      expect(() => repository.getClaimTypes(1), throwsA(AppError.unknown));
    });
  });

  // ── getClaimRecords ───────────────────────────────────────
  group('getClaimRecords', () {
    test('servisten veri gelince ClaimRecord listesi döner', () async {
      when(
        () => mockServices.getClaimRecords('ARC-2024-00812'),
      ).thenAnswer((_) async => _fakeClaimRecordJson);

      final result = await repository.getClaimRecords('ARC-2024-00812');

      expect(result, isA<List<ClaimRecord>>());
      expect(result.length, 1);
      expect(result.first.refNo, 'HDR-2025-00001');
      expect(result.first.status, 'in_progress');
    });

    test('DioException — receiveTimeout → AppError.timeout fırlatır', () async {
      when(() => mockServices.getClaimRecords(any())).thenThrow(
        DioException(
          requestOptions: RequestOptions(),
          type: DioExceptionType.receiveTimeout,
        ),
      );

      expect(
        () => repository.getClaimRecords('ARC-2024-00812'),
        throwsA(AppError.timeout),
      );
    });
  });

  // ── getClaimDetail ────────────────────────────────────────
  group('getClaimDetail', () {
    test('ref no ile doğru ClaimRecord döner', () async {
      when(
        () => mockServices.getClaimDetail('HDR-2025-00001'),
      ).thenAnswer((_) async => _fakeClaimDetailJson);

      final result = await repository.getClaimDetail('HDR-2025-00001');

      expect(result, isA<ClaimRecord>());
      expect(result.refNo, 'HDR-2025-00001');
      expect(result.policyNo, 'ARC-2024-00812');
    });

    test('hata durumunda AppError fırlatır', () async {
      when(
        () => mockServices.getClaimDetail(any()),
      ).thenThrow(Exception('error'));

      expect(
        () => repository.getClaimDetail('HDR-2025-00001'),
        throwsA(AppError.unknown),
      );
    });
  });

  // ── submitClaim ───────────────────────────────────────────
  group('submitClaim', () {
    final claimData = {
      'policy_no': 'ARC-2024-00812',
      'claim_type_id': 'kaza',
      'incident_date': '18.04.2025 14:30',
      'description': 'Test açıklama',
      'phone': '05321234567',
    };

    test('başarılı submit → ref_no string döner', () async {
      when(() => mockServices.submitClaim(claimData)).thenAnswer(
        (_) async => {
          'claim': {'ref_no': 'HDR-2025-99999'},
        },
      );

      final result = await repository.submitClaim(claimData);

      expect(result, 'HDR-2025-99999');
    });

    test(
      'DioException — badResponse → AppError.serverError fırlatır',
      () async {
        when(() => mockServices.submitClaim(any())).thenThrow(
          DioException(
            requestOptions: RequestOptions(),
            type: DioExceptionType.badResponse,
          ),
        );

        expect(
          () => repository.submitClaim(claimData),
          throwsA(AppError.serverError),
        );
      },
    );
  });
}
