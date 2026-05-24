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
}

private struct CreditMainScreen: View {
    let metrics: CreditMetrics
    let onHome: () -> Void
    let onOpenAI: () -> Void
    let onShowOfferDetails: () -> Void
    let onSelectLiability: (CreditLiabilityKind) -> Void

    var body: some View {
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
                        .frame(width: metrics.canvasWidth, height: 221)

                    CreditCardOffersSection(
                        contentWidth: metrics.contentWidth,
                        onShowDetails: onShowOfferDetails
                    )
                        .padding(.top, 0)

                    CreditLoanOffersSection(contentWidth: metrics.contentWidth)
                        .padding(.top, 48)

                    CreditSavingsOffersSection(contentWidth: metrics.contentWidth)
                        .padding(.top, 48)

                    CreditDisclosuresSection()
                        .frame(width: metrics.contentWidth)
                        .padding(.top, 48)

                    BONBottomNav(
                        selectedID: "credit",
                        items: HomeFirstTimerFixture.navItems,
                        width: 200,
                        variant: .compact,
                        collapseProgress: 1
                    ) { item in
                        if item.id == "home" {
                            onHome()
                        }
                    }
                    .padding(.top, 32)
                    .padding(.bottom, 24 + metrics.safeBottom)
                }
                .frame(width: metrics.canvasWidth)
                .frame(maxWidth: .infinity)
            }
            .background(Color.white)
        }
        .frame(width: metrics.screenWidth, height: metrics.screenHeight)
    }
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
                    .init(color: Color.creditHex(0xC5EAFA), location: 0),
                    .init(color: Color.creditHex(0xC1EAFC), location: 0.50),
                    .init(color: .white, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 609)

            HStack(alignment: .top) {
                CreditCircleButton(systemName: "sparkle", size: 32)

                Spacer(minLength: 0)

                CreditGlassPill(text: "Free credit report", height: 32, horizontalPadding: 16)
            }
            .frame(width: contentWidth)
            .padding(.top, 70)

            VStack(spacing: 2) {
                Text("total outstanding balance")
                    .font(BONTypography.zalando(size: 12, weight: .light))

                Text("$41,860")
                    .font(BONTypography.geistPixel(size: 48))
                    .tracking(-0.96)
            }
            .foregroundStyle(Color.black)
            .multilineTextAlignment(.center)
            .padding(.top, 150)

            CreditLiabilitiesSummaryCard(onSelect: onSelectLiability)
                .frame(width: contentWidth)
                .padding(.top, 253)

            Button(action: onOpenAI) {
                CreditAIPromoCard(width: contentWidth)
            }
            .buttonStyle(BONScaleButtonStyle())
            .padding(.top, 609)
        }
        .frame(width: canvasWidth, height: 736, alignment: .top)
    }
}

private struct CreditLiabilitiesSummaryCard: View {
    let onSelect: (CreditLiabilityKind) -> Void

    private let rows: [CreditLiabilitySummaryRow] = [
        .init(kind: .creditCards, icon: "creditcard", title: "Credit cards balance", amount: "$11,480"),
        .init(kind: .student, icon: "graduationcap", title: "Student loan", amount: "$10,000"),
        .init(kind: .auto, icon: "car", title: "Auto loan", amount: "$7,456"),
        .init(kind: .personal, icon: "doc.text", title: "Personal loan", amount: "$2,045"),
        .init(kind: .mortgage, icon: "house", title: "Mortgage loan", amount: "$10,879")
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.title) { index, row in
                Button {
                    BONHaptics.selection()
                    onSelect(row.kind)
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: row.icon)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.black.opacity(0.46))
                            .frame(width: 20, height: 20)

                        Text(row.title)
                            .font(BONTypography.zalando(size: 14, weight: .medium))
                            .tracking(0.28)
                            .foregroundStyle(Color.black)

                        Spacer(minLength: 12)

