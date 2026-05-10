import SwiftUI

struct BONColorRole {
    let light: Color
    let dark: Color

    func color(for scheme: ColorScheme) -> Color {
        scheme == .dark ? dark : light
    }
}

enum BONColor {
    private static func hex(_ value: UInt32) -> Color {
        Color(
            red: Double((value >> 16) & 0xFF) / 255.0,
            green: Double((value >> 8) & 0xFF) / 255.0,
            blue: Double(value & 0xFF) / 255.0
        )
    }

    static let lime50 = hex(0xF7FFD9)
    static let lime100 = hex(0xECFFAA)
    static let lime200 = hex(0xDBFF6F)
    static let lime300 = hex(0xC5FF33)
    static let lime400 = hex(0xB5FF14)
    static let lime500 = hex(0xA1FF00)
    static let lime600 = hex(0x7BC700)
    static let lime700 = hex(0x5C9400)
    static let lime800 = hex(0x3F6500)
    static let lime900 = hex(0x1F3300)

    static let backgroundPrimaryRole = BONColorRole(
        light: Color.white,
        dark: Color(red: 0.043, green: 0.043, blue: 0.047)
    )
    static let surfacePrimaryRole = BONColorRole(
        light: Color.white,
        dark: Color(red: 0.074, green: 0.074, blue: 0.082)
    )
    static let surfaceElevatedRole = BONColorRole(
        light: Color.white,
        dark: Color(red: 0.102, green: 0.102, blue: 0.114)
    )
    static let textPrimaryRole = BONColorRole(
        light: Color.black,
        dark: Color.white
    )
    static let textSecondaryRole = BONColorRole(
        light: Color(red: 0.2, green: 0.2, blue: 0.2).opacity(0.64),
        dark: Color.white.opacity(0.68)
    )
    static let textTertiaryRole = BONColorRole(
        light: Color(red: 0.541, green: 0.541, blue: 0.541),
        dark: Color.white.opacity(0.48)
    )
    static let borderSubtleRole = BONColorRole(
        light: Color(red: 0.933, green: 0.933, blue: 0.933),
        dark: Color.white.opacity(0.12)
    )
    static let dividerRole = BONColorRole(
        light: Color(red: 0.922, green: 0.922, blue: 0.922),
        dark: Color.white.opacity(0.10)
    )
    static let accentLimeRole = BONColorRole(
        light: lime500,
        dark: lime500
    )
    static let glassDarkRole = BONColorRole(
        light: Color.black.opacity(0.88),
        dark: Color.white.opacity(0.16)
    )
    static let glassLightRole = BONColorRole(
        light: Color.white.opacity(0.10),
        dark: Color.white.opacity(0.08)
    )
    static let successRole = BONColorRole(
        light: Color(red: 0.055, green: 0.471, blue: 0.302),
        dark: Color(red: 0.302, green: 0.820, blue: 0.553)
    )
    static let warningRole = BONColorRole(
        light: Color(red: 0.757, green: 0.412, blue: 0.071),
        dark: Color(red: 1.0, green: 0.702, blue: 0.278)
    )
    static let errorRole = BONColorRole(
        light: Color(red: 0.816, green: 0.165, blue: 0.165),
        dark: Color(red: 1.0, green: 0.455, blue: 0.455)
    )

    static let backgroundPrimary = backgroundPrimaryRole.light
    static let surfacePrimary = surfacePrimaryRole.light
    static let surfaceElevated = surfaceElevatedRole.light
    static let textPrimary = textPrimaryRole.light
    static let textSecondary = textSecondaryRole.light
    static let textTertiary = textTertiaryRole.light
    static let textOnDark = Color.white
    static let borderSubtle = borderSubtleRole.light
    static let divider = dividerRole.light
    static let accentLime = accentLimeRole.light
    static let limeGlow = lime200.opacity(0.80)
    static let glassDark = glassDarkRole.light
    static let glassLight = glassLightRole.light
    static let navInactive = Color(red: 0.733, green: 0.733, blue: 0.733)
    static let success = successRole.light
    static let warning = warningRole.light
    static let error = errorRole.light

    // Compatibility aliases for the current scaffold.
    static let canvas = backgroundPrimary
    static let surface = surfacePrimary
    static let elevatedSurface = surfaceElevated
    static let ink = textPrimary
    static let secondaryInk = textSecondary
    static let tertiaryInk = textTertiary
    static let line = borderSubtle
    static let brand = glassDark
    static let brandPressed = Color.black.opacity(0.96)
    static let danger = error
}
