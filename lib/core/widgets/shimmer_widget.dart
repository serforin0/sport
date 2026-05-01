import 'package:flutter/material.dart';

/// A reusable shimmer animation widget. Wrap any placeholder shape with it.
class ShimmerWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const ShimmerWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  const ShimmerWidget.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null,
        shape = BoxShape.circle;

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.circle
                ? null
                : (widget.borderRadius ?? BorderRadius.circular(8)),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                Color(0xFF1E293B),
                Color(0xFF334155),
                Color(0xFF1E293B),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
