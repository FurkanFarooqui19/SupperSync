import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// SupperSync Design System — Typography
///
/// Uses Nunito for display/headings (friendly, rounded)
/// Uses Inter for body text (clean, readable)
abstract final class AppTextStyles {
  AppTextStyles._();

  // ── Display ───────────────────────────────────────────────────────────────
  static TextStyle display({Color? color}) => GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.2,
        color: color,
      );

  // ── Headings ──────────────────────────────────────────────────────────────
  static TextStyle h1({Color? color}) => GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.3,
        color: color,
      );

  static TextStyle h2({Color? color}) => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.35,
        color: color,
      );

  static TextStyle h3({Color? color}) => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.4,
        color: color,
      );

  static TextStyle h4({Color? color}) => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle bodyLg({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color,
      );

  static TextStyle body({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color,
      );

  static TextStyle bodySm({Color? color}) => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  // ── Label & Caption ───────────────────────────────────────────────────────
  static TextStyle label({Color? color}) => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle labelSm({Color? color}) => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: color,
      );

  static TextStyle caption({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.4,
        color: color,
      );

  // ── Button ────────────────────────────────────────────────────────────────
  static TextStyle button({Color? color}) => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
        height: 1.2,
        color: color,
      );

  static TextStyle buttonSm({Color? color}) => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.2,
        color: color,
      );

  // ── Overline ──────────────────────────────────────────────────────────────
  static TextStyle overline({Color? color}) => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.0,
        height: 1.4,
        color: color,
      );

  // ── Impact / Stats ────────────────────────────────────────────────────────
  static TextStyle stat({Color? color}) => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        height: 1.1,
        color: color ?? AppColors.primary,
      );

  static TextStyle statSm({Color? color}) => GoogleFonts.nunito(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: color ?? AppColors.primary,
      );
}
