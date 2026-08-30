import 'package:flutter/material.dart';

/// Monochrome white/black/gray palette. No hue anywhere — hierarchy and
/// state are communicated through value (light/dark), weight and
/// spacing instead of color.
class AppColors {
  AppColors._();

  // ---- Light theme -------------------------------------------------
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF5F5F5);
  static const Color lightSurfaceSunken = Color(0xFFEEEEEE);
  static const Color lightOutline = Color(0xFFBDBDBD);
  static const Color lightOutlineFaint = Color(0xFFE0E0E0);

  static const Color maroon = Color(0xFF000000);
  static const Color maroonDeep = Color(0xFF000000);
  static const Color maroonSoft = Color(0xFFEEEEEE);

  static const Color saffron = Color(0xFF424242);
  static const Color saffronSoft = Color(0xFFEDEDED);
  static const Color gold = Color(0xFF616161);

  static const Color bronze = Color(0xFF757575);
  static const Color bronzeSoft = Color(0xFFF0F0F0);

  static const Color lightTextPrimary = Color(0xFF000000);
  static const Color lightTextSecondary = Color(0xFF616161);
  static const Color lightTextFaint = Color(0xFF9E9E9E);

  static const Color success = Color(0xFF212121);
  static const Color error = Color(0xFF212121);

  // ---- Dark theme ----------------------------------------------------
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF121212);
  static const Color darkSurfaceAlt = Color(0xFF1E1E1E);
  static const Color darkSurfaceSunken = Color(0xFF000000);
  static const Color darkOutline = Color(0xFF616161);
  static const Color darkOutlineFaint = Color(0xFF424242);

  static const Color darkGold = Color(0xFFFFFFFF);
  static const Color darkMaroon = Color(0xFFBDBDBD);
  static const Color darkMaroonSoft = Color(0xFF2A2A2A);
  static const Color darkSaffronSoft = Color(0xFF2A2A2A);
  static const Color darkBronzeSoft = Color(0xFF2A2A2A);

  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFBDBDBD);
  static const Color darkTextFaint = Color(0xFF757575);

  // ---- Grayscale accents used for chart/rashi differentiation --------
  static const List<Color> rashiAccents = [
    Color(0xFF1A1A1A),
    Color(0xFF2B2B2B),
    Color(0xFF3C3C3C),
    Color(0xFF4D4D4D),
    Color(0xFF5E5E5E),
    Color(0xFF6F6F6F),
    Color(0xFF808080),
    Color(0xFF919191),
    Color(0xFF3C3C3C),
    Color(0xFF5E5E5E),
    Color(0xFF2B2B2B),
    Color(0xFF6F6F6F),
  ];
}
