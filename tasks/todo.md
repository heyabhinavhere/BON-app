# BON Implementation Todo

## 2026-05-07 - AI Chat Budget Graph Color Correction (`1:5397`)

### Check-In Status

- Status: completed the monthly-spending heatmap correction after user feedback that graph colors did not match Figma.
- Scope: `AIChatMonthlySpendHeatmap` and related documented color tokens only; keep the approved card shell, prompt, filter, composer, and routing unless measurement proves they are implicated.
- Figma reference: `FigmaExports/ai-chat-budget-spending-1-5397-reference.png`.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: sample the Figma heatmap colors structurally and update the reusable heatmap palette/distribution, instead of hand-tuning a one-off screenshot crop.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Record this correction checklist before coding.
- [x] Inspect Figma metadata/reference pixels for the exact heatmap color palette and mark distribution.
- [x] Compare current simulator heatmap colors against Figma reference.
- [x] Update SwiftUI heatmap color tokens/distribution to match Figma.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture final `1:5397` response screenshot and inspect graph color parity.
- [x] Update docs/lessons before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Final screenshot: `PixelQA/bon-ai-chat-1-5397-budget-spending-heatmap-color-final.png`.
- Side-by-side crop: `PixelQA/bon-ai-chat-1-5397-heatmap-color-side-by-side.png`.
- Pixel sampling: Figma heatmap reference contains 30 columns, 14 sampled row positions, row 4 intentionally empty, and center colors `#FF3333`, `#FF5C5C`, `#FFBBBB`, `#FFE1E1`, `#FFEFE5`, `#FFF7EA`, `#F9F6D0`, `#FFFBD9`, `#ECFFAA`, `#DBFF6F`, `#C5FF33`, `#B4FF33`, and `#A1FF00`.
- Visual check: SwiftUI now uses the sampled Figma row palette and per-column matrix, so the graph no longer appears as broad generic lime/yellow/red bands.

### Review Notes

- User feedback: graph colors are visibly wrong even though the card structure is close.
- Risk: current implementation uses hardcoded approximate heatmap colors and a y-position color function; Figma may use explicit mark colors by data intensity, not a smooth position-derived threshold.
- Correction made: replaced column-height/y-threshold drawing with a top-row matrix plus a shared empty gap row, matching the Figma heatmap structure.
- Follow-up correction: remaining mismatch came from scaling the Figma `310pt` chart to the wider Pro card, causing non-integer rendered mark sizes and antialias/color drift. The graph and metric strip are now locked to the exact `310pt` Figma baseline.
- Final exact-size screenshot: `PixelQA/bon-ai-chat-1-5397-budget-spending-heatmap-exact-final.png`.
- Final exact-size side-by-side: `PixelQA/bon-ai-chat-1-5397-heatmap-exact-side-by-side.png`.
- Rendered center-pixel proof: the final simulator marks now sample at the Figma row colors exactly: `#A1FF00`, `#B4FF33`, `#C5FF33`, `#ECFFAA`, `#DBFF6F`, `#FFFBD9`, `#F9F6D0`, `#FFF7EA`, `#FFEFE5`, `#FFE1E1`, `#FFBBBB`, `#FF5C5C`, and `#FF3333`.
- Build after exact-size correction: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.

---

## 2026-05-07 - AI Chat Budgeting Graphics Pass (`1:5397`)

### Check-In Status

- Status: implemented and verifying the first detailed AI Chat budgeting graphics pass.
- Scope: frame `1:5397` and the response graphics/cards for the budgeting scenario.
- Figma reference: `https://www.figma.com/design/SMVZkasMIx4TzoOMBxqSs9/O2-Final?node-id=1-5397&m=dev`.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: audit `1:5397` exactly, identify reusable budgeting modules first, then implement structured SwiftUI graphics instead of screenshot-backed mockups unless Figma evidence shows a true illustration asset.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Load Figma, BON Figma audit, BON SwiftUI implementation, preflight, and pixel-QA rules.
- [x] Record this checklist before coding.
- [x] Run repo preflight and inspect current budgeting response implementation.
- [x] Fetch Figma design context, metadata, variables, and screenshot for node `1:5397`.
- [x] Inventory `1:5397` budgeting modules and classify SwiftUI-drawn vs asset-backed pieces.
- [x] Update SwiftUI response modules and scenario fixture copy to match `1:5397`.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture `1:5397` response screenshot(s) and compare against Figma reference.
- [x] Update tracker/lessons before final.

### Verification Results

- Baseline build before edits: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Figma reference: `FigmaExports/ai-chat-budget-spending-1-5397-reference.png`.
- Final build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Final screenshot: `PixelQA/bon-ai-chat-1-5397-budget-spending-final.png`.
- Extra comparison capture without launch scroll target: `PixelQA/bon-ai-chat-1-5397-budget-spending-no-scroll-target.png`.
- Visual check: monthly-spending response uses the exact `Here’s your month at a glance.` intro, trailing sent prompt, white card shell, `$6,136` Geist Pixel value, filter pill, dense heatmap, date labels, and two-cell metric strip from `1:5397`.
- QA note: the iPhone 17 Pro capture is taller than the Figma `390 x 752` visible frame, so the final QA screenshot preserves the full card and bottom composer rather than forcing the shorter Figma crop.

### Review Notes

- User direction: budgeting graphics are more complex than the credit-score ones, so avoid generic charts and match the exact Figma data-story anatomy.
- Risk: do not reuse home-story budgeting visuals if the chat response uses different chart scale, copy, or card structure.
- Figma finding: `1:5397` is a monthly-spending overview, not the generic category-row budgeting module from the earlier foundation pass.
- Mapping decision: draw the heatmap and metric strip in SwiftUI because they are structured data graphics; no exported image asset is needed.
- Correction made during implementation: route `Show me my monthly spending` to `.budgetSpending` before broad `month`/timeline checks, because `monthly` otherwise matched the timeline path.

---

## 2026-05-07 - AI Chat Credit Drop Graphics Pass (`1:5165`)

### Check-In Status

- Status: starting the second detailed AI Chat credit-score graphics pass.
- Scope: frame `1:5165` and the response graphics/cards for the credit-score-dropping scenario.
- Figma reference: `https://www.figma.com/design/SMVZkasMIx4TzoOMBxqSs9/O2-Final?node-id=1-5165&m=dev`.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: audit exact `1:5165` strings, geometry, and card modules first, then implement them as reusable SwiftUI response pieces where they fit the existing chat-card system.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Load Figma, BON Figma audit, BON SwiftUI implementation, preflight, and pixel-QA rules.
- [x] Record this checklist before coding.
- [x] Run repo preflight and inspect current credit-drop implementation.
- [x] Fetch Figma design context, metadata, variables, and screenshot for node `1:5165`.
- [x] Inventory `1:5165` response modules and classify SwiftUI-drawn vs asset-backed pieces.
- [x] Update SwiftUI response modules and scenario fixture copy to match `1:5165`.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture `1:5165` response screenshot(s) and compare against Figma reference.
- [x] Update tracker/lessons before final.

### Verification Results

- Baseline build before edits: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Figma reference: `FigmaExports/ai-chat-credit-drop-1-5165-reference.png`.
- Final build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Payment-history screenshot: `PixelQA/bon-ai-chat-1-5165-credit-drop-payment-history-final.png`.
- Hard-inquiries screenshot: `PixelQA/bon-ai-chat-1-5165-credit-drop-hard-inquiries.png`.
- Visual check: Payment History now uses exact 24-bar rows, green/late-red bar pattern, `view all` floating pill, and `1:5165` account names/amounts.
- Visual check: Hard Inquiries now uses the Figma grey row cards, age labels, and point-impact values instead of generic account rows.
- QA note: iPhone 17 Pro screenshot uses BON's live `24pt` side-margin rule, so the card shell is wider than the `390pt` Figma baseline while preserving the same internal anatomy.

### Review Notes