                        Text(row.amount)
                            .font(BONTypography.geistPixel(size: 14))
                            .foregroundStyle(Color.black)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Color.black.opacity(0.42))
                    }
                    .frame(height: 41)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if index < rows.count - 1 {
                    Divider()
                        .background(Color.black.opacity(0.06))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.48))
                .shadow(color: Color.black.opacity(0.12), radius: 32, x: 0, y: 8)
        }
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

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12), radius: 32, x: 0, y: 8)

            Image("creditAIPromoArtwork")
                .resizable()
                .scaledToFill()
                .frame(width: 185, height: 127)
                .clipped()
                .offset(x: -5)

            Rectangle()
                .fill(Color.white)
                .blur(radius: 7)
                .frame(width: 210, height: 160)
                .offset(x: 132)

            VStack(alignment: .leading, spacing: 12) {
                Text("Get debt-free faster\nwith BON Credit AI.")
                    .font(BONTypography.zalando(size: 16, weight: .medium))
                    .lineSpacing(2)
                    .foregroundStyle(Color.black)
                    .frame(width: 174, alignment: .leading)

                Text("Start chat")
                    .font(BONTypography.zalando(size: 14, weight: .medium))
                    .foregroundStyle(Color.black)
                    .frame(height: 36)
                    .padding(.horizontal, 16)
                    .background {
                        Capsule(style: .continuous)
                            .fill(BONColor.lime500)
                            .stroke(Color.black, lineWidth: 1)
                    }
            }
            .offset(x: 149)
        }
        .frame(width: width, height: 127)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct CreditProductsHeader: View {
    let canvasWidth: CGFloat
    let contentWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Product & offers")
                        .font(BONTypography.zalando(size: 20, weight: .medium))
                        .foregroundStyle(Color.black)

                    Text("Find best options for you")
                        .font(BONTypography.zalando(size: 14, weight: .light))
                        .foregroundStyle(Color.creditHex(0x777777))
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Powered by")
                        .font(BONTypography.zalando(size: 12, weight: .light))
                        .foregroundStyle(Color.creditHex(0x333333))
                    Image("creditMoneyLionLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 16)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    CreditProductChip(title: "Credit cards", systemIcon: "creditcard", isSelected: true)
                    CreditProductChip(title: "Cash advance", systemIcon: "dollarsign.circle", isSelected: false)
                    CreditProductChip(title: "Savings accounts", systemIcon: "banknote", isSelected: false)
                    CreditProductChip(title: "Personal loans", systemIcon: "doc.text", isSelected: false)
                }
                .padding(4)
            }
            .frame(height: 40)
            .background {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.10))
                    .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 0)
            }

            Divider()
                .background(Color.black.opacity(0.08))
        }
        .frame(width: contentWidth, alignment: .leading)
        .padding(.top, 64)
        .frame(width: canvasWidth, height: 221, alignment: .top)
        .background(Color.white)
    }
}

private struct CreditProductChip: View {
    let title: String
    let systemIcon: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemIcon)
                .font(.system(size: 11, weight: .regular))

            Text(title)
                .font(BONTypography.zalando(size: 12, weight: .regular))
        }
        .foregroundStyle(isSelected ? Color.white : Color.black)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(height: 32)
        .background {
            Capsule(style: .continuous)
                .fill(isSelected ? Color.black : Color.clear)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        }
    }
}

private struct CreditCardOffersSection: View {
    let contentWidth: CGFloat
    let onShowDetails: () -> Void

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
                                .foregroundStyle(title == "Dining" ? Color.white : Color.creditHex(0x777777))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background {
                                    Capsule(style: .continuous)
                                        .fill(title == "Dining" ? Color.black : Color.clear)
                                        .stroke(title == "Dining" ? Color.black : Color.creditHex(0x777777), lineWidth: 1)
                                }
                        }
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    CreditCardOfferCard(
                        imageAsset: "creditOfferChaseCard",
                        title: "Chase Sapphire Reserve",
                        subtitle: "Great for people with minimal credit history",
                        annualFee: "$0",
                        apr: "0%",
                        benefits: ["No interest", "No credit check to apply", "Help you build credit stress free"],
                        onShowDetails: onShowDetails
                    )

                    CreditCardOfferCard(
                        imageAsset: "creditOfferAvantCard",
                        title: "Avant credit card",
                        subtitle: "Great for repairing your credit",
                        annualFee: "$39",
                        apr: "35%",
                        benefits: ["No deposit required", "No penalty APR", "No hidden fees"],
                        onShowDetails: onShowDetails
                    )
                }
                .padding(.bottom, 32)
            }
            .padding(.horizontal, -24)
            .contentMargins(.horizontal, 24, for: .scrollContent)
        }
        .frame(width: contentWidth, alignment: .leading)
    }
}

