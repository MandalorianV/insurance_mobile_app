import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:insurance_mobile_app/features/claim/bloc/claim_bloc.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_record_model.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_types_model.dart';
import 'package:insurance_mobile_app/features/claim/repository/claim_repository.dart';

// ── Mock ────────────────────────────────────────────────────────────────────
class MockClaimRepository extends Mock implements ClaimRepositoryInterface {}

// ── Fake data ───────────────────────────────────────────────────────────────
final tClaimTypes = [
  ClaimType(id: '1', label: 'Trafik Kazası', emoji: '🚗'),
  ClaimType(id: '2', label: 'Cam Hasarı', emoji: '🪟'),
];

final tClaimRecord = ClaimRecord(
  claimTypeId: '1',
  refNo: 'HDR-2026-123',
  policyNo: 'POL-001',
  claimTypeLabel: 'Trafik Kazası',
  claimTypeEmoji: '🚗',
  incidentDate: '01.01.2026',
  description: 'Test açıklama',
  phone: '05001234567',
  status: 'in_progress',
  createdAt: '01.01.2026',
);

final tClaimRecords = [tClaimRecord];

final tClaimData = {
  'id': 1,
  'policy_no': 'POL-001',
  'claim_type_id': '1',
  'claim_type_label': 'Trafik Kazası',
  'incident_date': '01.01.2026',
  'description': 'Test açıklama',
  'phone': '05001234567',
  'status': 'in_progress',
  'created_at': '01.01.2026',
};

