import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/core/helpers/hex_to_color_extension.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/models/insurance_model.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class InsuranceCard extends StatelessWidget {
  final InsuranceModel insurance;
  final VoidCallback? onTap;

  const InsuranceCard({
    super.key,
    required this.insurance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = insurance.statusColorHex.toColor();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: insurance
                .gradientHexForTheme(context)
                .map((h) => h.toColor())
                .toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.appColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              insurance.emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                insurance.type,
                                style: context.textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                insurance.subtitle,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.13),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: statusColor.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            insurance.status,
                            style: context.textTheme.labelSmall?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(
                      color: Colors.white.withValues(alpha: 0.06),
                      height: 1,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _infoCol(
                          context,
                          'policy_card.expiry'.tr(),
                          insurance.expiry,
                        ),
                        _infoCol(
                          context,
                          'policy_card.coverage'.tr(),
                          insurance.coverage,
                          center: true,
                        ),
                        _infoCol(
                          context,
                          'policy_card.premium'.tr(),
                          insurance.premium,
                          right: true,
                          valueColor: context.appColors.accent,
                          suffix: insurance.period,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCol(
    BuildContext context,
    String label,
    String value, {
    bool center = false,
    bool right = false,
    Color? valueColor,
    String? suffix,
  }) {
    final align = right
        ? CrossAxisAlignment.end
        : center
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          label,
          style: context.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            text: value,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? Colors.white,
            ),
            children: suffix != null
                ? [
                    TextSpan(
                      text: ' $suffix',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ]
                : [],
          ),
        ),
      ],
    );
  }
}