- User direction: continue chat graphics one by one with high care.
- Risk: do not blend this credit-drop flow with the previously implemented `1:5061` credit-improve modules.
- Figma finding: visible `1:5165` card content is not generic account rows; it is a Payment History card with 24-bar account timelines and a Hard Inquiries card with three `#F7F7F7` inquiry rows.
- Mapping decision: draw the bars and inquiry rows in SwiftUI because they are structured UI/data graphics; no exported image asset is required for this pass.
- Implementation note: added a shared chat top scrim so scrolled response content fades under the top controls, matching the Figma top overlay pattern.

---

## 2026-05-07 - AI Chat Prompt Chip Geometry Correction

### Check-In Status

- Status: correcting sent prompt and fallback suggestion chip geometry from user screenshot feedback.
- Scope: `BONChatChip` sent/suggestion/responseSuggestion variants only.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: fix the shared chip component and remove one-off hardcoded fallback widths so all prompt-like chips inherit max-width, padding, and message-tail geometry.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Inspect current chip implementation and fallback response usage.
- [x] Update prompt chips to max at 65% of chat space where appropriate.
- [x] Apply `16pt` horizontal and `12pt` vertical padding.
- [x] Replace capsule with message-bubble shape: rounded top/left corners and sharp bottom-right corner.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture fallback response screenshot for visual verification.
- [x] Update tracker/lessons before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Screenshot: `PixelQA/bon-ai-chat-fallback-prompt-bubbles-tail-v2.png`.
- Visual check: fallback response suggestions now stay under the 65% device-width cap, remain trailing-aligned, and the long third suggestion wraps to two lines instead of spanning the full chat column.
- Visual check: sent and suggestion chips now use `16pt` horizontal / `12pt` vertical padding and a sharp bottom-right message corner.

### Review Notes

- User feedback: third fallback suggestion is too wide and visually overflows the intended 65% message width.
- User feedback: sent prompts and suggestions should read like message bubbles, with bottom-right corner sharp and `16 x 12` text padding.
- Implementation note: the width cap is based on device width, not the `354pt` Pro chat column, so it matches the user's "65% of the screen" direction while preserving the `24pt` page margin.

---

## 2026-05-07 - AI Chat Credit Improve Graphics Pass (`1:5061`)

### Check-In Status

- Status: starting the first detailed AI Chat graphics pass.
- Scope: frame `1:5061` (`Chat - prompt sent - Agent responded`) and its detailed credit-improve response graphics/cards only.
- Figma reference: `https://www.figma.com/design/SMVZkasMIx4TzoOMBxqSs9/O2-Final?node-id=1-5061&m=dev`.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: audit and build the reusable response-card modules for this frame first, instead of one-off drawing the whole long screen as a static image.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Load Figma, BON Figma audit, BON SwiftUI implementation, preflight, and pixel-QA rules.
- [x] Record this checklist before coding.
- [x] Run repo preflight and inspect current AI Chat implementation.
- [x] Fetch or refresh Figma design context and screenshot for node `1:5061`.
- [x] Inventory the detailed graphics/cards in `1:5061` and map each to SwiftUI or asset export.
- [x] Update SwiftUI response modules for the first credit-improve graphic set.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture `1:5061` response screenshot and compare against Figma reference.
- [x] Update tracker/lessons before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Figma reference: `FigmaExports/ai-chat-credit-improve-1-5061-reference.png`.
- Top response capture: `PixelQA/bon-ai-chat-1-5061-credit-improve-top-v2.png`.
- Action-card capture: `PixelQA/bon-ai-chat-1-5061-action-card-centered.png`.
- Curated-path capture: `PixelQA/bon-ai-chat-1-5061-curated-path-centered.png`.
- Visual check: action-card shell, soft lime tag, black metric panel, white How panel, black CTA, three-month path strip, and score progress row now map to the `1:5061` Figma context.
- QA note: the iPhone 17 Pro app uses the product `24pt` side-margin rule, so chat cards render `354pt` wide on `402pt` devices instead of forcing Figma's `342pt` width from a `390pt` frame.

### Review Notes

- User direction: the chat graphics are detailed and must be handled one by one with high care.
- Initial target: first AI Chat response frame `1:5061`.
- Figma artifacts: `FigmaExports/ai-chat-credit-improve-1-5061-design-context.sse`, `FigmaExports/ai-chat-credit-improve-1-5061-metadata.sse`, `FigmaExports/ai-chat-credit-improve-1-5061-variable-defs.sse`, and `FigmaExports/ai-chat-credit-improve-1-5061-reference.png`.
- Component inventory: action-card shell, soft lime tag row, black expected-lift panel, white How steps panel, black schedule-payment CTA, curated-path three-month strip, and score-progress row.
- Mapping decision: draw these as SwiftUI components because the graphics are structured financial UI, not static illustration assets.
- Correction made during implementation: remove sibling-frame content from the `creditImprove` action card and match `1:5061` exact strings, font weights, and module sizes.
- Added launch-only PixelQA scroll targets for action-card and curated-path screenshots; normal app behavior is unchanged.

---

## 2026-05-07 - AI Chat Fallback Suggestions Design Pass

### Check-In Status

- Status: fixing the fallback/random-question response suggestion design.
- Scope: unknown-prompt fallback response suggestions only; keep approved initial suggestions, sent bubble, composer, and voice/send morph unchanged.
- Figma reference: AI Chat section response states under `1:5059`; local Figma exports/metadata to be inspected before changing the component.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: create or tune a response-suggestion chip variant instead of reusing the existing initial suggestion or generic category chip style.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Load BON SwiftUI, pixel-QA, and Figma audit rules.
- [x] Record this checklist before coding.
- [x] Inspect current fallback scenario routing and suggestion-chip implementation.
- [x] Inspect local Figma metadata/screens for response suggestion chip anatomy.
- [x] Update SwiftUI chip styling/layout to match the Figma response suggestion style.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture unknown-prompt response screenshot.
- [x] Update tracker and lessons before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Screenshot: `PixelQA/bon-ai-chat-fallback-suggestions-response-final.png`.
- Visual check: unknown-prompt fallback choices now use bright lime BON prompt chips instead of pale grey outlined category pills, remain trailing-aligned in the chat column, and keep the long third prompt readable across two lines.
- Launch check: verified with `-BONInitialRoute ai-chat -BONAIChatState response -BONAIChatScenario fallback -BONAIChatPrompt 'How are you doing?'`.
- Interaction check: fallback choices now call the existing AI Chat prompt router instead of being visual-only buttons.

### Review Notes

- User feedback: random-question response and suggestions are functionally good, but suggestion design does not match Figma.
- User screenshot shows fallback suggestions currently rendered as pale outlined pills, including one long two-line pill.
- Code finding: fallback response uses `BONChatChipStyle.category`, which is a neutral grey chip style rather than a Figma chat prompt/suggestion treatment.
- Figma finding: response prompt chips in the AI Chat section are right-aligned within the `342pt` column, use `16pt` horizontal text inset, and have a `48pt` baseline height for single-line prompts.
- Design-system update: chat chips now document separate bright-lime suggestion and pale-lime sent prompt treatments.

---

## 2026-05-07 - AI Chat Suggestion Morph Refinement

### Check-In Status

- Status: refining suggestion-chip animation after user approval of the icon morph but rejection of the suggestion exit.
- Scope: initial suggestion stack only; keep the voice/send icon morph unchanged.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: replace removal transitions with a persistent morphing suggestion container whose height, scale, opacity, and hit testing animate together.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Load BON motion, SwiftUI implementation, and pixel-QA rules.
- [x] Record this checklist before coding.
- [x] Replace conditional suggestion removal with a persistent morph container.
- [x] Make chips shrink/collapse smoothly before disappearing.
- [x] Preserve Reduce Motion with opacity-only behavior.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture initial and typed-state screenshots.
- [x] Update tracker and lessons before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Initial state screenshot: `PixelQA/bon-ai-chat-suggestion-morph-initial.png`.
- Typed state screenshot: `PixelQA/bon-ai-chat-suggestion-morph-typed.png`.
- Visual check: typed state has no leftover suggestion layout gap and keeps the composer arrow state intact.
- Code verification: suggestion chips now stay in a persistent `AIChatSuggestionStack` while visibility animates; the stack scales, fades, shifts, disables hit testing, and animates height to zero.
- Accessibility check: Reduce Motion keeps geometry simple and removes scale/offset morphing.

