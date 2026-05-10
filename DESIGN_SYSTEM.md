# BON Design System

## Purpose

This document is the source of truth for BON's native iOS SwiftUI design system. It translates the Figma app into stable foundations, component APIs, asset decisions, accessibility rules, motion behavior, and pixel-QA gates before any product screen is implemented.

## Current Status

- Source: Figma file `O2 Final`, key `SMVZkasMIx4TzoOMBxqSs9`.
- Figma baseline frame size: `390 x 845`.
- Primary device target: iPhone Pro simulator, currently `iPhone 17 Pro`.
- Production width policy: screens adapt to the actual iPhone Pro width; do not center a fixed `390pt` canvas on wider devices.
- Visual target: light mode first.
- Dark mode: semantic token slots reserved, values not approved.
- Golden candidate: `1:628` - `Home - First timer - clicked on home`.
- Product screen implementation: blocked until this system is reviewed.

## Design Principles

- Use Figma as the visual source of truth and SwiftUI as the interaction source of truth.
- Promote repeated values into named tokens or component properties.
- Keep reusable foundations in `BON/DesignSystem`.
- Prefer Apple-native controls, SF Symbols, materials, haptics, and safe-area behavior when they do not break visual parity.
- Export complex decorative and card graphics as production assets unless they must reflect live data.
- Never depend on localhost Figma asset URLs at runtime.

## Token Taxonomy

BON uses three token layers:

| Layer | Purpose | Examples |
| --- | --- | --- |
| Reference | Literal Figma evidence | `#A1FF00`, `56`, `100`, `0 12 12 rgba(0,0,0,0.16)` |
| Semantic | Product meaning | `accentLime`, `surfacePrimary`, `textSecondary`, `glassDark`, `navShadow` |
| Component | Anatomy-specific role | `heroPanel.radius`, `ctaPill.height`, `bottomNav.itemGap`, `chatComposer.sendButtonWidth` |

Screen code should consume semantic or component tokens. Reference values belong in design-system files and docs only.

## Foundations

### Color

| Role | Light value | Dark slot | Notes |
| --- | --- | --- | --- |
| `backgroundPrimary` | `#FFFFFF` | reserved | Figma app background. |
| `surfacePrimary` | `#FFFFFF` | reserved | Cards, hero panel, input surfaces. |
| `surfaceElevated` | `#FFFFFF` | reserved | Elevated white panels with shadow or inset highlight. |
| `textPrimary` | `#000000` | reserved | Main text. |
| `textSecondary` | `rgba(51,51,51,0.64)` | reserved | AI mode label and secondary copy. |
| `textTertiary` | `#8A8A8A` | reserved | Low emphasis labels. |
| `textOnDark` | `#FFFFFF` | reserved | CTA and active nav labels. |
| `borderSubtle` | `#EEEEEE` | reserved | Light borders. |
| `divider` | `#EBEBEB` | reserved | Dividers from Figma variables. |
| `accentLime` | `#A1FF00` | reserved | Brand accent and glow anchor. |
| `limeGlow` | `rgba(219,255,111,0.80)` | reserved | Hero inset glow. |
| `glassDark` | `rgba(0,0,0,0.88)` | reserved | Bottom nav and CTA fill. |
| `glassLight` | `rgba(255,255,255,0.10)` | reserved | Top icon button fill. |
| `navInactive` | `#BBBBBB` | reserved | Bottom nav inactive labels. |
| `success` | provisional | reserved | Required semantic slot. |
| `warning` | provisional | reserved | Required semantic slot. |
| `error` | provisional | reserved | Required semantic slot. |

Known Figma variable definitions are sparse. `Home - Returning scenarios` exposes `Light/Border`, `Light/Text/Primary`, `Base Colors/pop black/100`, and `Light/Primary`; `AI chat` additionally exposes `Light/Divider`, `System Background/Light/Primary`, `Label Color/Light/Primary`, and SF Pro text styles.

Brand lime primitive scale:

| Token | Hex | Usage guidance |
| --- | --- | --- |
| `lime50` | `#F7FFD9` | Pale backgrounds, large soft wash, accessible tint fields. |
| `lime100` | `#ECFFAA` | Light selected surfaces and quiet highlights. |
| `lime200` | `#DBFF6F` | Glow source; `limeGlow` uses this at `0.80` opacity. |
| `lime300` | `#C5FF33` | Mid-emphasis highlights and chart bands. |
| `lime400` | `#B5FF14` | Bright hover/active accents and dense chart blocks. |
| `lime500` | `#A1FF00` | Primary brand accent; `accentLime` maps here. |
| `lime600` | `#7BC700` | Positive trend accents requiring more contrast. |
| `lime700` | `#5C9400` | Text/icon accents on light lime surfaces. |
| `lime800` | `#3F6500` | High-contrast lime text and dark accent states. |
| `lime900` | `#1F3300` | Deep green ink or dark-mode contrast anchor. |

