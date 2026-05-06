import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/core/helpers/hex_to_color_extension.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view_mixin/insurance_view_details_mixin.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/widgets/claim_record_item.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';
import '../models/insurance_model.dart';

class InsuranceViewDetails extends StatefulWidget {
  final InsuranceModel insurance;
  const InsuranceViewDetails({super.key, required this.insurance});

  @override
  State<InsuranceViewDetails> createState() => _InsuranceViewDetailsState();
}

class _InsuranceViewDetailsState extends State<InsuranceViewDetails>
    with InsuranceViewDetailsMixin {
  InsuranceModel get insurance => widget.insurance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeroHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoGrid(context),
                  const SizedBox(height: 16),
                  _buildCoverageCard(context),
                  const SizedBox(height: 16),
                  _buildClaimsHistoryCard(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _buildCTAButton(context),
        ],
      ),
    );
  }

  // Hero header with gradient background, policy info and status badge
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: insurance
              .gradientHexForTheme(context)
              .map((h) => h.toColor())
              .toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Decorative background circles
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -60,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.03),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            insurance.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            insurance.type,
                            style: context.textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insurance.subtitle,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Policy no and status row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'policy_detail.policy_no'.tr(),
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              insurance.policyNo,
                              style: context.textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'policy_detail.status'.tr(),
                              style: context.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: insurance.statusColorHex.toColor(),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  insurance.status,
                                  style: context.textTheme.titleSmall?.copyWith(
                                    color: insurance.statusColorHex.toColor(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Key policy info displayed in a 2-column grid
  Widget _buildInfoGrid(BuildContext context) {
    final items = [
      {'label': 'policy_detail.start_date'.tr(), 'value': insurance.startDate},
      {'label': 'policy_detail.end_date'.tr(), 'value': insurance.expiry},
      {'label': 'policy_detail.coverage'.tr(), 'value': insurance.coverage},
      {
        'label': 'policy_detail.annual_premium'.tr(),
        'value': insurance.premium,
      },
    ];

    Widget buildItem(Map<String, String> item) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: context.colorCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.colorBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item['label']!,
              style: context.textTheme.labelSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              item['value']!,
              style: context.textTheme.titleSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: buildItem(items[0])),
              const SizedBox(width: 10),
              Expanded(child: buildItem(items[1])),
            ],
          ),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(child: buildItem(items[2])),
              const SizedBox(width: 10),
              Expanded(child: buildItem(items[3])),
            ],
          ),
        ),
      ],
    );
  }

  // Coverage items list with covered/not covered indicators
  Widget _buildCoverageCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'policy_detail.coverage_details'.tr(),
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...insurance.coverageItems.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      Icon(
                        item.covered
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        size: 16,
                        color: item.covered
                            ? context.appColors.success
                            : context.appColors.danger,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.name,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: item.covered
                                ? context.appColors.textPrimary
                                : context.appColors.textMuted,
                          ),
                        ),
                      ),
                      Text(
                        item.limit,
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: item.covered
                              ? context.appColors.textSub
                              : context.appColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < insurance.coverageItems.length - 1)
                  Divider(
                    color: context.colorBorder.withValues(alpha: 0.5),
                    height: 1,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // _buildClaimsHistoryCard — insurance_view_details.dart içine yapıştır

  Widget _buildClaimsHistoryCard(BuildContext context) {
    final historyTitle = switch (insurance.category) {
      'vehicle' => 'policy_detail.claims_history_vehicle'.tr(),
      'health' => 'policy_detail.claims_history_health'.tr(),
      'home' => 'policy_detail.claims_history_home'.tr(),
      'travel' => 'policy_detail.claims_history_travel'.tr(),
      _ => 'policy_detail.claims_history'.tr(),
    };

    final emptyText = switch (insurance.category) {
      'vehicle' => 'policy_detail.no_claims_vehicle'.tr(),
      'health' => 'policy_detail.no_claims_health'.tr(),
      'home' => 'policy_detail.no_claims_home'.tr(),
      'travel' => 'policy_detail.no_claims_travel'.tr(),
      _ => 'policy_detail.no_claims'.tr(),
    };

    return BlocBuilder<InsuranceBloc, InsuranceState>(
      buildWhen: (previous, current) =>
          current is LoadingRecordListState ||
          current is GetInsuranceRecordsListState ||
          current is InsuranceRecordsListEmptyState ||
          current is InsuranceRecordsListErrorState,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.colorBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(historyTitle, style: context.textTheme.titleMedium),
                  if (state is GetInsuranceRecordsListState)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.accent.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${state.insuranceRecordsList.length} ${'common.records'.tr()}',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.appColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              switch (state) {
                LoadingRecordListState() => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(),
                  ),
                ),
                InsuranceRecordsListErrorState() => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'policy_detail.error_subtitle'.tr(),
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                ),
                GetInsuranceRecordsListState() => Column(
                  children: state.insuranceRecordsList
                      .map((r) => ClaimRecordItem(record: r))
                      .toList(),
                ),
                _ => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      emptyText,
                      style: context.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              },
            ],
          ),
        );
      },
    );
  }

  // CTA button — navigates to claim filing screen
  Widget _buildCTAButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      color: context.colorBg,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [context.appColors.accent, context.appColors.indigo],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: context.appColors.accent.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            key: Key('cta_claim_button'),
            onPressed: () =>
                context.push('/insuranceDetails/claim', extra: insurance),
            icon: const Text('⚡', style: TextStyle(fontSize: 16)),
            label: Text(
              switch (insurance.category) {
                'vehicle' => 'claim.submit_vehicle'.tr(),
                'health' => 'claim.submit_health'.tr(),
                'home' => 'claim.submit_home'.tr(),
                'travel' => 'claim.submit_travel'.tr(),
                _ => 'claim.submit_home'.tr(),
              },
              style: context.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
