import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/event_model.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  final EventModel event;
  final VoidCallback? onTap;

  Color get _statusColor {
    switch (event.status) {
      case EventStatus.confirmed:
        return AppColors.success;
      case EventStatus.completed:
        return AppColors.info;
      case EventStatus.cancelled:
        return AppColors.error;
      case EventStatus.planning:
        return AppColors.warning;
    }
  }

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.15),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusFull),
                    ),
                    child: Text(
                      event.status.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space2),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    event.eventDate.fullDateTime,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              if (event.clubName != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.groups_rounded,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      event.clubName!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
              if (event.location != null && event.location!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.location!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