### Review Notes

- User feedback: voice/arrow switch is good.
- User feedback: suggestion animation should feel more like a smooth morph: shrink, then disappear.
- Implementation note: this pass replaces the previous removal transition, which was the wrong abstraction for the desired morph.

---

## 2026-05-07 - AI Chat Typing Motion Pass

### Check-In Status

- Status: smoothing the AI Chat typing transition.
- Scope: voice-to-send icon transition, initial suggestion chip disappearance/reappearance, and reduced-motion behavior.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: add explicit motion only to the affected chat components and phase changes, not a broad animation modifier over the full screen.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Load BON motion, SwiftUI implementation, and pixel-QA rules.
- [x] Record this checklist before coding.
- [x] Inspect current AI Chat phase, suggestion, and composer icon implementation.
- [x] Add smooth voice-to-arrow transition with Reduce Motion fallback.
- [x] Add smooth suggestion-stack removal/reveal transition with staggered chip motion.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture initial and typed-state screenshots.
- [x] Update verification and lessons before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Initial state screenshot: `PixelQA/bon-ai-chat-typing-motion-initial-final.png`.
- Typed state screenshot: `PixelQA/bon-ai-chat-typing-motion-typed-final.png`.
- Visual check: initial state keeps suggestions visible and the voice icon in the composer.
- Visual check: typed state removes suggestions and shows the send arrow in the same stable icon slot.
- Accessibility check: Reduce Motion uses opacity-only suggestion transitions and removes icon scale/rotation/blur.

### Review Notes

- User feedback: voice icon switching to arrow when typing starts is sharp and harsh.
- User feedback: suggestions disappear harshly when typing starts and need a more beautiful animation.
- Implementation note: `phase` changes now go through a local animated setter for typing thresholds; submit/response animations remain on the existing reveal timing.

---

## 2026-05-07 - AI Chat Composer Whole-Surface Parity Pass

### Check-In Status

- Status: correcting the latest AI Chat composer crop mismatch.
- Scope: `BONChatGlassCapsule`, `BONChatComposerActionSurface`, focused composer state, and design-system/lesson notes if the correction creates a new rule.
- Figma reference: user-provided composer crop from `2026-05-07 7.34.58 PM`, plus AI Chat frames `1:7506`, `1:7550`, and `1:7595`.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: tune the composer as one glass component instead of treating the voice pill as an isolated button, because the shell stain, inset lighting, action insert, and shadow are visually coupled.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Load BON SwiftUI, motion, and pixel-QA rules.
- [x] Record this correction checklist before coding.
- [x] Compare the latest user crop against the current simulator/Figma crop.
- [x] Darken and integrate the action insert so it reads as graphite Liquid Glass rather than a silver outlined pill.
- [x] Soften the main composer shell edge so its lighting comes from depth and specular material, not a visible border.
- [x] Preserve the visible focused caret/tint behavior.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture AI Chat initial and focused/keyboard screenshots.
- [x] Update verification and lessons before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Initial AI Chat screenshot: `PixelQA/bon-ai-chat-composer-whole-surface-final.png`.
- Initial composer crop: `PixelQA/bon-ai-chat-composer-whole-surface-final-composer-crop.png`.
- Focused launch screenshot: `PixelQA/bon-ai-chat-composer-whole-surface-focused-final.png`.
- Focused composer crop: `PixelQA/bon-ai-chat-composer-whole-surface-focused-final-composer-crop.png`.
- Interactive focused caret screenshot: `PixelQA/bon-ai-chat-composer-focused-caret-interactive.png`.
- Figma/current crop comparison: `PixelQA/bon-ai-chat-composer-reference-vs-current-final.png`.
- Visual check: the action insert no longer uses a stroke-like silver layer; it is a graphite insert with native glass underneath, soft specular light, and darker occlusion at the right/bottom.
- Visual check: the main composer shell no longer uses the previous masked `strokeBorder` highlight; edge definition now comes from dark stain, a subtle satin band, radial highlights, and shadow.
- Interactive check: tapping the composer in Simulator shows the light insertion cursor on the dark bar.

### Review Notes

- User feedback: the current result still has a massive visual difference from Figma.
- Visual finding: the current action insert is too bright/silver and outlined; Figma reads as a darker graphite insert with soft Liquid Glass depth.
- Visual finding: the main shell edge/lighting needs to be tuned with the insert, not separately.
- First revised pass removed the silver outline but over-darkened the action insert and flattened the shell. Final pass restored a graphite highlight and shell satin band without reintroducing a visible stroke border.

---

## 2026-05-07 - AI Chat Voice Pill Glass And Caret Pass

### Check-In Status

- Status: correcting the AI Chat composer voice pill and focused text-field caret visibility.
- Scope: `BONChatComposer`, `BONChatComposerActionSurface`, and related design-system/tracker notes.
- Figma reference: `PixelQA/bon-ai-chat-static-glass-pass-v4-figma-size.png` and AI Chat frames `1:7506`, `1:7550`, `1:7595`.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: keep the fix inside the composer action surface and text-field tint instead of changing the whole composer shell.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Load BON SwiftUI, motion, and pixel-QA rules.
- [x] Record this correction checklist before coding.
- [x] Compare current voice pill against the local Figma reference.
- [x] Remove the attention-seeking border from the voice pill and use a softer native Liquid Glass/specular treatment.
- [x] Make the focused text-field insertion bar visible on the dark composer.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture AI Chat initial and focused/keyboard screenshots.
- [x] Update lessons and verification notes before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Initial AI Chat screenshot: `PixelQA/bon-ai-chat-voice-pill-glass-initial-v2.png`.
- Focused empty composer screenshot: `PixelQA/bon-ai-chat-voice-pill-glass-keyboard-empty-v2.png`.
- Visual check: voice pill no longer uses an explicit stroke border; its edge now comes from dark glass tint, specular gradient, native `glassEffect`, and shadow. The focused insertion bar is now light and visible against the dark composer.

### Review Notes

- User feedback: current voice pill has a strange border; Figma reads as Liquid Glass depth/light, not a visible border.
- User feedback: when the chat box is clicked, the input bar is black and not visible; caret/tint should be clearly visible on the dark composer.
- Existing lesson constraints: do not convert inner/glass lighting into borders; visual requirements must survive simulator composition.
- First attempt made the voice/action pill too bright and silver. Final tuning restores a darker Figma-like glass insert while keeping the no-stroke boundary.

---

## 2026-05-07 - Chat Icon Size And Edge Glow Gradient Pass

### Check-In Status

- Status: correcting implemented icon scale to the user's `16px` spec and tightening the AI Chat edge glow.
- Scope: implemented icon surfaces so far, new SVGs added under `/Users/abhinavjain/BON app/Svg icons`, and `BONSiriEdgeGlow`.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: keep the icon correction at component sizing/semantic asset boundaries and keep the glow correction in the existing edge-glow component using the new lime primitive scale.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Load BON asset, motion, and SwiftUI implementation rules.
- [x] Record this correction checklist before coding.
- [x] Inventory the 4 new SVGs and map any clear roles to semantic assets.
- [x] Set implemented icon rendering to the `16pt` visual size where the design expects `16px` glyphs.
- [x] Reduce AI Chat edge-glow width and replace single-color glow with a `lime50`/`lime100`/`lime200`/`lime300` gradient.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture chat/home visual QA screenshots for icon scale and glow.
- [x] Update lessons and verification notes before final.

