import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../viewmodels/event_viewmodel.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/events/event_card.dart';

class EventsView extends StatelessWidget {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventViewModel>();

    if (!events.hasLoaded && !events.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<EventViewModel>().loadEvents();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.events),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: _TabButton(
                    label: AppStrings.upcoming,
                    selected: events.showingUpcoming,
                    onTap: () => events.setShowingUpcoming(true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TabButton(
                    label: AppStrings.past,
                    selected: !events.showingUpcoming,
                    onTap: () => events.setShowingUpcoming(false),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(RouteNames.createEvent),
        icon: const Icon(Icons.add_rounded),
        label: const Text(AppStrings.createEvent),
      ),
      body: events.isLoading && !events.hasLoaded
          ? const LoadingView()
          : events.error != null
              ? ErrorState(
                  message: events.error,
                  onRetry: () => context.read<EventViewModel>().loadEvents(),
                )
              : events.filteredEvents.isEmpty
                  ? EmptyState(
                      icon: Icons.event_outlined,
                      title: AppStrings.noEvents,
                      subtitle: AppStrings.noEventsSubtitle,
                      actionLabel: AppStrings.createEvent,
                      onAction: () => context.go(RouteNames.createEvent),
                    )
                  : RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () =>
                          context.read<EventViewModel>().loadEvents(),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppDimensions.screenHorizontalPadding,
                          AppDimensions.space3,
                          AppDimensions.screenHorizontalPadding,
                          100,
                        ),
                        itemCount: events.filteredEvents.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppDimensions.space3),
                        itemBuilder: (context, index) {
                          final event = events.filteredEvents[index];
                          return EventCard(
                            event: event,
                            onTap: () => context.go('/events/${event.id}'),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
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
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
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
