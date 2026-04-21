import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/features/claim/view/claim_view.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view/insurance_view.dart';

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
          path: '/claim',
          builder: (BuildContext context, GoRouterState state) {
            return const ClaimView();
          },
        ),
      ],
    ),
  ],
);
