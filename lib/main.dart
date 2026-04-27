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
  // Initialize Flutter binding, localization and restore saved theme
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await ThemeManager.instance.loadSavedTheme();

  // Keep status bar transparent across both themes
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

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

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.insuranceServices});
  final InsuranceServices insuranceServices;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ThemeManager — ChangeNotifier, enables reactive theme switching via Consumer
        ChangeNotifierProvider<ThemeManager>.value(
          value: ThemeManager.instance,
        ),
        // InsuranceRepository — accessible throughout the widget tree
        RepositoryProvider(
          create: (_) => InsuranceRepository(insuranceServices),
        ),
      ],
      child: BlocProvider(
        // InsuranceBloc — global bloc shared across dashboard and detail screens
        create: (context) => InsuranceBloc(context.read<InsuranceRepository>()),
        child: Consumer<ThemeManager>(
          builder: (context, themeManager, _) => MaterialApp.router(
            routerConfig: router,
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
