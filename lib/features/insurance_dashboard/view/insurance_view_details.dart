import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/core/helpers/hex_to_color_extension.dart';
import 'package:insurance_mobile_app/core/widgets/error_widgets.dart';
import 'package:insurance_mobile_app/core/widgets/shimmer_widgets.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';
import '../models/insurance_model.dart';

class InsuranceViewDetails extends StatefulWidget {
  final InsuranceModel insurance;
  const InsuranceViewDetails({super.key, required this.insurance});

  @override
  State<InsuranceViewDetails> createState() => _InsuranceViewDetailsState();
}

class _InsuranceViewDetailsState extends State<InsuranceViewDetails> {
  InsuranceModel get insurance => widget.insurance;

  // Detay sayfası şu an statik veri gösteriyor.
  // İleride BLoC'a bağlanacaksa buraya mixin / BlocBuilder eklenebilir.
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeroHeader(context),
          Expanded(
            child: _loading
                ? const PolicyDetailShimmer()
                : _error != null
                ? AppErrorWidget(
                    title: 'policy_detail.error_title'.tr(),
                    subtitle: 'policy_detail.error_subtitle'.tr(),
                    onRetry: () => setState(() => _error = null),
                  )
                : SingleChildScrollView(
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

  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: insurance.gradientHex.map((h) => h.toColor()).toList(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
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
                  color: Colors.white.withOpacity(0.03),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: context.appColors.textPrimary,
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
                          color: Colors.white.withOpacity(0.1),
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
                            style: context.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            insurance.subtitle,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.appColors.textSub.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
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
                              style: context.textTheme.labelSmall,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              insurance.policyNo,
                              style: context.textTheme.titleSmall,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'policy_detail.status'.tr(),
                              style: context.textTheme.labelSmall,
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

  Widget _buildInfoGrid(BuildContext context) {
    final items = [
      {'label': 'policy_detail.start_date'.tr(), 'value': '22 Apr 2024'},
      {'label': 'policy_detail.end_date'.tr(), 'value': insurance.expiry},
      {'label': 'policy_detail.coverage'.tr(), 'value': insurance.coverage},
      {
        'label': 'policy_detail.annual_premium'.tr(),
        'value': insurance.premium,
      },
    ];
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: context.colorCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.colorBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(item['label']!, style: context.textTheme.labelSmall),
              const SizedBox(height: 4),
              Text(item['value']!, style: context.textTheme.titleSmall),
            ],
          ),
        );
      }).toList(),
    );
  }

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
                    color: context.colorBorder.withOpacity(0.5),
                    height: 1,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildClaimsHistoryCard(BuildContext context) {
    //TODO: Detayları gösterebiliriz. Şimdilik sadece kayıt sayısını gösteriyor.
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
              Text(
                'policy_detail.claims_history'.tr(),
                style: context.textTheme.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colors.primary.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${insurance.claimsCount} ${'common.records'.tr()}',
                  style: context.textTheme.labelSmall?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          insurance.claimsCount == 0
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'policy_detail.no_claims'.tr(),
                      style: context.textTheme.bodyMedium,
                    ),
                  ),
                )
              : Text(
                  'policy_detail.existing_claims'.tr(
                    namedArgs: {'count': '${insurance.claimsCount}'},
                  ),
                  style: context.textTheme.bodyMedium,
                ),
        ],
      ),
    );
  }

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
                color: context.appColors.accent.withOpacity(0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () =>
                context.go('/insuranceDetails/claim', extra: insurance),
            icon: const Text('⚡', style: TextStyle(fontSize: 16)),
            label: Text(
              switch (insurance.category) {
                'vehicle' => 'Kaza Bildir',
                'health' => 'Tedavi Bildir',
                'home' => 'Hasar Bildir',
                'travel' => 'Olay Bildir',
                _ => 'Hasar Bildir',
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
