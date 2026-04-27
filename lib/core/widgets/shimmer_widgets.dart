import 'package:flutter/material.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';
import 'package:shimmer/shimmer.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AppShimmer — base shimmer wrapper
// ─────────────────────────────────────────────────────────────────────────────
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: context.appColors.border,
      highlightColor: context.appColors.card,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ShimmerBox — temel dikdörtgen blok
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// InsuranceCardShimmer — dashboard listesi için tek kart iskeleti
// ─────────────────────────────────────────────────────────────────────────────
class InsuranceCardShimmer extends StatelessWidget {
  const InsuranceCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: context.appColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.appColors.border),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Emoji icon placeholder
                _ShimmerBox(width: 46, height: 46, radius: 14),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ShimmerBox(
                        width: double.infinity,
                        height: 14,
                        radius: 6,
                      ),
                      const SizedBox(height: 8),
                      _ShimmerBox(width: 140, height: 11, radius: 5),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _ShimmerBox(width: 60, height: 22, radius: 8),
              ],
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: context.appColors.border),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ShimmerBox(width: 70, height: 32, radius: 6),
                _ShimmerBox(width: 80, height: 32, radius: 6),
                _ShimmerBox(width: 70, height: 32, radius: 6),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// InsuranceListShimmer — dashboard listesi için n adet kart iskeleti
// ─────────────────────────────────────────────────────────────────────────────
class InsuranceListShimmer extends StatelessWidget {
  final int itemCount;
  const InsuranceListShimmer({super.key, this.itemCount = 4});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: Column(
        children: List.generate(
          itemCount,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i < itemCount - 1 ? 12 : 0),
            child: const InsuranceCardShimmer(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SummaryCardShimmer — dashboard özet kartı için iskelet
// ─────────────────────────────────────────────────────────────────────────────
class SummaryCardShimmer extends StatelessWidget {
  const SummaryCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: context.appColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.appColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ShimmerBox(width: 100, height: 11, radius: 5),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 130, height: 18, radius: 6),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ShimmerBox(width: 70, height: 11, radius: 5),
                  const SizedBox(height: 6),
                  _ShimmerBox(width: 90, height: 18, radius: 6),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PolicyDetailShimmer — detay sayfası içerik iskeleti
// ─────────────────────────────────────────────────────────────────────────────
class PolicyDetailShimmer extends StatelessWidget {
  const PolicyDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info grid — 2x2
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                4,
                (_) => Container(
                  decoration: BoxDecoration(
                    color: context.appColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: context.appColors.border),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Coverage card
            _shimmerCard(height: 180, context: context),
            const SizedBox(height: 16),
            // Claims card
            _shimmerCard(height: 80, context: context),
          ],
        ),
      ),
    );
  }

  Widget _shimmerCard({required double height, required BuildContext context}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ShimmerBox(width: 140, height: 13, radius: 6),
          const SizedBox(height: 14),
          _ShimmerBox(width: double.infinity, height: 11, radius: 5),
          const SizedBox(height: 10),
          _ShimmerBox(width: double.infinity, height: 11, radius: 5),
          const SizedBox(height: 10),
          _ShimmerBox(width: 200, height: 11, radius: 5),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ClaimTypesShimmer — claim step 1 için iskelet
// ─────────────────────────────────────────────────────────────────────────────
class ClaimTypesShimmer extends StatelessWidget {
  const ClaimTypesShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: List.generate(
          5,
          (i) => Padding(
            padding: EdgeInsets.only(bottom: i < 4 ? 10 : 0),
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                color: context.appColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.appColors.border),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
