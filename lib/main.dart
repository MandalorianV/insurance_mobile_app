import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/core/app_init/app_init.dart';
import 'package:insurance_mobile_app/core/network/client/dio_interceptor.dart';
import 'package:insurance_mobile_app/core/routes/router.dart' show createRouter;
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/repository/insurance_repository.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/services/insurance_services.dart';
import 'package:insurance_mobile_app/theme/theme_manager.dart';
import 'package:provider/provider.dart';

void main() async {
  await initializeApp();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      startLocale: const Locale('tr'),
      child: MainApp(
        insuranceServices: InsuranceServices(DioClient().instance),
      ),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,
    required this.insuranceServices,
    this.insuranceBloc,
  });

  final InsuranceServices insuranceServices;

  final InsuranceBloc? insuranceBloc;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final InsuranceRepository _repository;
  late final InsuranceBloc _bloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _repository = InsuranceRepository(widget.insuranceServices);
    _bloc = widget.insuranceBloc ?? InsuranceBloc(_repository);
    _router = createRouter();
  }

  @override
  void dispose() {
    if (widget.insuranceBloc == null) {
      _bloc.close();
    }
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeManager>.value(
          value: ThemeManager.instance,
        ),
        RepositoryProvider<InsuranceRepository>.value(value: _repository),
      ],
      child: BlocProvider<InsuranceBloc>.value(
        value: _bloc,
        child: Consumer<ThemeManager>(
          builder: (context, themeManager, _) => MaterialApp.router(
            routerConfig: _router,
            theme: themeManager.currentTheme,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}
