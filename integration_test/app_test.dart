import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:insurance_mobile_app/core/app_init/app_init.dart';
import 'package:insurance_mobile_app/core/network/client/dio_interceptor.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/repository/insurance_repository.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/services/insurance_services.dart';
import 'package:integration_test/integration_test.dart';
import 'package:insurance_mobile_app/main.dart' as app;
import 'package:path_provider/path_provider.dart';

// ─────────────────────────────────────────────────────────────
// App cleanup
// ─────────────────────────────────────────────────────────────

Future<void> cleanApp(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 800));
}

Future<void> runCleanTest(
  WidgetTester tester,
  Future<void> Function() body,
) async {
  try {
    await body();
  } finally {
    await cleanApp(tester);
  }
}

// ─────────────────────────────────────────────────────────────
// Mock data cleanup
// ─────────────────────────────────────────────────────────────

Future<void> clearMockClaimData() async {
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/mock_claim_records.json');
  if (await file.exists()) {
    await file.delete();
  }
}

// ─────────────────────────────────────────────────────────────
// App starter
// ─────────────────────────────────────────────────────────────

Future<void> startApp(WidgetTester tester) async {
  await cleanApp(tester);

  final dio = DioClient(
    languageCode: 'tr',
    enableLogging: false,
    useMockInterceptor: true,
  ).instance;

  final services = InsuranceServices(dio);
  final repository = InsuranceRepository(services);

  final bloc = InsuranceBloc(repository);
  addTearDown(bloc.close);

  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      startLocale: const Locale('tr'),
      child: app.MainApp(
        key: UniqueKey(),
        insuranceServices: services,
        insuranceBloc: bloc,
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));

  await waitForWidget(
    tester,
    find.text('Poliçelerim'),
    timeout: const Duration(seconds: 20),
  );
}

// ─────────────────────────────────────────────────────────────
// Navigation helpers
// ─────────────────────────────────────────────────────────────

Future<void> goToStep1(WidgetTester tester) async {
  await waitForWidget(
    tester,
    find.byKey(const Key('insurance_card_0')),
    timeout: const Duration(seconds: 20),
  );

  await tester.tap(find.byKey(const Key('insurance_card_0')));
  await tester.pumpAndSettle();

  await waitForWidget(
    tester,
    find.text('policy_detail.policy_no'.tr()),
    timeout: const Duration(seconds: 15),
  );

  await tester.tap(find.byKey(const Key('cta_claim_button')));
  await tester.pumpAndSettle();

  await waitForWidget(
    tester,
    find.text(
      'claim.step_indicator'.tr(
        namedArgs: {'step': '1', 'label': 'claim.step1_label_vehicle'.tr()},
      ),
    ),
    timeout: const Duration(seconds: 15),
  );
}

// ─────────────────────────────────────────────────────────────
// Wait helper
// ─────────────────────────────────────────────────────────────

Future<void> waitForWidget(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
  Duration interval = const Duration(milliseconds: 300),
}) async {
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(interval);

    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  throw TestFailure(
    'Widget bulunamadı: $finder\n${timeout.inSeconds}s içinde görünmedi.',
  );
}

// ─────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await initializeApp();
    await clearMockClaimData();
  });

  group('Claim Submission Flow —', () {
    testWidgets(
      'full flow: dashboard → detail → claim step1 → step2 → step3 → success',
      (tester) async {
        await runCleanTest(tester, () async {
          await startApp(tester);
          await goToStep1(tester);

          await waitForWidget(
            tester,
            find.byKey(const Key('claim_type_item_kaza')),
            timeout: const Duration(seconds: 10),
          );

          await tester.tap(find.byKey(const Key('claim_type_item_kaza')));
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

          await tester.tap(find.byKey(const Key('claim_next_button')));
          await tester.pumpAndSettle();

          expect(
            find.text(
              'claim.step_indicator'.tr(
                namedArgs: {
                  'step': '2',
                  'label': 'claim.step2_label_vehicle'.tr(),
                },
              ),
            ),
            findsOneWidget,
          );

          await tester.tap(find.byKey(const Key('claim_date_field')));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Tamam').last);
          await tester.pumpAndSettle();

          await tester.tap(find.text('Tamam').last);
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const Key('claim_location_field')),
            'İstanbul, Kadıköy',
          );

          await tester.enterText(
            find.byKey(const Key('claim_description_field')),
            'Test hasar açıklaması',
          );

          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('claim_next_button')));
          await tester.pumpAndSettle();

          expect(
            find.text(
              'claim.step_indicator'.tr(
                namedArgs: {'step': '3', 'label': 'claim.step3_label'.tr()},
              ),
            ),
            findsOneWidget,
          );

          expect(find.text('claim.summary_title'.tr()), findsOneWidget);

          await tester.enterText(
            find.byKey(const Key('claim_phone_field')),
            '+905384462408',
          );

          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('claim_next_button')));
          await tester.pumpAndSettle(const Duration(seconds: 3));

          expect(find.text('claim.success_title_vehicle'.tr()), findsOneWidget);

          expect(
            find.text('claim.success_subtitle_vehicle'.tr()),
            findsOneWidget,
          );

          expect(
            find.byWidgetPredicate(
              (widget) =>
                  widget is Text && (widget.data?.startsWith('#') ?? false),
            ),
            findsOneWidget,
          );

          await tester.tap(find.text('claim.back_to_policies'.tr()));
          await tester.pumpAndSettle(const Duration(seconds: 2));

          expect(find.text('Poliçelerim'), findsOneWidget);
        });
      },
    );

    testWidgets('step1 validation — hasar tipi seçmeden ileri gidilemiyor', (
      tester,
    ) async {
      await runCleanTest(tester, () async {
        await startApp(tester);
        await goToStep1(tester);

        await waitForWidget(
          tester,
          find.byKey(const Key('claim_type_item_kaza')),
          timeout: const Duration(seconds: 10),
        );

        await tester.tap(find.byKey(const Key('claim_next_button')));
        await tester.pumpAndSettle();

        expect(find.text('claim.validation_select_type'.tr()), findsOneWidget);

        expect(
          find.text(
            'claim.step_indicator'.tr(
              namedArgs: {
                'step': '1',
                'label': 'claim.step1_label_vehicle'.tr(),
              },
            ),
          ),
          findsOneWidget,
        );
      });
    });

    testWidgets(
      'step2 validation — zorunlu alanlar boş bırakılınca step3\'e geçilemiyor',
      (tester) async {
        await runCleanTest(tester, () async {
          await startApp(tester);
          await goToStep1(tester);

          await waitForWidget(
            tester,
            find.byKey(const Key('claim_type_item_kaza')),
            timeout: const Duration(seconds: 10),
          );

          await tester.tap(find.byKey(const Key('claim_type_item_kaza')));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('claim_next_button')));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('claim_next_button')));
          await tester.pumpAndSettle();

          expect(
            find.text(
              'claim.step_indicator'.tr(
                namedArgs: {
                  'step': '2',
                  'label': 'claim.step2_label_vehicle'.tr(),
                },
              ),
            ),
            findsOneWidget,
          );

          expect(
            find.text('claim.validation_date_required'.tr()),
            findsOneWidget,
          );

          expect(
            find.text('claim.validation_desc_required'.tr()),
            findsOneWidget,
          );
        });
      },
    );
  });
}
