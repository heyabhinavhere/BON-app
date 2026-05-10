# BON Native iOS Implementation Workflow

## Goal

Build BON as a native iOS SwiftUI app that tracks the Figma design closely while still feeling like a polished Apple-platform product: smooth motion, native interaction patterns, correct safe-area behavior, accessible controls, and production-quality assets.

## Current Workspace State

- Workspace: `/Users/abhinavjain/BON app`
- Existing app project: native SwiftUI scaffold in `BON.xcodeproj`
- Git repository: initialized on 2026-05-06
- Local tooling observed on 2026-05-06:
  - Xcode: `26.4.1`
  - Swift: available at `/usr/bin/swift`
  - XcodeGen: not installed
  - iOS simulator runtime: `26.4`
  - iPhone Pro simulator available: `iPhone 17 Pro`

This means the first code phase should intentionally create the iOS project structure instead of trying to retrofit an existing app.
The project scaffold has now been created. The next implementation phase is not a product screen yet; it is the full BON design-system foundation pass. The audit placeholder should only be replaced after `DESIGN_SYSTEM.md`, `FIGMA_AUDIT.md`, workflow files, token updates, and verification gates are reviewed.

## Required Inputs

Before building UI code, collect these inputs:

- Figma file link and frame links for all app screens.
- Figma access permissions for design inspection and asset export.
- Target devices and orientations.
- Minimum iOS version.
- App name, bundle identifier, team/signing preference, and deployment target.
- Whether the design supports light mode only, dark mode, or both.
- Any custom fonts, licensed graphics, brand assets, and animation files.
- Backend/API expectations, if any screens are data-driven.
- Product states for each screen: loading, empty, error, disabled, selected, pressed, expanded, scrolled, keyboard visible.

Known inputs:

- Figma file: `https://www.figma.com/design/SMVZkasMIx4TzoOMBxqSs9/O2-Final?node-id=1-627&m=dev`
- Figma file key: `SMVZkasMIx4TzoOMBxqSs9`
- Starting node: `1-627`
- Native framework: SwiftUI
- Minimum iOS version: `18.0`
- Primary device class: iPhone Pro.
- Figma baseline width: `390 pt`.
- App project: created in this workspace.
- Design-system depth: full library first.
- Dark mode: reserve token slots; ship light-mode parity first.
- Fonts required for pixel QA: `Zalando Sans` and `Geist Pixel` are bundled; `Instrument Serif` remains conditional if still used after final audit.

## Core Principles

- Figma is the visual source of truth, but SwiftUI and Apple HIG patterns are the interaction source of truth.
- Build a design system first enough to avoid one-off screen code.
- Use native components and SF Symbols where they match the design.
- Use custom drawing, images, Lottie, Rive, or video only when the visual cannot be achieved cleanly with SwiftUI.
- Prove fidelity on one representative screen before scaling to the full app.
- Every screen needs screenshot QA on real simulator sizes, not just SwiftUI previews.
- Document intentional deviations from Figma, especially for accessibility or platform behavior.

## Mandatory Project Workflow

For every non-trivial BON implementation turn:

1. Read relevant entries in `tasks/lessons.md`.
2. Write or update `tasks/todo.md` with the plan, progress checklist, verification section, and review notes.
3. Ask before implementation: "Is there a simpler, more elegant system boundary?"
4. Use `$bon-design-system-builder` for design-system foundation changes.
5. Do not mark any task complete without proof in `tasks/todo.md`.
6. After any correction, update `tasks/lessons.md` with correction, root cause, prevention rule, and verification rule.

Staff-engineer standard:

- Reject repeated one-off values when they should become tokens.
- Reject component work without states, accessibility, and asset dependencies.
- Reject product screen readiness without Figma reference, production assets, fonts, and screenshot QA criteria.

## Project Architecture

Target structure once the app is scaffolded:

```text
BON/
  App/
    BONApp.swift
    AppEnvironment.swift
  DesignSystem/
    BONColor.swift
    BONTypography.swift
    BONSpacing.swift
    BONRadius.swift
    BONShadow.swift
    BONMotion.swift
    BONHaptics.swift
  Components/
    Buttons/
    Cards/
    Inputs/
    Navigation/
    Overlays/
    Media/
  Screens/
    Onboarding/
    Home/
    Detail/
    Settings/
  Assets.xcassets/
    Colors/
    Images/
    AppIcon.appiconset/
  Navigation/
    AppRoute.swift
    AppRouter.swift
  Models/
  ViewModels/
  Services/
  Tests/
  UITests/
  SnapshotTests/
```

