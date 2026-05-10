import Foundation

struct AppEnvironment: Equatable {
    let figmaFileURL: URL
    let figmaFileKey: String
    let figmaStartingNodeID: String
    let primaryDeviceClass: String
    let minimumOSVersion: String

    static let current = AppEnvironment(
        figmaFileURL: URL(string: "https://www.figma.com/design/SMVZkasMIx4TzoOMBxqSs9/O2-Final?node-id=1-627&m=dev")!,
        figmaFileKey: "SMVZkasMIx4TzoOMBxqSs9",
        figmaStartingNodeID: "1-627",
        primaryDeviceClass: "iPhone Pro",
        minimumOSVersion: "18.0"
    )
}
