# BON Figma Audit

## Source

- File: `O2 Final`
- URL: `https://www.figma.com/design/SMVZkasMIx4TzoOMBxqSs9/O2-Final?node-id=1-627&m=dev`
- File key: `SMVZkasMIx4TzoOMBxqSs9`
- Starting section: `1:627`
- Figma MCP access: local Figma Desktop endpoint `http://127.0.0.1:3845/mcp`
- Native MCP resources exposed in this session: none
- Saved evidence directory: `FigmaExports/` local artifacts

## Audited Sections

| Section | Node | Status | Evidence |
| --- | --- | --- | --- |
| Home - First timer | `1:627` | System audit in progress | `home-first-timer-section.xml`, screenshots |
| Home - Returning scenarios | `1:4312` | System audit in progress | `home-returning-section-metadata.sse`, screenshots |
| AI chat | `1:5059` | System audit in progress | `ai-chat-section-metadata.sse`, screenshots |

## Figma Variables

Variable extraction is sparse and cannot be the only token source.

| Scope | Result |
| --- | --- |
| `1:627` | `Light/Border`, `Light/Text/Primary`, `Light/Divider`, `Base Colors/pop black/100`, `Light/Primary` found in prior frame audit; section variable file saved. |
| `1:4312` | `Light/Border`, `Light/Text/Primary`, `Base Colors/pop black/100`, `Light/Primary`. |
| `1:5059` | `Light/Border`, `Light/Text/Primary`, `Light/Divider`, `System Background/Light/Primary`, `Label Color/Light/Primary`, `Default/Regular/Title2`, `Default/Regular/Callout`. |

## Frame Inventory

### Home - First Timer (`1:627`)

| Node | Name | Size | Reference | Status |
| --- | --- | --- | --- | --- |
| `1:2962` | Home - First timer | `390 x 845` | `home-first-timer-base-screenshot.sse` | audited for system patterns |
| `1:628` | Home - First timer - clicked on home | `390 x 845` | `home-clicked-figma.png`, `home-clicked-screenshot.sse` | golden candidate |
| `1:3008` | Home - First timer - budgeting | `390 x 845` | `home-first-timer-budgeting-screenshot.sse` | audited for system patterns |
| `1:4201` | Home - First timer - credit score | `390 x 845` | `home-first-timer-credit-score-screenshot.sse` | audited for system patterns |
| `1:4253` | Home - First timer - Cash advance | `390 x 845` | `home-first-timer-cash-advance-screenshot.sse` | audited for system patterns |

### Home - Returning Scenarios (`1:4312`)

| Node | Name | Size | Reference | Status |
| --- | --- | --- | --- | --- |
| `1:4313` | Home - Credit score | `390 x 1413` | `home-returning-credit-score-screenshot.sse` | audited for system patterns |
| `1:4474` | Home - Paycheck arrived | `390 x 845` | `home-returning-paycheck-arrived-screenshot.sse` | audited for system patterns |
| `1:4589` | Home - New transactions | `390 x 845` | `home-returning-new-transactions-screenshot.sse` | audited for system patterns |
| `1:4725` | Home - Payment due | `390 x 845` | `home-returning-payment-due-screenshot.sse` | audited for system patterns |
| `1:4825` | Home - Statement landed | `390 x 845` | `home-returning-statement-landed-screenshot.sse` | audited for system patterns |
| `1:4951` | Home - Due date near | `390 x 845` | `home-returning-due-date-near-screenshot.sse` | audited for system patterns |

### AI Chat (`1:5059`)

| Node | Name | Size | Reference | Status |
| --- | --- | --- | --- | --- |
| `1:7506` | Chat | `390 x 845` | `ai-chat-initial-screenshot.sse` | audited for system patterns |
| `1:7550` | Chat - typing not started yet | `390 x 845` | `ai-chat-keyboard-empty-screenshot.sse` | audited for system patterns |
| `1:7595` | Chat - typing started | `390 x 845` | `ai-chat-keyboard-typed-screenshot.sse` | audited for system patterns |
| `1:7631` | Chat - prompt sent - Agent thinking | `390 x 845` | `ai-chat-thinking-screenshot.sse` | audited for system patterns |