### Verification Results

- Asset JSON validation: passed with `jq empty` for `chatInfo`, `chatFilters`, `chatMenu`, and `chatBackChevron`.
- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Home expanded nav screenshot: `PixelQA/bon-icon16-glow-pass-home.png`.
- AI Chat screenshot: `PixelQA/bon-icon16-glow-pass-ai-chat.png`.
- Compact nav screenshot: `PixelQA/bon-icon16-glow-pass-compact-nav.png`.
- Visual check: chat menu uses the supplied 16 px SVG asset, top-home and bottom-nav glyphs render at 16 pt, compact nav remains centered, and the AI Chat edge glow is narrower with lime 50-300 gradient layers.

### Review Notes

- User feedback: icons feel too big and should use `16px`; chat border glow animation is smooth but too wide and should use a lime gradient instead of one color.
- Existing lesson constraints: supplied icons should be semantic assets; asset catalog source swaps must not leave stale children; simulator screenshot proof is needed for visual corrections.
- New SVG mapping: `Frame-8.svg` -> `chatInfo`, `Frame-9.svg` -> `chatFilters`, `Frame-10.svg` -> `chatMenu`, `Frame-11.svg` -> `chatBackChevron`.
- Only `chatMenu` is currently wired because it maps to an implemented control; the other three are installed as semantic production assets for upcoming chat controls.

---

## 2026-05-07 - Lime Scale Token Pass

### Check-In Status

- Status: adding the user-provided BON lime palette to the formal design system and Swift color tokens.
- Source: user-provided screenshot with `lime/50` through `lime/900` hex values.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: add a complete primitive lime scale and keep semantic aliases like `accentLime` and `limeGlow` mapped to it, instead of replacing semantic names in screen code.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Load BON design-system and token extraction rules.
- [x] Record this token checklist before coding.
- [x] Add `lime50...lime900` to `BONColor`.
- [x] Remap `accentLime` to `lime500` and `limeGlow` to `lime200.opacity(0.80)`.
- [x] Document the lime scale in `DESIGN_SYSTEM.md`.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Update verification notes before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`; rerun after tracker/doc updates also passed.
- Token check: `BONColor` now contains `lime50` through `lime900`; `accentLimeRole` maps to `lime500`; `limeGlow` maps to `lime200.opacity(0.80)`.
- Documentation check: `DESIGN_SYSTEM.md` now records the full primitive lime scale with usage guidance for each shade.
- Screenshot QA: not captured for this pass because the semantic values used by existing screens remain visually equivalent (`accentLime` stayed `#A1FF00`, `limeGlow` stayed `#DBFF6F` at `0.80` opacity).

### Review Notes

- Palette values from the screenshot: `lime/50 #F7FFD9`, `lime/100 #ECFFAA`, `lime/200 #DBFF6F`, `lime/300 #C5FF33`, `lime/400 #B5FF14`, `lime/500 #A1FF00`, `lime/600 #7BC700`, `lime/700 #5C9400`, `lime/800 #3F6500`, `lime/900 #1F3300`.
- Existing `accentLime` already matches `lime/500`; existing `limeGlow` matches `lime/200` at `0.80` opacity.

---

## 2026-05-07 - Supplied SVG Icon Replacement Pass

### Check-In Status

- Status: replacing mismatched SF Symbols and prior icon assets with supplied local SVG icons where they map cleanly to implemented BON surfaces.
- Scope: inventory `/Users/abhinavjain/BON app/Svg icons`, add production asset-catalog entries, update implemented home/nav/chat icon call sites, then verify sharpness in simulator.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: create semantic icon assets in `Assets.xcassets` and a tiny reusable image renderer instead of wiring raw file names or keeping one-off SF Symbol substitutions in screen code.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Load BON asset and SwiftUI implementation rules.
- [x] Record this correction checklist before coding.
- [x] Inventory every supplied SVG and identify intended role.
- [x] Add sanitized semantic icon assets into `BON/Assets.xcassets`.
- [x] Replace incorrect implemented icons with supplied assets in home, bottom nav, and AI Chat where roles are clear.
- [x] Keep SF Symbols only where no supplied SVG maps cleanly.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture home/nav and AI Chat screenshots to verify icons render sharply.
- [x] Update lessons and verification notes before final.

### Verification Results

- JSON validation: passed with `jq empty` for the edited icon asset catalogs.
- SVG sanity check: passed; no `var(--...)`, `preserveAspectRatio`, or `width="100%"` patterns remain in `BON/Assets.xcassets/*.imageset/*.svg`.
- Build: passed cleanly with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Home/top/nav screenshot: `PixelQA/bon-svg-icons-home-logical.png`.
- AI Chat screenshot: `PixelQA/bon-svg-icons-ai-chat-logical.png`.
- Compact nav story screenshot: `PixelQA/bon-svg-icons-compact-nav-logical.png`.
- Asset-catalog cleanup: removed stale `topProfile` and `topBell` PNG children after the first build proved they were unassigned warnings.

### Review Notes

- User provided local SVG icons in `Svg icons` and explicitly asked to use them in correct places already implemented.
- Existing code still has SF Symbols in AI Chat top controls, composer, category rows, debt rows, and some Home/story sections; bottom nav already uses assets but may need remapping/replacement if supplied SVGs are the canonical source.
- Supplied SVG mapping: `Frame.svg` -> `topProfile`, `Frame-1.svg` -> `topBell`, `Frame-2.svg` -> `navCards`, `Frame-3.svg` -> `navSpend`, `Frame-4.svg` -> `navHome`, `Frame-5.svg` -> `navCredit`, `Frame-6.svg` -> `navMoney`, `Frame 7.svg` -> `chatVoice`.
- Remaining SF Symbols are intentional for roles not present in the supplied folder, including chat menu, send arrow, stop square, story chevrons, category rows, trends, and decorative benefit/partner symbols.

---

## 2026-05-07 - AI Chat Static Entry And Glass Pass

### Check-In Status

- Status: fixing review feedback one item at a time.
- Target frame: static AI Chat `1:7506` first, then top bar and composer anatomy.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: keep this pass limited to `AIChatView` and chat entry routing. Extract reusable glass only if duplicated top/composer code becomes hard to reason about.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Record this correction checklist before coding.
- [x] Inspect current home-to-chat routing and prevent `Talk with AI` from opening thinking state.
- [x] Inspect current iOS 26 glass API availability in the local SDK.
- [x] Rework top bar icon buttons and expert pill toward native Liquid Glass plus Figma dark tint.
- [x] Rework composer background, voice/send pill sizing, and shadow against Figma `1:7506`.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture static chat entry and compare against Figma reference.
- [x] Update lessons and verification notes before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Direct static AI Chat launch: `PixelQA/bon-ai-chat-static-glass-pass-v4-logical.png`.
- Direct static AI Chat diff against `/tmp/bon-ai-chat-figma/ai-chat-initial.png`: `32.4209%` mismatch at threshold `10`, diff `PixelQA/bon-ai-chat-static-glass-pass-v4-diff.png`.
- Tap-path regression check: launched home with stale `-BONAIChatState thinking`, tapped `Talk with AI`, and confirmed it still opened the static suggestion state. Evidence: `PixelQA/bon-ai-chat-home-stale-thinking-after-tap-logical.png`.
- Intermediate failed glass layering capture kept for evidence: `PixelQA/bon-ai-chat-static-glass-pass-v2-logical.png`; it showed expert text and icon foreground being swallowed by the parent glass container.

### Review Notes

- User-provided screenshot shows the app opening the thinking state after tapping `Talk with AI`; expected behavior for this step is the static Figma chat state with suggestions visible.
- Top bar center pill is closer than before, but left/right buttons still read like dull white circles, not Apple-style Liquid Glass controls.
- Composer needs Figma-specific dark surface, stronger bottom shadow, and correct right voice pill/button geometry.
- Fixed route state by making launch arguments opt-in only for direct PixelQA chat launches. Normal in-app taps now always start from static chat.
- Removed the top-level `GlassEffectContainer` around the top bar after simulator evidence showed it swallowed text/icons; native `glassEffect` remains on each control surface.
- The remaining full-frame numeric diff is still noisy because the Figma reference includes the rounded device frame and the simulator capture uses iPhone 17 Pro logical dimensions. Human review for this pass focused on the user-raised top bar, static state, and composer issues.

