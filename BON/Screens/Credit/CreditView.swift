import SwiftUI

struct CreditView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedLiability: CreditLiabilityKind?
    @State private var showsOfferDetails: Bool
    @State private var showsAccountPicker: Bool

    let onHome: () -> Void
    let onOpenAI: () -> Void

    init(
        onHome: @escaping () -> Void = {},
        onOpenAI: @escaping () -> Void = {}
    ) {
        self.onHome = onHome
        self.onOpenAI = onOpenAI
        _selectedLiability = State(initialValue: CreditLaunch.initialLiability)
        _showsOfferDetails = State(initialValue: CreditLaunch.initialSheet == "offer-details")
        _showsAccountPicker = State(initialValue: CreditLaunch.initialSheet == "account-picker")
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = CreditMetrics(size: proxy.size, safeArea: proxy.safeAreaInsets)

            ZStack {
                CreditMainScreen(
                    metrics: metrics,
                    onHome: onHome,
                    onOpenAI: onOpenAI,
                    onShowOfferDetails: { showsOfferDetails = true },
                    onSelectLiability: { liability in
                        withAnimation(screenAnimation) {
                            selectedLiability = liability
                        }
                    }
                )

                if let selectedLiability {
                    CreditLiabilityDetailScreen(
                        metrics: metrics,
                        kind: selectedLiability,
                        showsAccountPicker: $showsAccountPicker,
                        onBack: {
                            withAnimation(screenAnimation) {
                                self.selectedLiability = nil
                            }
                        },
                        onOpenAI: onOpenAI
                    )
                    .transition(reduceMotion ? .opacity : .move(edge: .trailing).combined(with: .opacity))
                    .zIndex(3)
                }

                if showsOfferDetails {
                    CreditModalScrim(opacity: 0.64) {
                        showsOfferDetails = false
                    }
                    .zIndex(20)

                    VStack {
                        Spacer(minLength: 0)
                        CreditOfferDetailsSheet {
                            showsOfferDetails = false
                        }
                        .frame(width: min(390, metrics.screenWidth), height: min(850, metrics.screenHeight - 24), alignment: .top)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                    .ignoresSafeArea()
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                    .zIndex(21)
                }

                if showsAccountPicker {
                    CreditModalScrim(opacity: 0.30) {
                        showsAccountPicker = false
                    }
                    .zIndex(22)

                    VStack {
                        Spacer(minLength: 0)
                        CreditAccountPickerSheet(
                            onSelect: { liability in
                                showsAccountPicker = false
                                withAnimation(screenAnimation) {
                                    selectedLiability = liability
                                }
                            },
                            onClose: {
                                showsAccountPicker = false
                            }
                        )
                        .frame(width: min(390, metrics.screenWidth), height: 522, alignment: .top)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                    .ignoresSafeArea()
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                    .zIndex(23)
                }
            }
            .frame(width: metrics.screenWidth, height: metrics.screenHeight)
            .background(Color.white)
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var screenAnimation: Animation {
        reduceMotion ? BONMotion.reducedMotionFallback : .timingCurve(0.24, 0.0, 0.14, 1.0, duration: 0.46)
    }
}

private enum CreditLaunch {
    static let initialLiability: CreditLiabilityKind? = {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-BONCreditState"),
              arguments.indices.contains(index + 1) else {
            return nil
        }

        return CreditLiabilityKind(rawValue: arguments[index + 1].lowercased())
    }()

    static let initialSheet: String? = {
        let arguments = ProcessInfo.processInfo.arguments
        guard let index = arguments.firstIndex(of: "-BONCreditSheet"),
              arguments.indices.contains(index + 1) else {
            return nil
        }

        return arguments[index + 1].lowercased()
    }()
}

private struct CreditMetrics {
    let screenWidth: CGFloat
    let screenHeight: CGFloat
    let safeBottom: CGFloat
    let canvasWidth: CGFloat
    let sideInset: CGFloat

    init(size: CGSize, safeArea: EdgeInsets) {
        screenWidth = size.width
        screenHeight = size.height
        safeBottom = safeArea.bottom
        canvasWidth = size.width
        sideInset = 0
    }

    var contentWidth: CGFloat { max(300, screenWidth - 48) }
    var navCenterY: CGFloat { screenHeight - safeBottom - 24 - 22 }

    // Scroll-morph nav anchoring — mirrors HomeFirstTimerMetrics so the nav
    // animates between the expanded resting position and the compact pinned position.
    var expandedNavBottom: CGFloat { safeBottom + 46 }
    var compactNavBottom: CGFloat { safeBottom + 22 }
}

private struct CreditMainScreen: View {
    let metrics: CreditMetrics
    let onHome: () -> Void
    let onOpenAI: () -> Void
    let onShowOfferDetails: () -> Void
    let onSelectLiability: (CreditLiabilityKind) -> Void

    @State private var scrollPosition = ScrollPosition(idType: Never.self)
    @State private var scrollOffset: CGFloat = 0
    @State private var didApplyInitialScroll = false

    private static let initialScrollY: CGFloat = {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-BONCreditScrollY"),
              args.indices.contains(i + 1),
              let value = Double(args[i + 1]) else {
            return 0
        }
        return CGFloat(value)
    }()

    var body: some View {
        let collapseProgress = min(1, max(0, (scrollOffset - 80) / 140))
        let navHeight = 64 - (20 * collapseProgress)
        let navBottom = metrics.expandedNavBottom + ((metrics.compactNavBottom - metrics.expandedNavBottom) * collapseProgress)

        ZStack(alignment: .top) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    CreditHeroSection(
                        canvasWidth: metrics.canvasWidth,
                        contentWidth: metrics.contentWidth,
                        onOpenAI: onOpenAI,
                        onSelectLiability: onSelectLiability
                    )
                    .frame(width: metrics.canvasWidth, height: 736)

                    CreditProductsHeader(
                        canvasWidth: metrics.canvasWidth,
                        contentWidth: metrics.contentWidth
                    )
                    .frame(width: metrics.canvasWidth, height: 193)

                    CreditCardOffersSection(
                        contentWidth: metrics.contentWidth,
                        onShowDetails: onShowOfferDetails
                    )
                    .padding(.top, 28)

                    CreditLoanOffersSection(contentWidth: metrics.contentWidth)
                    .padding(.top, 48)

                    CreditSavingsOffersSection(contentWidth: metrics.contentWidth)
                    .padding(.top, 48)

                    CreditDisclosuresSection()
                    .frame(width: metrics.contentWidth)
                    .padding(.top, 64)

                    // Leave room at the bottom so the overlaid nav never covers content.
                    Color.clear.frame(height: 160 + metrics.safeBottom)
                }
                .frame(width: metrics.canvasWidth)
                .frame(maxWidth: .infinity)
            }
            .background(Color.white)
            .scrollPosition($scrollPosition)
            .onScrollGeometryChange(for: CGFloat.self) { geometry in
                max(0, geometry.contentOffset.y)
            } action: { _, newValue in
                scrollOffset = newValue
            }
            .task(id: metrics.screenHeight) {
                guard !didApplyInitialScroll, Self.initialScrollY > 0 else { return }
                didApplyInitialScroll = true
                scrollOffset = Self.initialScrollY
                scrollPosition.scrollTo(y: Self.initialScrollY)
            }

            BONBottomNav(
                selectedID: "credit",
                items: HomeFirstTimerFixture.navItems,
                width: metrics.contentWidth,
                variant: collapseProgress >= 1 ? .compact : .expanded,
                collapseProgress: collapseProgress
            ) { item in
                if item.id == "home" {
                    onHome()
                }
            }
            .position(
                x: metrics.screenWidth / 2,
                y: metrics.screenHeight - navBottom - (navHeight / 2)
            )
        }
        .frame(width: metrics.screenWidth, height: metrics.screenHeight)
    }
}

private enum CreditPalette {
    static let secondaryText = Color.creditHex(0x777777)
    static let tertiaryText = Color.creditHex(0x333333)
    static let accentBlue = Color.creditHex(0x3B7AF0)
    static let border = Color.creditHex(0xEEEEEE)
    static let subtleSurface = Color.creditHex(0xF7F7F7)
    static let divider = Color.black.opacity(0.08)
    static let cardShadow = Color.black.opacity(0.12)
    static let artworkShadow = Color.black.opacity(0.24)
}