### Typography

| Role | Family | Size | Line height | Notes |
| --- | --- | --- | --- | --- |
| `screenTitle` | Zalando Sans | 24 | 29 | Main page and card titles. |
| `sectionTitle` | Zalando Sans | 14 | 17 | Section headers such as "More actions". |
| `body` | Zalando Sans | 16 | 22-24 | Main explanatory copy. |
| `caption` | Zalando Sans | 12 | 15 | Small labels and metadata. |
| `navLabel` | Zalando Sans | 10 | 12 | Bottom nav labels. |
| `chip` | Zalando Sans | 14 | 17-20 | Chat suggestions, CTA labels. |
| `cta` | Zalando Sans | 14 | 17 | Pill buttons. |
| `numericDisplay` | Geist Pixel | 48 | natural | Hero amount, score, and large numbers. |
| `numericCompact` | Geist Pixel | 24-40 | natural | Smaller dashboard values. |
| `editorialAccent` | Instrument Serif | pending | pending | Reserve only if verified in final audited screens. |

Bundled font files:

- `ZalandoSans-Regular.ttf`
- `ZalandoSans-Light.ttf`
- `ZalandoSans-ExtraLight.ttf`
- `ZalandoSans-Medium.ttf`
- `ZalandoSans-SemiBold.ttf`
- `ZalandoSans-Bold.ttf`
- `GeistPixel-Grid.ttf`
- `GeistPixel-Square.ttf`
- `GeistPixel-Circle.ttf`
- `GeistPixel-Triangle.ttf`
- `GeistPixel-Line.ttf`

Licenses are bundled under `BON/Resources/FontLicenses`.

Remaining conditional font:

- `Instrument Serif` Italic only if the final audited screens still use it.

SwiftUI typography tokens must use the registered PostScript names from `BONFontFamily`, not display-family guesses. Simulator text can now use the bundled Zalando Sans and Geist Pixel fonts; pixel QA still requires Figma-to-simulator screenshot comparison once product screens exist.

### Spacing

| Token | Value | Usage |
| --- | --- | --- |
| `xxs` | 4 | Nav label/icon gap. |
| `xs` | 8 | Inner card padding, small vertical gaps. |
| `sm` | 12 | Button vertical padding, small groups. |
| `md` | 16 | Card/content standard inset. |
| `lg` | 20 | CTA horizontal padding and card gaps. |
| `xl` | 24 | Screen horizontal inset. |
| `xxl` | 32 | Hero vertical group spacing. |
| `xxxl` | 40 | Large screen separation. |

Figma also uses fixed widths such as `342`, `326`, `310`, `278`, `264`, and `112`; these should be component layout constraints, not global spacing tokens.

Responsive home-screen policy:

- Home AI/hero panel: `8pt` top/left/right margin on iPhone Pro.
- Main content and bottom nav: `24pt` left/right margin on iPhone Pro.
- On iPhone 17 Pro (`402pt` wide), hero width is `386pt`; main content and bottom nav width is `354pt`.

### Radius

| Token | Value | Usage |
| --- | --- | --- |
| `sm` | 8 | Small chips, small graphic rectangles. |
| `md` | 14 | Compact cards. |
| `lg` | 20 | Dashboard cards and rows. |
| `xl` | 28 | Large content cards. |
| `hero` | 56 | Hero panel. |
| `pill` | 100 | CTA, nav, AI mode, icon controls. |
| `fullyRounded` | 999 | Dynamic circles/capsules when exact 100 is not appropriate. |

### Elevation, Glass, And Glow

| Token | Figma value | Usage |
| --- | --- | --- |
| `controlSoft` | `0 8 32 rgba(0,0,0,0.08)` | Top icon buttons. |
| `cta` | `0 8 32 rgba(0,0,0,0.12)` | `Talk with AI` pill. |
| `nav` | `0 12 12 rgba(0,0,0,0.16)` | Floating bottom nav. |
| `limeInsetGlow` | `inset 0 0 12 rgba(219,255,111,0.80)` | Hero panel. |
| `whiteInsetGlow` | `inset 0 0 8 rgba(255,255,255,0.40)` | CTA pill. |
| `navInsetHighlight` | `inset 0 3 8 rgba(255,255,255,0.36)` | Bottom nav. |

