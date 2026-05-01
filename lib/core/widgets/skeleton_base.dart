import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonBase extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;
  final Widget? child;

  const SkeletonBase({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? const Color(0xFF1E293B),
      highlightColor: highlightColor ?? const Color(0xFF334155),
      child: child ??
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
    );
  }
}
