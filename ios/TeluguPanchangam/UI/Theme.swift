import SwiftUI

/// Monochrome palette. No hue anywhere — hierarchy comes from value,
/// weight and spacing. The light theme is a white page with black ink;
/// the dark theme is its true inverse on a near-black page.
///
/// Names describe roles, not values: `strong` is the darkest ink on the
/// page (black in light mode, white in dark mode), `page` the background.
struct InkColors {
    let strong: Color
    let body: Color
    let secondary: Color
    let faint: Color
    let disabled: Color
    let line: Color
    let lineFaint: Color
    let wash: Color
    let page: Color
    let isDark: Bool

    static let light = InkColors(
        strong: Color(hex: 0x000000),
        body: Color(hex: 0x1A1A1A),
        secondary: Color(hex: 0x5F5F5F),
        faint: Color(hex: 0x9A9A9A),
        disabled: Color(hex: 0xC2C2C2),
        line: Color(hex: 0xE3E3E3),
        lineFaint: Color(hex: 0xF0F0F0),
        wash: Color(hex: 0xF5F5F5),
        page: Color(hex: 0xFFFFFF),
        isDark: false
    )

    static let dark = InkColors(
        strong: Color(hex: 0xFFFFFF),
        body: Color(hex: 0xE8E8E8),
        secondary: Color(hex: 0xA6A6A6),
        faint: Color(hex: 0x707070),
        disabled: Color(hex: 0x4A4A4A),
        line: Color(hex: 0x2C2C2C),
        lineFaint: Color(hex: 0x1F1F1F),
        wash: Color(hex: 0x181818),
        page: Color(hex: 0x0A0A0A),
        isDark: true
    )

    /// Ink on an inverted card (white on black in light mode).
    var onCard: Color { isDark ? strong : page }
    var onCardSoft: Color { isDark ? secondary : disabled }
    var cardFill: Color { isDark ? wash : strong }
    var cardRim: Color { isDark ? line : strong }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: 1.0
        )
    }
}

private struct InkKey: EnvironmentKey {
    static let defaultValue = InkColors.light
}

extension EnvironmentValues {
    var ink: InkColors {
        get { self[InkKey.self] }
        set { self[InkKey.self] = newValue }
    }
}

/// Reads the effective colour scheme and provides the matching palette.
struct InkProvider<Content: View>: View {
    @Environment(\.colorScheme) private var scheme
    @ViewBuilder let content: () -> Content

    var body: some View {
        content().environment(\.ink, scheme == .dark ? InkColors.dark : InkColors.light)
    }
}

/// Type scale, matching the Android app's Material 3 typography.
enum AppFont {
    static let displayLarge = Font.system(size: 44, weight: .light)
    static let displayMedium = Font.system(size: 34, weight: .regular)
    static let displaySmall = Font.system(size: 26, weight: .semibold)
    static let headlineMedium = Font.system(size: 24, weight: .semibold)
    static let headlineSmall = Font.system(size: 19, weight: .semibold)
    static let titleLarge = Font.system(size: 17, weight: .semibold)
    static let titleMedium = Font.system(size: 15, weight: .semibold)
    static let titleSmall = Font.system(size: 13, weight: .medium)
    static let bodyLarge = Font.system(size: 16)
    static let bodyMedium = Font.system(size: 14)
    static let bodySmall = Font.system(size: 12.5)
    static let labelLarge = Font.system(size: 13.5, weight: .semibold)
    static let labelMedium = Font.system(size: 12, weight: .semibold)
    static let labelSmall = Font.system(size: 10.5, weight: .semibold)
}

enum ThemeMode: String, CaseIterable {
    case system = "SYSTEM"
    case light = "LIGHT"
    case dark = "DARK"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