SwiftUI `shadow` covers outer shadows. Inset glows require overlay strokes, layered blurs, or exported assets if native rendering cannot match Figma.

Bottom nav glass policy:

- `BONBottomNav` must preserve the Figma anatomy first: dark stained capsule, `0 12 12 rgba(0,0,0,0.16)` outer shadow, and soft inset lighting.
- On iOS 26+, the nav surface uses native Apple Liquid Glass as the functional layer: `GlassEffectContainer` plus `glassEffect(.regular.tint(...).interactive(), in: Capsule())` applied to the actual control surface after appearance modifiers.
- The BON dark stain sits inside the Liquid Glass surface to keep the Figma-dark identity without returning to a fully opaque capsule. Tune stain values with simulator crops, not by eye alone.
- On older iOS targets or Reduce Transparency, fall back to a dark material/solid surface that preserves legibility and the same nav geometry.
- The Figma inner shadow is not a border: implement `inset 0 3 8 rgba(255,255,255,0.36)` as a masked soft edge highlight plus diffuse inset that is visually present in the simulator crop. Do not add crisp outline strokes to the nav.
- Small nav glyphs must stay vector-backed and render as 16 pt visual icons; avoid screenshot PNGs unless SVG/PDF rendering fails in simulator.
- AI Chat edge glow uses a narrow animated lime gradient built from `lime50`, `lime100`, `lime200`, and `lime300`. Keep the side wash restrained so it reads as a screen-edge aura, not a wide solid border.

### Motion And Haptics

| Role | Behavior |
| --- | --- |
| `press` | Fast spring scale on buttons, chips, nav items; light impact haptic. |
| `reveal` | Soft spring for cards entering or expanding. |
| `sheetTransition` | Native sheet/navigation transition unless a custom morph is required. |
| `matchedMorph` | Matched geometry for AI pill, cards, and chat-to-action transitions where identity is clear. |
| `scrollPolish` | Subtle opacity/scale and sticky composer behavior; no layout jumps. |
| `chatIconMorph` | Composer icon state changes; voice, send, and stop icons crossfade with restrained scale/rotation unless Reduce Motion is enabled. |
| `chatSuggestionFlow` | Suggestion chips live in a persistent morph container; on typing they shrink toward the trailing edge, fade, and collapse reserved height smoothly. Reduce Motion uses opacity/height only. |
| `thinking` | Low-amplitude repeating opacity or dot animation; must stop cleanly. |
| `reducedMotion` | Replace morph/scroll effects with fade or no animation. |

Use `.sensoryFeedback` where available and `BONHaptics` for UIKit-backed fallback. Respect Reduce Motion and Reduce Transparency.

### Accessibility

- Minimum interactive hit target: 44 x 44.
- Every icon button needs a VoiceOver label.
- AI mode, CTA, chat chips, and nav items need selected/pressed/disabled states.
- Text must support at least one larger Dynamic Type step without clipped controls; where pixel layout is fixed, document the fixed-size decision.
- Contrast must be checked for dark glass labels, inactive nav text, chips, and lime-on-white usage.
- Do not rely only on lime or red/green to communicate status.

## Components

### Top Action Bar

- Anatomy: left icon button, centered AI mode pill, right icon button.
- Baseline: `326 x 40`, horizontal inset `24`, top y around `66-75`.
- States: normal, pressed, disabled, loading where relevant.
- Accessibility: each icon button announces action; AI mode announces current mode.
- SwiftUI API: `BONTopActionBar(leftAction:title:rightAction:)`.
- Asset dependencies: icon assets or SF Symbols for side controls.

### Icon Button

- Anatomy: 40 x 40 pill/circle, 16 pt icon, light glass fill, soft shadow.
- States: normal, pressed scale, disabled opacity, focus/accessibility highlight.
- SwiftUI API: `BONIconButton(symbol:assetName:accessibilityLabel:action:)`.

### AI Mode Pill

- Anatomy: 110 x 40 capsule, 12 pt label, subtle border.
- States: default, active, pressed, disabled.
- SwiftUI API: `BONModePill(title:isActive:action:)`.

### CTA Pill

- Anatomy: dark glass capsule, 14 pt label, white inset glow, outer shadow.
- Baseline examples: `112 x 33`, `310 x 48`, `238 x 33`.
- States: normal, pressed, disabled, loading, destructive if needed.
- SwiftUI API: `BONCTAPill(title:variant:size:action:)`.

