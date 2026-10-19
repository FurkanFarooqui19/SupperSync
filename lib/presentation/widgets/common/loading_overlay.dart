import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          if (message != null) ...[
            const SizedBox(height: AppDimensions.space4),
            Text(
              message!,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  const ShimmerList({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.cardDark : AppColors.shimmerBase,
      highlightColor:
          isDark ? AppColors.borderDark : AppColors.shimmerHighlight,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
        itemCount: itemCount,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimensions.space3),
        itemBuilder: (_, __) => Container(
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          ),
        ),
      ),
    );
  }
}
