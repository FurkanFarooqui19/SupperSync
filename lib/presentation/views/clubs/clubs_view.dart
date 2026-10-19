import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/validators.dart';
import '../../viewmodels/club_viewmodel.dart';
import '../../viewmodels/forms/club_form_controller.dart';
import '../../widgets/clubs/club_card.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_overlay.dart';

class ClubsView extends StatelessWidget {
  const ClubsView({super.key});

  Future<void> _showJoinDialog(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      builder: (_) => ChangeNotifierProvider(
        create: (_) => ClubFormController(),
        child: const _JoinClubSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clubs = context.watch<ClubViewModel>();

    if (!clubs.hasLoaded && !clubs.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ClubViewModel>().loadClubs();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.clubs),
        actions: [
          TextButton(
            onPressed: () => _showJoinDialog(context),
            child: const Text(AppStrings.joinClub),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RouteNames.createClub),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.createClub),
      ),
      body: clubs.isLoading && !clubs.hasLoaded
          ? const LoadingView()
          : clubs.error != null
              ? ErrorState(
                  message: clubs.error,
                  onRetry: () => context.read<ClubViewModel>().loadClubs(),
                )
              : !clubs.hasClubs
                  ? EmptyState(
                      icon: Icons.groups_outlined,
                      title: AppStrings.noClubs,
                      subtitle: AppStrings.noClubsSubtitle,
                      actionLabel: AppStrings.createClub,
                      onAction: () => context.go(RouteNames.createClub),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () =>
                          context.read<ClubViewModel>().loadClubs(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.screenHorizontalPadding,
                          AppDimensions.space3,
                          AppDimensions.screenHorizontalPadding,
                          100,
                        ),
                        itemCount: clubs.clubs.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppDimensions.space3),
                        itemBuilder: (context, index) {
                          final club = clubs.clubs[index];
                          return ClubCard(
                            club: club,
                            onTap: () => context.go('/clubs/${club.id}'),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _JoinClubSheet extends StatelessWidget {
  const _JoinClubSheet();

  Future<void> _join(BuildContext context) async {
    final form = context.read<ClubFormController>();
    if (!form.validate()) return;

    final club = await context.read<ClubViewModel>().joinClub(
          form.inviteCodeController.text,
        );
    if (club != null && context.mounted) {
      Navigator.pop(context);
      context.go('/clubs/${club.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = context.watch<ClubFormController>();
    final clubs = context.watch<ClubViewModel>();
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.screenHorizontalPadding,
        AppDimensions.space6,
        AppDimensions.screenHorizontalPadding,
        AppDimensions.space6 + bottom,
      ),
      child: Form(
        key: form.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.joinClub,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppDimensions.space4),
            AppTextField(
              controller: form.inviteCodeController,
              label: AppStrings.inviteCode,
              hint: AppStrings.enterInviteCode,
              prefixIcon: Icons.vpn_key_outlined,
              textCapitalization: TextCapitalization.characters,
              validator: AppValidators.required,
            ),
            if (clubs.error != null) ...[
              const SizedBox(height: AppDimensions.space3),
              Text(
                clubs.error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ],
            const SizedBox(height: AppDimensions.space5),
            AppButton(
              label: AppStrings.joinClub,
              isLoading: clubs.isSaving,
              onPressed: () => _join(context),
            ),
          ],
        ),
      ),
    );
  }
}
