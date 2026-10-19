import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/pantry_item_model.dart';

class PantryItemCard extends StatelessWidget {
  const PantryItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onToggleShare,
    this.onDelete,
    this.readOnly = false,
  });

  final PantryItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onToggleShare;
  final VoidCallback? onDelete;
  /// When true, shows as someone else's shared item (no edit affordances).
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final urgency = item.expiryDate?.expiryUrgency ?? 0;
    final canEdit = !readOnly && (onTap != null || onToggleShare != null || onDelete != null);

    return Material(
      color: isDark ? AppColors.cardDark : AppColors.cardLight,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: InkWell(
        onTap: canEdit ? onTap : null,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                alignment: Alignment.center,
                child: Text(
                  item.categoryEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: AppDimensions.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (item.isShared)
                          const Icon(
                            Icons.groups_rounded,
                            size: 16,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.quantity} ${item.unit} · ${item.storageType.label}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    if (item.ownerName != null && item.ownerName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        readOnly
                            ? 'Shared by ${item.ownerName}'
                            : item.ownerName!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                      ),
                    ],
                    if (item.expiryDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.expiryDate!.expiryLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: urgency.expiryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (canEdit && (onToggleShare != null || onDelete != null))
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'share') onToggleShare?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  itemBuilder: (_) => [
                    if (onToggleShare != null)
                      PopupMenuItem(
                        value: 'share',
                        child: Text(
                          item.isShared ? 'Make private' : 'Share with club',
                        ),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
