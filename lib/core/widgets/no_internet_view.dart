import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/core/error/app_error.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class NoInternetView extends StatelessWidget {
  final AppError error;
  const NoInternetView({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final (emoji, title, subtitle) = switch (error) {
      AppError.noInternet => (
        '📡',
        'İnternet Bağlantısı Yok',
        'Lütfen bağlantınızı kontrol edip tekrar deneyin.',
      ),
      AppError.timeout => (
        '⏱',
        'Bağlantı Zaman Aşımı',
        'Sunucu yanıt vermiyor, lütfen tekrar deneyin.',
      ),
      AppError.serverError => (
        '🔧',
        'Sunucu Hatası',
        'Bir sorun oluştu, lütfen daha sonra tekrar deneyin.',
      ),
      AppError.unknown => (
        '⚠️',
        'Bir Hata Oluştu',
        'Beklenmeyen bir hata oluştu, lütfen tekrar deneyin.',
      ),
    };

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 24),
              Text(
                title,
                style: context.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.appColors.textSub,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: context.appColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Tekrar Dene',
                    style: context.textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () => context.go('/'),
                  child: Text(
                    'Ana Sayfaya Dön',
                    style: context.textTheme.titleLarge?.copyWith(
                      color: context.appColors.textSub,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
