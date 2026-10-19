import 'package:flutter/material.dart';

/// SupperSync Design System — Color Palette
///
/// All colors are defined here as constants. No hardcoded color values
/// should appear anywhere else in the codebase.
abstract final class AppColors {
  AppColors._();

  // ── Brand Primary (Forest Green) ───────────────────────────────────────────
  static const Color primary = Color(0xFF22C55E);
  static const Color primaryDark = Color(0xFF16A34A);
  static const Color primaryLight = Color(0xFF4ADE80);
  static const Color primaryMuted = Color(0xFF22C55E26); // 15% opacity

  // ── Brand Secondary (Warm Amber) ───────────────────────────────────────────
  static const Color secondary = Color(0xFFF97316);
  static const Color secondaryDark = Color(0xFFEA580C);
  static const Color secondaryLight = Color(0xFFFB923C);
  static const Color secondaryMuted = Color(0xFFF9731626);

  // ── Semantic Colors ────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successMuted = Color(0xFF10B98120);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningMuted = Color(0xFFF59E0B20);
  static const Color error = Color(0xFFEF4444);
  static const Color errorMuted = Color(0xFFEF444420);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoMuted = Color(0xFF3B82F620);

  // ── Expiry Status ──────────────────────────────────────────────────────────
  static const Color expiryFresh = Color(0xFF22C55E);
  static const Color expirySoon = Color(0xFFF59E0B);  // within 3 days
  static const Color expiryUrgent = Color(0xFFEF4444); // within 1 day / expired

  // ── Light Theme Surfaces ───────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF6F8FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF3F4F6);
  static const Color overlayLight = Color(0x0A000000);

  // ── Dark Theme Surfaces ────────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF1E2430);
  static const Color borderDark = Color(0xFF30363D);
  static const Color dividerDark = Color(0xFF21262D);
  static const Color overlayDark = Color(0x1AFFFFFF);

  // ── Light Theme Text ───────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);
  static const Color textDisabledLight = Color(0xFFD1D5DB);

  // ── Dark Theme Text ────────────────────────────────────────────────────────
  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);
  static const Color textDisabledDark = Color(0xFF374151);

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0D1117), Color(0xFF1A2744)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Category Colors ────────────────────────────────────────────────────────
  static const Color categoryVegetables = Color(0xFF22C55E);
  static const Color categoryFruits = Color(0xFFF97316);
  static const Color categoryDairy = Color(0xFF3B82F6);
  static const Color categoryMeat = Color(0xFFEF4444);
  static const Color categoryGrains = Color(0xFFF59E0B);
  static const Color categorySeasonings = Color(0xFF8B5CF6);
  static const Color categoryBeverages = Color(0xFF06B6D4);
  static const Color categoryOther = Color(0xFF6B7280);

  // ── Overlay & Scrim ────────────────────────────────────────────────────────
  static const Color scrim = Color(0x80000000);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