Additional response-flow sections inside AI Chat:

| Section | Node | Frames | Notes |
| --- | --- | --- | --- |
| Credit score | `1:5060` | `1:5061`, `1:5165` | Long response cards, action card, curated path, payment history, hard inquiries. `1:5061` and `1:5165` audited and implemented as SwiftUI response-card modules. |
| Budgeting | `1:5396` | `1:5397`, `1:6647`, `1:7245` | Long response, budget cards, rows. `1:5397` audited and implemented as a SwiftUI monthly-spending response-card module. |
| Debt payoff | `1:7335` | `1:7336`, `1:7423` | Card rows, payment/debt action layout. |

`1:5061` credit-improve graphic inventory:

- Evidence: `FigmaExports/ai-chat-credit-improve-1-5061-design-context.sse`, `FigmaExports/ai-chat-credit-improve-1-5061-metadata.sse`, `FigmaExports/ai-chat-credit-improve-1-5061-reference.png`.
- Long frame size: `390 x 1579`; response column remains `342pt` wide at `x=24`.
- Action-card module: section label, white `342pt` card, `16pt` card padding, `24pt` radius, `0 8 32 rgba(0,0,0,0.12)`, soft lime tag, 14pt black metadata row, 16pt medium title, black expected-lift panel, white How panel, black schedule-payment CTA.
- Curated-path module: same response-card shell, soft lime tag, 16pt medium title, `310 x 145` three-month strip, `#DEF1E7`, `#ECFFAA`, `#DBFF6F` month backgrounds, score path row with `193 x 6` progress track and `93pt` gradient fill.
- Implementation boundary: draw as reusable SwiftUI modules, not static screenshots, because the cards are structured financial UI and will need dynamic state later.

`1:5165` credit-drop graphic inventory:

- Evidence: `FigmaExports/ai-chat-credit-drop-1-5165-design-context.sse`, `FigmaExports/ai-chat-credit-drop-1-5165-metadata.sse`, `FigmaExports/ai-chat-credit-drop-1-5165-reference.png`.
- Long frame size: `390 x 1148`; visible response column remains `342pt` wide at `x=24`.
- Payment-history module: white `342 x 326` card, `24pt` radius, `0 8 16 rgba(0,0,0,0.12)`, soft lime `Payment History` tag, 16pt medium title, three `310 x 43` account timeline rows, 24 bars per row (`9 x 20`, `4pt` gap), green `#7BC700`, late bars `#C70000`, and floating white `view all` pill with subtle border/shadow.
- Hard-inquiries module: white `342 x 324` card, soft lime tag, 16pt medium title, three `310 x 64` grey rows (`#F7F7F7`) with account name, age text, and point impact.
- Implementation boundary: draw as SwiftUI bar/row components because the graphics are structured financial UI.

`1:5397` monthly-spending graphic inventory:

- Evidence: `FigmaExports/ai-chat-budget-spending-1-5397-design-context.sse`, `FigmaExports/ai-chat-budget-spending-1-5397-metadata.sse`, `FigmaExports/ai-chat-budget-spending-1-5397-variable-defs.sse`, and `FigmaExports/ai-chat-budget-spending-1-5397-reference.png`.
- Visible frame size: `390 x 752`; response column remains `342pt` wide at `x=24`.
- Prompt module: sent bubble `264 x 48`, trailing aligned, pale lime fill, 16pt horizontal and 12pt vertical padding, sharp bottom-right message corner.
- Monthly-spending module: white `342 x 344` card, `24pt` radius, `0 8 32 rgba(0,0,0,0.12)` shadow, `16pt` internal padding, header with `spent this month`, Geist Pixel `$6,136`, and `129 x 31` filter pill.
- Heatmap module: fixed `310 x 156` dense rounded-rectangle chart with `$10k` top label, `$1k` baseline label, date labels `Apr 05`, `Apr 20`, `May 05`, 30 columns, 14 sampled row positions, a universal empty gap at row 4, and sampled row colors `#FF3333`, `#FF5C5C`, `#FFBBBB`, `#FFE1E1`, `#FFEFE5`, `#FFF7EA`, `#F9F6D0`, `#FFFBD9`, `#ECFFAA`, `#DBFF6F`, `#C5FF33`, `#B4FF33`, and `#A1FF00`. Do not scale this chart to wider Pro card internals; non-integer square sizes change rounded-rectangle antialiasing and perceived color.
- Metric strip: `310 x 57` `#F7F7F7` panel with `AVG SPEND/DAY` / `$204` and `MOST SPENT DAY` / `14 Apr | $432`.
- Implementation boundary: draw as SwiftUI data graphics because the heatmap and metric strip are structured budget UI and will need live data later; no production image asset is required for this pass.

