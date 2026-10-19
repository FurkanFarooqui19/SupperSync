import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../viewmodels/club_viewmodel.dart';
import '../../viewmodels/forms/club_form_controller.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';

class CreateClubView extends StatelessWidget {
  const CreateClubView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClubFormController(),
      child: const _CreateClubBody(),
    );
  }
}

class _CreateClubBody extends StatelessWidget {
  const _CreateClubBody();

  Future<void> _create(BuildContext context) async {
    final form = context.read<ClubFormController>();
    if (!form.validate()) return;

    final club = await context.read<ClubViewModel>().createClub(
          name: form.nameController.text,
          description: form.descriptionController.text.trim().isEmpty
              ? null
              : form.descriptionController.text,
        );

    if (club != null && context.mounted) {
      context.go('/clubs/${club.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<ClubFormController>();
    final clubs = context.watch<ClubViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.createClub)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
        child: Form(
          key: form.formKey,
          child: Column(
            children: [
              AppTextField(
                controller: form.nameController,
                label: AppStrings.clubName,
                hint: 'e.g. Weekend Feast Club',
                prefixIcon: Icons.groups_outlined,
                validator: AppValidators.displayName,
              ),
              const SizedBox(height: AppDimensions.space4),
              AppTextField(
                controller: form.descriptionController,
                label: AppStrings.clubDescription,
                hint: 'What is this club about?',
                maxLines: 4,
              ),
              if (clubs.error != null) ...[
                const SizedBox(height: AppDimensions.space3),
                Text(
                  clubs.error!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ],
              const SizedBox(height: AppDimensions.space6),
              AppButton(
                label: AppStrings.createClub,
                isLoading: clubs.isSaving,
                onPressed: () => _create(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