void main() {
  late MockClaimRepository mockRepository;

  setUp(() {
    mockRepository = MockClaimRepository();
  });

  group('ClaimBloc —', () {
    // ── initial state ──────────────────────────────────────────────────────
    test('initial state is ClaimInitial', () {
      final bloc = ClaimBloc(mockRepository);
      expect(bloc.state, isA<ClaimInitial>());
      bloc.close();
    });

    // ── GetClaimTypesEvent ─────────────────────────────────────────────────
    group('GetClaimTypesEvent', () {
      blocTest<ClaimBloc, ClaimState>(
        'emits [ClaimTypesLoading, GetClaimTypesState] on success',
        build: () {
          when(
            () => mockRepository.getClaimTypes(1),
          ).thenAnswer((_) async => tClaimTypes);
          return ClaimBloc(mockRepository);
        },
        act: (bloc) => bloc.add(GetClaimTypesEvent(id: 1)),
        expect: () => [
          isA<ClaimTypesLoading>(),
          GetClaimTypesState(claimTypes: tClaimTypes),
        ],
      );

      blocTest<ClaimBloc, ClaimState>(
        'emits [ClaimTypesLoading, ClaimTypesError] on noInternet error',
        build: () {
          when(
            () => mockRepository.getClaimTypes(1),
          ).thenThrow(AppError.noInternet);
          return ClaimBloc(mockRepository);
        },
        act: (bloc) => bloc.add(GetClaimTypesEvent(id: 1)),
        expect: () => [
          isA<ClaimTypesLoading>(),
          ClaimTypesError(error: AppError.noInternet),
        ],
      );

      blocTest<ClaimBloc, ClaimState>(
        'emits [ClaimTypesLoading, ClaimTypesError] on unknown error',
        build: () {
          when(
            () => mockRepository.getClaimTypes(1),
          ).thenThrow(AppError.unknown);
          return ClaimBloc(mockRepository);
        },
        act: (bloc) => bloc.add(GetClaimTypesEvent(id: 1)),
        expect: () => [
          isA<ClaimTypesLoading>(),
          ClaimTypesError(error: AppError.unknown),
        ],
      );
    });

    // ── GetClaimRecordsEvent ───────────────────────────────────────────────
    group('GetClaimRecordsEvent', () {
      blocTest<ClaimBloc, ClaimState>(
        'emits [ClaimRecordsLoading, GetClaimRecords] on success',
        build: () {
          when(
            () => mockRepository.getClaimRecords('POL-001'),
          ).thenAnswer((_) async => tClaimRecords);
          return ClaimBloc(mockRepository);
        },
        act: (bloc) => bloc.add(GetClaimRecordsEvent(policyNo: 'POL-001')),
        expect: () => [
          isA<ClaimRecordsLoading>(),
          GetClaimRecords(records: tClaimRecords),
        ],
      );

      blocTest<ClaimBloc, ClaimState>(
        'emits [ClaimRecordsLoading, ClaimRecordsError] on error',
        build: () {
          when(
            () => mockRepository.getClaimRecords('POL-001'),
          ).thenThrow(AppError.serverError);
          return ClaimBloc(mockRepository);
        },
        act: (bloc) => bloc.add(GetClaimRecordsEvent(policyNo: 'POL-001')),
        expect: () => [
          isA<ClaimRecordsLoading>(),
          ClaimRecordsError(error: AppError.serverError),
        ],
      );
    });

    // ── GetClaimDetailEvent ────────────────────────────────────────────────
    group('GetClaimDetailEvent', () {
      blocTest<ClaimBloc, ClaimState>(
        'emits [ClaimDetailLoading, GetClaimDetail] on success',
        build: () {
          when(
            () => mockRepository.getClaimDetail('HDR-2026-123'),
          ).thenAnswer((_) async => tClaimRecord);
          return ClaimBloc(mockRepository);
        },
        act: (bloc) => bloc.add(GetClaimDetailEvent(refNo: 'HDR-2026-123')),
        expect: () => [
          isA<ClaimDetailLoading>(),
          GetClaimDetail(record: tClaimRecord),
        ],
      );

      blocTest<ClaimBloc, ClaimState>(
        'emits [ClaimDetailLoading, ClaimDetailError] on error',
        build: () {
          when(
            () => mockRepository.getClaimDetail('HDR-2026-123'),
          ).thenThrow(AppError.noInternet);
          return ClaimBloc(mockRepository);
        },
        act: (bloc) => bloc.add(GetClaimDetailEvent(refNo: 'HDR-2026-123')),
        expect: () => [
          isA<ClaimDetailLoading>(),
          ClaimDetailError(error: AppError.noInternet),
        ],
      );
    });

    // ── SelectDamageTypeEvent ──────────────────────────────────────────────
    group('SelectDamageTypeEvent', () {
      blocTest<ClaimBloc, ClaimState>(
        'emits [SelectedDamageTypeState] with correct damageType',
        build: () => ClaimBloc(mockRepository),
        act: (bloc) =>
            bloc.add(SelectDamageTypeEvent(damageType: 'Trafik Kazası')),
        expect: () => [SelectedDamageTypeState(damageType: 'Trafik Kazası')],
      );
    });

    // ── ClaimStepUpEvent ───────────────────────────────────────────────────
    group('ClaimStepUpEvent', () {
      blocTest<ClaimBloc, ClaimState>(
        'emits [ClaimStepUpState] with step 2',
        build: () => ClaimBloc(mockRepository),
        act: (bloc) => bloc.add(ClaimStepUpEvent(step: 2)),
        expect: () => [ClaimStepUpState(step: 2)],
      );

      blocTest<ClaimBloc, ClaimState>(
        'emits [ClaimStepUpState] with step 3',
        build: () => ClaimBloc(mockRepository),
        act: (bloc) => bloc.add(ClaimStepUpEvent(step: 3)),
        expect: () => [ClaimStepUpState(step: 3)],
      );
    });

    // ── SubmitClaimEvent ───────────────────────────────────────────────────
    group('SubmitClaimEvent', () {
      blocTest<ClaimBloc, ClaimState>(
        'emits [ClaimSubmitting, ClaimSubmissionSuccess] on success',
        build: () {
          when(
            () => mockRepository.submitClaim(tClaimData),
          ).thenAnswer((_) async => 'HDR-2026-123');
          return ClaimBloc(mockRepository);
        },
        act: (bloc) => bloc.add(SubmitClaimEvent(claimData: tClaimData)),
        expect: () => [
          isA<ClaimSubmitting>(),
          ClaimSubmissionSuccess(refNo: 'HDR-2026-123'),
        ],
      );

      blocTest<ClaimBloc, ClaimState>(
        'emits [ClaimSubmitting, ClaimSubmissionError] on serverError',
        build: () {
          when(
            () => mockRepository.submitClaim(tClaimData),
          ).thenThrow(AppError.serverError);
          return ClaimBloc(mockRepository);
        },
        act: (bloc) => bloc.add(SubmitClaimEvent(claimData: tClaimData)),
        expect: () => [
          isA<ClaimSubmitting>(),
          ClaimSubmissionError(error: AppError.serverError),
        ],
      );

      blocTest<ClaimBloc, ClaimState>(
        'does not emit new state if already submitting (double submit protection)',
        build: () {
          when(() => mockRepository.submitClaim(tClaimData)).thenAnswer((
            _,
          ) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return 'HDR-2026-123';
          });
          return ClaimBloc(mockRepository);
        },
        act: (bloc) async {
          bloc.add(SubmitClaimEvent(claimData: tClaimData));
          await Future.delayed(const Duration(milliseconds: 10));
          bloc.add(SubmitClaimEvent(claimData: tClaimData));
        },
        wait: const Duration(milliseconds: 200),
        expect: () => [
          isA<ClaimSubmitting>(),
          ClaimSubmissionSuccess(refNo: 'HDR-2026-123'),
        ],
        verify: (_) {
          verify(() => mockRepository.submitClaim(tClaimData)).called(1);
        },
      );
    });

    // ── RetryLastEvent ─────────────────────────────────────────────────────
    group('RetryLastEvent', () {
      blocTest<ClaimBloc, ClaimState>(
        'retries last event — GetClaimTypesEvent',
        build: () {
          when(
            () => mockRepository.getClaimTypes(1),
          ).thenAnswer((_) async => tClaimTypes);
          return ClaimBloc(mockRepository);
        },
        act: (bloc) async {
          bloc.add(GetClaimTypesEvent(id: 1));
          await Future.delayed(Duration.zero);
          bloc.add(RetryLastEvent());
        },
        expect: () => [
          isA<ClaimTypesLoading>(),
          GetClaimTypesState(claimTypes: tClaimTypes),
          isA<ClaimTypesLoading>(),
          GetClaimTypesState(claimTypes: tClaimTypes),
        ],
        verify: (_) {
          verify(() => mockRepository.getClaimTypes(1)).called(2);
        },
      );

      blocTest<ClaimBloc, ClaimState>(
        'does nothing if no last event exists',
        build: () => ClaimBloc(mockRepository),
        act: (bloc) => bloc.add(RetryLastEvent()),
        expect: () => [],
      );
    });
  });
}