---

## 2026-05-07 - AI Chat Pixel Match Pass

### Check-In Status

- Status: tightening AI Chat against Figma screenshots and metadata.
- Target section: `1:5059` AI chat.
- Pixel-approved targets for this pass: `1:7506`, `1:7550`, `1:7595`, and `1:7631`, because exact Figma screenshots exist locally.
- Metadata-only targets for this pass: response frames `1:5061`, `1:5165`, `1:5397`, `1:6647`, `1:7245`, `1:7336`, and `1:7423`.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: keep one AI chat screen, but separate Figma-baseline chat metrics from reusable response components. Do not claim long response frames are pixel-approved until exact screenshots are exported.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Audit available Figma references and PixelQA captures.
- [x] Align AI Chat coordinate system to Figma `390 x 845` baseline.
- [x] Match exact initial-state Figma copy, chip labels, chip positions, top bar, and composer.
- [x] Match keyboard and thinking states as closely as native keyboard allows.
- [x] Tighten long response card spacing and typography from metadata.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture refreshed PixelQA screenshots and diffs for entry states.
- [x] Record screenshot blockers for metadata-only response frames.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Exact entry-state QA screenshots from the current build:
  - `PixelQA/bon-ai-chat-pixel-pass-v3-initial-logical.png`
  - `PixelQA/bon-ai-chat-pixel-pass-v3-keyboard-empty-logical.png`
  - `PixelQA/bon-ai-chat-pixel-pass-v3-keyboard-typed-logical.png`
  - `PixelQA/bon-ai-chat-pixel-pass-v3-thinking-logical.png`
- Entry-state Figma diffs, normalized to `390 x 845`:
  - Initial: `31.7827%` mismatch, diff `PixelQA/bon-ai-chat-pixel-pass-v3-initial-diff.png`.
  - Keyboard empty: `51.1139%` mismatch, diff `PixelQA/bon-ai-chat-pixel-pass-v3-keyboard-empty-diff.png`.
  - Keyboard typed: `47.0499%` mismatch, diff `PixelQA/bon-ai-chat-pixel-pass-v3-keyboard-typed-diff.png`.
  - Thinking: `27.9293%` mismatch, diff `PixelQA/bon-ai-chat-pixel-pass-v3-thinking-diff.png`.
- The diff percentages remain noisy because the Figma references include rounded black frame corners while simulator captures are rectangular screen renders, and the native iOS 26 keyboard differs from the Figma `AlphabeticKeyboard` instance.
- Response scenario QA screenshots from the current build:
  - `PixelQA/bon-ai-chat-pixel-pass-v3-response-credit-improve-logical.png`
  - `PixelQA/bon-ai-chat-pixel-pass-v3-response-credit-drop-logical.png`
  - `PixelQA/bon-ai-chat-pixel-pass-v3-response-budget-spending-logical.png`
  - `PixelQA/bon-ai-chat-pixel-pass-v3-response-budget-timeline-logical.png`
  - `PixelQA/bon-ai-chat-pixel-pass-v3-response-budget-runway-logical.png`
  - `PixelQA/bon-ai-chat-pixel-pass-v3-response-debt-cards-logical.png`
  - `PixelQA/bon-ai-chat-pixel-pass-v3-response-debt-path-logical.png`

### Review Notes

- Existing exact local screenshots: `ai-chat-initial`, `ai-chat-keyboard-empty`, `ai-chat-keyboard-typed`, and `ai-chat-thinking`.
- Long response frames currently have node metadata but no local screenshot PNG/SSE references, so they can be layout-tightened but not pixel-approved yet.
- Updated the chat metric boundary to keep the iPhone Pro `24pt` horizontal margin while still matching the `390 x 845` Figma baseline proportions.
- Matched the dark top expert pill, bright lime suggestion chips, exact initial chip labels, and exact Figma chat copy for the seven routed response prompts where metadata is available.
- Native keyboard states are visually close for composer placement, but not pixel-equivalent because the simulator renders a real iOS keyboard, not Figma's static keyboard component.
- Response scenarios are metadata-matched for copy and component order, but still need exact Figma screenshots before claiming pixel approval for card graphics and scroll-position framing.

---

## 2026-05-07 - AI Chat Scenario Foundation

### Check-In Status

- Status: implementing accepted plan for native SwiftUI AI Chat scenarios.
- Target section: `1:5059` AI chat, including entry, keyboard, thinking, Credit Score, Budgeting, and Debt Payoff response flows.
- Scope: deterministic scenario-router chat foundation, not live AI/backend integration.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: add a routed `AIChatView` with reusable private chat components and fixture-driven scenario rendering. Keep home/story code unchanged except for explicit AI entry actions.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Record this AI chat checklist before coding.
- [x] Wire `NavigationStack`, `.aiChat`, and home entry actions.
- [x] Make `Talk with AI` and the home `AI mode` pill open AI Chat.
- [x] Implement `AIChatView` state machine: initial, focused empty, typing, thinking, responded.
- [x] Implement reusable chat surfaces: top bar, composer, chips, response cards, and edge glow.
- [x] Implement deterministic scenario router and seven response flows.
- [x] Add native keyboard/focus behavior with safe-area composer lift.
- [x] Register new Swift source in `BON.xcodeproj`.
- [x] Build on iPhone 17 Pro simulator destination.
- [x] Capture PixelQA screenshots for chat entry states and response scenarios.
- [x] Review Reduce Motion and Reduce Transparency behavior.
- [x] Update verification results and review notes before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Home and entry QA:
  - `PixelQA/bon-ai-chat-home-rest-logical.png`
  - `PixelQA/bon-ai-chat-cta-tap-result-logical.png`
  - `PixelQA/bon-ai-chat-mode-pill-tap-result-logical.png`
- Chat state QA:
  - `PixelQA/bon-ai-chat-initial-logical.png`
  - `PixelQA/bon-ai-chat-keyboard-empty-final-logical.png`
  - `PixelQA/bon-ai-chat-keyboard-typed-final-logical.png`
  - `PixelQA/bon-ai-chat-thinking-logical.png`
- Response scenario QA:
  - `PixelQA/bon-ai-chat-response-credit-improve-logical.png`
  - `PixelQA/bon-ai-chat-response-credit-drop-logical.png`
  - `PixelQA/bon-ai-chat-response-budget-spending-logical.png`
  - `PixelQA/bon-ai-chat-response-budget-timeline-logical.png`
  - `PixelQA/bon-ai-chat-response-budget-runway-logical.png`
  - `PixelQA/bon-ai-chat-response-debt-cards-logical.png`
  - `PixelQA/bon-ai-chat-response-debt-path-logical.png`
- Accessibility QA: `PixelQA/bon-ai-chat-reduce-motion-transparency-logical.png`.
- Figma comparison: initial chat resized to Figma baseline is `PixelQA/bon-ai-chat-initial-resized-to-figma.png`; diff is `PixelQA/bon-ai-chat-initial-diff.png`; mismatch is `36.4800%` at threshold `10`. This is not pixel-approved yet because the implementation is responsive to iPhone 17 Pro, uses revised useful suggestion prompts, and top/safe-area spacing differs from the `390 x 845` Figma frame.
- Keyboard QA: software keyboard screenshots required toggling the Simulator software keyboard path after the host initially showed a hardware-keyboard text cursor only.

### Review Notes