### Chat Chip

- Anatomy: right-aligned or centered rounded prompt chip, 14-16 pt label.
- Initial and fallback response suggestions: bright lime prompt bubbles, no grey outline, `44pt` baseline height, `16pt` horizontal and `12pt` vertical text inset, trailing-aligned, max `65%` of device width before wrapping.
- Sent prompt chips: pale lime prompt bubbles, `48pt` baseline height, `16pt` horizontal and `12pt` vertical text inset, subtle lime stroke, trailing-aligned, max `65%` of device width before wrapping.
- Prompt-like chips use message geometry: rounded top-left, top-right, and bottom-left corners; bottom-right corner is sharp.
- States: normal, pressed, selected/sent, disabled.
- Accessibility: labels must be full prompt text, not truncated.
- SwiftUI API: `BONChatChip(text:isSelected:action:)`.

### AI Chat Response Cards

- Anatomy: `342pt` outer response section, `16pt` section gap, white card shell, `16pt` internal padding, `24pt` radius, `0 8 32 rgba(0,0,0,0.12)` shadow.
- `1:5061` action-card modules: soft lime tag `rgba(161,255,0,0.08)`, 14pt black metadata row, 16pt medium title, black `310 x 96` metric panel with lime 14/24/14 text, white `310 x 229` How panel with `20pt` pale-lime numbered badges, and black `310 x 48` CTA.
- `1:5061` curated-path modules: `310 x 145` three-month strip, month colors `#DEF1E7`, `lime100`, `lime200`, dark green text `#12472C`, muted result text `#4A9974`, and score progress row using a `193 x 6` track with a `93pt` lime gradient fill.
- `1:5165` payment-history module: white `342 x 326` shell with softer `0 8 16 rgba(0,0,0,0.12)` shadow, three timeline rows, 24 rounded `9 x 20` bars per row, `4pt` bar gap, green `lime600`, late red `#C70000`, and floating `view all` pill.
- `1:5165` hard-inquiries module: white `342 x 324` shell, three `310 x 64` `#F7F7F7` rows, 14pt regular account names, 14pt light muted age labels, and 12pt point impact.
- `1:5397` monthly-spending module: white `342 x 344` shell, `16pt` internal padding, `24pt` radius, `0 8 32 rgba(0,0,0,0.12)` shadow, `spent this month` caption, Geist Pixel `$6,136`, and `129 x 31` white filter pill.
- `1:5397` heatmap module: fixed `310 x 156` data graphic, not scaled to wider Pro card internals. Use 8pt rounded marks, 10pt grid spacing, `$10k` top-axis label, `$1k` baseline label, date labels `Apr 05`, `Apr 20`, `May 05`, and a sampled Figma row palette: `#FF3333`, `#FF5C5C`, `#FFBBBB`, `#FFE1E1`, empty gap row, `#FFEFE5`, `#FFF7EA`, `#F9F6D0`, `#FFFBD9`, `lime100`, `lime200`, `lime300`, `#B4FF33`, and `lime500`.
- `1:5397` metric strip: `310 x 57` `#F7F7F7` panel with two equal metric cells, 10pt uppercase captions, and 14pt semibold values.
- Do not blend sibling response-frame content. Each chat graphic pass must map exact strings and modules to its Figma frame ID before implementation.
- SwiftUI API shape: `BONChatResponseCard`, `AIChatMetricBox`, `AIChatHowSteps`, `AIChatMonthCard`, `AIChatScorePath`, `AIChatPaymentHistoryRows`, `AIChatHardInquiryRow`, `AIChatMonthlySpendingCard`, `AIChatMonthlySpendHeatmap`, `AIChatMonthlySpendMetricStrip`, plus scenario-specific composition.

### Hero Panel

- Anatomy: rounded white panel, top action bar, greeting, numeric display, explanation, CTA.
- Baseline: `374 x 407` for golden screen; returning scenario hero can be `374 x 478-610`.
- States: first-timer, credit score, paycheck, transaction, payment, statement, due-date.
- Asset dependencies: score rings, card clouds, charts, and decorative graphics likely exported.
- SwiftUI API: `BONHeroPanel(kind:content:primaryAction:)`.

### Feature Card

- Anatomy: `342` width stack, rounded white card, graphic area, title/body, optional CTA.
- States: static, pressed, partially occluded by nav, loading if data-driven.
- Asset dependencies: complex rectangle-cloud graphics should be exported unless live.
- SwiftUI API: `BONFeatureCard(title:subtitle:asset:action:)`.

