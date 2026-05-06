import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insurance_mobile_app/core/shaders/app_shader_warm_up.dart';
import 'package:insurance_mobile_app/theme/theme_manager.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.shaderWarmUp = const AppShaderWarmUp();
  await EasyLocalization.ensureInitialized();
  await ThemeManager.instance.loadSavedTheme();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
}
