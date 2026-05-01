import 'package:flutter/material.dart';
import 'package:sport/core/widgets/shimmer_widget.dart';

/// Skeleton placeholder that mimics the shape of a MatchResultCard
class MatchResultSkeleton extends StatelessWidget {
  const MatchResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // League row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerWidget(width: 80, height: 10, borderRadius: BorderRadius.circular(4)),
              ShimmerWidget(width: 30, height: 16, borderRadius: BorderRadius.circular(4)),
            ],
          ),
          const SizedBox(height: 20),
          // Teams + score row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  const ShimmerWidget.circle(size: 42),
                  const SizedBox(height: 8),
                  ShimmerWidget(width: 60, height: 11, borderRadius: BorderRadius.circular(4)),
                ],
              ),
              ShimmerWidget(width: 60, height: 28, borderRadius: BorderRadius.circular(6)),
              Column(
                children: [
                  const ShimmerWidget.circle(size: 42),
                  const SizedBox(height: 8),
                  ShimmerWidget(width: 60, height: 11, borderRadius: BorderRadius.circular(4)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          ShimmerWidget(width: 100, height: 10, borderRadius: BorderRadius.circular(4)),
        ],
      ),
    );
  }
}
