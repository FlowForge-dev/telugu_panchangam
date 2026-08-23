import 'package:flutter/material.dart';

/// Typography scale. Headlines use the platform serif fallback for a
/// restrained "manuscript" feel; body/UI text stays on the default
/// sans-serif for legibility, including for longer Telugu strings.
///
/// Font sizes are intentionally generous and weights restrained so the
/// scale still reads well under large accessibility text-scale factors.
class AppTextStyles {
  AppTextStyles._();

  static const String _serif = 'serif';

  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: _serif,
        fontSize: 40,
        height: 1.15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primary,
      ),
      displayMedium: TextStyle(
        fontFamily: _serif,
        fontSize: 32,
        height: 1.18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: primary,
      ),
      displaySmall: TextStyle(
        fontFamily: _serif,
        fontSize: 26,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: _serif,
        fontSize: 22,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      headlineSmall: TextStyle(
        fontFamily: _serif,
        fontSize: 19,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontSize: 13,
        height: 1.35,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: secondary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodySmall: TextStyle(
        fontSize: 12.5,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontSize: 13.5,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontSize: 10.5,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: secondary,
      ),
    );
  }
}

/// A dedicated style for Telugu-script labels, kept slightly larger and
/// with looser line-height since conjunct consonants need more vertical
/// breathing room than Latin text at the same nominal size.
TextStyle teluguLabelStyle(BuildContext context, {Color? color, double size = 15, FontWeight weight = FontWeight.w500}) {
  return TextStyle(
    fontSize: size,
    height: 1.6,
    fontWeight: weight,
    color: color ?? Theme.of(context).colorScheme.onSurface,
  );
}
