import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../presentation/viewmodels/auth_viewmodel.dart';
import '../../presentation/views/auth/login_view.dart';
import '../../presentation/views/auth/register_view.dart';
import '../../presentation/views/clubs/club_detail_view.dart';
import '../../presentation/views/clubs/clubs_view.dart';
import '../../presentation/views/clubs/create_club_view.dart';
import '../../presentation/views/events/create_event_view.dart';
import '../../presentation/views/events/event_detail_view.dart';
import '../../presentation/views/events/events_view.dart';
import '../../presentation/views/home/home_view.dart';
import '../../presentation/views/pantry/add_item_view.dart';
import '../../presentation/views/pantry/pantry_view.dart';
import '../../presentation/views/profile/edit_profile_view.dart';
import '../../presentation/views/profile/profile_view.dart';
import '../../presentation/views/shell/main_shell_view.dart';
import '../../presentation/views/splash/splash_view.dart';
import 'route_names.dart';

/// SupperSync App Router
///
/// Uses go_router with ShellRoute for bottom navigation.
/// Auth redirect is handled via a stream listener on Supabase auth state.
abstract final class AppRouter {
  AppRouter._();

  static GoRouter? _instance;

  /// Creates the router once and reuses it (avoids resetting nav on rebuild).
  static GoRouter createRouter(BuildContext context) {
    if (_instance != null) return _instance!;

    final authVM = context.read<AuthViewModel>();

    _instance = GoRouter(
      initialLocation: RouteNames.splash,
      refreshListenable: authVM,
      redirect: _redirect,
      routes: [
        GoRoute(
          path: RouteNames.splash,
          name: 'splash',
          builder: (_, __) => const SplashView(),
        ),
        GoRoute(
          path: RouteNames.login,
          name: 'login',
          builder: (_, __) => const LoginView(),
        ),
        GoRoute(
          path: RouteNames.register,
          name: 'register',
          builder: (_, __) => const RegisterView(),
        ),
        ShellRoute(
          builder: (context, state, child) =>
              MainShellView(child: child, location: state.uri.toString()),
          routes: [
            GoRoute(
              path: RouteNames.home,
              name: 'home',
              builder: (_, __) => const HomeView(),
            ),
            GoRoute(
              path: RouteNames.pantry,
              name: 'pantry',
              builder: (_, __) => const PantryView(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'addPantryItem',
                  builder: (_, state) {
                    final extra = state.extra as Map<String, dynamic>?;
                    return AddItemView(editItem: extra);
                  },
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.clubs,
              name: 'clubs',
              builder: (_, __) => const ClubsView(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'createClub',
                  builder: (_, __) => const CreateClubView(),
                ),
                GoRoute(
                  path: ':clubId',
                  name: 'clubDetail',
                  builder: (_, state) => ClubDetailView(
                    clubId: state.pathParameters['clubId']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.events,
              name: 'events',
              builder: (_, __) => const EventsView(),
              routes: [
                GoRoute(
                  path: 'create',
                  name: 'createEvent',
                  builder: (_, state) {
                    final clubId = state.extra as String?;
                    return CreateEventView(preselectedClubId: clubId);
                  },
                ),
                GoRoute(
                  path: ':eventId',
                  name: 'eventDetail',
                  builder: (_, state) => EventDetailView(
                    eventId: state.pathParameters['eventId']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: RouteNames.profile,
              name: 'profile',
              builder: (_, __) => const ProfileView(),
              routes: [
                GoRoute(
                  path: 'edit',
                  name: 'editProfile',
                  builder: (_, __) => const EditProfileView(),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    return _instance!;
  }

  static String? _redirect(BuildContext context, GoRouterState state) {
    final session = Supabase.instance.client.auth.currentSession;
    final isAuthenticated = session != null;
    final location = state.uri.toString();

    final isSplash = location == RouteNames.splash;
    final isAuthPage =
        location == RouteNames.login || location == RouteNames.register;

    if (isSplash) return null;

    if (!isAuthenticated && !isAuthPage) {
      return RouteNames.login;
    }

    if (isAuthenticated && isAuthPage) {
      return RouteNames.home;
    }

    return null;
  }
}