- The implementation should adapt Apple's Siri-style active edge glow into a branded BON lime glow without turning it into a static border.
- `Talk to human expert` is visual-only in this pass.
- Unknown prompts should route to helpful category chips instead of pretending to be live AI.
- Implemented `NavigationStack` routing, `.aiChat`, launch-argument QA states, home CTA entry, and home `AI mode` pill entry.
- Implemented AI Chat as deterministic fixture content with reusable private SwiftUI components in `AIChatView`.
- The seven response scenarios render real SwiftUI cards/charts/rows rather than static screenshots.
- Known visual risks: response cards are first-pass SwiftUI approximations, not final pixel-perfect audits; complex row logos/icons still use SF Symbols; exact mid-transition screenshot capture was not stable through simulator automation, but tap-through final states were verified from both entry controls.

---

## 2026-05-07 - Real Device Story Motion Corrections

### Check-In Status

- Status: implementing corrections from real iPhone testing.
- Corrections: remove the strange white AI-box overlay during handoff, make CTA motion start immediately, make story paging easier to trigger, and recenter compact nav icons.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: remove the duplicate morph surface and use the real hero panel plus CTA overlay for continuity. Keep paging as a single `ScrollView` but lower the page snap threshold.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Record correction checklist before coding.
- [x] Remove the duplicate white morph surface from the chrome overlay.
- [x] Make CTA/nav collapse progress direct from scroll offset instead of double-eased.
- [x] Make the real AI hero panel shrink/fade from the start of the gesture.
- [x] Lower snap threshold so short flicks advance one page.
- [x] Recenter compact nav icon layout.
- [x] Rebuild and capture simulator QA states.
- [x] Update lessons and verification notes before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Handoff QA:
  - `PixelQA/home-story-realdevice-fix-handoff-logical.png`
  - `PixelQA/home-story-realdevice-fix-handoff-deep-logical.png`
- Snapped story QA:
  - `PixelQA/home-story-realdevice-fix-budgeting-logical.png`
  - `PixelQA/home-story-realdevice-fix-credit-logical.png`
  - `PixelQA/home-story-realdevice-fix-cash-logical.png`
- Accessibility QA: `PixelQA/home-story-realdevice-fix-reduce-motion-transparency-logical.png`.
- Compact nav crop: `PixelQA/home-story-realdevice-fix-budgeting-nav-crop-logical.png`.
- Compact nav measurement: dark visual bounds `198 x 42`, centered at `x=200.5` on a `402pt` logical screenshot, bottom margin `21pt`.
- Handoff visual result: the duplicate white AI-box overlay is gone; the remaining handoff shows outgoing cards fading, incoming budgeting content rising, CTA already moved upward, and compacting nav.

### Review Notes

- Real-device screenshot showed the separate morph surface looking like a late, oversized white panel over the cards.
- Real-device testing showed the previous page threshold required too much drag before the page changed.
- Removed `HomeHeroMorphSurface`; continuity now comes from the real hero panel shrinking/fading and the CTA overlay moving from scroll offset.
- Changed collapse progress to direct clamped scroll progress over `0.48 * screenHeight`, so CTA motion starts immediately.
- Changed page target selection to a biased threshold (`0.74 * pageHeight`) so a shorter flick advances pages.
- Removed collapsed bottom-nav labels from layout and returned compact padding to a centered value.

---

## 2026-05-07 - Story Snap And Morph Corrections

### Check-In Status

- Status: implementing corrections from review.
- Corrections: make the first home state one screen, remove the visible subscription card from the intro, make story scrolling feel page-snapped, improve the AI hero-to-CTA morph, and move compact nav closer to the bottom edge during collapse.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: treat the home intro and each feature story as equal full-screen scroll targets. Keep the AI hero morph and bottom-nav morph as overlay chrome driven by the same story handoff progress.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Record correction checklist before coding.
- [x] Inspect current home/story layout and nav variant code.
- [x] Make home intro a single viewport with only Budgeting and Credit Score cards visible.
- [x] Replace soft custom snapping with stronger full-page target behavior.
- [x] Rework AI motion so the hero box shrinks/dissolves into the pinned CTA instead of simply fixing the CTA.
- [x] Tune compact nav padding and bottom offset so it shifts closer to the edge during collapse.
- [x] Rebuild on iPhone 17 Pro.
- [x] Capture resting, handoff, snapped Budgeting, snapped Credit Score, snapped Cash Advance, compact-nav, and accessibility QA screenshots.
- [x] Update verification results and lessons before final.

### Verification Results

- Build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Resting home QA: `PixelQA/home-story-corrected-v2-resting-logical.png`; intro is one viewport and the subscription card is no longer visible.
- Handoff QA: `PixelQA/home-story-corrected-v2-handoff-logical.png`; debug offset capture disables snap only for the intermediate screenshot, so it shows the actual scroll-position handoff instead of settling to a page.
- Snapped story QA:
  - `PixelQA/home-story-corrected-v2-budgeting-logical.png`
  - `PixelQA/home-story-corrected-v2-credit-logical.png`
  - `PixelQA/home-story-corrected-v2-cash-logical.png`
- Compact nav crops:
  - `PixelQA/home-story-corrected-v2-budgeting-nav-only-crop-logical.png`
  - `PixelQA/home-story-corrected-v2-credit-nav-only-crop-logical.png`
  - `PixelQA/home-story-corrected-v2-cash-nav-only-crop-logical.png`
- Compact nav measurement: dark visual bounds `198 x 42`, centered at `x=200.5` on a `402pt` logical screen, bottom margin `21pt`.
- Reduce Motion/Reduce Transparency QA: `PixelQA/home-story-corrected-v2-reduce-motion-transparency-logical.png`.
- Manual drag limitation: Simulator host drag/scroll injection still does not affect the app, so physical finger-feel must be checked manually. Code-level snap is implemented by page-height `ScrollTargetBehavior` with `limitsScrolls` on iOS 18.4+.

### Review Notes

- The previous pass was structurally correct but felt like normal scrolling because the intro height exceeded one viewport and the custom target behavior only adjusted the final target after a threshold.
- The CTA motion needs to preserve the sense of the AI hero panel collapsing into the CTA. A pinned CTA alone is not enough.
- Implemented full-screen scroll targets by making `homeIntroHeight == screenHeight` and each story page `screenHeight`.
- Added a morphing hero surface overlay that shrinks/dissolves from the AI box into the CTA path while the CTA remains tappable above it.
- Added asymmetric compact-nav padding so icons align closer to the planned Figma centers, and moved compact nav bottom margin from about `49pt` to `21pt`.
- Kept the existing corrected Liquid Glass/inner-shadow implementation intact.

---

## 2026-05-07 - Home Feature Story Scroll Flow

### Check-In Status

- Status: implementing accepted plan for the natural-scroll home-to-feature-story flow.
- Target frames: `1:3008` Budgeting, `1:4201` Credit Score, `1:4253` Cash Advance.
- Scope: full three-screen story flow below the current home, with pinned `Talk with AI` CTA and compact bottom nav.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: split the current home into an intro section, reusable story chrome, compact/expanded nav variants, and page-specific story modules. Do not duplicate the corrected nav glass/inner-shadow implementation.

### Plan

- [x] Review relevant lessons before implementation.
- [x] Create this story-flow checklist before coding.
- [x] Run preflight build before Swift changes.
- [x] Refactor home into a scroll-driven story flow container.
- [x] Add expanded/compact variants to `BONBottomNav` while preserving current expanded anatomy.
- [x] Add pinned `Talk with AI` story chrome and scroll-progress based collapse.
- [x] Implement Budgeting story page from Figma frame `1:3008`.
- [x] Implement Credit Score story page from Figma frame `1:4201`.
- [x] Implement Cash Advance story page from Figma frame `1:4253`.
- [x] Add story paging/snap behavior and Reduce Motion fallback.
- [x] Rebuild on iPhone 17 Pro destination.
- [x] Launch simulator and capture home, handoff, budgeting, credit score, cash advance, and compact-nav QA screenshots.
- [x] Review visual results for centering, safe areas, nav inner shadow, icon sharpness, snapping, CTA continuity, and text clipping.
- [x] Document verification results and review notes before final.

