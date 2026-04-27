import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/features/claim/models/claim_record_model.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

class ClaimRecordItem extends StatelessWidget {
  final ClaimRecord record;
  const ClaimRecordItem({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (record.status) {
      'approved' => context.appColors.success,
      'rejected' => context.appColors.danger,
      'in_progress' => context.appColors.accent,
      _ => context.appColors.textMuted,
    };

    final statusLabel = switch (record.status) {
      'approved' => 'claim_detail.status_approved'.tr(),
      'rejected' => 'claim_detail.status_rejected'.tr(),
      'in_progress' => 'claim_detail.status_in_progress'.tr(),
      _ => 'claim_detail.status_pending'.tr(),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.appColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        children: [
          Text(record.claimTypeEmoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.claimTypeLabel,
                  style: context.textTheme.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  '#${record.refNo} · ${record.createdAt}',
                  style: context.textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: context.textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
