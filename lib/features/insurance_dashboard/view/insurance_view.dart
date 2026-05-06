import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/core/widgets/error_widgets.dart';
import 'package:insurance_mobile_app/core/widgets/shimmer_widgets.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view_mixin/insurance_view_mixin.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/widgets/insurance_card.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';

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
        child: BlocBuilder<InsuranceBloc, InsuranceState>(
          buildWhen: (previous, current) {
            return current is LoadingListState ||
                current is GetInsuranceListState ||
                current is InsuranceListErrorState ||
                current is InsuranceListEmptyState;
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

            if (state is InsuranceListErrorState) {
              return AppErrorWidget(
                title: 'dashboard.error_title'.tr(),
                subtitle: 'dashboard.error_subtitle'.tr(),
                onRetry: () {
                  if (!context.mounted) return;
                  context.read<InsuranceBloc>().add(RetryLastEvent());
                },
              );
            }

            if (state is InsuranceListEmptyState) {
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
                    SliverToBoxAdapter(child: _buildHeader()),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(child: _buildSummaryCard(state)),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          return InsuranceCard(
                            key: Key('insurance_card_$index'),
                            onTap: () => onInsuranceTap(
                              context,
                              state.insuranceList[index],
                            ),
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
                colors: [context.appColors.accent, context.appColors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: GestureDetector(
              onTap: () => context.push('/settings'),
              child: Icon(Icons.settings_outlined),
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
            colors: [context.appColors.accentSoft, context.appColors.card],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.appColors.accent.withValues(alpha: 0.2),
          ),
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
