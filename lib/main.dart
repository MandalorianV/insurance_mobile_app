import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insurance_mobile_app/core/network/client/dio_interceptor.dart';
import 'package:insurance_mobile_app/core/routes/router.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/repository/insurance_repository.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/services/insurance_services.dart';
import 'package:insurance_mobile_app/theme/theme_manager.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeManager.instance.loadSavedTheme();
  // easy_localization init
  await EasyLocalization.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  final dio = DioClient().instance;
  final insuranceServices = InsuranceServices(dio);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('tr'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('tr'),
      startLocale: const Locale('tr'),
      child: MainApp(insuranceServices: insuranceServices),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.insuranceServices});

  final InsuranceServices insuranceServices;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeManager>.value(
          value: ThemeManager.instance,
        ),
        RepositoryProvider(
          create: (_) => InsuranceRepository(insuranceServices),
        ),
      ],
      child: BlocProvider(
        create: (context) => InsuranceBloc(context.read<InsuranceRepository>()),
        child: MaterialApp.router(
          routerConfig: router,
          theme: ThemeManager.instance.currentTheme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
