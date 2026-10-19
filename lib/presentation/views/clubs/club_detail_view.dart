import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/pantry_item_model.dart';
import '../../viewmodels/club_viewmodel.dart';
import '../../viewmodels/pantry_viewmodel.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/pantry/cook_together_banner.dart';
import '../../widgets/pantry/pantry_item_card.dart';

class ClubDetailView extends StatelessWidget {
  const ClubDetailView({super.key, required this.clubId});

  final String clubId;

  @override
  Widget build(BuildContext context) {
    final clubs = context.watch<ClubViewModel>();
    final pantry = context.watch<PantryViewModel>();
    final recipes = context.watch<RecipeViewModel>();

    if (clubs.loadedDetailId != clubId && !clubs.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final clubVm = context.read<ClubViewModel>();
        final pantryVm = context.read<PantryViewModel>();
        final recipeVm = context.read<RecipeViewModel>();
        clubVm.loadClubDetail(clubId).then((_) {
          if (!context.mounted) return;
          final loaded = context.read<ClubViewModel>().selectedClub;
          if (loaded != null) {
            recipeVm.loadRecipesForClub(
              loaded.id,
              clubName: loaded.name,
              memberCount: loaded.memberCount,
            );
          }
        });
        pantryVm.loadClubPantry(clubId);
      });
    }

    final club = clubs.selectedClub;
    final memberCount = clubs.selectedClubMembers.isNotEmpty
        ? clubs.selectedClubMembers.length
        : (club?.memberCount ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(club?.name ?? AppStrings.clubs),
        actions: [
          if (club != null)
            IconButton(
              tooltip: AppStrings.copyInviteCode,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: club.inviteCode));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.codeCopied)),
                );
              },
              icon: const Icon(Icons.copy_rounded),
            ),
        ],
      ),
      body: clubs.isLoading && club == null
          ? const LoadingView()
          : clubs.error != null && club == null
              ? ErrorState(
                  message: clubs.error,
                  onRetry: () =>
                      context.read<ClubViewModel>().loadClubDetail(clubId),
                )
              : club == null
                  ? const EmptyState(
                      icon: Icons.groups_outlined,
                      title: 'Club not found',
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        final clubVm = context.read<ClubViewModel>();
                        final pantryVm = context.read<PantryViewModel>();
                        final recipeVm = context.read<RecipeViewModel>();
                        await clubVm.loadClubDetail(clubId);
                        await pantryVm.loadClubPantry(clubId);
                        final loaded = clubVm.selectedClub;
                        if (loaded != null) {
                          await recipeVm.loadRecipesForClub(
                            loaded.id,
                            clubName: loaded.name,
                            memberCount: loaded.memberCount,
                          );
                        }
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(
                          AppDimensions.screenHorizontalPadding,
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppDimensions.space5),
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusLg,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  club.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                if (club.description != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    club.description!,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: AppDimensions.space4),
                                Row(
                                  children: [
                                    _InfoPill(
                                      icon: Icons.vpn_key_rounded,
                                      label: club.inviteCode,
                                    ),
                                    const SizedBox(width: 8),
                                    _InfoPill(
                                      icon: Icons.people_rounded,
                                      label:
                                          '$memberCount ${AppStrings.members}',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space5),
                          AppButton(
                            label: AppStrings.createEvent,
                            icon: Icons.event_rounded,
                            onPressed: () => context.go(
                              RouteNames.createEvent,
                              extra: clubId,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space4),
                          CookTogetherBanner(recipes: recipes),
                          const SizedBox(height: AppDimensions.space4),
                          Text(
                            AppStrings.members,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppDimensions.space3),
                          ...clubs.selectedClubMembers.map(
                            (m) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primaryMuted,
                                child: Text(
                                  m.displayName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              title: Text(m.displayName),
                              trailing: Text(
                                m.role,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space6),
                          Text(
                            AppStrings.clubInventory,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppDimensions.space3),
                          if (pantry.allClubItems.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No shared items yet. Members can share from their pantry.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            ...pantry.allClubItems.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppDimensions.space3,
                                ),
                                child: PantryItemCard(
                                  item: item,
                                  // Club inventory is view-only — only the owner
                                  // can edit from their own Pantry tab.
                                  readOnly: !pantry.isOwnedByMe(item),
                                  onTap: pantry.isOwnedByMe(item)
                                      ? () => context.go(
                                            RouteNames.addPantryItem,
                                            extra: {
                                              'id': item.id,
                                              'name': item.name,
                                              'quantity': item.quantity,
                                              'unit': item.unit,
                                              'category': item.category,
                                              'storage_type':
                                                  item.storageType.name,
                                              'visibility':
                                                  item.visibility.name,
                                              'expiry_date': item.expiryDate
                                                  ?.toIso8601String(),
                                              'notes': item.notes,
                                              'owner_id': item.ownerId,
                                              'created_at': item.createdAt
                                                  .toIso8601String(),
                                              'updated_at': item.updatedAt
                                                  .toIso8601String(),
                                            },
                                          )
                                      : null,
                                  onToggleShare: pantry.isOwnedByMe(item)
                                      ? () => pantry.toggleVisibility(item)
                                      : null,
                                  onDelete: pantry.isOwnedByMe(item)
                                      ? () => pantry.deleteItem(item.id)
                                      : null,
                                ),
                              ),
                            ),
                          const SizedBox(height: AppDimensions.space6),
                          AppButton(
                            label: 'Leave Club',
                            variant: AppButtonVariant.outline,
                            onPressed: () async {
                              final ok = await context
                                  .read<ClubViewModel>()
                                  .leaveClub(clubId);
                              if (ok && context.mounted) {
                                context.go(RouteNames.clubs);
                              }
                            },
                          ),
                          const SizedBox(height: AppDimensions.space8),
                        ],
                      ),
                    ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
