import '../constants/app_strings.dart';

/// Form validation functions used across all input fields
abstract final class AppValidators {
  AppValidators._();

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) return AppStrings.invalidEmail;
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return AppStrings.fieldRequired;
    if (value.length < 8) return AppStrings.passwordTooShort;
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return AppStrings.fieldRequired;
    if (value != original) return AppStrings.passwordsDoNotMatch;
    return null;
  }

  static String? displayName(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    if (value.trim().length < 2) return AppStrings.nameTooShort;
    return null;
  }

  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    return null;
  }

  static String? quantity(String? value) {
    if (value == null || value.trim().isEmpty) return AppStrings.fieldRequired;
    final num = double.tryParse(value.trim());
    if (num == null || num <= 0) return AppStrings.invalidQuantity;
    return null;
  }

  static String? optionalMinLength(String? value, int min) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length < min) return 'Minimum $min characters';
    return null;
  }
}
