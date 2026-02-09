import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

/// Loading shimmer effect for skeleton screens
class LoadingShimmer extends StatelessWidget {
  final double width;
  final double height;
  final bool isCircle;
  final BorderRadius? borderRadius;

  const LoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.isCircle = false,
    this.borderRadius,
  });

  const LoadingShimmer.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        isCircle = true,
        borderRadius = null;

  const LoadingShimmer.rectangular({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : isCircle = false;

  const LoadingShimmer.listItem({
    super.key,
  })  : width = double.infinity,
        height = 80,
        isCircle = false,
        borderRadius = const BorderRadius.all(Radius.circular(12));



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark
          ? AppColors.darkSurfaceVariant
          : AppColors.lightSurfaceVariant,
      highlightColor: isDark
          ? AppColors.darkSurface.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.5),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle ? null : (borderRadius ?? BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

/// Shimmer loading state for list items
class ListItemShimmer extends StatelessWidget {
  final int itemCount;

  const ListItemShimmer({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LoadingShimmer.circle(size: 60),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LoadingShimmer.rectangular(
                      width: double.infinity,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    LoadingShimmer.rectangular(
                      width: 200,
                      height: 14,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 8),
                    LoadingShimmer.rectangular(
                      width: 150,
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
