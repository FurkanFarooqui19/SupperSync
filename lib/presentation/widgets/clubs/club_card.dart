import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/club_model.dart';

class ClubCard extends StatelessWidget {
  const ClubCard({
    super.key,
    required this.club,
    this.onTap,
  });

  final ClubModel club;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                alignment: Alignment.center,
                child: Text(
                  club.name.isNotEmpty ? club.name[0].toUpperCase() : 'S',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      club.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    if (club.description != null &&
                        club.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        club.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (club.isHost)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryMuted,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusFull,
                              ),
                            ),
                            child: const Text(
                              'Host',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ),
                        if (club.isHost)
                          const SizedBox(width: AppDimensions.space2),
                        Text(
                          '${club.memberCount} members',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textTertiaryDark
                                : AppColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