private struct CreditCardOfferCard: View {
    let imageAsset: String
    let title: String
    let subtitle: String
    let annualFee: String
    let apr: String
    let benefits: [String]
    let onShowDetails: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 24) {
            VStack(spacing: 16) {
                Image(imageAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 292, height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.black.opacity(0.24), radius: 32, x: 0, y: 8)

                VStack(spacing: 8) {
                    Text(title)
                        .font(BONTypography.zalando(size: 20, weight: .medium))
                        .foregroundStyle(Color.black)
                        .lineLimit(1)

                    Label(subtitle, systemImage: "sparkle")
                        .font(BONTypography.zalando(size: 14, weight: .light))
                        .foregroundStyle(Color.creditHex(0x3B7AF0))
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)
                }
            }

            VStack(spacing: 16) {
                CreditStatPairBox(leftTitle: "Annual fee", leftValue: annualFee, rightTitle: "APR", rightValue: apr)

                ZStack(alignment: .bottom) {
                    VStack(spacing: 12) {
                        ForEach(benefits, id: \.self) { benefit in
                            HStack(spacing: 12) {
                                Image(systemName: "seal")
                                    .font(.system(size: 13, weight: .light))
                                Text(benefit)
                                    .font(BONTypography.zalando(size: 14, weight: .light))
                                    .frame(width: 217, alignment: .leading)
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
                            Image(systemName: "chevron.up")
                                .font(.system(size: 9, weight: .medium))
                        }
                        .font(BONTypography.zalando(size: 14, weight: .light))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background {
                            Capsule(style: .continuous)
                                .fill(Color.white)
                                .stroke(BONColor.borderSubtle, lineWidth: 1)
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
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12), radius: 32, x: 0, y: 8)
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
                .background(Color.black.opacity(0.06))

            stat(title: rightTitle, value: rightValue)
        }
        .frame(width: 292, height: 75)
        .background(CreditSubtleGradientBox(cornerRadius: 12))
    }

    private func stat(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(BONTypography.zalando(size: 12, weight: .light))
                .foregroundStyle(Color.creditHex(0x333333))
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
                    .foregroundStyle(Color.creditHex(0x777777))
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
                .frame(width: 292, height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            CreditBlackCTA(title: "Apply now", width: 294, height: 47)
            CreditUnderlinedLink(title: "Rates & terms")
        }
        .padding(20)
        .frame(width: 332)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12), radius: 32, x: 0, y: 8)
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
                        .frame(width: 76, height: 22)

                    VStack(spacing: 2) {
                        Text("1.75%")
                            .font(BONTypography.geistPixel(size: 32))
                            .tracking(-0.64)
                        Text("Annual percentage yield")
                            .font(BONTypography.zalando(size: 12, weight: .light))
                            .foregroundStyle(Color.creditHex(0x777777))
                    }

                    CreditStatPairBox(leftTitle: "Monthly fee", leftValue: "$0", rightTitle: "Check writing", rightValue: "No")

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(["No minimum to open", "No monthly fees", "Member FDIC"], id: \.self) { item in
                            Label(item, systemImage: "seal")
                                .font(BONTypography.zalando(size: 14, weight: .light))
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
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.12), radius: 32, x: 0, y: 8)
            }
        }
        .frame(width: contentWidth, alignment: .leading)
    }
}