### Bottom Nav

- Variants:
  - Product tab nav: five items, `342 x 64`, y `733`, radius `100`, dark glass.
  - Compact first-timer nav: five icon-only items, `200 x 44`, y `781`.
  - Chat composer: `342 x 64`, text input plus send button.
- Surface: native iOS 26+ Liquid Glass control layer with dark BON staining, exact Figma inner shadow `0 3 8 rgba(255,255,255,0.36)`, and exact outer floating shadow `0 12 12 rgba(0,0,0,0.16)`. Older iOS and Reduce Transparency keep a material/solid dark fallback.
- Item layout: natural visual item widths from Figma (`27`, `31`, `28`, `28`, `31`) with `36pt` horizontal padding and `justify-between` distribution.
- Icons: sanitized Figma SVG template assets rendered as vectors at 16 pt; active item is white, inactive items use `navInactive`.
- Labels: Zalando Sans Light for selected, ExtraLight for inactive, size `10`, tracking `0.10`, height `12`.
- Composer action/voice button: no visible border stroke. Edge definition should come from native Liquid Glass, graphite material tint, specular highlights, and shadow only.
- Composer glass tuning: tune the main shell and action insert together. The shell carries the dark BON stain and soft satin band; the action insert should remain graphite, not silver, with the native glass layer underneath the brand tint so material brightness does not read as an outline.
- Composer text field: use a light caret/tint so the insertion bar remains visible on the dark glass shell.
- States: selected, inactive, pressed, disabled, keyboard lifted.
- Accessibility: each item has label and selected trait; composer send button announces state.
- SwiftUI API: `BONBottomNav(items:selected:)` and `BONChatComposer(text:isThinking:onSend:)`.

### Dashboard Cards

- Anatomy: task card, progress card, more-action tiles, secure/private card.
- States: normal, loading, empty, pressed, data-updated.
- Assets: progress sparkline, dots, security artwork, action icons.
- SwiftUI API: `BONMetricCard`, `BONActionTile`, `BONInfoBanner`.

### Task And Progress Cards

- Anatomy: title, chart or graphic, numeric value, labels.
- Special handling: dense progress dots are better as SwiftUI data-driven Canvas only if live; otherwise export.
- Accessibility: expose concise summary such as "Saved 285 dollars so far".

### Transaction And Payment Rows

- Anatomy: logo/avatar, merchant/card text, secondary metadata, amount or action.
- States: pending, due, paid, selected, error.
- Assets: card issuer logos and merchant/category icons.
- SwiftUI API: `BONPaymentRow` and `BONTransactionRow`.

### Score And Ring Modules

- Anatomy: circular rings, numeric score, score delta, legends.
- States: loading, improved, declined, neutral.
- Implementation: prefer SwiftUI `Canvas` for live score/ring data; export static decorative rings if exact gradients/masks are required.
- Accessibility: score and trend must be spoken as text.

## Asset Strategy

| Asset class | Rule |
| --- | --- |
| SF Symbol | Use for common platform actions when the silhouette matches Figma. |
| Vector/PDF/SVG | Use for custom icons, nav glyphs, small marks, and static vector art. |
| Raster image | Use for detailed hero illustrations, card textures, photos, and composite Figma graphics. |
| SwiftUI-drawn | Use for live charts, rings, progress bars, simple shapes, and data-driven visuals. |

Initial classifications:

- Bottom nav icons: supplied sanitized SVG template assets; use `navCards`, `navSpend`, `navHome`, `navCredit`, and `navMoney`.
- Top action icons: supplied sanitized SVG template assets; use `topProfile` and `topBell`.
- Chat composer voice icon: supplied sanitized SVG template asset; use `chatVoice`.
- Chat utility icons: supplied sanitized SVG template assets; use `chatMenu`, `chatInfo`, `chatFilters`, and `chatBackChevron` where those controls exist.
- Hero cloud/card rectangle graphics: export as assets unless they need live data.
- Credit score rings: SwiftUI-drawn if values animate; exported if Figma gradients/masks are complex.
- Card issuer logos and app-specific artwork: raster/vector in `Assets.xcassets`.
- iOS keyboard in chat states: use native keyboard behavior, not a production asset.

Production asset work is not complete. The app must not ship with localhost Figma URLs.

## Screen Inventory

### Home - First Timer (`1:627`)

