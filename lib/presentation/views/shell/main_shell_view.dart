import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';

/// Bottom navigation shell. Stateless — navigation via go_router only.
class MainShellView extends StatelessWidget {
  const MainShellView({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  int get _currentIndex {
    if (location.startsWith(RouteNames.pantry)) return 1;
    if (location.startsWith(RouteNames.clubs)) return 2;
    if (location.startsWith(RouteNames.events)) return 3;
    if (location.startsWith(RouteNames.profile)) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
      case 1:
        context.go(RouteNames.pantry);
      case 2:
        context.go(RouteNames.clubs);
      case 3:
        context.go(RouteNames.events);
      case 4:
        context.go(RouteNames.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: AppDimensions.bottomNavHeight - 16,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (i) => _onTap(context, i),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
              selectedFontSize: AppDimensions.bottomNavLabelSize,
              unselectedFontSize: AppDimensions.bottomNavLabelSize,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: AppStrings.navHome,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.kitchen_outlined),
                  activeIcon: Icon(Icons.kitchen_rounded),
                  label: AppStrings.navPantry,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.groups_outlined),
                  activeIcon: Icon(Icons.groups_rounded),
                  label: AppStrings.navClubs,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_outlined),
                  activeIcon: Icon(Icons.event_rounded),
                  label: AppStrings.navEvents,
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: AppStrings.navProfile,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