/// Template-rendered Credit icon sized into a square frame.
/// Used for the liability summary rows, account chip overlays, picker rows,
/// product nav chips, and the AI suggest sparkle.
private struct CreditTemplateIcon: View {
    let asset: String
    var size: CGFloat = 20
    var color: Color = CreditPalette.secondaryText

    var body: some View {
        Image(asset)
            .renderingMode(.template)
            .resizable()
            .interpolation(.high)
            .scaledToFit()
            .frame(width: size, height: size)
            .foregroundStyle(color)
    }
}

private struct CreditProductNavItemModel: Identifiable {
    let id: String
    let title: String
    /// Template asset name when set; falls back to `systemIcon` SF Symbol otherwise.
    var iconAsset: String? = nil
    let systemIcon: String
    let width: CGFloat
    let isSelected: Bool
}

private struct CreditCardOfferModel: Identifiable {
    let id: String
    let imageAsset: String
    let title: String
    let subtitle: String
    let annualFee: String
    let apr: String
    let benefits: [String]
}

private struct CreditHeroSection: View {
    let canvasWidth: CGFloat
    let contentWidth: CGFloat
    let onOpenAI: () -> Void
    let onSelectLiability: (CreditLiabilityKind) -> Void

    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                stops: [
                    .init(color: Color.creditHex(0xC5EAFA), location: 0.00),
                    .init(color: Color.creditHex(0xC1EAFC), location: 0.55),
                    .init(color: Color.creditHex(0xE7F4FB), location: 0.86),
                    .init(color: .white, location: 1.00)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 609)

            HStack(alignment: .top) {
                CreditCircleButton(asset: "creditIconSparkle", size: 32)

                Spacer(minLength: 0)

                CreditGlassPill(text: "Free credit report", height: 32, horizontalPadding: 16)
            }
            .frame(width: contentWidth)
            .padding(.top, 70)

            VStack(spacing: 2) {
                Text("total outstanding balance")
                    .font(BONTypography.zalando(size: 12, weight: .light))
                    .frame(height: 15)

                Text("$41,860")
                    .font(BONTypography.geistPixel(size: 48))
                    .tracking(-0.96)
                    .frame(height: 62)
            }
            .frame(width: 181, height: 79, alignment: .top)
            .foregroundStyle(Color.black)
            .multilineTextAlignment(.center)
            .padding(.top, 150)

            CreditLiabilitiesSummaryCard(onSelect: onSelectLiability)
                .frame(width: contentWidth)
                .padding(.top, 253)

            CreditAIPromoCard(width: contentWidth, onOpenAI: onOpenAI)
                .padding(.top, 609)
        }
        .frame(width: canvasWidth, height: 736, alignment: .top)
    }
}

private struct CreditLiabilitiesSummaryCard: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let onSelect: (CreditLiabilityKind) -> Void

    private let rows: [CreditLiabilitySummaryRow] = [
        .init(kind: .creditCards, icon: "creditIconCard", title: "Credit cards balance", amount: "$11,480"),
        .init(kind: .student, icon: "creditIconStudent", title: "Student loan", amount: "$10,000"),
        .init(kind: .auto, icon: "creditIconAuto", title: "Auto loan", amount: "$7,456"),
        .init(kind: .personal, icon: "creditIconPersonal", title: "Personal loan", amount: "$2,045"),
        .init(kind: .mortgage, icon: "creditIconMortgage", title: "Mortgage loan", amount: "$10,879")
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.title) { index, row in
                rowButton(for: row)

                if index < rows.count - 1 {
                    Spacer(minLength: 0).frame(height: 20)
                    Divider().background(CreditPalette.divider)
                    Spacer(minLength: 0).frame(height: 20)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background {
            let rect = RoundedRectangle(cornerRadius: 16, style: .continuous)
            ZStack {
                if #available(iOS 26.0, *), !reduceTransparency {
                    rect
                        .fill(Color.white.opacity(0.30))
                        .glassEffect(.regular.tint(Color.white.opacity(0.32)), in: rect)
                } else if reduceTransparency {
                    rect.fill(Color.white.opacity(0.92))
                } else {
                    rect
                        .fill(Color.white.opacity(0.42))
                        .background(.ultraThinMaterial, in: rect)
                }

                rect
                    .strokeBorder(Color.white.opacity(0.42), lineWidth: 0.6)
                    .blendMode(.screen)
            }
        }
        .shadow(color: CreditPalette.cardShadow, radius: 32, x: 0, y: 8)
    }

    @ViewBuilder
    private func rowButton(for row: CreditLiabilitySummaryRow) -> some View {
        Button {
            BONHaptics.selection()
            onSelect(row.kind)
        } label: {
            HStack(spacing: 16) {
                Image(row.icon)
                    .renderingMode(.template)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(CreditPalette.secondaryText)

                Text(row.title)
                    .font(BONTypography.zalando(size: 14, weight: .medium))
                    .tracking(0.14)
                    .foregroundStyle(Color.black)

                Spacer(minLength: 12)

                Text(row.amount)
                    .font(BONTypography.geistPixel(size: 14))
                    .foregroundStyle(Color.black)

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.46))
            }
            .frame(height: 20)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct CreditLiabilitySummaryRow {
    let kind: CreditLiabilityKind
    let icon: String
    let title: String
    let amount: String
}

private struct CreditAIPromoCard: View {
    let width: CGFloat
    let onOpenAI: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            CreditOfferSurfaceCard(cornerRadius: 24)

            HStack(spacing: 0) {
                Image("creditAIPromoArtwork")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 137, height: 127, alignment: .leading)
                    .clipped()
                Spacer(minLength: 0)
            }

            HStack(spacing: 0) {
                Spacer(minLength: 0).frame(width: 149)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Get debt-free faster\nwith BON Credit AI.")
                        .font(BONTypography.zalando(size: 16, weight: .medium))
                        .lineSpacing(2)
                        .foregroundStyle(Color.black)
                        .frame(width: 174, alignment: .leading)

                    BONIntentCTA(title: "Start chat", theme: .lime, horizontalPadding: 16, action: onOpenAI)
                        .frame(width: 104, height: 36)
                }
                Spacer(minLength: 0)
            }
        }
        .frame(width: width, height: 127)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct CreditProductsHeader: View {
    let canvasWidth: CGFloat
    let contentWidth: CGFloat

    private let items: [CreditProductNavItemModel] = [
        .init(id: "credit-cards", title: "Credit cards", iconAsset: "creditIconCard", systemIcon: "creditcard", width: 117, isSelected: true),
        .init(id: "cash-advance", title: "Cash advance", systemIcon: "dollarsign.circle", width: 127, isSelected: false),
        .init(id: "savings", title: "Savings accounts", systemIcon: "building.columns", width: 147, isSelected: false),
        .init(id: "personal-loans", title: "Personal loans", iconAsset: "creditIconPersonal", systemIcon: "banknote", width: 130, isSelected: false)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Product & offers")
                        .font(BONTypography.zalando(size: 20, weight: .medium))
                        .foregroundStyle(Color.black)

                    Text("Find best options for you")
                        .font(BONTypography.zalando(size: 14, weight: .light))
                        .foregroundStyle(CreditPalette.secondaryText)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Powered by")
                        .font(BONTypography.zalando(size: 12, weight: .light))
                        .foregroundStyle(CreditPalette.tertiaryText)
                    Image("creditMoneyLionLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 16)
                }
            }

            // Figma 61:7519 — unified pill container, 1pt #eee border, soft inset shadow, 10% white tint.
            CreditProductsNavBar(items: items)

            Divider()
                .background(CreditPalette.divider)
        }
        .frame(width: contentWidth, alignment: .leading)
        .padding(.top, 64)
        .frame(width: canvasWidth, height: 193, alignment: .top)
        .background(Color.white)
    }
}

private struct CreditProductChip: View {
    let item: CreditProductNavItemModel

