import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';
import '../../../core/utils/extensions.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/theme_viewmodel.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/loading_overlay.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final profile = context.watch<ProfileViewModel>();
    final theme = context.watch<ThemeViewModel>();
    final user = auth.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user != null && !profile.hasLoaded && !profile.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ProfileViewModel>().loadImpact(user.id);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          IconButton(
            onPressed: () => context.go(RouteNames.editProfile),
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: user == null
          ? const LoadingView()
          : ListView(
              padding: const EdgeInsets.all(
                AppDimensions.screenHorizontalPadding,
              ),
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryMuted,
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.displayName.isNotEmpty
                                    ? user.displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: AppDimensions.space3),
                      Text(
                        user.displayName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                        ),
                      ),
                      if (user.dietaryTags.isNotEmpty) ...[
                        const SizedBox(height: AppDimensions.space3),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          alignment: WrapAlignment.center,
                          children: user.dietaryTags
                              .map(
                                (t) => Chip(
                                  label: Text(t),
                                  visualDensity: VisualDensity.compact,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space6),
                Text(
                  AppStrings.impactTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.space3),
                Row(
                  children: [
                    Expanded(
                      child: _ImpactCard(
                        label: AppStrings.foodRescued,
                        value: profile.weightSaved.asKg,
                        icon: Icons.eco_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space3),
                    Expanded(
                      child: _ImpactCard(
                        label: AppStrings.moneySaved,
                        value: profile.costSaved.asCurrency,
                        icon: Icons.savings_outlined,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space3),
                _ImpactCard(
                  label: AppStrings.carbonOffset,
                  value: profile.carbonOffset.asCo2,
                  icon: Icons.cloud_outlined,
                  color: AppColors.info,
                ),
                const SizedBox(height: AppDimensions.space6),
                Text(
                  AppStrings.appearance,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.space2),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {theme.themeMode},
                  onSelectionChanged: (s) => theme.setTheme(s.first),
                ),
                const SizedBox(height: AppDimensions.space8),
                AppButton(
                  label: AppStrings.signOut,
                  variant: AppButtonVariant.outline,
                  icon: Icons.logout_rounded,
                  isLoading: auth.isLoading,
                  onPressed: () async {
                    await context.read<AuthViewModel>().signOut();
                    if (context.mounted) context.go(RouteNames.login);
                  },
                ),
                const SizedBox(height: AppDimensions.space8),
              ],
            ),
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
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
          ),
        ],
      ),
    );
  }
}