| Frame | Name | Baseline | References | Components | Risk |
| --- | --- | --- | --- | --- | --- |
| `1:2962` | Home - First timer | `390 x 845` | `FigmaExports/home-first-timer-base-screenshot.sse` | compact nav, CTA, hero | medium |
| `1:628` | Home - First timer - clicked on home | `390 x 845` | `FigmaExports/home-clicked-figma.png`, `FigmaExports/home-clicked-screenshot.sse` | hero panel, feature cards, bottom nav | high |
| `1:3008` | Home - First timer - budgeting | `390 x 845` | `FigmaExports/home-first-timer-budgeting-screenshot.sse` | CTA, compact nav, chart graphic | high |
| `1:4201` | Home - First timer - credit score | `390 x 845` | `FigmaExports/home-first-timer-credit-score-screenshot.sse` | CTA, compact nav, score/ring | high |
| `1:4253` | Home - First timer - Cash advance | `390 x 845` | `FigmaExports/home-first-timer-cash-advance-screenshot.sse` | CTA, compact nav, benefit pills | medium |

### Home - Returning Scenarios (`1:4312`)

| Frame | Name | Baseline | References | Components | Risk |
| --- | --- | --- | --- | --- | --- |
| `1:4313` | Home - Credit score | `390 x 1413` | `FigmaExports/home-returning-credit-score-screenshot.sse` | long scroll, hero score, cards, nav | high |
| `1:4474` | Home - Paycheck arrived | `390 x 845` | `FigmaExports/home-returning-paycheck-arrived-screenshot.sse` | balance hero, spend card, task/progress | high |
| `1:4589` | Home - New transactions | `390 x 845` | `FigmaExports/home-returning-new-transactions-screenshot.sse` | transaction rows, task/progress | high |
| `1:4725` | Home - Payment due | `390 x 845` | `FigmaExports/home-returning-payment-due-screenshot.sse` | payment row, CTA, task/progress | high |
| `1:4825` | Home - Statement landed | `390 x 845` | `FigmaExports/home-returning-statement-landed-screenshot.sse` | chart/ring, CTA, task/progress | high |
| `1:4951` | Home - Due date near | `390 x 845` | `FigmaExports/home-returning-due-date-near-screenshot.sse` | payment card, CTA, task/progress | high |

### AI Chat (`1:5059`)

| Frame | Name | Baseline | References | Components | Risk |
| --- | --- | --- | --- | --- | --- |
| `1:7506` | Chat | `390 x 845` | `FigmaExports/ai-chat-initial-screenshot.sse` | chat text, chips, composer, top bar | high |
| `1:7550` | Chat - typing not started yet | `390 x 845` | `FigmaExports/ai-chat-keyboard-empty-screenshot.sse` | native keyboard, composer | high |
| `1:7595` | Chat - typing started | `390 x 845` | `FigmaExports/ai-chat-keyboard-typed-screenshot.sse` | native keyboard, composer input | high |
| `1:7631` | Chat - prompt sent - Agent thinking | `390 x 845` | `FigmaExports/ai-chat-thinking-screenshot.sse` | sent chip, thinking state, composer | high |

Additional AI-chat response sections are present and need later implementation audit:

- `1:5060` Credit score response flows: `1:5061`, `1:5165`.
- `1:5396` Budgeting response flows: `1:5397`, `1:6647`, `1:7245`.
- `1:7335` Debt payoff response flows: `1:7336`, `1:7423`.

These response frames define action cards, curated paths, card/payment rows, charts, and long-scroll chat layouts. They are system-relevant but not implementation-ready.

## QA Gates

Before any screen is implemented:

- Figma screenshot reference exists.
- Node metadata and relevant sublayer context are captured.
- Fonts are available or explicitly blocked.
- Production asset strategy is documented.
- Component states are listed.
- Accessibility labels and hit targets are planned.
- Pixel QA criteria are recorded.

Before any screen is approved:

- CLI build succeeds.
- Simulator screenshot is captured for iPhone Pro.
- Small and large width behavior is checked where relevant.
- Figma reference and simulator output are compared.
- Motion is checked with Reduce Motion.
- VoiceOver labels are present for tappable custom controls.

## Current Blockers

- `Instrument Serif` is not bundled and remains conditional on final audited-screen usage.
- Production asset exports into `Assets.xcassets` are not complete.
- Dark-mode values are reserved but not designed.
- Long AI-chat response flows need deeper state and asset extraction.
- No product screen is implementation-ready until the design-system review gate passes.
