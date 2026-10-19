import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/events/event_card.dart';
import '../../widgets/pantry/pantry_item_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return AppStrings.goodMorning;
    if (hour < 17) return AppStrings.goodAfternoon;
    return AppStrings.goodEvening;
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeViewModel>();
    final auth = context.watch<AuthViewModel>();
    final theme = context.watch<ThemeViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!home.hasLoaded && !home.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<HomeViewModel>().loadDashboard();
      });
    }

    final name = auth.user?.displayName.split(' ').first ?? 'there';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => context.read<HomeViewModel>().loadDashboard(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppDimensions.screenHorizontalPadding,
                    AppDimensions.space4,
                    AppDimensions.screenHorizontalPadding,
                    AppDimensions.space2,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting()}, $name',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.appTagline,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppIconThemeToggle(
                        isDarkMode: theme.isDark ||
                            (theme.isSystem &&
                                MediaQuery.platformBrightnessOf(context) ==
                                    Brightness.dark),
                        onToggle: theme.toggleDarkLight,
                      ),
                    ],
                  ),
                ),
              ),
              if (home.isLoading)
                const SliverFillRemaining(child: LoadingView())
              else if (home.error != null)
                SliverFillRemaining(
                  child: ErrorState(
                    message: home.error,
                    onRetry: () =>
                        context.read<HomeViewModel>().loadDashboard(),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenHorizontalPadding,
                      vertical: AppDimensions.space4,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatChip(
                            label: 'Expiring',
                            value: '${home.expiringCount}',
                            color: AppColors.warning,
                            icon: Icons.timer_outlined,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space3),
                        Expanded(
                          child: _StatChip(
                            label: 'Events',
                            value: '${home.upcomingEventCount}',
                            color: AppColors.primary,
                            icon: Icons.event_available_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenHorizontalPadding,
                      vertical: AppDimensions.space2,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppDimensions.space4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryMuted,
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusLg),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Where to get recipe ideas',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '1. Pantry → add items → turn on “Share with Club”\n'
                            '2. Clubs → open your club → “Suggest recipes from combined pantry”\n'
                            '3. Or Events → open an event → “Recipe Matches”',
                            style: TextStyle(fontSize: 13, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: AppStrings.upcomingEvents,
                    onViewAll: () => context.go(RouteNames.events),
                  ),
                ),
                if (home.upcomingEvents.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.space6),
                      child: Text(
                        AppStrings.noUpcomingEvents,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenHorizontalPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final event = home.upcomingEvents[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.space3,
                            ),
                            child: EventCard(
                              event: event,
                              onTap: () => context.go(
                                '/events/${event.id}',
                              ),
                            ),
                          );
                        },
                        childCount: home.upcomingEvents.length,
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: SectionHeader(
                    title: AppStrings.expiringSoon,
                    onViewAll: () => context.go(RouteNames.pantry),
                  ),
                ),
                if (home.expiringSoon.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(AppDimensions.space6),
                      child: Text(
                        AppStrings.noExpiringItems,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.screenHorizontalPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = home.expiringSoon[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppDimensions.space3,
                            ),
                            child: PantryItemCard(item: item),
                          );
                        },
                        childCount: home.expiringSoon.length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppDimensions.space8),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppIconThemeToggle extends StatelessWidget {
  const AppIconThemeToggle({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
  });

  final bool isDarkMode;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: Icon(
        isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
        color: AppColors.primary,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppDimensions.space3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