private struct CreditDisclosuresSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Divider()
                .background(Color.black.opacity(0.08))

            Text("Sponsored | Advertisers disclosure")
                .font(BONTypography.zalando(size: 10, weight: .medium))
                .foregroundStyle(Color.creditHex(0x777777))

            Text(disclosure)
                .font(BONTypography.zalando(size: 10, weight: .light))
                .lineSpacing(3)
                .foregroundStyle(Color.creditHex(0x777777))

            Text("Additional Information")
                .font(BONTypography.zalando(size: 10, weight: .medium))
                .foregroundStyle(Color.creditHex(0x777777))

            Text(additional)
                .font(BONTypography.zalando(size: 10, weight: .light))
                .lineSpacing(3)
                .foregroundStyle(Color.creditHex(0x777777))
        }
        .frame(width: 342, alignment: .leading)
    }

    private var disclosure: String {
        "The offers that appear are from companies which MoneyLion, and its partners receive compensation. This compensation may influence the selection, appearance, and order of appearance of the offers listed below."
    }

    private var additional: String {
        "The listings that appear on this page are from companies from which Even Financial, Inc. may impact how, where and in what order products appear. This is directed at, and made available to, persons in the continental U.S., Alaska and Hawaii only."
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

    var systemIcon: String {
        switch self {
        case .creditCards: "creditcard"
        case .auto: "car"
        case .student: "graduationcap"
        case .personal: "doc.text"
        case .mortgage: "house"
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
                CreditCardDebtScreen(metrics: metrics, onBack: onBack)
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
                                .stroke(Color.creditHex(0x1499FF).opacity(0.11), lineWidth: 1)
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
                            .stroke(Color.white.opacity(0.50), lineWidth: 1)
                            .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
                    }
            }
            .buttonStyle(BONScaleButtonStyle())

            Spacer()

            Button(action: onPicker) {
                HStack(spacing: 12) {
                    Image(systemName: kind.systemIcon)
                        .font(.system(size: 14, weight: .regular))
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

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.black)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(Color.white).shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8))
                    }
                    .buttonStyle(BONScaleButtonStyle())

                    Spacer()

                    HStack(spacing: 12) {
                        Image(systemName: "creditcard")
                            .frame(width: 32, height: 32)
                            .background(Circle().stroke(Color.black.opacity(0.16), lineWidth: 1))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Credit cards")
                                .font(BONTypography.zalando(size: 14, weight: .medium))
                            Text("5 open")
                                .font(BONTypography.zalando(size: 12, weight: .light))
                        }
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                    }
                    .foregroundStyle(Color.black)
                }
                .frame(width: 342)
                .padding(.top, 62)

                VStack(spacing: 8) {
                    Text("Total outstanding balance")
                        .font(BONTypography.zalando(size: 12, weight: .light))
                    Text("$26,893")
                        .font(BONTypography.geistPixel(size: 48))
                        .tracking(-0.96)
                    Text("Costing ~ $285/mo in interest")
                        .font(BONTypography.zalando(size: 12, weight: .regular))
                        .foregroundStyle(Color.creditHex(0xFF3333))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.creditHex(0xFF3333).opacity(0.10)))
                }
                .padding(.top, 48)

                VStack(alignment: .leading, spacing: 18) {
                    Text("Your credit cards")
                        .font(BONTypography.zalando(size: 16, weight: .medium))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Image("creditOfferChaseCard").resizable().scaledToFill().frame(width: 90, height: 56).clipShape(RoundedRectangle(cornerRadius: 4))
                            Image("creditOfferAvantCard").resizable().scaledToFill().frame(width: 90, height: 56).clipShape(RoundedRectangle(cornerRadius: 4))
                            Image("creditOfferChaseCard").resizable().scaledToFill().frame(width: 90, height: 56).clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    .padding(.horizontal, -24)
                }
                .frame(width: 342, alignment: .leading)
                .padding(.top, 32)

                CreditDebtCard(title: "Chase sapphire reserve", tint: Color.creditHex(0x35C759))
                    .padding(.top, 32)
                CreditDebtCard(title: "Discover it student", tint: BONColor.lime500)
                    .padding(.top, 64)
                CreditDebtChatCard()
                    .padding(.top, 64)

                Color.clear.frame(height: 80)
            }
            .frame(width: metrics.canvasWidth)
            .frame(maxWidth: .infinity)
        }
        .background(Color.white)
    }
}

