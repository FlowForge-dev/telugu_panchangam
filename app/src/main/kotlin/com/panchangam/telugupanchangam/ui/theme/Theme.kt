package com.panchangam.telugupanchangam.ui.theme

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.ReadOnlyComposable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp

/**
 * Monochrome palette. No hue anywhere — hierarchy comes from value,
 * weight and spacing. The light theme is a white page with black ink;
 * the dark theme is its true inverse on a near-black page.
 *
 * Names describe roles, not values: [strong] is the darkest ink on the
 * page (black in light mode, white in dark mode), [page] the background.
 */
@Immutable
data class InkColors(
    val strong: Color,
    val body: Color,
    val secondary: Color,
    val faint: Color,
    val disabled: Color,
    val line: Color,
    val lineFaint: Color,
    val wash: Color,
    val page: Color,
    val isDark: Boolean
)

private val LightInk = InkColors(
    strong = Color(0xFF000000),
    body = Color(0xFF1A1A1A),
    secondary = Color(0xFF5F5F5F),
    faint = Color(0xFF9A9A9A),
    disabled = Color(0xFFC2C2C2),
    line = Color(0xFFE3E3E3),
    lineFaint = Color(0xFFF0F0F0),
    wash = Color(0xFFF5F5F5),
    page = Color(0xFFFFFFFF),
    isDark = false
)

private val DarkInk = InkColors(
    strong = Color(0xFFFFFFFF),
    body = Color(0xFFE8E8E8),
    secondary = Color(0xFFA6A6A6),
    faint = Color(0xFF707070),
    disabled = Color(0xFF4A4A4A),
    line = Color(0xFF2C2C2C),
    lineFaint = Color(0xFF1F1F1F),
    wash = Color(0xFF181818),
    page = Color(0xFF0A0A0A),
    isDark = true
)

val LocalInk = staticCompositionLocalOf { LightInk }

/** The current monochrome palette. */
object Ink {
    val current: InkColors
        @Composable @ReadOnlyComposable get() = LocalInk.current
}

private fun schemeFor(ink: InkColors): ColorScheme {
    val base = if (ink.isDark) darkColorScheme() else lightColorScheme()
    return base.copy(
        primary = ink.strong,
        onPrimary = ink.page,
        primaryContainer = ink.wash,
        onPrimaryContainer = ink.strong,
        secondary = ink.secondary,
        onSecondary = ink.page,
        secondaryContainer = ink.wash,
        onSecondaryContainer = ink.strong,
        tertiary = ink.secondary,
        onTertiary = ink.page,
        tertiaryContainer = ink.wash,
        onTertiaryContainer = ink.strong,
        error = ink.strong,
        onError = ink.page,
        errorContainer = ink.wash,
        onErrorContainer = ink.strong,
        background = ink.page,
        onBackground = ink.body,
        surface = ink.page,
        onSurface = ink.body,
        surfaceVariant = ink.wash,
        onSurfaceVariant = ink.secondary,
        surfaceContainerLowest = ink.page,
        surfaceContainerLow = ink.page,
        surfaceContainer = ink.page,
        surfaceContainerHigh = ink.wash,
        surfaceContainerHighest = ink.wash,
        surfaceBright = ink.page,
        surfaceDim = ink.wash,
        outline = ink.disabled,
        outlineVariant = ink.line,
        scrim = Color.Black,
        inverseSurface = ink.strong,
        inverseOnSurface = ink.page,
        inversePrimary = ink.page,
        surfaceTint = Color.Transparent
    )
}

private val AppTypography = Typography(
    displayLarge = TextStyle(fontSize = 44.sp, lineHeight = 50.sp, fontWeight = FontWeight.Light, letterSpacing = (-1).sp),
    displayMedium = TextStyle(fontSize = 34.sp, lineHeight = 42.sp, fontWeight = FontWeight.Normal, letterSpacing = (-0.5).sp),
    displaySmall = TextStyle(fontSize = 26.sp, lineHeight = 34.sp, fontWeight = FontWeight.SemiBold),
    headlineMedium = TextStyle(fontSize = 24.sp, lineHeight = 32.sp, fontWeight = FontWeight.SemiBold, letterSpacing = (-0.3).sp),
    headlineSmall = TextStyle(fontSize = 19.sp, lineHeight = 26.sp, fontWeight = FontWeight.SemiBold),
    titleLarge = TextStyle(fontSize = 17.sp, lineHeight = 24.sp, fontWeight = FontWeight.SemiBold),
    titleMedium = TextStyle(fontSize = 15.sp, lineHeight = 22.sp, fontWeight = FontWeight.SemiBold),
    titleSmall = TextStyle(fontSize = 13.sp, lineHeight = 19.sp, fontWeight = FontWeight.Medium),
    bodyLarge = TextStyle(fontSize = 16.sp, lineHeight = 25.sp),
    bodyMedium = TextStyle(fontSize = 14.sp, lineHeight = 21.sp),
    bodySmall = TextStyle(fontSize = 12.5.sp, lineHeight = 18.sp),
    labelLarge = TextStyle(fontSize = 13.5.sp, lineHeight = 18.sp, fontWeight = FontWeight.SemiBold),
    labelMedium = TextStyle(fontSize = 12.sp, lineHeight = 16.sp, fontWeight = FontWeight.SemiBold, letterSpacing = 0.2.sp),
    labelSmall = TextStyle(fontSize = 10.5.sp, lineHeight = 14.sp, fontWeight = FontWeight.SemiBold, letterSpacing = 0.4.sp)
)

enum class ThemeMode { SYSTEM, LIGHT, DARK }

@Composable
fun TeluguPanchangamTheme(
    mode: ThemeMode = ThemeMode.SYSTEM,
    content: @Composable () -> Unit
) {
    val dark = when (mode) {
        ThemeMode.SYSTEM -> isSystemInDarkTheme()
        ThemeMode.LIGHT -> false
        ThemeMode.DARK -> true
    }
    val ink = if (dark) DarkInk else LightInk
    CompositionLocalProvider(LocalInk provides ink) {
        MaterialTheme(
            colorScheme = schemeFor(ink),
            typography = AppTypography,
            content = content
        )
    }
}
