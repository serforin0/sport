import 'package:flutter/material.dart';
import 'package:sport/core/widgets/shimmer_widget.dart';

/// Skeleton placeholder that mimics the shape of a NewsCard
class NewsCardSkeleton extends StatelessWidget {
  const NewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image placeholder
          ShimmerWidget(
            width: double.infinity,
            height: 130,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ShimmerWidget(width: 60, height: 16, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 8),
                ShimmerWidget(width: double.infinity, height: 14, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 4),
                ShimmerWidget(width: 180, height: 14, borderRadius: BorderRadius.circular(4)),
                const SizedBox(height: 10),
                ShimmerWidget(width: 80, height: 10, borderRadius: BorderRadius.circular(4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