private struct CreditDebtCard: View {
    let title: String
    let tint: Color

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 40, height: 40)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(BONTypography.zalando(size: 16, weight: .medium))
                        Text("XX 2345")
                            .font(BONTypography.zalando(size: 12, weight: .light))
                            .foregroundStyle(Color.creditHex(0x777777))
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .frame(height: 82)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 4)
                }
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(tint)
                        .frame(height: 1)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                    metric("$6,561", "Balance")
                    metric("$185", "Monthly min.")
                    metric("~$23", "Monthly interest", color: Color.creditHex(0xFF3333))
                    metric("91%", "Current utilization")
                }
                .frame(height: 160)

                VStack(alignment: .leading, spacing: 10) {
                    Label("AI suggests:", systemImage: "sparkle")
                        .font(BONTypography.zalando(size: 10, weight: .regular))
                        .foregroundStyle(BONColor.lime600)
                    Text("This card is costing you the most and dragging your score as well as your overall finances down.")
                        .font(BONTypography.zalando(size: 12, weight: .light))
                        .lineSpacing(3)
                    CreditUnderlinedLink(title: "Chat about this card", color: BONColor.lime600)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding(16)
                .frame(width: 294)
                .background {
                    Rectangle()
                        .fill(BONColor.lime50)
                        .stroke(BONColor.lime300, lineWidth: 1)
                }

                CreditBlackCTA(title: "Link card", width: 294, height: 47)
                    .padding(.top, 28)
                    .padding(.bottom, 24)
            }
            .frame(width: 342)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.12), radius: 32, x: 0, y: 8)
            }
        }
    }

    private func metric(_ value: String, _ label: String, color: Color = .black) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(BONTypography.geistPixel(size: 18))
                .foregroundStyle(color)
            Text(label)
                .font(BONTypography.zalando(size: 10, weight: .light))
                .foregroundStyle(Color.creditHex(0x777777))
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .border(Color.black.opacity(0.04), width: 0.5)
    }
}

private struct CreditDebtChatCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                CreditCircleButton(systemName: "chevron.left", size: 40)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amex blue cash preferred")
                        .font(BONTypography.zalando(size: 16, weight: .medium))
                    Text("XX 2345")
                        .font(BONTypography.zalando(size: 12, weight: .light))
                        .foregroundStyle(Color.creditHex(0x777777))
                }
                Spacer()
            }
            Text("This card is costing you the most and dragging your score as well as your overall finances down.")
                .font(BONTypography.zalando(size: 16, weight: .regular))
                .lineSpacing(4)
            Text("How can I payoff this card?")
                .font(BONTypography.zalando(size: 14, weight: .regular))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(BONColor.lime100)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 24,
                        bottomLeadingRadius: 24,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 24,
                        style: .continuous
                    )
                )
                .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer(minLength: 260)
            CreditMiniComposer()
        }
        .padding(24)
        .frame(width: 342, height: 544)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.12), radius: 32, x: 0, y: 8)
        }
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
                            Image(systemName: kind.systemIcon)
                                .font(.system(size: 15, weight: .regular))
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

    var body: some View {
        Text(title)
            .font(BONTypography.zalando(size: 14, weight: .medium))
            .foregroundStyle(Color.white)
            .frame(width: width, height: height)
            .background(Capsule(style: .continuous).fill(Color.black))
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
    let text: String
    let height: CGFloat
    let horizontalPadding: CGFloat

    var body: some View {
        Text(text)
            .font(BONTypography.zalando(size: 14, weight: .regular))
            .foregroundStyle(Color.creditHex(0x333333))
            .padding(.horizontal, horizontalPadding)
            .frame(height: height)
            .background {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.12))
                    .background(.ultraThinMaterial, in: Capsule(style: .continuous))
                    .shadow(color: Color.black.opacity(0.12), radius: 24, x: 0, y: 8)
            }
    }
}

private struct CreditCircleButton: View {
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
        Group {
            if let asset {
                Image(asset)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size * 0.56, height: size * 0.56)
            } else if let systemName {
                Image(systemName: systemName)
                    .font(.system(size: size * 0.42, weight: .regular))
            }
        }
        .foregroundStyle(Color.black)
        .frame(width: size, height: size)
        .background {
            Circle()
                .fill(Color.white.opacity(0.40))
                .background(.ultraThinMaterial, in: Circle())
                .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
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
