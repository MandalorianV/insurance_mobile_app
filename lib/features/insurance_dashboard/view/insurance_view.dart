import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:insurance_mobile_app/core/helpers/hex_to_color_extension.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/bloc/insurance_bloc.dart';
import 'package:insurance_mobile_app/features/insurance_dashboard/view_mixin/insurance_view_mixin.dart';
import 'package:insurance_mobile_app/theme/app_theme.dart';
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
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildSummaryCard(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'SİGORTA POLİÇELERİ',
                style: AppTextStyles.muted.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<InsuranceBloc, InsuranceState>(
                builder: (context, state) {
                  if (state is LoadingListState) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GetInsuranceListState) {
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      itemCount: state.insuranceList.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final ins = state.insuranceList[index];
                        return _InsuranceCard(insurance: ins);
                      },
                    );
                  }
                  // Fallback for unexpected states
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Merhaba, Ahmet 👋',
                style: AppTextStyles.sub.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Poliçelerim',
                style: AppTextStyles.heading.copyWith(fontSize: 22),
              ),
            ],
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.success],
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

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accentSoft, Color(0xFF1a2a4a)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Toplam Koruma',
                  style: AppTextStyles.sub.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  '4 Aktif Poliçe',
                  style: AppTextStyles.heading.copyWith(fontSize: 20),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Aylık Prim',
                  style: AppTextStyles.sub.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  '₺9.540',
                  style: AppTextStyles.heading.copyWith(
                    fontSize: 20,
                    color: AppColors.accent,
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

class _InsuranceCard extends StatelessWidget {
  final InsuranceModel insurance;
  const _InsuranceCard({required this.insurance});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/insuranceDetails', extra: insurance),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: insurance.gradientHex.map((hex) => hex.toColor()).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Decorative circle
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
                        // Icon
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
                        // Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                insurance.type,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                insurance.subtitle,
                                style: AppTextStyles.sub.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSub.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: insurance.statusColorHex
                                .toColor()
                                .withOpacity(0.13),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: insurance.statusColorHex
                                  .toColor()
                                  .withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            insurance.status,
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: insurance.statusColorHex.toColor(),
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
                        _infoCol('Bitiş', insurance.expiry),
                        _infoCol('Kapsam', insurance.coverage, center: true),
                        _infoCol(
                          'Prim',
                          insurance.premium,
                          right: true,
                          valueColor: AppColors.accent,
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
          style: AppTextStyles.sub.copyWith(
            fontSize: 11,
            color: AppColors.textSub.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          text: TextSpan(
            text: value,
            style: AppTextStyles.body.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
            children: suffix != null
                ? [
                    TextSpan(
                      text: ' $suffix',
                      style: AppTextStyles.sub.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
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