Adjust folder names after the Figma screen inventory is known.

## Phase 1: Figma Audit

Deliverables:

- Screen inventory with frame IDs and implementation status.
- Component inventory: buttons, inputs, cards, list rows, tabs, sheets, dialogs, menus, toasts, charts, decorative graphics.
- Token inventory: colors, typography, spacing, radius, shadows, blur, opacity, gradients, materials.
- Asset inventory: icons, logos, illustrations, photos, background graphics, animation files.
- Interaction inventory: taps, drags, scroll states, transitions, loading animations, gestures, haptics.
- Risk list: areas that may need custom SwiftUI, UIKit bridging, raster assets, or design adjustment.

Acceptance gate:

- We know every screen and state that must ship.
- We know which frame will be the golden screen.
- We know which visuals are native, vector, raster, animated, or custom drawn.

Current audit scope:

- `Home - First timer` section `1:627`
- `Home - Returning scenarios` section `1:4312`
- `AI chat` section `1:5059`
- See `FIGMA_AUDIT.md` and `DESIGN_SYSTEM.md`.

## Phase 2: Native Design System

Build reusable SwiftUI foundations:

- `BONColor`: semantic colors mapped from Figma tokens.
- `BONTypography`: SF Pro/SF Rounded/custom font mapping with line-height handling.
- `BONSpacing`: spacing scale from Figma.
- `BONRadius`: corner radius tokens.
- `BONShadow`: shadow/material definitions tuned against simulator screenshots.
- `BONMotion`: spring, ease, duration, delay, and transition presets.
- `BONHaptics`: light, medium, selection, success, warning, error feedback.
- Base controls: primary button, secondary button, icon button, text field, card, section header, sheet container, loading indicator.

Acceptance gate:

- Components match the core Figma variants.
- Controls have pressed, disabled, loading, and accessibility states.
- Components work on small and large iPhone widths.

Current design-system deliverables:

- `DESIGN_SYSTEM.md` as the primary source of truth.
- `BON/DesignSystem/*` as executable SwiftUI foundations.
- `tasks/todo.md` and `tasks/lessons.md` as process gates.
- `bon-design-system-builder` local Codex skill as the repeatable workflow.

## Phase 3: Asset Pipeline

Rules:

- Prefer SF Symbols for common Apple-native icons when visually acceptable.
- Export simple custom icons as PDF/vector assets where possible.
- Export detailed artwork as appropriately scaled PNG/WebP assets.
- Preserve transparent backgrounds for cutouts and overlays.
- Avoid low-resolution exports and screenshots-as-assets.
- Keep naming stable and semantic, for example `homeHeroArtwork`, `brandMark`, `emptyStateIllustration`.
- Track source Figma node IDs for non-trivial assets.

Acceptance gate:

- Assets render sharply on `@2x` and `@3x` devices.
- No placeholder artwork remains in production screens.
- App icon and launch assets are handled separately from in-app assets.

Current blocker:

- Production asset exports have not been completed.
- `Instrument Serif` is not bundled and must stay out of screen implementation unless verified in final audited screens.

## Phase 4: Golden Screen

Pick one representative, high-complexity screen and implement it first.

Current golden-screen candidate:

- `1:628` — `Home - First timer - clicked on home`
- Figma reference: `FigmaExports/home-clicked-figma.png`
- Size: `390 x 845`

Golden screen criteria:

- Contains real typography hierarchy.
- Uses multiple reusable components.
- Includes one or more custom graphics or images.
- Has scroll/safe-area behavior.
- Has at least one interaction or animation.

Workflow:

1. Capture Figma reference screenshot.
2. Implement the SwiftUI screen using design-system tokens.
3. Run in simulator.
4. Capture simulator screenshots.
5. Compare layout, spacing, typography, colors, radius, shadows, and assets.
6. Tune until the visual delta is small and understood.
7. Record any intentional deviations.

Acceptance gate:

- The golden screen is visually approved before broad screen implementation starts.

Current gate:

- Golden screen `1:628` has a first native SwiftUI implementation pass.
- Build and simulator launch are passing.
- Broad product implementation still waits until golden-screen pixel QA is approved.
- Current QA evidence: `PixelQA/home-1-628-iphone17pro-top-nav-credit-assets-normalized.png` and `PixelQA/home-1-628-top-nav-credit-assets-diff.png`.
- Current diff: `20.7717%` mismatch at threshold `8`; remaining deltas are recorded in `FIGMA_AUDIT.md`.
- Current Pro-device responsive evidence: `PixelQA/home-17pro-scroll-content-centered-logical.png`.
- Current Pro-device centering proof: CTA center `200.5`, section title center `200.5`, nav center `200.5`, and amount center `202.0` against the iPhone 17 Pro screen center `201.0`.
- Current bottom-nav Liquid Glass evidence: `PixelQA/home-17pro-nav-liquid-glass-inner-shadow-corrected-logical.png`, `PixelQA/bottom-nav-liquid-glass-inner-shadow-corrected-crop.png`, and `PixelQA/bottom-nav-liquid-glass-inner-shadow-corrected-side-by-side.png`.
- Current bottom-nav implementation: iOS 26+ uses `GlassEffectContainer` and `glassEffect(.regular.tint(...).interactive(), in: Capsule())` on the actual control surface, with a BON dark stained layer, exact outer shadow `0 12 12 rgba(0,0,0,0.16)`, a visually restored Figma inner shadow rendered as a thin soft edge highlight plus diffuse inset without crisp border strokes, natural item widths, tracked Zalando Sans labels, sanitized SVG template nav icons, and an iOS 18 material fallback.
- Current bottom-nav comparison: known-box normalized RGB diff is `9.94/12.35/13.46`; measured luminance is top-edge `51.4` vs Figma `51.0`, top inner band `34.2` vs `26.1`, left over art `22.7` vs `17.9`, center `36.0` vs `31.8`, right over white `35.4` vs `35.2`, bottom band `24.9` vs `22.5`.
- Current Pro-device layout policy: do not force the `390pt` Figma width; home AI/hero panel uses `8pt` top/left/right margin, and main content/nav uses `24pt` left/right margin.

## Phase 5: Full Screen Implementation

Implementation order:

1. Static layout for each screen.
2. Shared components extracted only when a pattern repeats or is clearly reusable.
3. Navigation and presentation flows.
4. Interactive states.
5. Data wiring or mocked data boundaries.
6. Error, empty, and loading states.
7. Final animation and polish pass.

Acceptance gate per screen:

- Pixel QA screenshot captured.
- Light/dark behavior verified if applicable.
- Small and large iPhone layouts verified.
- Keyboard and safe-area behavior verified where relevant.
- Accessibility labels and hit targets checked.

## Phase 6: Motion And Interaction

Motion should feel native, not web-translated.

Use:

- `withAnimation` and transaction tuning for state changes.
- `spring` for physical UI movement.
- `matchedGeometryEffect` for shared element transitions.
- `gesture` and `simultaneousGesture` for direct manipulation.
- `.sensoryFeedback` or UIKit haptics where appropriate.
- Native sheet/navigation transitions unless a custom transition is clearly required.

Motion acceptance gate:

- Animations are interruptible.
- No layout jumps during animation.
- Scrolling stays smooth.
- Buttons and cards provide immediate tactile feedback.
- Heavy graphics do not cause dropped frames.

## Phase 7: QA Matrix

Default simulator classes:

- Small iPhone width, for example iPhone SE class.
- Standard iPhone width.
- Large Pro Max width.

Checks:

- Build succeeds from CLI.
- App launches cleanly.
- Screens match Figma references.
- Text does not truncate unexpectedly.
- Hit targets are at least Apple-recommended sizes unless the design explicitly calls for display-only elements.
- Safe areas are respected.
- Dynamic Type decision is documented per major screen.
- VoiceOver labels exist for tappable custom controls.
- Motion reduction behavior is acceptable.
- No debug placeholders remain.

## Phase 8: Production Readiness

Before release-oriented work:

- Initialize git if not already done.
- Add a reproducible build command.
- Decide whether to use a project generator such as XcodeGen or keep a hand-managed Xcode project.
- Add lint/format tooling if useful.
- Add unit tests for logic and snapshot/UI tests for high-risk visual surfaces.
- Configure app icon, launch screen, permissions strings, signing, and bundle settings.
- Prepare TestFlight build workflow.

## Working Tracker

### Decisions

| Decision | Status | Notes |
| --- | --- | --- |
| Native framework | Decided | SwiftUI |
| Existing project | Decided | Native Xcode project scaffold exists in `BON.xcodeproj` |
| Minimum iOS version | Decided | `18.0` |
| Device matrix | Partial | Primary: iPhone Pro class; verify small and Pro Max later |
| Figma baseline | Decided | `390 pt` width |
| Dark mode | Partial | Light-mode parity first; dark token slots reserved |
| Project generation | Decided for now | Hand-managed Xcode project; XcodeGen not installed |
| Snapshot testing | Deferred | Decide after golden screen proves the visual QA workflow |
| Design-system gate | Passed for golden pass | Design-system foundation exists; broad product implementation waits for golden-screen pixel approval |

