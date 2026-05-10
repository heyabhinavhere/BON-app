import CoreText
import Foundation

enum BONFontRegistrar {
    private static let fontSubdirectory = "Fonts"
    private static let supportedExtensions = ["ttf", "otf"]
    private static var didRegister = false

    static func registerFonts() {
        guard !didRegister else { return }
        didRegister = true

        supportedExtensions.forEach { fileExtension in
            registerFonts(withExtension: fileExtension)
        }
    }

    private static func registerFonts(withExtension fileExtension: String) {
        guard let urls = Bundle.main.urls(
            forResourcesWithExtension: fileExtension,
            subdirectory: fontSubdirectory
        ) else {
            return
        }

        urls
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
            .forEach { url in
                _ = CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
    }
}
