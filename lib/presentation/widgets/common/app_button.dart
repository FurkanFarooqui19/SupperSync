import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }
enum AppButtonSize { small, medium, large }

/// SupperSync Design System — Reusable Button Component
///
/// Supports primary, secondary, outline, ghost, and destructive variants.
/// Never calls setState() — fully stateless.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.borderRadius,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final height = switch (size) {
      AppButtonSize.small => AppDimensions.buttonHeightSm,
      AppButtonSize.medium => AppDimensions.buttonHeight,
      AppButtonSize.large => AppDimensions.buttonHeight + 8,
    };

    final radius = borderRadius ?? AppDimensions.radiusMd.toDouble();

    Widget child = _buildContent(theme, isDark);

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height,
      child: switch (variant) {
        AppButtonVariant.primary => _buildPrimary(child, radius),
        AppButtonVariant.secondary => _buildSecondary(child, radius),
        AppButtonVariant.outline => _buildOutline(child, radius, isDark),
        AppButtonVariant.ghost => _buildGhost(child, radius),
        AppButtonVariant.destructive =>
          _buildDestructive(child, radius),
      },
    );
  }

  Widget _buildContent(ThemeData theme, bool isDark) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: AppDimensions.iconSm),
          const SizedBox(width: AppDimensions.space2),
          Text(label),
        ],
      );
    }

    return Text(label);
  }

  Widget _buildPrimary(Widget child, double radius) => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 0,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        ),
        child: child,
      );

  Widget _buildSecondary(Widget child, double radius) => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 0,
        ),
        child: child,
      );

  Widget _buildOutline(Widget child, double radius, bool isDark) =>
      OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: child,
      );

  Widget _buildGhost(Widget child, double radius) => TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space4,
            vertical: AppDimensions.space2,
          ),
        ),
        child: child,
      );

  Widget _buildDestructive(Widget child, double radius) => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 0,
        ),
        child: child,
      );
}

/// Icon-only circular button
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ??
                (isDark ? AppColors.cardDark : AppColors.backgroundLight),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: AppDimensions.borderThin,
            ),
          ),
          child: Icon(
            icon,
            size: AppDimensions.iconSm,
            color: color ??
                (isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight),
          ),
        ),
      ),
    );
  }
}
