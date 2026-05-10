import SwiftUI

@main
struct BONApp: App {
    @StateObject private var router = AppRouter()

    init() {
        BONFontRegistrar.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            RootView(environment: .current)
                .environmentObject(router)
        }
    }
}
