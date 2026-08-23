import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

/// A gentle shimmer-free skeleton block (opacity pulse) used while
/// mock-repository futures resolve. Avoids a hard "loading spinner"
/// jolt on a screen that otherwise reads as calm and considered.
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({super.key, this.height = 16, this.width, this.borderRadius});

  final double height;
  final double? width;
  final double? borderRadius;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  late final Animation<double> _opacity = Tween(begin: 0.35, end: 0.7).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: child,
      ),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(widget.borderRadius ?? AppRadii.sm),
        ),
      ),
    );
  }
}

/// A skeleton card used while the Home dashboard's data loads.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.height = 140});
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingSkeleton(width: 120, height: 12),
          const SizedBox(height: AppSpacing.md),
          LoadingSkeleton(width: 180, height: 22),
          const SizedBox(height: AppSpacing.sm),
          LoadingSkeleton(width: 100, height: 12),
          const Spacer(),
          Row(
            children: [
              Expanded(child: LoadingSkeleton(height: 12)),
              const SizedBox(width: AppSpacing.lg),
              Expanded(child: LoadingSkeleton(height: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