    var body: some View {
        HStack(spacing: 8) {
            if let asset = item.iconAsset {
                Image(asset)
                    .renderingMode(.template)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: item.systemIcon)
                    .font(.system(size: 12, weight: .regular))
            }

            Text(item.title)
                .font(BONTypography.zalando(size: 12, weight: .light))
                .tracking(0.12)
        }
        .foregroundStyle(item.isSelected ? Color.white : Color.black)
        .frame(width: item.width, height: 32)
        .background {
            // Figma chips inside the nav: active = black fill, inactive = clear with 4% black border.
            // The outer pill's #eee border supplies the visible chrome around the row, so chips
            // themselves get only a barely-visible 4% border.
            Capsule(style: .continuous)
                .fill(item.isSelected ? Color.black : Color.clear)
                .overlay {
                    Capsule(style: .continuous)
                        .stroke(item.isSelected ? Color.black : Color.black.opacity(0.04), lineWidth: 1)
                }
        }
    }
}

/// Figma 61:7519 — unified pill container hosting horizontally-scrolling product chips.
/// Outer chrome: 1pt `#eee` border, 4pt internal padding around chips, soft black 12% inset shadow.
private struct CreditProductsNavBar: View {
    let items: [CreditProductNavItemModel]

    var body: some View {
        let capsule = Capsule(style: .continuous)

        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(items) { item in
                    CreditProductChip(item: item)
                }
            }
            .padding(4)
        }
        .frame(height: 40)
        .background {
            capsule.fill(Color.white.opacity(0.10))
        }
        // The inset shadow has to render INSIDE the clip mask so its blurred tail stays inside the
        // pill. Order: clip the stack first, then add the inset shadow + outer border on top so the
        // outer border isn't washed out by the darker inset.
        .clipShape(capsule)
        .overlay {
            // Inset shadow per Figma `inset 0 0 4 rgba(0,0,0,0.12)`.
            capsule
                .stroke(Color.black.opacity(0.12), lineWidth: 4)
                .blur(radius: 2)
                .clipShape(capsule)
                .allowsHitTesting(false)
        }
        .overlay {
            // Outer border drawn LAST. Spec is `1pt #eee`, but on a white background a literal
            // `#eee` stroke is essentially invisible at the device's native sub-pixel rendering.
            // Figma's rasterizer over-emphasizes thin pale strokes, so we bump opacity to give the
            // border the same visual weight the Figma export shows.
            capsule
                .strokeBorder(Color.black.opacity(0.10), lineWidth: 1.0)
                .allowsHitTesting(false)
        }
    }
}

private struct CreditCardOffersSection: View {
    let contentWidth: CGFloat
    let onShowDetails: () -> Void

    private let offers: [CreditCardOfferModel] = [
        .init(
            id: "chase",
            imageAsset: "creditOfferChaseCard",
            title: "Chase Sapphire Reserve",
            subtitle: "Great for people with minimal credit history",
            annualFee: "$0",
            apr: "0%",
            benefits: ["No interest", "No credit check to apply", "Help you build credit stress free"]
        ),
        .init(
            id: "avant",
            imageAsset: "creditOfferAvantCard",
            title: "Avant credit card",
            subtitle: "Great for repairing your credit",
            annualFee: "$39",
            apr: "35%",
            benefits: ["No deposit required", "No penalty APR", "No hidden fees"]
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Best credit card offers for you")
                    .font(BONTypography.zalando(size: 16, weight: .medium))
                    .foregroundStyle(Color.black)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(["Build credit", "Balance transfer", "Dining", "Travel", "Cashback"], id: \.self) { title in
                            Text(title)
                                .font(BONTypography.zalando(size: 14, weight: .medium))
                                .foregroundStyle(title == "Dining" ? Color.white : CreditPalette.secondaryText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .frame(height: 33)
                                .background {
                                    Capsule(style: .continuous)
                                        .fill(title == "Dining" ? Color.black : Color.clear)
                                        .overlay {
                                            Capsule(style: .continuous)
                                                .stroke(title == "Dining" ? Color.black : CreditPalette.secondaryText, lineWidth: 1)
                                        }
                                }
                        }
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(offers) { offer in
                        CreditCardOfferCard(offer: offer, onShowDetails: onShowDetails)
                    }
                }
            }
            .padding(.horizontal, -24)
            .contentMargins(.horizontal, 24, for: .scrollContent)
        }
        .frame(width: contentWidth, alignment: .leading)
    }
}

private struct CreditCardOfferCard: View {
    let offer: CreditCardOfferModel
    let onShowDetails: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(spacing: 16) {
                Image(offer.imageAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 292, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: CreditPalette.artworkShadow, radius: 32, x: 0, y: 8)

                VStack(spacing: 8) {
                    Text(offer.title)
                        .font(BONTypography.zalando(size: 20, weight: .medium))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .medium))
                        Text(offer.subtitle)
                            .lineLimit(1)
                            .minimumScaleFactor(0.82)
                    }
                    .font(BONTypography.zalando(size: 14, weight: .light))
                    .foregroundStyle(CreditPalette.accentBlue)
                }
                .frame(width: 292)
            }

            VStack(spacing: 16) {
                CreditStatPairBox(leftTitle: "Annual fee", leftValue: offer.annualFee, rightTitle: "APR", rightValue: offer.apr)

                ZStack(alignment: .bottom) {
                    VStack(spacing: 12) {
                        ForEach(offer.benefits, id: \.self) { benefit in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundStyle(CreditPalette.tertiaryText)
                                Text(benefit)
                                    .font(BONTypography.zalando(size: 14, weight: .light))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .foregroundStyle(Color.black)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                    .frame(width: 292, height: 130, alignment: .top)
                    .background(CreditSubtleGradientBox(cornerRadius: 12))

                    Button(action: onShowDetails) {
                        HStack(spacing: 8) {
                            Text("View all details")
                            Image(systemName: "chevron.down")
                                .font(.system(size: 9, weight: .medium))
                                .rotationEffect(.degrees(-90))
                        }
                        .font(BONTypography.zalando(size: 14, weight: .light))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background {
                            Capsule(style: .continuous)
                                .fill(Color.white)
                                .overlay {
                                    Capsule(style: .continuous)
                                        .stroke(CreditPalette.border, lineWidth: 1)
                                }
                                .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 4)
                        }
                    }
                    .buttonStyle(BONScaleButtonStyle())
                    .offset(y: 16)
                }
                .frame(height: 146)
            }

            VStack(spacing: 16) {
                CreditBlackCTA(title: "Apply now", width: 294, height: 47)

                CreditUnderlinedLink(title: "Rates & terms")
            }
        }
        .padding(20)
        .frame(width: 332)
        .background {
            CreditOfferSurfaceCard(cornerRadius: 24)
        }
    }
}

private struct CreditStatPairBox: View {
    let leftTitle: String
    let leftValue: String
    let rightTitle: String
    let rightValue: String

    var body: some View {
        HStack(spacing: 48) {
            stat(title: leftTitle, value: leftValue)

            Divider()
                .frame(height: 43)
                .background(CreditPalette.divider)

            stat(title: rightTitle, value: rightValue)
        }
        .frame(width: 292, height: 75)
        .background(CreditSubtleGradientBox(cornerRadius: 12))
    }

    private func stat(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(BONTypography.zalando(size: 12, weight: .light))
                .foregroundStyle(CreditPalette.tertiaryText)
            Text(value)
                .font(BONTypography.geistPixel(size: 20))
                .tracking(-0.4)
                .foregroundStyle(Color.black)
        }
        .frame(width: 60)
    }
}

private struct CreditLoanOffersSection: View {
    let contentWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Your loan offers")
                    .font(BONTypography.zalando(size: 16, weight: .medium))
                    .foregroundStyle(Color.black)

                Text("Compare 6 loan offers for upto $10,000")
                    .font(BONTypography.zalando(size: 12, weight: .light))
                    .foregroundStyle(CreditPalette.secondaryText)
            }

            CreditLoanOfferCard()
        }
        .frame(width: contentWidth, alignment: .leading)
    }
}

private struct CreditLoanOfferCard: View {
    var body: some View {
        VStack(spacing: 24) {
            Image("creditLoanOfferCard")
                .resizable()
                .scaledToFill()
                .frame(width: 292, height: 207)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: CreditPalette.artworkShadow, radius: 32, x: 0, y: 8)

            VStack(spacing: 16) {
                CreditBlackCTA(title: "Apply now", width: 294, height: 47)
                CreditUnderlinedLink(title: "Rates & terms")
            }
        }
        .padding(20)
        .frame(width: 332)
        .background {
            CreditOfferSurfaceCard(cornerRadius: 24)
        }
    }
}

