import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/club_repository.dart';
import 'data/repositories/event_repository.dart';
import 'data/repositories/pantry_repository.dart';
import 'data/repositories/recipe_repository.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/club_viewmodel.dart';
import 'presentation/viewmodels/event_viewmodel.dart';
import 'presentation/viewmodels/home_viewmodel.dart';
import 'presentation/viewmodels/pantry_viewmodel.dart';
import 'presentation/viewmodels/profile_viewmodel.dart';
import 'presentation/viewmodels/recipe_viewmodel.dart';
import 'presentation/viewmodels/theme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Lock to portrait on mobile; allow all orientations on web/tablet
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  runApp(const SupperSyncApp());
}

class SupperSyncApp extends StatelessWidget {
  const SupperSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Repositories ─────────────────────────────────────────────────────────
    final authRepository = AuthRepository();
    final clubRepository = ClubRepository();
    final pantryRepository = PantryRepository();
    final eventRepository = EventRepository();
    final recipeRepository = RecipeRepository();

    return MultiProvider(
      providers: [
        // ── Theme ─────────────────────────────────────────────────────────────
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),

        // ── Auth ──────────────────────────────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(authRepository),
        ),

        // ── Home ──────────────────────────────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(pantryRepository, eventRepository),
        ),

        // ── Pantry ────────────────────────────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => PantryViewModel(pantryRepository),
        ),

        // ── Club ──────────────────────────────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => ClubViewModel(clubRepository),
        ),

        // ── Event ─────────────────────────────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => EventViewModel(eventRepository),
        ),

        // ── Recipe ────────────────────────────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => RecipeViewModel(recipeRepository, pantryRepository),
        ),

        // ── Profile ───────────────────────────────────────────────────────────
        ChangeNotifierProvider(
          create: (_) => ProfileViewModel(authRepository),
        ),
      ],
      child: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewModel>();
    final router = AppRouter.createRouter(context);

    return MaterialApp.router(
      title: 'SupperSync',
      debugShowCheckedModeBanner: false,
      themeMode: themeVM.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
