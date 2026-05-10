import SwiftUI

enum BONFontFamily {
    static let zalandoSansExtraLight = "ZalandoSans-ExtraLight"
    static let zalandoSansLight = "ZalandoSans-Light"
    static let zalandoSansRegular = "ZalandoSans-Regular"
    static let zalandoSansMedium = "ZalandoSans-Medium"
    static let zalandoSansSemiBold = "ZalandoSans-SemiBold"
    static let zalandoSansBold = "ZalandoSans-Bold"
    static let geistPixelGrid = "GeistPixel-Grid"
    static let geistPixelSquare = "GeistPixel-Square"
    static let geistPixelCircle = "GeistPixel-Circle"
    static let geistPixelTriangle = "GeistPixel-Triangle"
    static let geistPixelLine = "GeistPixel-Line"
    static let instrumentSerifItalic = "Instrument Serif Italic"

    static func zalandoSans(for weight: Font.Weight) -> String {
        if weight == .bold {
            return zalandoSansBold
        }

        if weight == .semibold {
            return zalandoSansSemiBold
        }

        if weight == .medium {
            return zalandoSansMedium
        }

        if weight == .light {
            return zalandoSansLight
        }

        if weight == .ultraLight || weight == .thin {
            return zalandoSansExtraLight
        }

        return zalandoSansRegular
    }
}

struct BONTextRole {
    let font: Font
    let pointSize: CGFloat
    let lineHeight: CGFloat
    let tracking: CGFloat
}

enum BONGeistPixelVariant {
    case circle
    case grid
    case line
    case square
    case triangle

    var postScriptName: String {
        switch self {
        case .circle:
            return BONFontFamily.geistPixelCircle
        case .grid:
            return BONFontFamily.geistPixelGrid
        case .line:
            return BONFontFamily.geistPixelLine
        case .square:
            return BONFontFamily.geistPixelSquare
        case .triangle:
            return BONFontFamily.geistPixelTriangle
        }
    }
}

enum BONTypography {
    static let screenTitleRole = BONTextRole(
        font: zalando(size: 24, weight: .regular),
        pointSize: 24,
        lineHeight: 29,
        tracking: -0.48
    )
    static let sectionTitleRole = BONTextRole(
        font: zalando(size: 14, weight: .regular),
        pointSize: 14,
        lineHeight: 17,
        tracking: -0.14
    )
    static let bodyRole = BONTextRole(
        font: zalando(size: 16, weight: .regular),
        pointSize: 16,
        lineHeight: 24,
        tracking: 0
    )
    static let captionRole = BONTextRole(
        font: zalando(size: 12, weight: .regular),
        pointSize: 12,
        lineHeight: 15,
        tracking: -0.12
    )
    static let navLabelRole = BONTextRole(
        font: zalando(size: 10, weight: .light),
        pointSize: 10,
        lineHeight: 12,
        tracking: 0.10
    )
    static let chipRole = BONTextRole(
        font: zalando(size: 14, weight: .regular),
        pointSize: 14,
        lineHeight: 20,
        tracking: -0.14
    )
    static let ctaRole = BONTextRole(
        font: zalando(size: 14, weight: .regular),
        pointSize: 14,
        lineHeight: 17,
        tracking: -0.14
    )
    static let numericDisplayRole = BONTextRole(
        font: geistPixel(size: 48),
        pointSize: 48,
        lineHeight: 56,
        tracking: -0.96
    )
    static let numericCompactRole = BONTextRole(
        font: geistPixel(size: 40),
        pointSize: 40,
        lineHeight: 48,
        tracking: -0.80
    )

    static let screenTitle = screenTitleRole.font
    static let sectionTitle = sectionTitleRole.font
    static let body = bodyRole.font
    static let caption = captionRole.font
    static let navLabel = navLabelRole.font
    static let chip = chipRole.font
    static let cta = ctaRole.font
    static let numericDisplay = numericDisplayRole.font
    static let numericCompact = numericCompactRole.font

    // Compatibility aliases for the current scaffold.
    static let display = zalando(size: 34, weight: .bold)
    static let title1 = zalando(size: 28, weight: .bold)
    static let title2 = screenTitle
    static let headline = zalando(size: 17, weight: .semibold)
    static let callout = zalando(size: 16, weight: .regular)
    static let subheadline = zalando(size: 15, weight: .regular)
    static let footnote = zalando(size: 13, weight: .regular)

    static func zalando(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.custom(BONFontFamily.zalandoSans(for: weight), size: size)
    }

    static func geistPixel(size: CGFloat, variant: BONGeistPixelVariant = .grid) -> Font {
        Font.custom(variant.postScriptName, size: size)
    }

    static func instrumentSerifItalic(size: CGFloat) -> Font {
        Font.custom(BONFontFamily.instrumentSerifItalic, size: size)
    }
}

extension Text {
    func bonTextStyle(_ role: BONTextRole) -> some View {
        self
            .font(role.font)
            .tracking(role.tracking)
            .lineSpacing(max(0, role.lineHeight - role.pointSize))
    }
}