private struct CreditSavingsOffersSection: View {
    let contentWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("High yield savings account offers")
                .font(BONTypography.zalando(size: 16, weight: .medium))
                .foregroundStyle(Color.black)

            VStack(spacing: 24) {
                VStack(spacing: 18) {
                    Image("creditSavingsChaseLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 84, height: 40)

                    VStack(spacing: 2) {
                        Text("1.75%")
                            .font(BONTypography.geistPixel(size: 32))
                            .tracking(-0.64)
                        Text("Annual percentage yield")
                            .font(BONTypography.zalando(size: 12, weight: .light))
                            .foregroundStyle(CreditPalette.secondaryText)
                    }
                    .frame(height: 59)

                    CreditStatPairBox(leftTitle: "Monthly fee", leftValue: "$0", rightTitle: "Check writing", rightValue: "No")

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(["No minimum to open", "No monthly fees", "Member FDIC"], id: \.self) { item in
                            Label(item, systemImage: "checkmark.circle.fill")
                                .font(BONTypography.zalando(size: 14, weight: .light))
                                .foregroundStyle(Color.black)
                        }
                    }
                    .frame(width: 292, alignment: .leading)
                }

                CreditBlackCTA(title: "Open account", width: 294, height: 47)
                CreditUnderlinedLink(title: "View terms")
            }
            .padding(20)
            .frame(width: 332)
            .background {
                CreditOfferSurfaceCard(cornerRadius: 24)
            }
        }
        .frame(width: contentWidth, alignment: .leading)
    }
}

private struct CreditDisclosuresSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Divider()
                .background(CreditPalette.divider)

            VStack(alignment: .leading, spacing: 16) {
                Text("Sponsored | Advertisers disclosure")
                    .font(BONTypography.zalando(size: 10, weight: .medium))
                    .foregroundStyle(CreditPalette.secondaryText)

                Text(disclosure)
                    .font(BONTypography.zalando(size: 10, weight: .light))
                    .lineSpacing(3)
                    .foregroundStyle(CreditPalette.secondaryText)
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("Additional Information")
                    .font(BONTypography.zalando(size: 10, weight: .medium))
                    .foregroundStyle(CreditPalette.secondaryText)

                Text(additional)
                    .font(BONTypography.zalando(size: 10, weight: .light))
                    .lineSpacing(3)
                    .foregroundStyle(CreditPalette.secondaryText)
            }
        }
        .frame(width: 342, alignment: .leading)
    }

    private var disclosure: String {
        "The offers that appear are from companies which Moneylion, and its partners receive compensation. This compensation may influence the selection, appearance, and order of appearance of the offers listed below. However, this compensation also facilitates the provision by Moneylion of certain services to you at no charge. The offers shown below do not include all Financial Services companies or all of their available product and service offerings."
    }

    private var additional: String {
        "The listings that appear on this page are from companies from which Even Financial, Inc. / Fiona (\"Even\", \"Even Financial\", \"Fiona\", \"we\", \"us\", \"our\") and its affiliates may receive compensation, which may impact how, where and in what order products appear. These listings do not include all companies or all available products. Neither Fiona nor this website endorses or recommends any companies or products. All rates are presented without guarantee and are subject to change pursuant to each provider's discretion. There may be certain minimum deposit and/or other funding requirements as well as restrictions placed in order to open an account and/or to earn the stated Annual Percentage Yield. Maximum balance limits may also apply. Please make sure to review the details as well as any Terms and Conditions on each provider's website. APY stands for Annual Percentage Yield. It's different from an interest rate because it takes into account compounding interest. The APY is subject to change before and after account opening. MMA stands for Money Market Account. It's a savings and checking hybrid, allowing you to earn interest and write checks 6 times a month. Even Financial, Inc. is the technology platform powering financial services online. Even's API enables its partners to connect their users with real-time decisions and personalized offers and rates from premium financial services providers. All decisions and rates offered, are the responsibility of the participating partners. Any trademarks used in connection with products or services appearing on this website are the sole property of their respective owners. No affiliation or endorsement is intended or implied. Even Financial offices are located at 50 West 23rd Street, Suite 700, New York, NY 10010, Telephone number: (800) 614- 7505. This site is directed at, and made available to, persons in the continental U.S., Alaska and Hawaii only."
    }
}

private struct CreditOfferSurfaceCard: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.white)
            .shadow(color: CreditPalette.cardShadow, radius: 32, x: 0, y: 8)
    }
}

private enum CreditLiabilityKind: String, Identifiable, CaseIterable {
    case creditCards = "credit-cards"
    case auto = "auto-loan"
    case student = "student-loan"
    case personal = "personal-loan"
    case mortgage = "mortgage-loan"

    var id: String { rawValue }

    var topTitle: String {
        switch self {
        case .creditCards: "Credit cards"
        case .auto: "Auto-BYD"
        case .student: "Student-Upstart"
        case .personal: "Personal-Lime"
        case .mortgage: "Mortgage-EY"
        }
    }

    var maskedNumber: String {
        switch self {
        case .creditCards: "5 open"
        case .auto, .student, .personal, .mortgage: "XXXX43"
        }
    }

    var balance: String {
        switch self {
        case .creditCards: "$26,893"
        case .auto: "$7,456"
        case .student: "$17,934"
        case .personal, .mortgage: "$2,986"
        }
    }

    /// Template-rendered asset name for this liability kind. Used by the liability summary card,
    /// account picker rows, detail-screen account chip, and the credit card debt account chip overlay.
    var iconAsset: String {
        switch self {
        case .creditCards: "creditIconCard"
        case .auto: "creditIconAuto"
        case .student: "creditIconStudent"
        case .personal: "creditIconPersonal"
        case .mortgage: "creditIconMortgage"
        }
    }

    var heroAsset: String? {
        switch self {
        case .creditCards: nil
        case .auto: "creditAutoHero"
        case .student: "creditStudentHero"
        case .personal: "creditPersonalHero"
        case .mortgage: "creditMortgageHero"
        }
    }

    var promoAsset: String? {
        switch self {
        case .creditCards: nil
        case .auto: "creditAutoPromo"
        case .student: "creditStudentPromo"
        case .personal: "creditPersonalPromo"
        case .mortgage: "creditMortgagePromo"
        }
    }

    var promoGradient: LinearGradient {
        switch self {
        case .creditCards, .auto:
            return LinearGradient(colors: [Color.creditHex(0x18181A), Color.black], startPoint: .top, endPoint: .bottom)
        case .student:
            return LinearGradient(colors: [Color.creditHex(0x250101), Color.creditHex(0x131313)], startPoint: .leading, endPoint: .trailing)
        case .personal:
            return LinearGradient(colors: [Color.creditHex(0xFBD99C), Color.creditHex(0x744907)], startPoint: .leading, endPoint: .trailing)
        case .mortgage:
            return LinearGradient(colors: [Color.creditHex(0x062501), Color.creditHex(0x131313)], startPoint: .leading, endPoint: .trailing)
        }
    }
}

private struct CreditLiabilityDetailScreen: View {
    let metrics: CreditMetrics
    let kind: CreditLiabilityKind
    @Binding var showsAccountPicker: Bool
    let onBack: () -> Void
    let onOpenAI: () -> Void

    var body: some View {
        Group {
            if kind == .creditCards {
                CreditCardDebtScreen(metrics: metrics, onBack: onBack, onOpenAI: onOpenAI)
            } else {
                CreditLoanDetailScreen(
                    metrics: metrics,
                    kind: kind,
                    showsAccountPicker: $showsAccountPicker,
                    onBack: onBack,
                    onOpenAI: onOpenAI
                )
            }
        }
    }
}

