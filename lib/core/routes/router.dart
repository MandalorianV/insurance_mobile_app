import 'dart:ui';

import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:insurance_mobile_app/core/widgets/no_internet_view.dart';
import 'package:insurance_mobile_app/features/claim/view/claim_view.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view/insurance_view.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view/insurance_view_details.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (_, __) => const InsuranceView(),
      routes: [
        GoRoute(
          path: '/insuranceDetails',
          builder: (_, state) {
            final insurance = state.extra as InsuranceModel;
            return InsuranceViewDetails(insurance: insurance);
          },
          routes: [
            GoRoute(
              path: '/claim',
              builder: (_, state) {
                final insurance = state.extra as InsuranceModel;
                return ClaimView(insurance: insurance);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/noInternet',
          builder: (_, state) => NoInternetView(
            error: state.extra as AppError? ?? AppError.noInternet,
          ),
        ),
      ],
    ),
  ],
);
