import SwiftUI

struct BONTopActionBar: View {
    var width: CGFloat = BONSpacing.contentWidth
    var modeAction: () -> Void = {}

    var body: some View {
        HStack {
            BONIconButton(imageAsset: "topProfile", accessibilityLabel: "Profile")

            Spacer()

            BONModePill(title: "AI mode", action: modeAction)

            Spacer()

            BONIconButton(imageAsset: "topBell", accessibilityLabel: "Notifications")
        }
        .frame(width: width, height: 40)
    }
}
