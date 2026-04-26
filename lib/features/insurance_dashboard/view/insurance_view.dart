import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/core/helpers/hex_to_color_extension.dart';
import 'package:insurance_mobile_app/core/widgets/error_widgets.dart';
import 'package:insurance_mobile_app/core/widgets/shimmer_widgets.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view_mixin/insurance_view_mixin.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';
import '../models/insurance_model.dart';

class InsuranceView extends StatefulWidget {
  const InsuranceView({super.key});

  @override
  State<InsuranceView> createState() => _InsuranceViewState();
}

class _InsuranceViewState extends State<InsuranceView> with InsuranceViewMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: BlocConsumer<InsuranceBloc, InsuranceState>(
                listener: (context, state) {
                  if (state is InsuranceListError) {
                    ErrorSnackBar.show(
                      context,
                      message: state.message,
                      onRetry: onRefresh,
                    );
                  }
                },
                builder: (context, state) {
                  if (state is LoadingListState) {
                    return const SingleChildScrollView(
                      child: Column(
                        children: [
                          SummaryCardShimmer(),
                          SizedBox(height: 20),
                          InsuranceListShimmer(),
                        ],
                      ),
                    );
                  }

                  if (state is InsuranceListError) {
                    return AppErrorWidget(
                      title: 'dashboard.error_title'.tr(),
                      subtitle: 'dashboard.error_subtitle'.tr(),
                      onRetry: onRefresh,
                    );
                  }

                  if (state is InsuranceEmptyState) {
                    return AppEmptyWidget(
                      title: 'dashboard.empty_title'.tr(),
                      subtitle: 'dashboard.empty_subtitle'.tr(),
                      icon: Icons.policy_outlined,
                    );
                  }

                  if (state is GetInsuranceListState) {
                    return RefreshIndicator(
                      onRefresh: () async => onRefresh(),
                      color: context.appColors.accent,
                      backgroundColor: context.appColors.card,
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(child: _buildSummaryCard(state)),
                          const SliverToBoxAdapter(child: SizedBox(height: 20)),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                'dashboard.section_title'.tr(),
                                style: context.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                            sliver: SliverList.separated(
                              itemCount: state.insuranceList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _InsuranceCard(
                                  insurance: state.insuranceList[index],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'dashboard.greeting'.tr(),
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'dashboard.title'.tr(),
                style: context.textTheme.headlineMedium,
              ),
            ],
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [context.appColors.accent, context.appColors.success],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🔔', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(GetInsuranceListState state) {
    final activeCount = state.insuranceList.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [context.appColors.accentSoft, Color(0xFF1a2a4a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.appColors.accent.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'dashboard.total_coverage'.tr(),
                  style: context.textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  'dashboard.active_policies'.tr(
                    namedArgs: {'count': '$activeCount'},
                  ),
                  style: context.textTheme.headlineMedium,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'dashboard.monthly_premium'.tr(),
                  style: context.textTheme.bodySmall,
                ),
                const SizedBox(height: 2),
                Text(
                  '₺9.540',
                  style: context.textTheme.headlineMedium?.copyWith(
                    color: context.colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Insurance Card ────────────────────────────────────────────
class _InsuranceCard extends StatelessWidget {
  final InsuranceModel insurance;
  const _InsuranceCard({required this.insurance});

  @override
  Widget build(BuildContext context) {
    final statusColor = insurance.statusColorHex.toColor();
    return GestureDetector(
      onTap: () => context.go('/insuranceDetails', extra: insurance),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: insurance.gradientHex.map((h) => h.toColor()).toList(),
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
                    color: Colors.white.withOpacity(0.04),
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
                            color: Colors.white.withOpacity(0.1),
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
                                style: context.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                insurance.subtitle,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.appColors.textSub.withOpacity(
                                    0.7,
                                  ),
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
                            color: statusColor.withOpacity(0.13),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: statusColor.withOpacity(0.4),
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
                    Divider(color: Colors.white.withOpacity(0.06), height: 1),
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
        Text(label, style: context.textTheme.labelSmall),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            text: value,
            style: context.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? context.appColors.textPrimary,
            ),
            children: suffix != null
                ? [
                    TextSpan(
                      text: ' $suffix',
                      style: context.textTheme.labelSmall,
                    ),
                  ]
                : [],
          ),
        ),
      ],
    );
  }
}
