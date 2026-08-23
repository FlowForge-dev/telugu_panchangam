import 'package:flutter/material.dart';

/// Restrained warm-neutral palette with saffron / maroon / gold accents.
/// Inspired by manuscript paper, temple stone and turmeric-dyed thread —
/// deliberately avoids "stereotypical gold everywhere" saturation.
class AppColors {
  AppColors._();

  // ---- Light theme -------------------------------------------------
  static const Color lightBackground = Color(0xFFFBF6EE);
  static const Color lightSurface = Color(0xFFFFFDF8);
  static const Color lightSurfaceAlt = Color(0xFFF3E9D8);
  static const Color lightSurfaceSunken = Color(0xFFEDE1CB);
  static const Color lightOutline = Color(0xFFDCCBAE);
  static const Color lightOutlineFaint = Color(0xFFEAE0CD);

  static const Color maroon = Color(0xFF7C2B2B);
  static const Color maroonDeep = Color(0xFF5C1F1F);
  static const Color maroonSoft = Color(0xFFF4E1DD);

  static const Color saffron = Color(0xFFC17A2C);
  static const Color saffronSoft = Color(0xFFF3E1C4);
  static const Color gold = Color(0xFFB08A3E);

  static const Color bronze = Color(0xFF5A6B4E);
  static const Color bronzeSoft = Color(0xFFE6EADB);

  static const Color lightTextPrimary = Color(0xFF2A211A);
  static const Color lightTextSecondary = Color(0xFF6B5D4F);
  static const Color lightTextFaint = Color(0xFF9B8C78);

  static const Color success = Color(0xFF4B7A4E);
  static const Color error = Color(0xFFA23B3B);

  // ---- Dark theme ----------------------------------------------------
  static const Color darkBackground = Color(0xFF15110D);
  static const Color darkSurface = Color(0xFF1E1812);
  static const Color darkSurfaceAlt = Color(0xFF261E16);
  static const Color darkSurfaceSunken = Color(0xFF0F0C09);
  static const Color darkOutline = Color(0xFF3A2F24);
  static const Color darkOutlineFaint = Color(0xFF2A2219);

  static const Color darkGold = Color(0xFFD8A85B);
  static const Color darkMaroon = Color(0xFFC97C7C);
  static const Color darkMaroonSoft = Color(0xFF35211E);
  static const Color darkSaffronSoft = Color(0xFF3A2C18);
  static const Color darkBronzeSoft = Color(0xFF232A1E);

  static const Color darkTextPrimary = Color(0xFFEFE7D8);
  static const Color darkTextSecondary = Color(0xFFBBAD97);
  static const Color darkTextFaint = Color(0xFF7E7160);

  // ---- Semantic accents used across both themes for chart / rashi ----
  static const List<Color> rashiAccents = [
    Color(0xFFB5473C),
    Color(0xFFBC7A2B),
    Color(0xFFB79A2E),
    Color(0xFF6E8B4F),
    Color(0xFF3F8B7A),
    Color(0xFF3E7EA6),
    Color(0xFF5C6BB0),
    Color(0xFF8258A8),
    Color(0xFFAA4C87),
    Color(0xFF9C4F5C),
    Color(0xFF3F7A6E),
    Color(0xFF7A6A3F),
  ];
}
