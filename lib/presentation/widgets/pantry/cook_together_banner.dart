import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/router/route_names.dart';
import '../../../data/models/recipe_model.dart';
import '../../viewmodels/recipe_viewmodel.dart';

/// Cook-together suggestions: headline + recipes with missing ingredients.
class CookTogetherBanner extends StatelessWidget {
  const CookTogetherBanner({
    super.key,
    required this.recipes,
  });

  final RecipeViewModel recipes;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (recipes.isLoading && !recipes.hasLoadedSuggestions) {
      return Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.space3),
        padding: const EdgeInsets.all(AppDimensions.space4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Finding recipes you can cook together...'),
          ],
        ),
      );
    }

    if (recipes.error != null && !recipes.hasRecipes) {
      return _InfoCard(
        title: 'Couldn’t load recipes',
        body: recipes.error!,
        actionLabel: 'Go to Clubs',
        onAction: () => context.go(RouteNames.clubs),
      );
    }

    if (!recipes.hasRecipes) {
      return _InfoCard(
        title: 'Cook together with your club',
        body:
            'Join a club and share pantry items. We’ll suggest recipes using everyone’s food — and list what’s still missing.',
        actionLabel: 'Go to Clubs',
        onAction: () => context.go(RouteNames.clubs),
      );
    }

    final others = recipes.otherClubMemberCount > 0
        ? recipes.otherClubMemberCount
        : recipes.otherContributorCount;
    final club = recipes.suggestionClubName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          club != null
              ? 'Cook together · $club'
              : 'Cook together',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          recipes.otherContributorCount > 0
              ? 'Using your pantry + ${recipes.otherContributorCount} member${recipes.otherContributorCount == 1 ? '' : 's'}\' shared items'
              : 'Using your pantry — ask clubmates to Share with Club for more matches',
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppDimensions.space3),
        ...recipes.recipes.take(5).map(
              (r) => _RecipeSuggestionCard(
                recipe: r,
                others: others,
                onTap: recipes.suggestionClubId == null
                    ? null
                    : () => context.go('/clubs/${recipes.suggestionClubId}'),
              ),
            ),
        const SizedBox(height: AppDimensions.space2),
      ],
    );
  }
}

class _RecipeSuggestionCard extends StatelessWidget {
  const _RecipeSuggestionCard({
    required this.recipe,
    required this.others,
    this.onTap,
  });

  final RecipeModel recipe;
  final int others;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final missing = recipe.missedIngredients;
    final used = recipe.usedIngredients;

    final headline = others > 0
        ? 'You + $others member${others == 1 ? '' : 's'} can make ${recipe.title}'
        : 'You can make ${recipe.title}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.space3),
      child: Material(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.space4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        headline,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusFull),
                      ),
                      child: Text(
                        '${recipe.matchPercentage.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${used.length} available'
                  '${missing.isEmpty ? ' · ready to cook' : ' · ${missing.length} missing'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                if (missing.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Missing: ${missing.map((i) => i.name).join(', ')}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                ],
                if (used.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Have: ${used.map((i) => i.name).take(5).join(', ')}'
                    '${used.length > 5 ? '…' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.space3),
      padding: const EdgeInsets.all(AppDimensions.space4),
      decoration: BoxDecoration(
        color: AppColors.primaryMuted,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