private struct CreditLoanDetailScreen: View {
    let metrics: CreditMetrics
    let kind: CreditLiabilityKind
    @Binding var showsAccountPicker: Bool
    let onBack: () -> Void
    let onOpenAI: () -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [Color.creditHex(0xDFDFDF).opacity(0.72), Color.white],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 605)

                CreditDetailTopBar(kind: kind, onBack: onBack) {
                    showsAccountPicker = true
                }
                .padding(.top, 62)

                VStack(spacing: 8) {
                    VStack(spacing: 2) {
                        Text("Outstanding balance")
                            .font(BONTypography.zalando(size: 12, weight: .light))
                        Text(kind.balance)
                            .font(BONTypography.geistPixel(size: 48))
                            .tracking(-0.96)
                    }
                    .foregroundStyle(Color.black)

                    Text("APR: 27.4%")
                        .font(BONTypography.zalando(size: 12, weight: .regular))
                        .textCase(.uppercase)
                        .foregroundStyle(Color.creditHex(0x1499FF))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .frame(minWidth: 154)
                        .background {
                            Capsule(style: .continuous)
                                .fill(Color.creditHex(0x1499FF).opacity(0.10))
                                .overlay {
                                    Capsule(style: .continuous)
                                        .stroke(Color.creditHex(0x1499FF).opacity(0.11), lineWidth: 1)
                                }
                        }
                }
                .padding(.top, 150)

                if let heroAsset = kind.heroAsset {
                    Image(heroAsset)
                        .resizable()
                        .scaledToFill()
                        .frame(width: heroWidth(for: kind), height: heroHeight(for: kind))
                        .scaleEffect(heroScale(for: kind))
                        .clipped()
                        .padding(.top, 320)
                }

                VStack(spacing: 48) {
                    CreditPrincipalProgress()
                    CreditPaymentHistory()
                    CreditMoreDetails()
                    CreditLoanAIPromo(kind: kind, onOpenAI: onOpenAI)
                }
                .frame(width: 342)
                .padding(.top, kind == .auto || kind == .student ? 504 : 579)
            }
            .frame(width: metrics.canvasWidth)
            .frame(minHeight: detailHeight(for: kind), alignment: .top)
            .frame(maxWidth: .infinity)
        }
        .background(Color.white)
    }

    private func heroWidth(for kind: CreditLiabilityKind) -> CGFloat {
        switch kind {
        case .auto: 312
        case .student: 229
        case .personal: 133
        case .mortgage: 367
        case .creditCards: 0
        }
    }

    private func heroHeight(for kind: CreditLiabilityKind) -> CGFloat {
        switch kind {
        case .auto, .student: 120
        case .personal: 195
        case .mortgage: 203
        case .creditCards: 0
        }
    }

    private func heroScale(for kind: CreditLiabilityKind) -> CGFloat {
        switch kind {
        case .auto: 1.14
        case .student, .personal, .mortgage, .creditCards: 1
        }
    }

    private func detailHeight(for kind: CreditLiabilityKind) -> CGFloat {
        switch kind {
        case .auto: 1337
        case .student: 1329
        case .personal: 1403
        case .mortgage: 1411
        case .creditCards: 1000
        }
    }
}

private struct CreditDetailTopBar: View {
    let kind: CreditLiabilityKind
    let onBack: () -> Void
    let onPicker: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.black)
                    .frame(width: 40, height: 40)
                    .background {
                        Circle()
                            .fill(Color.white.opacity(0.40))
                            .overlay {
                                Circle()
                                    .stroke(Color.white.opacity(0.50), lineWidth: 1)
                            }
                            .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
                    }
            }
            .buttonStyle(BONScaleButtonStyle())

            Spacer()

            Button(action: onPicker) {
                HStack(spacing: 12) {
                    CreditTemplateIcon(asset: kind.iconAsset, size: 18, color: Color.black.opacity(0.84))
                        .frame(width: 32, height: 32)
                        .background {
                            Circle()
                                .stroke(Color.black.opacity(0.16), lineWidth: 1)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(kind.topTitle)
                            .font(BONTypography.zalando(size: 14, weight: .medium))
                        Text(kind.maskedNumber)
                            .font(BONTypography.zalando(size: 12, weight: .light))
                            .textCase(.uppercase)
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(Color.black)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 342)
    }
}

private struct CreditPrincipalProgress: View {
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.creditHex(0xF0F0F0))
                    .frame(height: 6)
                Rectangle()
                    .fill(Color.creditHex(0x35C759))
                    .frame(width: 255, height: 6)
            }

            HStack {
                Text("Paid: $25,000")
                    .foregroundStyle(Color.black)
                Spacer()
                Text("Principal: $35,000")
                    .foregroundStyle(Color.creditHex(0x9D9D9D))
            }
            .font(BONTypography.zalando(size: 14, weight: .medium))
        }
    }
}

private struct CreditPaymentHistory: View {
    private let months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"]

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Divider()
                .background(Color.black.opacity(0.08))

            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Payment history")
                        .font(BONTypography.zalando(size: 16, weight: .medium))
                    Spacer()
                    HStack(spacing: 26) {
                        Image(systemName: "chevron.left")
                        Text("2025")
                            .font(BONTypography.zalando(size: 14, weight: .medium))
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 9, weight: .regular))
                }

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(18), spacing: 39), count: 6), spacing: 20) {
                    ForEach(months.indices, id: \.self) { index in
                        VStack(spacing: 12) {
                            CreditPaymentSquare(index: index)
                            Text(months[index])
                                .font(BONTypography.zalando(size: 8, weight: .medium))
                                .tracking(0.32)
                                .foregroundStyle(Color.creditHex(0xBBBBBB))
                                .lineLimit(1)
                                .fixedSize(horizontal: true, vertical: false)
                        }
                    }
                }

                Divider()
                    .background(Color.black.opacity(0.08))

                HStack(spacing: 12) {
                    legend(color: Color.creditHex(0x35C759), title: "Paid on time", checkmark: true)
                    legend(color: Color.creditHex(0xD0021B), title: "Delayed", checkmark: true)
                    legend(color: Color.creditHex(0xF26C22), title: "Overdue", checkmark: false)
                    legend(color: Color.creditHex(0xBBBBBB), title: "No data", checkmark: false)
                }
            }
        }
    }

    private func legend(color: Color, title: String, checkmark: Bool) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(color)
                .frame(width: 10, height: 10)
                .overlay {
                    if checkmark {
                        Image(systemName: "checkmark")
                            .font(.system(size: 6, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
            Text(title)
                .font(BONTypography.zalando(size: 11, weight: .medium))
                .foregroundStyle(Color.creditHex(0xBBBBBB))
        }
    }
}

private struct CreditPaymentSquare: View {
    let index: Int

    var body: some View {
        RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(fillColor)
            .frame(width: 18, height: 18)
            .overlay {
                if index < 4 {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Color.white)
                } else {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .stroke(Color.creditHex(0xEEEEEE), lineWidth: 2)
                }
            }
    }

    private var fillColor: Color {
        switch index {
        case 0, 1, 3: Color.creditHex(0x35C759)
        case 2: Color.creditHex(0xD0021B)
        default: Color.clear
        }
    }
}

private struct CreditMoreDetails: View {
    private let rows = [
        ("Account Number", "SX1X9X0X"),
        ("Open Date", "Aug 08, 2017"),
        ("Last Activity", "apr 02, 2025"),
        ("Owner name", "emily clark")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("More details")
                .font(BONTypography.zalando(size: 16, weight: .medium))
                .foregroundStyle(Color.black)

            VStack(spacing: 20) {
                ForEach(rows, id: \.0) { row in
                    HStack {
                        Text(row.0)
                            .font(BONTypography.zalando(size: 14, weight: .light))
                        Spacer()
                        Text(row.1)
                            .font(BONTypography.zalando(size: 14, weight: .medium))
                    }
                    Divider()
                        .background(Color.black.opacity(0.08))
                }
            }

            Text("Last updated on 02 April 2026 to Equifax")
                .font(BONTypography.zalando(size: 14, weight: .light))
                .foregroundStyle(Color.creditHex(0x999999))
        }
        .foregroundStyle(Color.black)
    }
}

private struct CreditLoanAIPromo: View {
    let kind: CreditLiabilityKind
    let onOpenAI: () -> Void

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(kind.promoGradient)