### Figma Screens

| Screen | Figma node | States | Status |
| --- | --- | --- | --- |
| Home - First timer | `1:627` | base, clicked home, budgeting, credit score, cash advance | System-audited |
| Home - Returning scenarios | `1:4312` | credit score, paycheck, transactions, payment due, statement, due date | System-audited |
| AI chat | `1:5059` | initial, keyboard empty, typed, sent/thinking, long response flows | Implementation in progress; detailed response frames `1:5061`, `1:5165`, and `1:5397` have audited SwiftUI modules |
| Golden candidate | `1:628` | clicked home | First SwiftUI pass built; pixel QA not approved |

### Components

| Component | Figma source | Native strategy | Status |
| --- | --- | --- | --- |
| Top action bar | Hero and chat frames | SwiftUI HStack using icon buttons and mode pill | Specified in `DESIGN_SYSTEM.md` |
| Icon button | `1:1733`, `1:1739`, repeated | SF Symbol if matched; otherwise vector asset | Specified |
| AI mode pill | repeated `AI mode` controls | Capsule control with subtle border | Specified |
| CTA pill | `Talk with AI`, payment actions | Dark glass capsule with haptics | Specified |
| Chat chip | AI chat suggestions and sent prompts | Bright lime suggestion variant plus pale lime sent state | Specified |
| Hero panel | Home hero variants | Reusable hero shell with content slots | Specified |
| Feature/action cards | Home and AI response cards | Card primitives plus content-specific modules | Specified; AI response modules implemented for `1:5061`, `1:5165`, and `1:5397` |
| Bottom nav variants | Home nav, compact nav, chat composer | Separate tab nav and composer components | Specified |
| Task/progress cards | Returning home scenarios | Metric cards; charts drawn/exported per asset decision | Specified |
| Transaction/payment rows | Payment, due-date, AI response flows | Row components with logo asset slots | Specified |
| Score/ring modules | Credit score and statement frames | SwiftUI Canvas if live; exported if static/complex | Specified |

### Assets

| Asset | Figma source | Format | Status |
| --- | --- | --- | --- |
| Bottom nav icons | `1:1764`, repeated navs | Figma SVG template asset sets for current golden pass | Exported for `1:628` |
| Top action icons | Hero/chat top bars | Figma PNG asset sets for current golden pass | Exported for `1:628` |
| Rectangle-cloud graphics | First-timer feature cards | Raster/vector composite | Needs export |
| Score/ring graphics | Credit score/statement frames | SwiftUI Canvas or exported asset | Needs fidelity test |
| Progress dots/charts | Returning home cards and AI budgeting cards | SwiftUI-drawn for data graphics; exported asset only for decorative/static art | `1:5397` monthly-spending heatmap implemented as SwiftUI |
| Card issuer logos | Payment rows | Raster/vector assets | Needs export |
| Security/promo imagery | Returning home cards | Raster asset | Needs export |
| Keyboard | AI chat keyboard states | Native iOS keyboard | No asset |

### Animations

| Interaction | Trigger | Native strategy | Status |
| --- | --- | --- | --- |
| Press feedback | CTA, chips, nav, cards | Spring scale plus light haptic | Tokenized |
| Hero/card reveal | Home state changes | Soft spring reveal; reduce motion to fade | Tokenized |
| Chat send | Composer send | Sent chip insertion and thinking state | Specified, not implemented |
| Keyboard lift | Composer focus | Native keyboard avoidance and safe-area inset | Specified, not implemented |
| Matched morph | AI pill/cards where identity is stable | `matchedGeometryEffect` candidate | Specified, not implemented |
| Scroll polish | Long home/chat content | Sticky composer/nav with bottom padding | Specified, not implemented |
| Thinking state | AI response generation | Pulse/dots, reduced motion fallback | Tokenized |

## Immediate Next Step

Current next step:

- Continue the AI Chat response graphics one frame at a time.
- Next unaudited budgeting targets: `1:6647` and `1:7245`.
- Preserve the existing `1:5397` monthly-spending card boundary as a reusable data module unless the next budgeting frames prove a better shared abstraction.
- Keep running iPhone 17 Pro simulator build and screenshot QA before marking each response graphic complete.