### Verification Results

- Baseline build: passed before Swift changes with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Final build: passed after implementation with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Simulator QA: captured resting home, mid-collapse handoff, Budgeting, Credit Score, Cash Advance, Reduce Motion/Reduce Transparency handoff, and compact-nav crops under `PixelQA/`.
- Final screenshot set:
  - `PixelQA/home-story-flow-resting-final-logical.png`
  - `PixelQA/home-story-flow-handoff-final-logical.png`
  - `PixelQA/home-story-flow-budgeting-final-logical.png`
  - `PixelQA/home-story-flow-credit-final-logical.png`
  - `PixelQA/home-story-flow-cash-final-logical.png`
  - `PixelQA/home-story-flow-reduce-motion-transparency-final-logical.png`
  - `PixelQA/home-story-flow-normal-launch-final.png`
  - `PixelQA/home-story-flow-budgeting-final-compact-nav-crop-logical.png`
  - `PixelQA/home-story-flow-credit-final-compact-nav-crop-logical.png`
  - `PixelQA/home-story-flow-cash-final-compact-nav-crop-logical.png`
- Side-by-side evidence: `PixelQA/home-story-budgeting-side-by-side.png`, `PixelQA/home-story-credit-side-by-side.png`, and `PixelQA/home-story-cash-side-by-side.png`.
- Diff evidence, normalized from Figma `390 x 845` into the iPhone 17 Pro screenshot size: Budgeting mean diff `27.10`, Credit Score mean diff `27.04`, Cash Advance mean diff `29.90`. These are noisy because of Dynamic Island/status-bar and responsive-width differences, so human review remains the primary QA gate.
- Compact nav measurement: dark visual bounds are centered at `x=201.0` on a `402pt` logical screenshot; measured dark core is about `198 x 37` inside the intended `200 x 44` compact frame.
- Reduce Motion/Reduce Transparency: first fallback created CTA overlap during handoff; fixed by preserving scroll-driven positional continuity while disabling decorative scale/reveal effects. Final accessibility screenshot shows no CTA/hero/nav overlap.
- Scroll verification: `HomeStoryScrollTargetBehavior` implements the home-to-story handoff and one-page story snapping. Host-level drag/scroll injection did not move the Simulator in this environment, so snapped page screenshots were captured through QA launch arguments rather than a physical drag.

### Review Notes

- Current accepted constraints remain active: home hero uses `8pt` outer inset, main home content uses `24pt` margins, iPhone Pro width is responsive, and the corrected bottom-nav inner shadow must remain visually present.
- Implemented the story flow as a single SwiftUI `ScrollView` with separate intro, story page, and overlay chrome responsibilities.
- `BONBottomNav` now has expanded and compact variants while reusing the same Liquid Glass, dark stain, specular overlay, vector icons, and corrected inner-shadow path.
- Story CTA and nav collapse are driven by scroll progress, not a timed-only animation, so the transition remains interruptible.
- Budgeting, Credit Score, and Cash Advance pages are implemented with real SwiftUI content rather than placeholders.
- Residual visual risk: the heatmap pattern, small row icons, and credit-score ring are SwiftUI/SF Symbol interpretations. If strict Figma parity is required for those details, export the exact vector/raster assets from Figma or audit the node geometry more deeply before calling the story pages pixel-approved.
- Physical scroll snapping still needs a manual Simulator/device check because host gesture injection did not affect the app during automated QA.

---

## Historical - BON Golden Screen 1:628 Todo

## Check-In Status

- Status: bottom-nav Liquid Glass inner-shadow regression corrected; golden screen still not fully pixel-approved.
- Target frame: `1:628` - `Home - First timer - clicked on home`.
- Scope: implement the first production SwiftUI screen plus only the assets/components required for this frame.
- Product-wide implementation: still gated by golden-screen QA; do not expand to every screen until this pass proves the system.
- Staff-engineer question: Is there a simpler, more elegant system boundary?
- Boundary decision: keep reusable Home/design-system components, export complex visuals when exact drawing is not practical, and keep the screen code token-driven.

## Plan

- [x] Review relevant lessons before implementation.
- [x] Create this golden-screen checklist before coding.
- [x] Run preflight checks for repo, scheme, and target device.
- [x] Fetch fresh Figma context and screenshot for `1:628`.
- [x] Classify required visuals as SF Symbols, SwiftUI-drawn, or exported assets.
- [x] Export first-pass production assets into `BON/Assets.xcassets`.
- [x] Implement reusable Home components and the `1:628` screen.
- [x] Run Xcode build validation.
- [x] Launch on iPhone 17 Pro simulator and capture screenshot.
- [x] Compare simulator screenshot against Figma reference and record gaps.
- [x] Update docs, review notes, and lessons before final.
- [x] Extract exact bottom-nav assets from Figma into `Assets.xcassets`.
- [x] Replace bottom-nav SF Symbol approximations with production image assets.
- [x] Extract exact top action-bar icons from Figma into `Assets.xcassets`.
- [x] Resolve visible credit-score artwork strategy for the golden screenshot.
- [x] Rebuild, relaunch, capture, and diff after refinement.
- [ ] Resolve clean, reusable subscription artwork export.
- [x] Replace fixed `390pt` screen canvas with device-width layout metrics.
- [x] Enforce home AI/hero panel `8pt` top/left/right margin on iPhone Pro.
- [x] Enforce main content and bottom-nav `24pt` left/right margin on iPhone Pro.
- [x] Rebuild, relaunch, and capture iPhone 17 Pro screenshot after responsive fix.
- [x] Audit current bottom-nav implementation against Figma and iPhone 17 Pro capture.
- [x] Replace raster nav icons with crisp vector/SVG or SwiftUI vector rendering.
- [x] Add Apple Liquid Glass-backed nav material where available, with an iOS 18 material fallback.
- [x] Rebuild, relaunch, capture, and crop bottom-nav QA after polish.
- [x] Remove false bottom-nav border strokes and apply Figma inner shadow exactly: `x=0`, `y=3`, blur `8`, white `36%`.
- [x] Rebuild, relaunch, capture, and crop bottom-nav QA after inner-shadow correction.
- [x] Compare latest simulator nav crop against Figma nav crop for geometry, surface color, shadow, inner shadow, icons, and label layout.
- [x] Record measured nav deltas and decide which are implementation defects vs intentional responsive differences.
- [x] Apply Figma-match nav fixes: darker `0.88` surface, exact outer shadow, tighter inner shadow, natural item widths, ExtraLight inactive labels, tracked labels, and no active-icon glow.
- [x] Rebuild, relaunch, capture, and re-measure nav against the Figma crop.
- [x] Research Apple Liquid Glass API/design guidance and convert nav surface from opaque glassmorphism to a real Liquid Glass functional layer.
- [x] Rebuild, relaunch, capture, and compare nav after Liquid Glass refactor.
- [x] Restore visible Figma inner shadow on the Liquid Glass nav without adding a border.
- [x] Rebuild, relaunch, crop, and compare the corrected nav before reporting back.

## Progress Checklist

- [x] Product screen implementation starts with one controlled golden frame.
- [x] Zalando Sans and Geist Pixel are bundled and verified.
- [x] No localhost Figma URLs are allowed at runtime.
- [x] Figma reference screenshot for `1:628` is saved as `FigmaExports/home-clicked-figma-fresh.png`.
- [x] First-pass `homeFeatureBudgetingArtwork` asset is in `BON/Assets.xcassets`.
- [x] SwiftUI screen compiles.
- [x] Pixel QA screenshot exists.
- [ ] Golden screen is pixel-approved.
- [ ] Exact lower-card artwork exports are approved for production.
- [x] Nav icon artwork is matched to the Figma nodes instead of SF Symbol approximations.
- [x] Top action-bar icon artwork is matched to the Figma nodes instead of SF Symbol approximations.
- [x] Second-pass screenshot and diff are recorded.
- [x] iPhone 17 Pro responsive screenshot is recorded.
- [x] Bottom nav Figma inner-shadow correction is verified.

