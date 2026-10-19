import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/event_model.dart';
import '../../viewmodels/event_viewmodel.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_overlay.dart';

class EventDetailView extends StatelessWidget {
  const EventDetailView({super.key, required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventViewModel>();
    final recipes = context.watch<RecipeViewModel>();

    if (events.loadedDetailId != eventId && !events.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<EventViewModel>().loadEventDetail(eventId);
      });
    }

    final event = events.selectedEvent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(event?.title ?? AppStrings.events),
      ),
      body: events.isLoading && event == null
          ? const LoadingView()
          : events.error != null && event == null
              ? ErrorState(
                  message: events.error,
                  onRetry: () => context
                      .read<EventViewModel>()
                      .loadEventDetail(eventId),
                )
              : event == null
                  ? const EmptyState(
                      icon: Icons.event_busy_outlined,
                      title: 'Event not found',
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () => context
                          .read<EventViewModel>()
                          .loadEventDetail(eventId),
                      child: ListView(
                        padding: const EdgeInsets.all(
                          AppDimensions.screenHorizontalPadding,
                        ),
                        children: [
                          Text(
                            event.title,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimaryLight,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space2),
                          Text(
                            event.eventDate.fullDateTime,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          if (event.location != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              event.location!,
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppDimensions.space5),
                          Text(
                            AppStrings.rsvp,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppDimensions.space2),
                          Wrap(
                            spacing: 8,
                            children: [
                              _RsvpChip(
                                label: AppStrings.attending,
                                selected: event.myRsvpStatus ==
                                    RsvpStatus.confirmed,
                                color: AppColors.success,
                                onTap: () => context
                                    .read<EventViewModel>()
                                    .rsvp(eventId, RsvpStatus.confirmed),
                              ),
                              _RsvpChip(
                                label: AppStrings.maybe,
                                selected:
                                    event.myRsvpStatus == RsvpStatus.maybe,
                                color: AppColors.warning,
                                onTap: () => context
                                    .read<EventViewModel>()
                                    .rsvp(eventId, RsvpStatus.maybe),
                              ),
                              _RsvpChip(
                                label: AppStrings.notAttending,
                                selected: event.myRsvpStatus ==
                                    RsvpStatus.declined,
                                color: AppColors.error,
                                onTap: () => context
                                    .read<EventViewModel>()
                                    .rsvp(eventId, RsvpStatus.declined),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.space6),
                          Text(
                            'Combined pantry recipes',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppDimensions.space2),
                          Text(
                            'Uses your pantry + shared items from other members.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space3),
                          AppButton(
                            label: AppStrings.recipeMatches,
                            icon: Icons.restaurant_rounded,
                            variant: AppButtonVariant.secondary,
                            isLoading: recipes.isLoading,
                            onPressed: () async {
                              final attendeeIds = events.attendees
                                  .where((a) => a['status'] == 'confirmed')
                                  .map((a) => a['user_id'] as String)
                                  .toList();
                              await context
                                  .read<RecipeViewModel>()
                                  .loadRecipesForEvent(
                                    clubId: event.clubId,
                                    attendeeIds: attendeeIds,
                                  );
                            },
                          ),
                          if (recipes.combinedItemCount > 0) ...[
                            const SizedBox(height: AppDimensions.space3),
                            Text(
                              'Combined pantry: ${recipes.combinedItemCount} items '
                              '(yours: ${recipes.myItemCount}, '
                              'shared by others: ${recipes.othersItemCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                          if (recipes.error != null) ...[
                            const SizedBox(height: AppDimensions.space2),
                            Text(
                              recipes.error!,
                              style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          if (recipes.recipes.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.space4),
                            Text(
                              AppStrings.recipeMatches,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppDimensions.space3),
                            ...recipes.recipes.map(
                              (r) => Container(
                                margin: const EdgeInsets.only(
                                  bottom: AppDimensions.space3,
                                ),
                                padding: const EdgeInsets.all(
                                  AppDimensions.cardPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.cardDark
                                      : AppColors.cardLight,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.cardRadius,
                                  ),
                                  border: Border.all(
                                    color: isDark
                                        ? AppColors.borderDark
                                        : AppColors.borderLight,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${r.matchPercentage.toStringAsFixed(0)}% ${AppStrings.matchPercentage} · '
                                      '${r.usedIngredients.length} available · '
                                      '${r.missedIngredients.length} ${AppStrings.missingIngredients}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                    if (r.missedIngredients.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        'Need: ${r.missedIngredients.map((i) => i.name).join(', ')}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: AppDimensions.space6),
                          Text(
                            AppStrings.attendees,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppDimensions.space2),
                          Text(
                            '${events.attendees.length} people',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.space6),
                          Text(
                            AppStrings.whosBringing,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppDimensions.space3),
                          if (events.assignments.isEmpty)
                            const Text(
                              'No ingredient assignments yet. Generate recipes first, then claim missing items.',
                            )
                          else
                            ...events.assignments.map(
                              (a) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(a.ingredientName),
                                subtitle: Text(
                                  '${a.quantity} ${a.unit}'
                                  '${a.assigneeName != null ? ' · ${a.assigneeName}' : ''}',
                                ),
                                trailing: a.isAcquired
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: AppColors.success,
                                      )
                                    : a.isClaimed
                                        ? TextButton(
                                            onPressed: () => context
                                                .read<EventViewModel>()
                                                .markAcquired(a.id),
                                            child: const Text(
                                              AppStrings.markAcquired,
                                            ),
                                          )
                                        : TextButton(
                                            onPressed: () => context
                                                .read<EventViewModel>()
                                                .claimAssignment(a.id),
                                            child: const Text(
                                              AppStrings.claimIngredient,
                                            ),
                                          ),
                              ),
                            ),
                          const SizedBox(height: AppDimensions.space8),
                        ],
                      ),
                    ),
    );
  }
}

class _RsvpChip extends StatelessWidget {
  const _RsvpChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: color.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: selected ? color : null,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
