import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

/// SupperSync Design System — Text Field Component
///
/// Consistent input field with label, hint, validation, prefix/suffix support.
/// Stateless — no setState() anywhere.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixWidget,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.textCapitalization = TextCapitalization.sentences,
    this.initialValue,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffixWidget;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final int maxLines;
  final int? minLines;
  final bool enabled;
  final bool autofocus;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final TextCapitalization textCapitalization;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppDimensions.space2),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          maxLines: maxLines,
          minLines: minLines,
          enabled: enabled,
          autofocus: autofocus,
          readOnly: readOnly,
          onTap: onTap,
          focusNode: focusNode,
          textCapitalization: textCapitalization,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    size: AppDimensions.iconSm,
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  )
                : null,
            suffixIcon: suffixWidget ??
                (suffixIcon != null
                    ? Icon(
                        suffixIcon,
                        size: AppDimensions.iconSm,
                        color: isDark
                            ? AppColors.textTertiaryDark
                            : AppColors.textTertiaryLight,
                      )
                    : null),
            filled: true,
            fillColor:
                isDark ? AppColors.cardDark : AppColors.surfaceLight,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd),
              borderSide:
                  const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd),
              borderSide:
                  const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space4,
              vertical: AppDimensions.space4,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide(
                color: (isDark
                        ? AppColors.borderDark
                        : AppColors.borderLight)
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