            if let asset = kind.promoAsset {
                Image(asset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 144, height: 94)
                    .offset(x: 8, y: 6)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Have any questions or want to\ncompare other loan options?")
                    .font(BONTypography.zalando(size: 12, weight: .regular))
                    .foregroundStyle(Color.white)

                Button(action: onOpenAI) {
                    Text("Ask BON Credit AI")
                        .font(BONTypography.zalando(size: 12, weight: .medium))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            Capsule(style: .continuous)
                                .fill(Color.white)
                                .shadow(color: Color.white.opacity(0.25), radius: 12, x: 0, y: 6)
                        }
                }
                .buttonStyle(BONScaleButtonStyle())
            }
            .offset(x: 160)
        }
        .frame(width: 342, height: 93)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct CreditCardDebtScreen: View {
    let metrics: CreditMetrics
    let onBack: () -> Void
    var onOpenAI: () -> Void = {}

    private static let initialScrollAnchor: (id: String, anchor: UnitPoint)? = {
        let args = ProcessInfo.processInfo.arguments
        if let i = args.firstIndex(of: "-BONCreditDebtScroll"), args.indices.contains(i+1) {
            let raw = args[i+1]
            let parts = raw.split(separator: ":", maxSplits: 1).map(String.init)
            let id = parts[0]
            let anchor: UnitPoint = (parts.count > 1 && parts[1] == "bottom") ? .bottom : .top
            return (id, anchor)
        }
        return nil
    }()

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 1).id("top")

                    Color.clear.frame(height: 79)

                    CreditCardDebtTopBar(
                        contentWidth: metrics.contentWidth,
                        onBack: onBack
                    )

                    Color.clear.frame(height: 38)

                    CreditCardDebtBalanceHero()

                    Color.clear.frame(height: 43)

                    CreditCardDebtThumbnailCarousel(canvasWidth: metrics.canvasWidth)

                    Color.clear.frame(height: 32)

                    VStack(spacing: 48) {
                        CreditCardDebtDetailCard(
                            kind: .chaseActive,
                            onOpenAI: onOpenAI
                        )
                        .id("card-chase")

                        CreditCardDebtDetailCard(
                            kind: .discoverWithSteps,
                            onOpenAI: onOpenAI
                        )
                        .id("card-discover")

                        CreditCardDebtDetailCard(
                            kind: .amexCollapsed,
                            onOpenAI: onOpenAI
                        )
                        .id("card-amex")
                    }

                    Color.clear.frame(height: 96 + metrics.safeBottom)
                }
                .frame(width: metrics.canvasWidth)
            }
            .background(Color.white)
            .onAppear {
                guard let target = Self.initialScrollAnchor else { return }
                DispatchQueue.main.async {
                    withAnimation(nil) {
                        proxy.scrollTo(target.id, anchor: target.anchor)
                    }
                }
            }
        }
        .frame(width: metrics.screenWidth, height: metrics.screenHeight)
        .background(Color.white)
    }
}

private struct CreditCardDebtTopBar: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let contentWidth: CGFloat
    let onBack: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.88))
                    .frame(width: 40, height: 40)
                    .background {
                        CreditLiquidGlassSurface(
                            shape: Circle(),
                            tint: Color.white.opacity(0.28),
                            fallbackFill: Color.white.opacity(0.46),
                            borderOpacity: 0.55,
                            reduceTransparency: reduceTransparency
                        )
                    }
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            }
            .buttonStyle(BONScaleButtonStyle())

            Spacer(minLength: 0)

            HStack(spacing: 12) {
                CreditTemplateIcon(asset: "creditIconCard", size: 18, color: Color.black.opacity(0.84))
                    .frame(width: 32, height: 32)
                    .background {
                        Circle()
                            .stroke(Color.black.opacity(0.12), lineWidth: 1)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Credit cards")
                        .font(BONTypography.zalando(size: 14, weight: .medium))
                        .foregroundStyle(Color.black)
                    Text("5 open")
                        .font(BONTypography.zalando(size: 12, weight: .light))
                        .foregroundStyle(CreditPalette.secondaryText)
                }

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.black.opacity(0.64))
            }
        }
        .frame(width: contentWidth)
    }
}

private struct CreditCardDebtBalanceHero: View {
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text("Total outstanding balance")
                    .font(BONTypography.zalando(size: 12, weight: .light))
                    .foregroundStyle(Color.black)
                    .frame(height: 15)

                Text("$26,893")
                    .font(BONTypography.geistPixel(size: 48))
                    .tracking(-0.96)
                    .foregroundStyle(Color.black)
                    .frame(height: 62)
            }
            .frame(width: 192, height: 79, alignment: .top)

            Text("Costing ~ $285/mo in interest")
                .font(BONTypography.zalando(size: 12, weight: .regular))
                .foregroundStyle(Color.creditHex(0xFF3333))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    Capsule(style: .continuous)
                        .fill(Color.creditHex(0xFF3333).opacity(0.10))
                        .overlay {
                            Capsule(style: .continuous)
                                .stroke(Color.creditHex(0xFF3333).opacity(0.12), lineWidth: 1)
                        }
                }
        }
    }
}

private struct CreditCardDebtThumbnailCarousel: View {
    let canvasWidth: CGFloat

    // Carousel order taken directly from Figma node 10488:9064 ("Credit card debt"):
    // Sapphire → AMEX Gold → AMEX Blue → Discover → Sapphire (loop tail).
    private let thumbnails: [String] = [
        "creditCardChaseSapphire",
        "creditCardAmexGold",
        "creditCardAmexBlue",
        "creditCardDiscover",
        "creditCardChaseSapphire"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Your credit cards")
                .font(BONTypography.zalando(size: 16, weight: .medium))
                .foregroundStyle(Color.black)
                .padding(.horizontal, 24)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(thumbnails.enumerated()), id: \.offset) { _, asset in
                        Image(asset)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 88, height: 54)
                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                            // Figma spec: drop shadow X=0 Y=8 blur=32 #000 24%.
                            // Figma "blur" is the Gaussian *diameter* (≈ 2 × stdDev). SwiftUI `.shadow(radius:)` IS the stdDev.
                            // Conversion: SwiftUI radius = Figma blur / 2 = 16. Using the raw blur as the radius
                            // bleeds the shadows of adjacent thumbnails together into a grey band.
                            .compositingGroup()
                            .shadow(color: Color.black.opacity(0.24), radius: 16, x: 0, y: 8)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
        }
        .frame(width: canvasWidth, alignment: .leading)
    }
}

private enum CreditDebtCardKind {
    case chaseActive
    case discoverWithSteps
    case amexCollapsed

    var title: String {
        switch self {
        case .chaseActive: return "Chase sapphire reserve"
        case .discoverWithSteps: return "Discover it student"
        case .amexCollapsed: return "Amex blue cash preferred"
        }
    }

    var subtitle: String { "XX 2345" }

    var accentColor: Color {
        switch self {
        case .chaseActive: return Color.creditHex(0xFF3333)
        case .discoverWithSteps: return BONColor.lime500
        case .amexCollapsed: return Color.clear
        }
    }

    var chipWidth: CGFloat {
        switch self {
        case .chaseActive: return 284
        case .discoverWithSteps: return 248
        case .amexCollapsed: return 301
        }
    }

    var chipShowsBack: Bool { self == .amexCollapsed }
}

private struct CreditCardDebtDetailCard: View {
    let kind: CreditDebtCardKind
    let onOpenAI: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            cardBody
                .padding(.top, 36)

            CreditDebtAccountChipOverlay(kind: kind)
        }
        .frame(width: 342)
    }

    @ViewBuilder
    private var cardBody: some View {
        VStack(spacing: 32) {
            switch kind {
            case .chaseActive:
                CreditDebtMetricGrid()
                CreditDebtAISuggestPanel()
                CreditDebtLinkCardCTA(onTap: onOpenAI)

            case .discoverWithSteps:
                CreditDebtMetricGrid()
                CreditDebtAISuggestPanel()
                CreditDebtNextStepsList(onSetUpAutopay: onOpenAI, onTalkWithAI: onOpenAI)

            case .amexCollapsed:
                CreditDebtCollapsedBody(onAskAI: onOpenAI)
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 52)
        .padding(.bottom, 32)
        .frame(width: 342, alignment: .top)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(CreditPalette.border, lineWidth: 1)
                }
        }
        .shadow(color: CreditPalette.cardShadow, radius: 32, x: 0, y: 8)
    }
}

private struct CreditDebtAccountChipOverlay: View {
    let kind: CreditDebtCardKind

