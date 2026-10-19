import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/router/route_names.dart';

/// Splash screen — navigates after branding animation.
/// No setState(); navigation is scheduled once via Future.microtask + delay.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  static bool _didScheduleNav = false;

  Future<void> _navigate(BuildContext context) async {
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!context.mounted) return;
    final session = Supabase.instance.client.auth.currentSession;
    context.go(session != null ? RouteNames.home : RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    // Kick off navigation once — no setState()
    if (!_didScheduleNav) {
      _didScheduleNav = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _navigate(context));
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radius2xl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.restaurant_rounded,
                color: Colors.white,
                size: 44,
              ),
            )
                .animate()
                .fadeIn(duration: 500.ms)
                .scale(begin: const Offset(0.8, 0.8)),
            const SizedBox(height: AppDimensions.space6),
            Text(
              AppStrings.appName,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
            const SizedBox(height: AppDimensions.space2),
            Text(
              AppStrings.appTagline,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.w400,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            const SizedBox(height: AppDimensions.space12),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
