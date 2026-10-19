import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.onViewAll,
  });

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenHorizontalPadding,
        vertical: AppDimensions.space2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text(AppStrings.viewAll),
            ),
        ],
      ),
    );
  }
}