    var body: some View {
        HStack(spacing: 12) {
            if kind.chipShowsBack {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.black.opacity(0.84))
                    .frame(width: 40, height: 40)
                    .background {
                        Circle()
                            .stroke(CreditPalette.border, lineWidth: 1)
                    }
            } else {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .overlay {
                            Circle()
                                .stroke(Color.creditHex(0xF7F7F7), lineWidth: 1)
                        }
                    CreditTemplateIcon(asset: "creditIconCard", size: 20, color: Color.black.opacity(0.84))
                }
                .frame(width: 48, height: 48)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(kind.title)
                    .font(BONTypography.zalando(size: 16, weight: .medium))
                    .tracking(0.16)
                    .foregroundStyle(Color.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.86)
                Text(kind.subtitle)
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .foregroundStyle(CreditPalette.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(width: kind.chipWidth, height: 72)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.creditHex(0xF7F7F7), lineWidth: 1)
                }
                .overlay(alignment: .bottom) {
                    if kind.accentColor != Color.clear {
                        Rectangle()
                            .fill(kind.accentColor)
                            .frame(height: 2)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
        }
        .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

private struct CreditDebtMetricGrid: View {
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    metricCell(value: "$6,561", label: "Balance")
                    metricCell(value: "$185", label: "Monthly min.")
                }
                .frame(height: 80)

                HStack(spacing: 0) {
                    metricCell(value: "~$23", label: "Monthly interest", color: Color.creditHex(0xFF3333))
                    metricCell(value: "91%", label: "Current utilization")
                }
                .frame(height: 80)
            }

            Rectangle()
                .fill(CreditPalette.border)
                .frame(height: 1)

            Rectangle()
                .fill(CreditPalette.border)
                .frame(width: 1, height: 140)
        }
        .frame(width: 294, height: 160)
    }

    private func metricCell(value: String, label: String, color: Color = .black) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(BONTypography.geistPixel(size: 20))
                .tracking(-0.4)
                .foregroundStyle(color)
            Text(label)
                .font(BONTypography.zalando(size: 12, weight: .light))
                .foregroundStyle(CreditPalette.tertiaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct CreditDebtAISuggestPanel: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(Color.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .stroke(BONColor.lime200, lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)

            LinearGradient(
                colors: [BONColor.lime200, BONColor.lime50],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 12)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 4,
                    bottomLeadingRadius: 4,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0,
                    style: .continuous
                )
            )

            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 8) {
                    Image("creditIconSparkle")
                        .renderingMode(.template)
                        .resizable()
                        .interpolation(.high)
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .foregroundStyle(BONColor.lime600)

                    Text("AI suggests:")
                        .font(BONTypography.zalando(size: 12, weight: .regular))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BONColor.lime600, BONColor.lime500, BONColor.lime600],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }

                Text("This card is costing you the most and dragging your score as well as your overall finances down.")
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .lineSpacing(6)
                    .foregroundStyle(CreditPalette.tertiaryText)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Spacer(minLength: 0)
                    CreditUnderlinedLink(title: "Chat about this card", color: BONColor.lime600)
                }
            }
            .padding(.leading, 27)
            .padding(.trailing, 25)
            .padding(.vertical, 11)
        }
        .frame(width: 294, height: 134)
    }
}

private struct CreditDebtLinkCardCTA: View {
    let onTap: () -> Void

    var body: some View {
        BONIntentCTA(title: "Link card", theme: .dark, action: onTap)
            .frame(width: 294, height: 48)
    }
}

private struct CreditDebtNextStepsList: View {
    let onSetUpAutopay: () -> Void
    let onTalkWithAI: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Next steps:")
                .font(BONTypography.zalando(size: 12, weight: .medium))
                .foregroundStyle(CreditPalette.tertiaryText)

            VStack(spacing: 16) {
                completedStep()
                actionStep(number: 2, title: "Set up autopay", actionLabel: "Set up now", action: onSetUpAutopay)
                actionStep(number: 3, title: "Start debt payoff plan", actionLabel: "Talk with AI", action: onTalkWithAI)
            }
        }
        .frame(width: 294, alignment: .leading)
    }

    private func completedStep() -> some View {
        ZStack(alignment: .leading) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(BONColor.lime100)
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(BONColor.lime700)
                }
                .frame(width: 24, height: 24)

                Text("Link card with BON Credit")
                    .font(BONTypography.zalando(size: 14, weight: .regular))
                    .foregroundStyle(CreditPalette.secondaryText)
                    .strikethrough(true, color: CreditPalette.secondaryText)

                Spacer(minLength: 0)
            }
        }
        .frame(height: 24)
    }

    private func actionStep(number: Int, title: String, actionLabel: String, action: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(CreditPalette.border, lineWidth: 1)
                Text("\(number)")
                    .font(BONTypography.zalando(size: 10, weight: .regular))
                    .foregroundStyle(CreditPalette.secondaryText)
            }
            .frame(width: 24, height: 24)

            Text(title)
                .font(BONTypography.zalando(size: 14, weight: .regular))
                .foregroundStyle(CreditPalette.tertiaryText)

            Spacer(minLength: 0)

            Button(action: action) {
                Text(actionLabel)
                    .font(BONTypography.zalando(size: 12, weight: .medium))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        Capsule(style: .continuous)
                            .fill(Color.black)
                    }
            }
            .buttonStyle(BONScaleButtonStyle())
        }
        .frame(height: 28)
    }
}

private struct CreditDebtCollapsedBody: View {
    let onAskAI: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("This card is costing you the most and dragging your score as well as your overall finances down.")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .lineSpacing(8)
                .foregroundStyle(Color.black)
                .fixedSize(horizontal: false, vertical: true)
                .frame(width: 294, alignment: .leading)

            HStack {
                Spacer(minLength: 0)
                Button(action: onAskAI) {
                    Text("How can I payoff this card?")
                        .font(BONTypography.zalando(size: 16, weight: .regular))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background {
                            UnevenRoundedRectangle(
                                topLeadingRadius: 24,
                                bottomLeadingRadius: 24,
                                bottomTrailingRadius: 0,
                                topTrailingRadius: 24,
                                style: .continuous
                            )
                            .fill(BONColor.lime100)
                        }
                }
                .buttonStyle(BONScaleButtonStyle())
            }
            .frame(width: 294)
            .padding(.top, 12)

            CreditDebtCardComposer()
                .padding(.top, 213)
        }
    }
}

private struct CreditDebtCardComposer: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Chat about this card...")
                .font(BONTypography.zalando(size: 14, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.72))
                .padding(.leading, 24)

            Spacer(minLength: 0)

            ZStack {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.18))
                Image(systemName: "mic.fill")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.white)
            }
            .frame(width: 72, height: 52)
            .padding(.trailing, 6)
        }
        .frame(width: 294, height: 64)
        .background(BONChatGlassCapsule())
    }
}

private struct CreditModalScrim: View {
    let opacity: CGFloat
    let onTap: () -> Void

    var body: some View {
        Color.black
            .opacity(opacity)
            .ignoresSafeArea()
            .onTapGesture(perform: onTap)
    }
}

