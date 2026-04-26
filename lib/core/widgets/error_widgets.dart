import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppErrorWidget — genel hata ekranı (tam sayfa)
// ─────────────────────────────────────────────────────────────────────────────
class AppErrorWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.onRetry,
    this.icon = Icons.cloud_off_rounded,
  });

  /// Ağ hatası için factory
  factory AppErrorWidget.network({VoidCallback? onRetry}) => AppErrorWidget(
    title: 'common.error_network'.tr(),
    subtitle: 'common.retry'.tr(),
    onRetry: onRetry,
    icon: Icons.wifi_off_rounded,
  );

  /// Genel hata için factory
  factory AppErrorWidget.generic({VoidCallback? onRetry}) => AppErrorWidget(
    title: 'common.error_generic'.tr(),
    subtitle: 'common.retry'.tr(),
    onRetry: onRetry,
  );

  /// Bulunamadı hatası için factory
  factory AppErrorWidget.notFound({VoidCallback? onRetry}) => AppErrorWidget(
    title: 'common.error_not_found'.tr(),
    subtitle: 'common.retry'.tr(),
    onRetry: onRetry,
    icon: Icons.search_off_rounded,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.appColors.danger.withOpacity(0.1),
                border: Border.all(
                  color: context.appColors.danger.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: context.appColors.danger, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 28),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('common.retry'.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AppEmptyWidget — boş liste / kayıt yok durumu
// ─────────────────────────────────────────────────────────────────────────────
class AppEmptyWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AppEmptyWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.inbox_rounded,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.colors.primary.withOpacity(0.08),
                border: Border.all(
                  color: context.colors.primary.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Icon(icon, color: context.colors.primary, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: context.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: context.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 28),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// InlineErrorBanner — form içi veya kart içi küçük hata bandı
// ─────────────────────────────────────────────────────────────────────────────
class InlineErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const InlineErrorBanner({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.colorDanger.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colorDanger.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: context.colorDanger,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: context.textTheme.labelSmall?.copyWith(
                color: context.colorDanger,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'common.retry'.tr(),
                style: context.textTheme.labelSmall?.copyWith(
                  color: context.colorDanger,
                  decoration: TextDecoration.underline,
                  decorationColor: context.colorDanger,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ErrorSnackBar — BLoC hata state'lerinde çağrılan yardımcı
//
// Kullanım:
//   ErrorSnackBar.show(context, message: 'Bir hata oluştu');
// ─────────────────────────────────────────────────────────────────────────────
class ErrorSnackBar {
  ErrorSnackBar._();

  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        backgroundColor: context.appColors.danger.withOpacity(0.93),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).clearSnackBars();
                  onRetry();
                },
                child: Text(
                  'common.retry'.tr(),
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
