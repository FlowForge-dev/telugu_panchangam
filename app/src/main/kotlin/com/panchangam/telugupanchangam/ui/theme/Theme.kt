package com.panchangam.telugupanchangam.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

/**
 * Monochrome palette. Every background is white; all text and iconography
 * is black or a gray step of it. No hue anywhere — hierarchy comes from
 * value, weight and spacing.
 */
object Ink {
    val Black = Color(0xFF000000)
    val Body = Color(0xFF1A1A1A)
    val Secondary = Color(0xFF616161)
    val Faint = Color(0xFF9E9E9E)
    val Disabled = Color(0xFFBDBDBD)
    val Line = Color(0xFFE0E0E0)
    val LineFaint = Color(0xFFEEEEEE)
    val Wash = Color(0xFFF5F5F5)
    val White = Color(0xFFFFFFFF)
}

private val MonochromeScheme = lightColorScheme(
    primary = Ink.Black,
    onPrimary = Ink.White,
    primaryContainer = Ink.Wash,
    onPrimaryContainer = Ink.Black,
    secondary = Ink.Secondary,
    onSecondary = Ink.White,
    secondaryContainer = Ink.Wash,
    onSecondaryContainer = Ink.Black,
    tertiary = Ink.Secondary,
    onTertiary = Ink.White,
    tertiaryContainer = Ink.Wash,
    onTertiaryContainer = Ink.Black,
    error = Ink.Black,
    onError = Ink.White,
    errorContainer = Ink.Wash,
    onErrorContainer = Ink.Black,
    background = Ink.White,
    onBackground = Ink.Body,
    surface = Ink.White,
    onSurface = Ink.Body,
    surfaceVariant = Ink.White,
    onSurfaceVariant = Ink.Secondary,
    surfaceContainerLowest = Ink.White,
    surfaceContainerLow = Ink.White,
    surfaceContainer = Ink.White,
    surfaceContainerHigh = Ink.Wash,
    surfaceContainerHighest = Ink.Wash,
    outline = Ink.Disabled,
    outlineVariant = Ink.Line,
    scrim = Ink.Black,
    inverseSurface = Ink.Black,
    inverseOnSurface = Ink.White,
    surfaceTint = Color.Transparent
)

private val AppTypography = Typography(
    displaySmall = TextStyle(fontSize = 26.sp, lineHeight = 32.sp, fontWeight = FontWeight.SemiBold, color = Ink.Black),
    headlineMedium = TextStyle(fontSize = 22.sp, lineHeight = 28.sp, fontWeight = FontWeight.SemiBold, color = Ink.Black),
    headlineSmall = TextStyle(fontSize = 19.sp, lineHeight = 25.sp, fontWeight = FontWeight.SemiBold, color = Ink.Black),
    titleLarge = TextStyle(fontSize = 17.sp, lineHeight = 23.sp, fontWeight = FontWeight.SemiBold, color = Ink.Black),
    titleMedium = TextStyle(fontSize = 15.sp, lineHeight = 21.sp, fontWeight = FontWeight.SemiBold, color = Ink.Black),
    titleSmall = TextStyle(fontSize = 13.sp, lineHeight = 18.sp, fontWeight = FontWeight.SemiBold, color = Ink.Secondary),
    bodyLarge = TextStyle(fontSize = 16.sp, lineHeight = 24.sp, color = Ink.Body),
    bodyMedium = TextStyle(fontSize = 14.sp, lineHeight = 21.sp, color = Ink.Body),
    bodySmall = TextStyle(fontSize = 12.5.sp, lineHeight = 18.sp, color = Ink.Secondary),
    labelLarge = TextStyle(fontSize = 13.5.sp, fontWeight = FontWeight.SemiBold, color = Ink.Black),
    labelMedium = TextStyle(fontSize = 12.sp, fontWeight = FontWeight.SemiBold, color = Ink.Secondary),
    labelSmall = TextStyle(fontSize = 10.5.sp, fontWeight = FontWeight.SemiBold, color = Ink.Secondary)
)

/**
 * The app is deliberately light-only: a monochrome design whose whole
 * premise is a white page would not survive being inverted, so the
 * system dark setting is intentionally ignored here.
 */
@Composable
fun TeluguPanchangamTheme(
    @Suppress("UNUSED_PARAMETER") darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    MaterialTheme(
        colorScheme = MonochromeScheme,
        typography = AppTypography,
        content = content
    )
}
