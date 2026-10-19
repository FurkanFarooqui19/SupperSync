import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/forms/profile_form_controller.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthViewModel>().user;

    return ChangeNotifierProvider(
      create: (_) => ProfileFormController(user),
      child: const _EditProfileBody(),
    );
  }
}

class _EditProfileBody extends StatelessWidget {
  const _EditProfileBody();

  Future<void> _save(BuildContext context) async {
    final form = context.read<ProfileFormController>();
    if (!form.validate()) return;

    final ok = await context.read<AuthViewModel>().updateProfile(
          displayName: form.displayNameController.text,
          bio: form.bioController.text.trim().isEmpty
              ? null
              : form.bioController.text,
          dietaryTags: form.dietaryTags,
        );

    if (ok && context.mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<ProfileFormController>();
    final auth = context.watch<AuthViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
        child: Form(
          key: form.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: form.displayNameController,
                label: AppStrings.displayName,
                prefixIcon: Icons.person_outline_rounded,
                validator: AppValidators.displayName,
              ),
              const SizedBox(height: AppDimensions.space4),
              AppTextField(
                controller: form.bioController,
                label: 'Bio',
                hint: 'Tell your club about yourself',
                maxLines: 3,
              ),
              const SizedBox(height: AppDimensions.space5),
              Text(
                AppStrings.dietaryPreferences,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppDimensions.space2),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ProfileFormController.availableTags.map((tag) {
                  final selected = form.dietaryTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: selected,
                    onSelected: (_) => form.toggleTag(tag),
                    selectedColor: AppColors.primaryMuted,
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              if (auth.error != null) ...[
                const SizedBox(height: AppDimensions.space3),
                Text(
                  auth.error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: AppDimensions.space6),
              AppButton(
                label: AppStrings.save,
                isLoading: auth.isLoading,
                onPressed: () => _save(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
