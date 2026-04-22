import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/features/claim/view/claim_view.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view/insurance_view.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view/insurance_view_details.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const InsuranceView();
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/insuranceDetails',
          builder: (BuildContext context, GoRouterState state) {
            // Risky area, need to ensure that the extra data is of type InsuranceModel
            InsuranceModel insurance = state.extra as InsuranceModel;
            return InsuranceViewDetails(insurance: insurance);
          },
          routes: <RouteBase>[
            GoRoute(
              path: '/claim',
              builder: (BuildContext context, GoRouterState state) {
                // Risky area, need to ensure that the extra data is of type InsuranceModel
                InsuranceModel insurance = state.extra as InsuranceModel;
                return ClaimView(insurance: insurance);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
