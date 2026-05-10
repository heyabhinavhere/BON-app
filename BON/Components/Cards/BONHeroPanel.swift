import SwiftUI

struct BONHeroPanel<Content: View>: View {
    var width: CGFloat = 374
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: BONRadius.hero, style: .continuous)
                .fill(BONColor.surfacePrimary)
                .bonHeroGlow()

            content
        }
        .frame(width: width, height: 407)
    }
}
