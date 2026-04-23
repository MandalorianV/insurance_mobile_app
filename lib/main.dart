import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurance_mobile_app/core/network/client/dio_interceptor.dart';
import 'package:insurance_mobile_app/core/routes/router.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/repository/insurance_repository.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/services/insurance_services.dart';
import 'package:insurance_mobile_app/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  final dio = DioClient().instance;

  final insuranceServices = InsuranceServices(dio);

  runApp(MainApp(insuranceServices: insuranceServices));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.insuranceServices});

  final InsuranceServices insuranceServices;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => InsuranceRepository(insuranceServices),

      child: BlocProvider(
        create: (context) => InsuranceBloc(context.read<InsuranceRepository>()),
        child: MaterialApp.router(routerConfig: router, theme: buildAppTheme()),
      ),
    );
  }
}
