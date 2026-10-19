import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// SupperSync Design System — Material Theme Configuration
///
/// Defines both light and dark [ThemeData] using the design token system.
/// All component themes are configured centrally here.
abstract final class AppTheme {
  AppTheme._();

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: _lightColorScheme,
        textTheme: _textTheme(Brightness.light),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        appBarTheme: _appBarTheme(Brightness.light),
        cardTheme: _cardTheme(Brightness.light),
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme(Brightness.light),
        textButtonTheme: _textButtonTheme,
        inputDecorationTheme: _inputDecorationTheme(Brightness.light),
        chipTheme: _chipTheme(Brightness.light),
        bottomNavigationBarTheme: _bottomNavTheme(Brightness.light),
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerLight,
          thickness: 1,
          space: 0,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryLight,
          size: AppDimensions.iconMd,
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space4,
            vertical: AppDimensions.space1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        switchTheme: _switchTheme,
        dialogTheme: _dialogTheme(Brightness.light),
        snackBarTheme: _snackBarTheme,
        floatingActionButtonTheme: _fabTheme,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          },
        ),
      );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: _darkColorScheme,
        textTheme: _textTheme(Brightness.dark),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        appBarTheme: _appBarTheme(Brightness.dark),
        cardTheme: _cardTheme(Brightness.dark),
        elevatedButtonTheme: _elevatedButtonTheme,
        outlinedButtonTheme: _outlinedButtonTheme(Brightness.dark),
        textButtonTheme: _textButtonTheme,
        inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
        chipTheme: _chipTheme(Brightness.dark),
        bottomNavigationBarTheme: _bottomNavTheme(Brightness.dark),
        dividerTheme: const DividerThemeData(
          color: AppColors.dividerDark,
          thickness: 1,
          space: 0,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimaryDark,
          size: AppDimensions.iconMd,
        ),
        listTileTheme: ListTileThemeData(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space4,
            vertical: AppDimensions.space1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        switchTheme: _switchTheme,
        dialogTheme: _dialogTheme(Brightness.dark),
        snackBarTheme: _snackBarTheme,
        floatingActionButtonTheme: _fabTheme,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: ZoomPageTransitionsBuilder(),
            TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          },
        ),
      );

  // ── Color Schemes ─────────────────────────────────────────────────────────
  static const ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryMuted,
    onPrimaryContainer: AppColors.primaryDark,
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: AppColors.secondaryMuted,
    onSecondaryContainer: AppColors.secondaryDark,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.textPrimaryLight,
    surfaceContainerHighest: AppColors.backgroundLight,
    onSurfaceVariant: AppColors.textSecondaryLight,
    error: AppColors.error,
    onError: Colors.white,
    outline: AppColors.borderLight,
    shadow: Color(0x1A000000),
  );

  static const ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: Color(0xFF052E16),
    primaryContainer: Color(0xFF14532D),
    onPrimaryContainer: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    onSecondary: Color(0xFF431407),
    secondaryContainer: Color(0xFF7C2D12),
    onSecondaryContainer: AppColors.secondaryLight,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.backgroundDark,
    onSurfaceVariant: AppColors.textSecondaryDark,
    error: AppColors.error,
    onError: Colors.white,
    outline: AppColors.borderDark,
    shadow: Color(0x40000000),
  );

  // ── Text Theme ────────────────────────────────────────────────────────────
  static TextTheme _textTheme(Brightness brightness) {
    final color = brightness == Brightness.light
        ? AppColors.textPrimaryLight
        : AppColors.textPrimaryDark;
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.nunito(
          fontSize: 32, fontWeight: FontWeight.w800, color: color),
      displayMedium: GoogleFonts.nunito(
          fontSize: 28, fontWeight: FontWeight.w700, color: color),
      headlineLarge: GoogleFonts.nunito(
          fontSize: 24, fontWeight: FontWeight.w700, color: color),
      headlineMedium: GoogleFonts.nunito(
          fontSize: 20, fontWeight: FontWeight.w600, color: color),
      headlineSmall: GoogleFonts.nunito(
          fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleLarge: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w600, color: color),
      titleMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, color: color),
      titleSmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: color),
      bodyLarge:
          GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium:
          GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: color),
      bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: brightness == Brightness.light
              ? AppColors.textSecondaryLight
              : AppColors.textSecondaryDark),
      labelLarge: GoogleFonts.nunito(
          fontSize: 16, fontWeight: FontWeight.w700, color: color),
      labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, color: color),
      labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: brightness == Brightness.light
              ? AppColors.textSecondaryLight
              : AppColors.textSecondaryDark),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  static AppBarTheme _appBarTheme(Brightness brightness) => AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: brightness == Brightness.light
            ? AppColors.backgroundLight
            : AppColors.backgroundDark,
        foregroundColor: brightness == Brightness.light
            ? AppColors.textPrimaryLight
            : AppColors.textPrimaryDark,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: brightness == Brightness.light
              ? AppColors.textPrimaryLight
              : AppColors.textPrimaryDark,
        ),
        iconTheme: IconThemeData(
          color: brightness == Brightness.light
              ? AppColors.textPrimaryLight
              : AppColors.textPrimaryDark,
          size: AppDimensions.iconMd,
        ),
      );

  // ── Card ──────────────────────────────────────────────────────────────────
  static CardThemeData _cardTheme(Brightness brightness) => CardThemeData(
        elevation: 0,
        color: brightness == Brightness.light
            ? AppColors.cardLight
            : AppColors.cardDark,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          side: BorderSide(
            color: brightness == Brightness.light
                ? AppColors.borderLight
                : AppColors.borderDark,
            width: AppDimensions.borderThin,
          ),
        ),
      );

  // ── Elevated Button ───────────────────────────────────────────────────────
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space6,
            vertical: AppDimensions.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      );

  // ── Outlined Button ───────────────────────────────────────────────────────
  static OutlinedButtonThemeData _outlinedButtonTheme(Brightness brightness) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space6,
            vertical: AppDimensions.space3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      );

  // ── Text Button ───────────────────────────────────────────────────────────
  static TextButtonThemeData get _textButtonTheme => TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.space3,
            vertical: AppDimensions.space2,
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      );

  // ── Input Decoration ──────────────────────────────────────────────────────
  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final borderColor = brightness == Brightness.light
        ? AppColors.borderLight
        : AppColors.borderDark;
    final fillColor = brightness == Brightness.light
        ? AppColors.surfaceLight
        : AppColors.cardDark;
    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space4,
        vertical: AppDimensions.space4,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.light
            ? AppColors.textTertiaryLight
            : AppColors.textTertiaryDark,
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      errorStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.error),
    );
  }

  // ── Chip Theme ────────────────────────────────────────────────────────────
  static ChipThemeData _chipTheme(Brightness brightness) => ChipThemeData(
        backgroundColor: brightness == Brightness.light
            ? AppColors.backgroundLight
            : AppColors.cardDark,
        selectedColor: AppColors.primaryMuted,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(
          color: brightness == Brightness.light
              ? AppColors.borderLight
              : AppColors.borderDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space3,
          vertical: AppDimensions.space1,
        ),
      );

  // ── Bottom Navigation Bar ─────────────────────────────────────────────────
  static BottomNavigationBarThemeData _bottomNavTheme(Brightness brightness) =>
      BottomNavigationBarThemeData(
        backgroundColor: brightness == Brightness.light
            ? AppColors.surfaceLight
            : AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: brightness == Brightness.light
            ? AppColors.textTertiaryLight
            : AppColors.textTertiaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle:
            GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400),
      );

  // ── Switch ────────────────────────────────────────────────────────────────
  static SwitchThemeData get _switchTheme => SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.primary;
          return null;
        }),
      );

  // ── Dialog ────────────────────────────────────────────────────────────────
  static DialogThemeData _dialogTheme(Brightness brightness) => DialogThemeData(
        backgroundColor: brightness == Brightness.light
            ? AppColors.surfaceLight
            : AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radius2xl),
        ),
      );

  // ── SnackBar ──────────────────────────────────────────────────────────────
  static SnackBarThemeData get _snackBarTheme => SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1D2E),
        contentTextStyle:
            GoogleFonts.inter(fontSize: 14, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      );

  // ── FAB ───────────────────────────────────────────────────────────────────
  static FloatingActionButtonThemeData get _fabTheme =>
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
      );
}
