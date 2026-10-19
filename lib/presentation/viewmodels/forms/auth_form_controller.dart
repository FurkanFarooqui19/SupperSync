import 'package:flutter/material.dart';

/// Local form state for auth screens.
/// Holds TextEditingControllers and password visibility — never uses setState().
class AuthFormController extends ChangeNotifier {
  AuthFormController();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final displayNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  bool obscureConfirm = true;

  void toggleObscurePassword() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirm() {
    obscureConfirm = !obscureConfirm;
    notifyListeners();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    displayNameController.dispose();
    super.dispose();
  }
}