private struct CreditOfferDetailsSheet: View {
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            ZStack(alignment: .topTrailing) {
                Image("creditOfferChaseCard")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 342, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .offset(y: -98)
                    .clipped()

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundStyle(Color.white)
                        .frame(width: 40, height: 40)
                        .background {
                            Circle()
                                .fill(Color.black.opacity(0.44))
                                .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
                        }
                }
                .buttonStyle(BONScaleButtonStyle())
                .offset(x: -2, y: -8)
            }
            .frame(width: 342, height: 72)

            VStack(spacing: 8) {
                Text("Chase Sapphire Reserve")
                    .font(BONTypography.zalando(size: 20, weight: .medium))
                    .foregroundStyle(Color.black)
                Label("Great for people with minimal credit history", systemImage: "sparkle")
                    .font(BONTypography.zalando(size: 14, weight: .light))
                    .foregroundStyle(Color.creditHex(0x3B7AF0))
            }

            CreditStatPairBox(leftTitle: "Annual fee", leftValue: "$0", rightTitle: "APR", rightValue: "0%")

            VStack(alignment: .leading, spacing: 16) {
                ForEach(["No interest", "No credit check to apply", "Help you build credit stress free", "Manage your finances with ease", "Achieve your savings goals effortlessly", "Track your expenses and stay on budget"], id: \.self) { item in
                    Label(item, systemImage: "seal")
                        .font(BONTypography.zalando(size: 14, weight: .light))
                        .foregroundStyle(Color.black)
                }
            }
            .padding(20)
            .frame(width: 342, alignment: .leading)
            .background(CreditSubtleGradientBox(cornerRadius: 12))

            VStack(spacing: 2) {
                Text("Recommended credit")
                    .font(BONTypography.zalando(size: 12, weight: .light))
                    .foregroundStyle(Color.creditHex(0x333333))
                Text("580 - 700")
                    .font(BONTypography.geistPixel(size: 20))
                    .tracking(-0.4)
            }
            .frame(width: 342, height: 70)
            .background(CreditSubtleGradientBox(cornerRadius: 12))

            HStack(spacing: 8) {
                Text("Powered by")
                    .font(BONTypography.zalando(size: 12, weight: .light))
                Image("creditMoneyLionLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 16)
            }

            CreditBlackCTA(title: "Apply now", width: 342, height: 47)
            CreditUnderlinedLink(title: "Rates & terms")
        }
        .padding(.horizontal, 24)
        .padding(.top, 32)
        .padding(.bottom, 48)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.white)
    }
}

private struct CreditAccountPickerSheet: View {
    let onSelect: (CreditLiabilityKind) -> Void
    let onClose: () -> Void

    private let rows: [(CreditLiabilityKind, String)] = [
        (.auto, "XX 2345"),
        (.creditCards, "5 open"),
        (.mortgage, "XX 9101"),
        (.student, "XX 9101"),
        (.personal, "XX 1123")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Select liability")
                    .font(BONTypography.zalando(size: 16, weight: .medium))
                    .foregroundStyle(Color.black)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.black)
                        .frame(width: 40, height: 40)
                        .background(Circle().fill(Color.white).shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6))
                }
                .buttonStyle(BONScaleButtonStyle())
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)

            VStack(spacing: 0) {
                ForEach(rows, id: \.0) { kind, caption in
                    Button {
                        onSelect(kind)
                    } label: {
                        HStack(spacing: 20) {
                            CreditTemplateIcon(asset: kind.iconAsset, size: 20, color: Color.black.opacity(0.84))
                                .frame(width: 40, height: 40)
                                .background(Circle().stroke(Color.black.opacity(0.08), lineWidth: 1))

                            VStack(alignment: .leading, spacing: 6) {
                                Text(kind == .auto ? "Auto - BYD" : kind == .mortgage ? "Mortgage - EY" : kind == .student ? "Student - EY" : kind == .personal ? "Personal - Lime" : "Credit cards")
                                    .font(BONTypography.zalando(size: 16, weight: .medium))
                                Text(caption)
                                    .font(BONTypography.zalando(size: 14, weight: .light))
                                    .foregroundStyle(Color.creditHex(0x777777))
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .regular))
                        }
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 24)
                        .frame(height: 82)
                        .background(kind == .creditCards ? Color.creditHex(0xF5F5F5) : Color.white)
                    }
                    .buttonStyle(.plain)

                    if kind != .personal {
                        Divider()
                            .padding(.leading, 84)
                    }
                }
            }
            .padding(.top, 20)
        }
        .background(Color.white)
    }
}

private struct CreditBlackCTA: View {
    let title: String
    let width: CGFloat
    let height: CGFloat
    var action: () -> Void = {}

    var body: some View {
        BONIntentCTA(title: title, theme: .dark, action: action)
            .frame(width: width, height: height)
    }
}

private struct CreditUnderlinedLink: View {
    let title: String
    var color: Color = Color.creditHex(0x777777)

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(BONTypography.zalando(size: 14, weight: .regular))
            Rectangle()
                .fill(color.opacity(0.8))
                .frame(height: 0.7)
        }
        .fixedSize()
        .foregroundStyle(color)
    }
}

private struct CreditSubtleGradientBox: View {
    let cornerRadius: CGFloat

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color.white, Color.creditHex(0xF7F7F7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .stroke(Color.creditHex(0xF7F7F7), lineWidth: 1)
    }
}

private struct CreditGlassPill: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    let text: String
    let height: CGFloat
    let horizontalPadding: CGFloat

    var body: some View {
        let capsule = Capsule(style: .continuous)
        Text(text)
            .font(BONTypography.zalando(size: 14, weight: .regular))
            .foregroundStyle(CreditPalette.tertiaryText)
            .padding(.horizontal, horizontalPadding)
            .frame(height: height)
            .background {
                // Figma 61:7626 spec: fill = rgba(255,255,255,0.12), no border highlight.
                // On iOS 26 we go through real Liquid Glass with NO additional base fill — `.regular`
                // already provides the frosted-glass refraction, and the tint is the only color overlay.
                // Earlier iterations added a 0.06 white base under the glass which compounded into a
                // far more opaque pill than the Figma spec, so the base fill is dropped here.
                if #available(iOS 26.0, *), !reduceTransparency {
                    // Use `.clear` (the lighter Liquid Glass variant) — `.regular` is too frosted on the
                    // blue gradient and reads more opaque than the Figma spec. `.clear` gives just the
                    // refraction without the heavy white frosting layer.
                    capsule
                        .glassEffect(.clear, in: capsule)
                } else if reduceTransparency {
                    capsule.fill(Color.white.opacity(0.78))
                } else {
                    capsule
                        .fill(Color.white.opacity(0.12))
                        .background(.ultraThinMaterial, in: capsule)
                }
            }
            // Figma drop shadow: X=0, Y=8, blur=24, #000 12% → SwiftUI radius = blur/2 = 12.
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 8)
    }
}

private struct CreditCircleButton: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    var asset: String?
    var systemName: String?
    let size: CGFloat

    init(asset: String, size: CGFloat) {
        self.asset = asset
        self.systemName = nil
        self.size = size
    }

    init(systemName: String, size: CGFloat) {
        self.asset = nil
        self.systemName = systemName
        self.size = size
    }

    var body: some View {
        let circle = Circle()
        Group {
            if let asset {
                Image(asset)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.50, height: size * 0.50)
            } else if let systemName {
                Image(systemName: systemName)
                    .font(.system(size: size * 0.44, weight: .regular))
            }
        }
        .foregroundStyle(Color.black.opacity(0.88))
        .frame(width: size, height: size)
        .background {
            CreditLiquidGlassSurface(
                shape: circle,
                tint: Color.white.opacity(0.28),
                fallbackFill: Color.white.opacity(0.46),
                borderOpacity: 0.55,
                reduceTransparency: reduceTransparency
            )
        }
        .shadow(color: Color.black.opacity(0.08), radius: 14, x: 0, y: 6)
    }
}

private struct CreditLiquidGlassSurface<S: InsettableShape>: View {
    let shape: S
    let tint: Color
    let fallbackFill: Color
    let borderOpacity: Double
    let reduceTransparency: Bool

    var body: some View {
        ZStack {
            if #available(iOS 26.0, *), !reduceTransparency {
                shape
                    .fill(Color.white.opacity(0.18))
                    .glassEffect(.regular.tint(tint), in: shape)
            } else if reduceTransparency {
                shape.fill(Color.white.opacity(0.92))
            } else {
                shape
                    .fill(fallbackFill)
                    .background(.ultraThinMaterial, in: shape)
            }

            shape
                .strokeBorder(Color.white.opacity(borderOpacity), lineWidth: 0.6)
                .blendMode(.screen)
                .allowsHitTesting(false)
        }
    }
}

private struct CreditMiniComposer: View {
    var body: some View {
        HStack(spacing: 0) {
            Text("Chat about this card...")
                .font(BONTypography.zalando(size: 12, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.72))
                .padding(.leading, 20)
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.16))
                    .frame(width: 52, height: 52)
                Image("chatVoice")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.white)
                    .frame(width: 16, height: 16)
            }
            .padding(.trailing, 6)
        }
        .frame(height: 64)
        .background(BONChatGlassCapsule())
    }
}

private extension Color {
    static func creditHex(_ value: UInt32, alpha: Double = 1) -> Color {
        Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: alpha
        )
    }
}
