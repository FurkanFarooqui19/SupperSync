import 'package:flutter/material.dart';
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
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/pantry/cook_together_banner.dart';
import '../../widgets/pantry/pantry_item_card.dart';

class PantryView extends StatelessWidget {
  const PantryView({super.key});

  Future<void> _loadAll(BuildContext context, {bool forceRecipes = false}) async {
    final pantry = context.read<PantryViewModel>();
    final clubs = context.read<ClubViewModel>();
    final recipes = context.read<RecipeViewModel>();

    await Future.wait([
      pantry.loadMyPantry(),
      clubs.loadClubs(),
    ]);
    if (!context.mounted) return;

    if (!clubs.hasClubs) {
      recipes.clearSuggestionsForNoClub();
      return;
    }

    if (forceRecipes || !recipes.hasLoadedSuggestions) {
      final club = clubs.clubs.first;
      await recipes.loadRecipesForClub(
        club.id,
        clubName: club.name,
        memberCount: club.memberCount,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pantry = context.watch<PantryViewModel>();
    final recipes = context.watch<RecipeViewModel>();
    final clubs = context.watch<ClubViewModel>();

    if (!pantry.hasLoaded && !pantry.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAll(context, forceRecipes: true);
      });
    } else if (pantry.hasLoaded &&
        clubs.hasLoaded &&
        clubs.hasClubs &&
        !recipes.hasLoadedSuggestions &&
        !recipes.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final club = context.read<ClubViewModel>().clubs.first;
        context.read<RecipeViewModel>().loadRecipesForClub(
              club.id,
              clubName: club.name,
              memberCount: club.memberCount,
            );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.myPantry),
        actions: [
          if (pantry.expiringCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warningMuted,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                  ),
                  child: Text(
                    '${pantry.expiringCount} expiring',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RouteNames.addPantryItem),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.addItem),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.screenHorizontalPadding,
              AppDimensions.space3,
              AppDimensions.screenHorizontalPadding,
              AppDimensions.space2,
            ),
            child: AppTextField(
              hint: AppStrings.searchItems,
              prefixIcon: Icons.search_rounded,
              onChanged: pantry.setSearch,
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.screenHorizontalPadding,
              ),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: pantry.selectedCategory == null,
                  onTap: () => pantry.setCategory(null),
                ),
                ...PantryCategory.all.take(8).map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _FilterChip(
                          label: c,
                          selected: pantry.selectedCategory == c,
                          onTap: () => pantry.setCategory(c),
                        ),
                      ),
                    ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.space3),
          Expanded(
            child: pantry.isLoading && !pantry.hasLoaded
                ? const LoadingView()
                : pantry.error != null
                    ? ErrorState(
                        message: pantry.error,
                        onRetry: () => _loadAll(context, forceRecipes: true),
                      )
                    : RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () => _loadAll(context, forceRecipes: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.screenHorizontalPadding,
                            0,
                            AppDimensions.screenHorizontalPadding,
                            100,
                          ),
                          itemCount: pantry.filteredItems.isEmpty
                              ? 2
                              : pantry.filteredItems.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return CookTogetherBanner(recipes: recipes);
                            }

                            if (pantry.filteredItems.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 24),
                                child: EmptyState(
                                  icon: Icons.kitchen_outlined,
                                  title: AppStrings.emptyPantry,
                                  subtitle: AppStrings.emptyPantrySubtitle,
                                ),
                              );
                            }

                            final item = pantry.filteredItems[index - 1];
                            final mine = pantry.isOwnedByMe(item);
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDimensions.space3,
                              ),
                              child: PantryItemCard(
                                item: item,
                                readOnly: !mine,
                                onTap: mine
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
                                onToggleShare: mine
                                    ? () => context
                                        .read<PantryViewModel>()
                                        .toggleVisibility(item)
                                    : null,
                                onDelete: mine
                                    ? () => _confirmDelete(context, item.id)
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.deleteConfirmTitle),
        content: const Text(AppStrings.deleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              AppStrings.delete,
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<PantryViewModel>().deleteItem(id);
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}
