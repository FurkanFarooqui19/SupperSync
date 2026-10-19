import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/forms/auth_form_controller.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthFormController(),
      child: const _LoginBody(),
    );
  }
}

class _LoginBody extends StatelessWidget {
  const _LoginBody();

  Future<void> _submit(BuildContext context) async {
    final form = context.read<AuthFormController>();
    if (!form.validate()) return;

    final auth = context.read<AuthViewModel>();
    final ok = await auth.signIn(
      email: form.emailController.text,
      password: form.passwordController.text,
    );
    if (ok && context.mounted) {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<AuthFormController>();
    final auth = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.screenHorizontalPadding,
            vertical: AppDimensions.space6,
          ),
          child: Form(
            key: form.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppDimensions.space8),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusLg),
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: AppDimensions.space6),
                Text(
                  AppStrings.welcomeBack,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: AppDimensions.space2),
                Text(
                  AppStrings.signInSubtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: AppDimensions.space8),
                AppTextField(
                  controller: form.emailController,
                  label: AppStrings.email,
                  hint: 'you@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.none,
                  validator: AppValidators.email,
                ),
                const SizedBox(height: AppDimensions.space4),
                AppTextField(
                  controller: form.passwordController,
                  label: AppStrings.password,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: form.obscurePassword,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.none,
                  validator: AppValidators.password,
                  onFieldSubmitted: (_) => _submit(context),
                  suffixWidget: IconButton(
                    icon: Icon(
                      form.obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: AppDimensions.iconSm,
                    ),
                    onPressed: form.toggleObscurePassword,
                  ),
                ),
                if (auth.error != null) ...[
                  const SizedBox(height: AppDimensions.space3),
                  Text(
                    auth.error!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimensions.space6),
                AppButton(
                  label: AppStrings.signIn,
                  isLoading: auth.isLoading,
                  onPressed: () => _submit(context),
                ),
                const SizedBox(height: AppDimensions.space6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.noAccount,
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(RouteNames.register),
                      child: const Text(AppStrings.signUp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