Remaining response flows are relevant to component taxonomy but need a deeper implementation audit before they are marked pixel-ready.

## Golden Candidate: `1:628`

Reference files:

- `FigmaExports/home-clicked-figma.png`
- `FigmaExports/home-clicked-screenshot.sse`
- `FigmaExports/home-clicked-design-context.sse`
- `FigmaExports/home-clicked-hero-context.txt`
- `FigmaExports/home-clicked-nav-context.txt`
- `FigmaExports/home-clicked-cards-context.txt`

Major sublayers:

| Node | Name | Notes |
| --- | --- | --- |
| `1:1731` | Top hero panel | White rounded panel, 56 pt radius, lime inner glow, AI mode pill, icon buttons, numeric display, CTA pill. |
| `1:630` | Feature cards | Card stack with dense graphics; first card visible, lower cards partly behind bottom nav. |
| `1:1764` | Nav bar | Floating dark pill, `342 x 64`, inset highlight, five items. |

Observed values:

- Frame width is `390 pt`; test iPhone Pro simulator width separately.
- Hero panel: `374 x 407`, top inset `8`, radius `56`, white fill, inset lime glow `rgba(219,255,111,0.8)`.
- Top controls: icon buttons `40 x 40`, AI mode pill `110 x 40`, soft shadow `0 8 32 rgba(0,0,0,0.08)`.
- Hero text: Zalando Sans 16/22 greeting, Geist Pixel 48 numeric display, body 16/24.
- CTA: `112 x 33`, dark fill `rgba(0,0,0,0.88)`, radius `100`, white inset glow, shadow `0 8 32 rgba(0,0,0,0.12)`.
- Bottom nav: `342 x 64`, x `24`, y `733`, dark fill `rgba(0,0,0,0.88)`, radius `100`, shadow `0 12 12 rgba(0,0,0,0.16)`, inactive `#BBBBBB`, active `#FFFFFF`.

Implementation pass - 2026-05-06:

- SwiftUI entry: `BON/Screens/Home/HomeFirstTimerClickedView.swift`.
- Component files: `BONHeroPanel`, `BONTopActionBar`, `BONIconButton`, `BONModePill`, `BONCTAPill`, `BONFeatureCard`, `BONBottomNav`.
- Production asset added: `BON/Assets.xcassets/homeFeatureBudgetingArtwork.imageset`.
- Final QA capture: `PixelQA/home-1-628-iphone17pro-final-pass-black-battery-normalized.png`.
- Final diff: `PixelQA/home-1-628-final-pass-black-battery-diff.png`, `24.6706%` mismatch at threshold `8`.
- Build proof: `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` passed.
- Geometry proof: first and second card artwork bounds match the Figma reference at `x=32`, `y=480/664`, `164 x 156`.
- Status: first implementation pass is running, but not pixel-approved.
- Known deltas after first pass: iPhone 17 Pro Dynamic Island vs Figma status-bar frame, SF Symbol nav approximations vs Figma SVG icons, SwiftUI-drawn lower-card artwork, typography antialiasing/baseline tuning, shadow/material tuning.

Second refinement pass - 2026-05-06:

- Bottom nav now uses production assets from Figma nodes `1:1766`, `1:1773`, `1:1779`, `1:1784`, and `1:1790`.
- Top action icons now use production assets from Figma nodes `1:1734` and `1:1740`.
- Credit-score thumbnail remains SwiftUI-drawn because node `1:1706` exports with bottom-nav contamination.
- Subscription thumbnail remains SwiftUI-drawn for now because node `1:1714` still exports as a `1 x 1` PNG through MCP.
- Latest QA capture: `PixelQA/home-1-628-iphone17pro-top-nav-credit-assets-normalized.png`.
- Latest diff: `PixelQA/home-1-628-top-nav-credit-assets-diff.png`, `20.7717%` mismatch at threshold `8`.
- Region checks: feature cards visible region `5.9309%`, nav region `53.7260%`, hero content excluding status `19.0248%`.
- Status: improved and running, but not pixel-approved against the old `390 x 845` Figma screenshot. The production policy now prioritizes fitting the available `iPhone 17 Pro` simulator's `402 x 874` Dynamic Island capture.

Bottom-nav polish pass - 2026-05-07:

- Previous nav PNG screenshot assets were replaced with sanitized SVG template assets for `navCards`, `navSpend`, `navHome`, `navCredit`, and `navMoney`.
- `BONBottomNav` now prioritizes the Figma nav anatomy over a bright system material: exact `rgba(0,0,0,0.88)` fill, exact `0 12 12 rgba(0,0,0,0.16)` outer shadow, natural item widths, and Zalando Sans ExtraLight inactive labels with `0.10` tracking.
- The false border strokes were removed; nav inner shadow now uses the exact Figma token `inset 0 3 8 rgba(255,255,255,0.36)`.
- Latest QA capture: `PixelQA/home-17pro-nav-figma-match-pass-2-logical.png`; nav crop: `PixelQA/bottom-nav-figma-match-pass-2-crop.png`; side-by-side: `PixelQA/bottom-nav-figma-match-pass-2-side-by-side.png`.
- Centering proof after polish: detected dark nav bounds center `200.5` against the iPhone 17 Pro screen center `201.0`.
- Known-box comparison: Figma nav box is `342 x 64`, simulator responsive nav box is `354 x 64`, and normalized RGB diff improved from `24.84/27.89/29.08` to `10.12/11.55/12.86`.
- Build proof: `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build` passed after the vector, Figma inner-shadow, surface, shadow, typography, and spacing update.

Bottom-nav Liquid Glass pass - 2026-05-07:

- Research-backed Apple Liquid Glass pass replaced the opaque-only surface with a native iOS 26+ `GlassEffectContainer` and `glassEffect(.regular.tint(...).interactive(), in: Capsule())` on the actual nav control surface.
- The first native attempt was rejected because a separate background glass layer visually covered the nav icons; the corrected implementation applies Liquid Glass to the control surface after appearance modifiers, then overlays the Figma inner shadow.
- The dark BON stain is asymmetric so the surface keeps Figma's dark functional-layer anatomy while still picking up the orange card and white card content underneath.
- Inner-shadow regression correction: the inset highlight now renders inside the glass surface as a thin soft edge highlight plus a weaker diffuse inset, instead of existing only as a code layer that disappeared in the final composition.
- Latest QA capture: `PixelQA/home-17pro-nav-liquid-glass-inner-shadow-corrected-logical.png`; nav crop: `PixelQA/bottom-nav-liquid-glass-inner-shadow-corrected-crop.png`; side-by-side: `PixelQA/bottom-nav-liquid-glass-inner-shadow-corrected-side-by-side.png`; diff: `PixelQA/bottom-nav-liquid-glass-inner-shadow-corrected-diff-amplified.png`.
- Known-box normalized RGB diff is `9.94/12.35/13.46`; measured luminance is top-edge `51.4` vs Figma `51.0`, top inner band `34.2` vs `26.1`, left over art `22.7` vs `17.9`, center `36.0` vs `31.8`, right over white `35.4` vs `35.2`, bottom band `24.9` vs `22.5`.
- Intentional difference: this pass remains slightly brighter than the prior opaque Figma-match pass because the nav now keeps the real Apple Liquid Glass rendering path and samples underlying content.

Responsive iPhone Pro policy - 2026-05-07:

- Product screens should not force the `390 x 845` Figma frame on wider Pro devices.
- The home AI/hero panel uses device-width layout with `8pt` top/left/right margin.
- Main content cards and bottom nav use `24pt` left/right margins.
- On iPhone 17 Pro (`402 x 874pt`), expected frames are: hero `x=8`, `width=386`; main content and nav `x=24`, `width=354`; nav bottom margin `48`.
- Latest responsive screenshot: `PixelQA/home-17pro-scroll-content-centered-logical.png`.
- Centering proof after ScrollView correction: CTA center `200.5`, section title center `200.5`, nav center `200.5`, and amount center `202.0` against the iPhone 17 Pro screen center `201.0`.
- The credit-score visible-state crop was rejected after responsive nav movement exposed the baked-in old nav overlay; credit score is SwiftUI-drawn until a clean isolated export is available.

## Repeated Patterns

- Top action bar repeats across home and chat surfaces.
- CTA pill repeats with multiple widths: compact `112 x 33`, wide `310 x 48`, and mid-width variants.
- Bottom nav repeats as a full tab nav, compact icon nav, and chat composer.
- Task and progress cards repeat across returning home scenarios.
- Large numeric display appears in hero, progress, score, and chat contexts.
- Chat chips and sent prompt bubbles share pill geometry and right alignment.
- Card/payment/transaction rows recur in payment due, due date near, and AI response flows.
- Score rings, budget charts, and dense rectangle graphics are recurring high-risk visual modules.

## Asset Audit

| Asset or graphic | Current classification | Production decision |
| --- | --- | --- |
| Bottom nav icons | Custom Figma icon nodes | Replaced with supplied sanitized SVG template asset sets: `navCards`, `navSpend`, `navHome`, `navCredit`, `navMoney`. |
| Top action icons | Figma icon nodes | Replaced with supplied sanitized SVG template asset sets: `topProfile`, `topBell`. |
| Chat composer voice icon | Custom Figma icon node | Added supplied sanitized SVG template asset set: `chatVoice`. |
| Hero rectangle clouds | Dense Figma rectangles | Export composite assets unless live-data-driven. |
| Score rings | Ellipse/vector groups | SwiftUI Canvas for live data, export if gradients/masks cannot match. |
| Progress dots/charts | Many small ellipses/vectors | SwiftUI-drawn if data-driven; export static if decorative. |
| Card issuer logos | Raster/vector node fills | Export production assets. |
| Security/private artwork | Raster rectangle/artwork | Export raster asset. |
| iOS keyboard | Figma keyboard instance | Use native keyboard; not an app asset. |

## Typography Audit

Primary Figma families:

- `Zalando Sans` for UI copy, labels, chips, nav, CTAs.
- `Geist Pixel` for numeric displays.
- `Instrument Serif` remains a reserved font only if verified in final audited screens.
- `SF Pro Display` and `SF Pro Text` appear in Figma variable definitions for the AI chat section.

Font status: Zalando Sans and Geist Pixel native TTF files plus OFL licenses are now bundled in `BON/Resources`. `Instrument Serif` remains conditional and should only be added if final audited screens verify live usage.

## Implementation Risks

- Figma frame width is 390 pt; iPhone 17 Pro simulator width must be reconciled without stretching fixed art incorrectly.
- Several visuals are dense vector/rectangle clouds that should not be hand-rebuilt as SwiftUI node-by-node graphics.
- Localhost Figma URLs in generated context are for inspection only.
- Bottom nav and chat composer overlap scroll content; implementation needs explicit safe-area inset and bottom padding.
- Native keyboard behavior will differ from static Figma keyboard frames and needs simulator verification.
- Long AI response frames require a separate state/content model before implementation.
- Status bar and system chrome must be normalized for pixel QA.

## Readiness

No product screen is implementation-ready yet.

Required before the first screen:

- Design-system docs reviewed.
- SwiftUI tokens compile.
- Zalando Sans and Geist Pixel files/licenses resolved; Instrument Serif confirmed unused or provided if needed.
- Asset export list approved.
- Golden screen `1:628` confirmed or replaced.
- Screenshot QA criteria written.