## Verification Results

- Preflight: passed. `BON.xcodeproj` has scheme `BON`; iPhone 17 Pro simulator is available and booted.
- Figma context: passed. Fresh local MCP outputs saved under `FigmaExports/home-clicked-*-fresh.*`.
- Asset verification: partial. `homeFeatureBudgetingArtwork`, `topProfile`, and `topBell` are installed at 1x/2x/3x; `navCards`, `navSpend`, `navHome`, `navCredit`, and `navMoney` are sanitized SVG template assets. Credit-score and subscription thumbnail exports are still not production-clean.
- Repo build: passed with `xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`.
- Simulator QA: passed for launch and screenshot capture. Latest normalized capture: `PixelQA/home-1-628-iphone17pro-top-nav-credit-assets-normalized.png`.
- Pixel diff: improved but not approved. `PixelQA/home-1-628-top-nav-credit-assets-diff.png` reports `20.7717%` mismatch at threshold `8`.
- Region diff: feature-card visible region is `5.9309%`; nav region is `53.7260%`; hero content excluding status is `19.0248%`.
- Responsive iPhone 17 Pro QA: passed for layout policy. Full logical screenshot is `402 x 874`; latest capture is `PixelQA/home-17pro-scroll-content-centered-logical.png`.
- Bottom-nav polish QA: passed for build, launch, visibility, and responsive centering. Latest full capture is `PixelQA/home-17pro-nav-glass-polish-logical.png`; nav crop is `PixelQA/bottom-nav-after-polish-crop.png`.
- Bottom-nav inner-shadow correction QA: passed for build, launch, and crop capture. Latest full capture is `PixelQA/home-17pro-nav-inner-shadow-figma-logical.png`; nav crop is `PixelQA/bottom-nav-inner-shadow-figma-crop.png`.
- Bottom-nav Figma-match QA: passed for build, launch, crop capture, and known-box comparison. Latest full capture is `PixelQA/home-17pro-nav-figma-match-pass-2-logical.png`; nav crop is `PixelQA/bottom-nav-figma-match-pass-2-crop.png`; side-by-side is `PixelQA/bottom-nav-figma-match-pass-2-side-by-side.png`.
- Bottom-nav Liquid Glass QA: passed for build, launch, crop capture, and known-box comparison. Latest full capture is `PixelQA/home-17pro-nav-liquid-glass-final-logical.png`; nav crop is `PixelQA/bottom-nav-liquid-glass-final-crop.png`; side-by-side is `PixelQA/bottom-nav-liquid-glass-final-side-by-side.png`; diff is `PixelQA/bottom-nav-liquid-glass-final-diff-amplified.png`.
- Bottom-nav inner-shadow regression correction QA: passed for build, relaunch, crop capture, visual review, and measured comparison. Latest full capture is `PixelQA/home-17pro-nav-liquid-glass-inner-shadow-corrected-logical.png`; nav crop is `PixelQA/bottom-nav-liquid-glass-inner-shadow-corrected-crop.png`; side-by-side is `PixelQA/bottom-nav-liquid-glass-inner-shadow-corrected-side-by-side.png`; diff is `PixelQA/bottom-nav-liquid-glass-inner-shadow-corrected-diff-amplified.png`.
- Bottom-nav centering proof after polish: dark nav bounds center `200.5` against iPhone 17 Pro screen center `201.0`.
- Responsive centering proof: CTA center `200.5`, section title center `200.5`, nav center `200.5`, amount center `202.0` against screen center `201.0`.
- Responsive layout frames: hero/home AI panel uses `8pt` visual side margin; main content and bottom nav use `24pt` visual side margin; bottom nav bottom margin `48`.
- Bottom-nav correction audit: previous nav used raster PNG screenshots for icons and a flat black capsule, which left the nav too soft/blurry and missed the stronger Apple-style glass/inset treatment.
- Bottom-nav implementation proof: `BONBottomNav` now uses exact `rgba(0,0,0,0.88)` dark fill, exact outer shadow `0 12 12 rgba(0,0,0,0.16)`, exact Figma inner shadow token `inset 0 3 8 rgba(255,255,255,0.36)` without border strokes, natural Figma item widths, ExtraLight inactive labels with `0.10` tracking, no active-icon glow, and sanitized SVG template assets for `navCards`, `navSpend`, `navHome`, `navCredit`, and `navMoney`.
- Bottom-nav comparison evidence: Figma known nav box is `342 x 64`; simulator responsive nav box is `354 x 64`. Known-box normalized diff improved from `24.84/27.89/29.08` RGB to `10.12/11.55/12.86` RGB.
- Bottom-nav measured surface deltas after fix: left over art `18.8` vs Figma `17.8`, center `23.3` vs `23.8`, right over white `31.2` vs `34.9`, top inner band `31.0` vs `28.2`, bottom band `27.1` vs `23.0`.
- Bottom-nav Liquid Glass measurements: known-box normalized RGB diff is `11.57/13.52/14.57`; luminance zones are left over art `22.7` vs Figma `17.9`, center `36.0` vs `31.8`, right over white `35.4` vs `35.2`, top inner band `24.9` vs `26.1`, bottom band `24.8` vs `22.5`.
- Bottom-nav corrected inner-shadow measurements: known-box normalized RGB diff is `9.94/12.35/13.46`; top-edge luminance is `51.4` vs Figma `51.0`, top inner band `34.2` vs `26.1`, left over art `22.7` vs `17.9`, center `36.0` vs `31.8`, right over white `35.4` vs `35.2`, bottom band `24.9` vs `22.5`.
- Bottom-nav Liquid Glass implementation proof: iOS 26+ nav now uses `GlassEffectContainer` and `glassEffect(.regular.tint(...).interactive(), in: Capsule())` on the actual nav control surface, with a BON dark stained layer, subtle specular overlay, Figma inner shadow, and an iOS 18 material fallback.
- Bottom-nav intentional difference: width is `354pt` on iPhone 17 Pro because of the approved `24pt` left/right responsive margin policy; Figma baseline is `342pt` on a `390pt` frame.
- Geometry spot-check: first and second card art bounds now match Figma exactly at `x=32`, `y=480/664`, `164 x 156`.
- Staff-engineer check: first pass proves the component boundary, but the screen must not be called pixel-perfect until the remaining visual deltas are closed.

## Review Notes

- Root screen is now `HomeFirstTimerClickedView`.
- Implemented components: hero panel, top action bar, icon button, AI mode pill, CTA pill, feature card, bottom nav.
- Biggest known visual delta is now explicitly accepted as a device-policy difference: the app should fit iPhone Pro widths instead of forcing the `390 x 845` Figma frame.
- Remaining product deltas: clean subscription artwork export, clean credit-score artwork export, typography antialiasing/baseline tuning, and final shadow/material tuning.
- Bottom nav polish preserved its `24pt` responsive margins and `64pt` height while correcting surface darkness, exact inner shadow, outer shadow, typography, item spacing, and icon rendering.
- Bottom nav now preserves the native Apple Liquid Glass path on iOS 26+ while keeping BON's dark Figma anatomy. The remaining Liquid Glass tradeoff is intentional: the surface is slightly brighter on the left/middle than the exact opaque Figma-match pass because it now samples and refracts underlying content instead of hiding it.
- The Liquid Glass inner-shadow regression was caused by placing the inset highlight where it was not visually surviving the glass composition. It now renders inside the glass surface as a thin soft edge highlight plus a weaker diffuse inset, preserving the Figma shadow without returning to a crisp border.
- Credit-score artwork is back to SwiftUI-drawn because the visible-state composite crop included the old nav overlay after the responsive nav moved down.
- `Instrument Serif` remains conditional and is not used in this screen.
- Long AI-chat response flows are out of scope for this pass.
