# BON Lessons

Review this file at the start of every non-trivial BON implementation turn. After any correction, append a new entry using this exact shape: correction, root cause, prevention rule, verification rule.

## 2026-05-06 - Design system before screens

- Correction: Do not start implementing product screens from a single Figma frame before building the BON design-system foundation.
- Root cause: A golden-screen-first workflow can accidentally turn reusable Figma patterns into one-off SwiftUI constants.
- Prevention rule: For BON, complete and review `DESIGN_SYSTEM.md`, `FIGMA_AUDIT.md`, and SwiftUI design-system tokens before implementing the first product screen.
- Verification rule: Before any screen is marked ready, confirm that its colors, typography, spacing, radius, shadows, assets, motion, and states map to documented design-system roles.

## 2026-05-06 - Persistent task tracking

- Correction: Non-trivial implementation work must not live only in chat.
- Root cause: Chat-only plans lose proof, review notes, and unresolved blockers across long sessions.
- Prevention rule: Start every non-trivial BON implementation turn by reading relevant lessons and creating or updating `tasks/todo.md`.
- Verification rule: Do not send a completion summary until `tasks/todo.md` has current progress, verification results, and review notes.

## 2026-05-06 - Prove completion

- Correction: Never mark a BON task complete without evidence that it works.
- Root cause: Visual implementation work can look complete in code while failing build, assets, simulator layout, or accessibility gates.
- Prevention rule: For each non-trivial change, define the verification command or artifact before calling the task done.
- Verification rule: Record build results, screenshot references, diff status, or explicit blockers in `tasks/todo.md`.

## 2026-05-06 - Elegant boundaries

- Correction: Avoid patchy fixes when a design-system boundary is the more maintainable answer.
- Root cause: Pixel-perfect pressure can encourage hardcoded values that later make animation, accessibility, and additional screens fragile.
- Prevention rule: For non-trivial changes, pause and ask whether tokens, component APIs, or asset boundaries can make the implementation simpler.
- Verification rule: Reject repeated raw values in screen code when they should be named tokens or documented component properties.

## 2026-05-06 - Keep trackers synchronized

- Correction: Do not update design-system docs while leaving tracker tables or immediate-next-step sections stale.
- Root cause: A stale tracker can point future work back toward screen implementation even after the current gate says design-system review is required first.
- Prevention rule: Whenever `DESIGN_SYSTEM.md` or `FIGMA_AUDIT.md` changes materially, update `DESIGN_IMPLEMENTATION_WORKFLOW.md` and `tasks/todo.md` in the same pass.
- Verification rule: Search workflow docs for stale placeholders or outdated next steps before finalizing a foundation pass.

## 2026-05-06 - Quote shell URLs

- Correction: Shell commands that pass URLs containing `?`, `&`, or other glob characters must quote the URL argument.
- Root cause: zsh treats unquoted `?` as a filename wildcard and fails when there is no match.
- Prevention rule: Wrap URLs in single quotes in shell commands, especially GitHub API and raw download URLs with query strings.
- Verification rule: Rerun the quoted command and confirm it exits successfully with the expected response.

## 2026-05-06 - Verify generated artifact paths

- Correction: Do not assume a batch export loop created every expected Figma artifact.
- Root cause: A shell loop can silently fail to create named outputs when arguments are malformed or the command is more complex than necessary.
- Prevention rule: After every multi-asset export, immediately list the expected files before decoding or consuming them.
- Verification rule: Run `find` or `ls` for the exact expected artifact names and confirm dimensions after decoding.

## 2026-05-06 - Compose SwiftUI frame constraints

- Correction: Do not call `.frame(width:minHeight:alignment:)`; SwiftUI does not provide that overload.
- Root cause: Width and minimum-height constraints were combined into a nonexistent convenience overload.
- Prevention rule: Chain `.frame(width:)` and `.frame(minHeight:alignment:)` when a view needs fixed width plus flexible minimum height.
- Verification rule: Re-run `xcodebuild` after any layout modifier correction.

## 2026-05-06 - Normalize Figma Canvas Safe Areas

- Correction: A Figma frame with absolute status-bar and nav coordinates must not be implemented in a SwiftUI root that implicitly shifts content below safe areas.
- Root cause: The initial golden-screen canvas was inside a root layout that respected container safe areas, moving the hero and nav down relative to Figma.
- Prevention rule: For pixel QA of full-frame Figma screens, explicitly decide whether the screen draws under system chrome and apply `.ignoresSafeArea` at the canvas boundary when Figma coordinates start at `y=0`.
- Verification rule: Capture a simulator screenshot, downsample to logical points, crop to the Figma baseline, and compare hero/nav y positions.

## 2026-05-06 - Spawn Forked Agents Without Overrides

- Correction: Do not pass `agent_type`, `model`, or `reasoning_effort` while also requesting a full-history forked agent.
- Root cause: Full-history forked agents inherit the parent agent type, model, and reasoning effort, so explicit overrides are rejected.
- Prevention rule: For full-history forks, omit overrides; for explicit agent roles, spawn without a full-history fork and pass the needed context directly.
- Verification rule: Confirm the spawn call returns a running agent ID before relying on delegated work.

## 2026-05-06 - Use Absolute Simulator Screenshot Paths

- Correction: Do not pass a relative output path to `xcrun simctl io screenshot` for BON PixelQA captures.
- Root cause: `simctl` resolved the relative path in a context where the expected folder did not exist, producing a Cocoa file-write error.
- Prevention rule: Use absolute paths under `/Users/abhinavjain/BON app/PixelQA/` for simulator screenshots.
- Verification rule: Confirm the screenshot command reports `Wrote screenshot to:` with the intended absolute file.

## 2026-05-06 - Relaunch Simulator Apps After Rebuild

- Correction: Do not assume an installed rebuild is reflected in screenshots while the app process is still running.
- Root cause: The simulator can keep displaying an already-running process after reinstall, hiding layout edits during visual QA.
- Prevention rule: Terminate `com.abhinavjain.bon` before relaunching for each screenshot-validation pass.
- Verification rule: Capture a new screenshot after terminate/install/launch and measure the edited geometry against the Figma reference.

## 2026-05-06 - Lock Feature Card Row Width

- Correction: Do not let SwiftUI center a feature card's natural HStack width when Figma defines an exact row inset.
- Root cause: The card row's natural layout width made artwork and text drift from the Figma x positions even though the outer card frame was correct.
- Prevention rule: Give fixed-format card rows an explicit full-width, leading-aligned internal frame before applying the outer card frame.
- Verification rule: Measure prominent artwork bounds in the simulator screenshot; for `1:628`, budgeting and credit artwork should start at `x=32` and remain `164 x 156`.

## 2026-05-06 - Verify Asset Rendering In Simulator

- Correction: Do not assume Figma SVG assets render correctly in iOS asset catalogs just because Xcode builds.
- Root cause: Figma SVGs with CSS-variable stroke declarations compiled but rendered invisible in SwiftUI image views.
- Prevention rule: For small Figma icons, prefer node screenshots converted to 1x/2x/3x transparent PNGs unless SVG rendering is visually proven in simulator.
- Verification rule: Capture and inspect a simulator screenshot after every new asset-rendering path; do not rely on build success alone.

## 2026-05-06 - Preserve Fixed Icon Button Geometry

- Correction: Do not add padding after a fixed `40 x 40` icon-button frame.
- Root cause: Padding after the frame would expand the tappable visual beyond the Figma button size.
- Prevention rule: Size the icon itself first, then place it inside a fixed button frame before applying the background.
- Verification rule: Rebuild and visually inspect top action buttons against the Figma `40 x 40` controls.

## 2026-05-06 - Reject Contaminated Node Exports

- Correction: Do not treat a node screenshot as a clean production asset when it includes overlay content from another layer.
- Root cause: Figma MCP exported the credit-score card artwork with the bottom nav composited over it, even when requesting contents-only rendering.
- Prevention rule: Inspect every exported artwork PNG before installing it; if it includes unrelated overlay content, classify it as a visible-state QA crop or re-export through a cleaner path.
- Verification rule: Open the exported PNG and compare it to the intended isolated node before adding it to `Assets.xcassets`.

## 2026-05-07 - Do Not Force Figma Frame Width On Pro Devices

- Correction: Do not center a fixed `390pt` Figma canvas inside wider iPhone Pro simulators.
- Root cause: The initial golden-screen implementation optimized for Figma screenshot diffing instead of the actual target device family.
- Prevention rule: Use device-width layout metrics for production screens; preserve Figma margins as constraints, with `8pt` hero/home AI outer inset and `24pt` main content margins on iPhone Pro.
- Verification rule: Capture the full iPhone Pro logical screenshot and confirm the hero frame is `x=8`, content/nav is `x=24`, and the screen uses the full device width.

## 2026-05-07 - Reject Visible-State Crops For Moving Overlays

- Correction: Do not keep a visible-state crop as an artwork asset when the overlay that was baked into the crop can move independently.
- Root cause: The credit-score thumbnail crop included the old bottom nav position; after the responsive nav moved down, the baked nav became visible as a duplicate.
- Prevention rule: Use only isolated clean artwork exports for reusable assets; if clean export fails, keep the artwork SwiftUI-drawn or explicitly mark it as temporary.
- Verification rule: Re-capture after any overlay-position change and inspect lower cards for duplicated nav, clipped overlays, or stale baked UI.

## 2026-05-07 - Measure ScrollView Content Centering

- Correction: Do not assume centered layout math is visually centered inside a SwiftUI `ScrollView`.
- Root cause: The scroll content rendered about `8pt` to the right on iPhone 17 Pro even though overlay nav positioning was centered.
- Prevention rule: For full-screen scroll layouts, validate the rendered centers of hero controls, CTA, section title, and card content against the simulator screen center; apply correction at the scroll-content boundary if needed.
- Verification rule: After the correction, capture the simulator screenshot and confirm centered elements are within `1pt` of the screen center.

## 2026-05-07 - Use Native Glass For Floating Navigation

- Correction: Do not approximate the bottom nav as only a flat black capsule when the product expects Apple-style glass and Figma shows inset lighting.
- Root cause: The previous component used a dark fill plus simple strokes, missing the native Liquid Glass layer and the stronger inner highlight/shadow structure.
- Prevention rule: Floating BON navigation surfaces should use native `glassEffect` where available, a material fallback for older iOS targets, and component-owned inset highlight/shadow layers.
- Verification rule: Build, launch on the target simulator, capture a crop of the nav, and inspect that backdrop tinting, edge lighting, and outer shadow are visible.

## 2026-05-07 - Keep Small Tab Icons Vector-Backed

- Correction: Do not ship 20 pt tab icons as Figma screenshot PNGs when clean SVG paths are available.
- Root cause: Raster screenshots antialias small strokes before iOS scales and composites them, making nav icons look soft.
- Prevention rule: For small custom tab icons, sanitize Figma SVGs into template assets or draw them as SwiftUI vectors; only use PNG if vector rendering fails in simulator.
- Verification rule: Confirm Xcode builds the vector assets and capture a simulator screenshot showing every nav icon rendered, tinted, and sharp.

## 2026-05-07 - Return Explicitly From Opaque View Helpers With Local Bindings

- Correction: Do not rely on implicit single-expression return from a `some View` helper after adding local constants.
- Root cause: The nav button helper gained local `let` bindings, so Swift could no longer infer the opaque return from the final expression.
- Prevention rule: Add an explicit `return` or convert the helper to a `@ViewBuilder` computed block whenever local setup statements are introduced before a `some View` expression.
- Verification rule: Run `xcodebuild` immediately after structural SwiftUI helper changes.

## 2026-05-07 - Do Not Convert Inner Shadows Into Borders

- Correction: Do not implement Figma's bottom-nav inner shadow as `strokeBorder` or crisp edge-highlight strokes.
- Root cause: The previous polish pass translated `inset 0 3 8 rgba(255,255,255,0.36)` into visible outline strokes, which looked like a border the design does not have.
- Prevention rule: When Figma specifies inner shadow, implement a masked blurred inner shadow using the exact x, y, blur, spread, color, and opacity; add no extra border unless Figma has a separate stroke.
- Verification rule: Capture a simulator crop and inspect that the edge lighting is soft and inset, with no crisp capsule outline.

## 2026-05-07 - Match Figma Anatomy Before Adding Platform Material

- Correction: Do not let native Liquid Glass or material brightness override Figma's measured dark surface for the bottom nav.
- Root cause: The nav looked visually wrong because the system material/glass layer made the capsule too bright and translucent compared with Figma's `rgba(0,0,0,0.88)` fill.
- Prevention rule: For pixel-critical surfaces, implement Figma fill, outer shadow, inner shadow, typography, and item geometry first; add platform material only as a subtle underlay if measured surface luminance stays close to Figma.
- Verification rule: Compare known nav boxes and record surface luminance zones plus normalized diff before calling the nav visually matched.

## 2026-05-07 - Apply Liquid Glass To The Control Surface

- Correction: Do not apply Liquid Glass as a separate background-only shape that can be composited over nav content.
- Root cause: The first iOS 26 glass pass rendered a real `glassEffect` layer, but the effect surface visually covered the bottom-nav icons and labels because it was detached from the actual control surface.
- Prevention rule: For custom BON Liquid Glass controls, apply `glassEffect` after the control's appearance modifiers on the actual interactive surface, then overlay inner shadows/highlights above it.
- Verification rule: After any Liquid Glass refactor, capture a simulator crop and confirm both the glass surface and all foreground controls are visible before measuring color parity.

## 2026-05-07 - Visual Requirements Must Survive Composition

- Correction: Do not report a component as fixed because the required layer exists in SwiftUI code; the simulator crop must prove the layer is visually present.
- Root cause: The Liquid Glass pass retained an inner-shadow view in code, but the final glass composition made the Figma inset highlight effectively disappear from the rendered nav.
- Prevention rule: For any corrected visual requirement, compare the latest simulator crop against the specific Figma evidence for that requirement before final handoff.
- Verification rule: Record visual evidence and at least one targeted measurement for the corrected requirement, such as top-edge luminance for the bottom-nav inset highlight.

## 2026-05-07 - Reduce Motion Must Not Create Overlap

- Correction: Do not replace scroll-driven chrome motion with an abrupt state jump if the intermediate scroll position still contains underlying hero content.
- Root cause: The first Reduce Motion fallback pinned the `Talk with AI` CTA immediately after a small scroll offset, which overlapped the hero amount during the handoff state.
- Prevention rule: For Reduce Motion, remove decorative scale/fade effects but keep user-driven positional continuity when abrupt jumps would cause layout overlap.
- Verification rule: Capture a Reduce Motion handoff screenshot and inspect CTA, hero amount, nav, and feature-card text for overlap before calling scroll chrome accessible.

## 2026-05-07 - Snap Requires Page-Sized Targets

- Correction: Do not expect TikTok-style snap if the intro content is taller than one viewport and can scroll internally before reaching the story pages.
- Root cause: The previous intro was `1020pt` tall, so the first gesture felt like normal scrolling even though story pages snapped later.
- Prevention rule: For story-style vertical flows, make the intro and each story a single viewport-height scroll target, then snap to page-height boundaries.
- Verification rule: Capture the resting home and first story page; the resting home must show no third intro card, and story pages must settle at full-screen offsets.

## 2026-05-07 - Pinned CTA Is Not A Morph

- Correction: Do not describe a CTA as morphing when only its final position is fixed while the source hero panel scrolls away.
- Root cause: The previous handoff moved `Talk with AI` but did not carry the AI hero box visually, so the animation felt detached and dull.
- Prevention rule: For hero-to-control transitions, animate the source surface itself with proportional shrink, dissolve, and scroll-driven continuity, while the surviving control remains above it.
- Verification rule: Capture a mid-handoff screenshot showing the source surface, CTA, outgoing home content, incoming story content, and nav all in a coherent intermediate state.

## 2026-05-07 - Compact Chrome Must Move Toward The Edge

- Correction: Do not keep floating bottom chrome at the expanded bottom offset during the compact story state.
- Root cause: The compact nav reused the expanded `48pt` bottom margin, leaving it too high compared with the Figma/Safari-like collapsed position.
- Prevention rule: Interpolate bottom chrome position independently from size; expanded nav can preserve the home margin, but compact nav should move toward the bottom safe-area edge.
- Verification rule: Measure compact nav bottom margin in the snapped story screenshots and compare it to the Figma baseline before approving the collapse.

## 2026-05-07 - Do Not Duplicate Morph Surfaces Over Scroll Content

- Correction: Remove the separate white AI morph surface that floated over the scrolling home cards during handoff.
- Root cause: The duplicate surface was not the real hero panel, so at intermediate scroll positions it looked like a late oversized white rectangle instead of a natural shrink/dissolve.
- Prevention rule: Prefer animating the real source view for scroll-driven morphs; if an overlay is needed, it must be subtle, non-opaque, and visually proven at mid-gesture.
- Verification rule: Capture a mid-handoff screenshot from a real scroll offset and confirm no opaque ghost panel covers outgoing or incoming content.

## 2026-05-07 - Do Not Blend AI Response Frame Variants

- Correction: Remove sibling-frame content and generic styling from the `1:5061` credit-improve action card.
- Root cause: The shared `creditImprove` fixture had blended content from nearby credit-response frames before the exact long-frame audit was complete.
- Prevention rule: For every detailed AI Chat graphic, first map exact strings, card modules, dimensions, colors, and font weights to the target Figma frame ID; do not borrow text or modules from sibling frames unless the scenario explicitly branches.
- Verification rule: Save the target Figma reference and capture simulator screenshots for the specific response sections before marking that graphic pass complete.

## 2026-05-07 - Do Not Reuse Neutral Chips For Chat Suggestions

- Correction: Fallback AI Chat suggestions must not use the generic grey category-chip style when Figma's chat prompt suggestions use bright lime capsules.
- Root cause: The fallback route was implemented from the scenario concept "category chips" instead of the visual evidence for BON chat suggestion chips.
- Prevention rule: Before adding a new chat chip state, classify it as initial suggestion, response suggestion, sent prompt, or data/category label, then map it to the matching design-system variant.
- Verification rule: Capture the exact chat state after routing an unknown prompt and confirm fallback choices use the bright lime suggestion treatment, not pale grey outlined pills.

## 2026-05-07 - Do Not Double-Ease Scroll Chrome Position

- Correction: Make the CTA and nav collapse progress respond directly to scroll offset instead of smoothstepping the value and then smoothstepping it again inside position helpers.
- Root cause: Double easing produced a dead zone where `Talk with AI` appeared fixed for the first part of the drag.
- Prevention rule: Use direct clamped scroll progress for positional continuity; reserve easing for opacity/scale details only.
- Verification rule: In a shallow handoff screenshot, verify the CTA has already moved from its home resting position.

## 2026-05-07 - Story Snap Threshold Must Be Flick-Friendly

- Correction: Lower the page-snap threshold from midpoint rounding to an early threshold so a shorter upward flick advances the story.
- Root cause: Half-page rounding made the user drag too far before a release would settle on the next page.
- Prevention rule: For TikTok-style story flows, bias the scroll target toward the next page once the proposed offset crosses roughly the first quarter of the page.
- Verification rule: Real-device testing should confirm a short upward flick advances one page without needing to drag near the top edge.

## 2026-05-07 - Remove Collapsed Labels From Layout

- Correction: Do not keep invisible zero-height bottom-nav labels in the compact layout.
- Root cause: Invisible labels can still affect stack measurement and make compact icons look subtly off-center.
- Prevention rule: Conditionally remove labels from the view tree when collapse progress hides them.

## 2026-05-07 - Route Destinations Must Preserve Existing Initializers

- Correction: Do not add a `NavigationStack` destination for an existing screen without passing its required initializer dependencies.
- Root cause: The AI Chat routing pass called `DesignAuditPlaceholderView()` even though that screen requires `AppEnvironment`.
- Prevention rule: When adding app-level routes, inspect every destination initializer and pass existing environment/dependency values through the route switch.
- Verification rule: Re-run `xcodebuild` after route additions and confirm all destination cases compile.

## 2026-05-07 - Prove Native Keyboard Visibility In QA

- Correction: Do not accept a focused text cursor as proof that the native keyboard state is visually verified.
- Root cause: The Simulator initially used the hardware-keyboard path, so focused chat screenshots showed the composer cursor but no software keyboard.
- Prevention rule: For keyboard-state PixelQA, explicitly force or toggle the Simulator software keyboard path before capturing screenshots.
- Verification rule: Open the keyboard screenshot and confirm the native keyboard is visibly present below the composer.
- Verification rule: Capture compact nav crop and measure that the dark capsule and icon group are centered.

## 2026-05-07 - Preserve Pro Margins In Figma Baseline Screens

- Correction: Do not clamp AI chat content to the `342pt` Figma column on iPhone Pro when the product margin rule is `24pt` per side.
- Root cause: A centered fixed-width column made the AI chat controls drift inward on the actual Pro device even though the baseline Figma frame used `390 - 48 = 342`.
- Prevention rule: For BON iPhone Pro screens, derive the primary column from the live device width minus the approved margins, then cap only where a wider device would make the content too broad.
- Verification rule: Capture the target simulator and confirm top controls, chat copy, chips, and composer align to the same `24pt` side margin rule before diffing against resized Figma references.

## 2026-05-07 - Gate PixelQA Launch State From User Navigation

- Correction: Do not let AI Chat PixelQA launch arguments affect normal in-app navigation from `Talk with AI` or `AI mode`.
- Root cause: `AIChatView` read process launch arguments unconditionally, so stale simulator flags like `-BONAIChatState thinking` could make a user tap open the thinking screen instead of the static Figma chat state.
- Prevention rule: Keep launch-argument-driven UI states behind an explicit router or QA flag; normal route actions should pass deterministic product defaults.
- Verification rule: Launch home with a stale state argument, tap the product entry control, and capture the destination before calling route behavior fixed.

## 2026-05-07 - Keep Glass Foreground Outside Parent Glass Containers

- Correction: Do not wrap custom glass controls in a parent `GlassEffectContainer` until foreground text and icons are proven visible in simulator.
- Root cause: The AI Chat top bar used a parent glass container around views that also applied `glassEffect`, and the simulator composition swallowed the expert-pill text and side icons.
- Prevention rule: Apply native `glassEffect` to the actual control surface, then overlay semantic foreground content outside that surface. Add a parent `GlassEffectContainer` only when morph grouping is required and visually verified.
- Verification rule: Capture the top bar after every glass refactor and confirm foreground labels/icons are readable before measuring material or shadow parity.

## 2026-05-07 - Do Not Paraphrase Pixel-QA Chat Copy

- Correction: Replace paraphrased AI chat prompts and responses with the exact Figma strings where metadata exists.
- Root cause: The deterministic scenario fixtures were written for readability first, which changed line breaks, card heights, and perceived design fidelity.
- Prevention rule: For pixel-QA chat scenarios, fixture copy must be copied from Figma metadata or explicitly marked as product-copy revision before implementation.
- Verification rule: Grep the Swift fixtures against the Figma metadata strings for every routed prompt and primary response before capturing screenshots.

## 2026-05-07 - Split Suggestion And Sent Bubble Styles

- Correction: Do not reuse the pale sent-message bubble style for initial suggestion chips.
- Root cause: Suggestion and sent chips shared one SwiftUI style even though Figma uses bright lime suggestions and pale sent-state bubbles.
- Prevention rule: Chat chip components need visual variants for suggestion, sent, and category states, not just content-driven sizing.
- Verification rule: Capture initial and thinking states together; initial suggestions should be neon lime and the sent prompt should remain pale lime.

## 2026-05-07 - Map Supplied Icons Semantically

- Correction: Do not keep SF Symbols or old exported assets when the user provides the actual BON SVG icons for implemented surfaces.
- Root cause: Several implemented controls still used platform symbols or older Figma exports, so silhouettes diverged from the app design even when layout and glass were close.
- Prevention rule: Inventory supplied icon files, assign semantic asset names, install them into `Assets.xcassets`, and render them through template image paths rather than referencing raw `Frame` filenames in SwiftUI.
- Verification rule: Build after asset replacement and capture every implemented state that uses the assets, including expanded nav, compact nav, top action buttons, and chat composer.

## 2026-05-07 - Remove Obsolete Asset Children

- Correction: Do not leave old PNG children inside an asset set after switching that asset to an SVG source.
- Root cause: Xcode compiled the asset catalog but warned that old `topProfile` and `topBell` PNGs were unassigned children, leaving ambiguity about the production source.
- Prevention rule: When replacing an asset set's source type, delete unreferenced siblings from that imageset so `Contents.json` is the complete truth.
- Verification rule: Re-run `xcodebuild` and confirm asset catalog compilation has no unassigned-child warnings.

## 2026-05-07 - Keep Brand Color Scale Primitive

- Correction: Do not represent BON lime as only one accent color when the design uses a full `lime/50` through `lime/900` scale.
- Root cause: A single semantic `accentLime` token forces future screens to invent ad hoc greens for charts, glows, backgrounds, selected states, and contrast states.
- Prevention rule: Add full primitive color scales to `BONColor` first, then map semantic aliases like `accentLime` and `limeGlow` to those primitives.
- Verification rule: Build after token changes and confirm both Swift tokens and `DESIGN_SYSTEM.md` list every supplied shade before using the palette in screens.

## 2026-05-07 - Preserve Source Icon Scale

- Correction: Do not enlarge supplied 16 px utility icons or nav glyphs to 20 pt just because their containers are larger.
- Root cause: The previous top/chat/nav rendering mixed 16 px source icons with 20 pt visual frames, making controls feel heavy even when the SVG silhouettes were correct.
- Prevention rule: Keep BON utility and nav glyphs at 16 pt visual size inside larger 40 pt or glass/nav hit targets unless Figma explicitly defines a larger glyph.
- Verification rule: Capture home, AI Chat, and compact-nav simulator screenshots after icon-size changes and confirm the glyphs remain centered and sharp.

## 2026-05-07 - Edge Glow Needs Gradient Restraint

- Correction: Do not render AI Chat's screen-edge glow as a wide single-color lime wash.
- Root cause: A broad blur and one-color side wash made the glow read like a thick border instead of a refined Siri-like aura.
- Prevention rule: Use a narrow layered glow with `lime50`, `lime100`, `lime200`, and `lime300` gradient stops, restrained blur, and short side washes.
- Verification rule: Capture the AI Chat entry state and inspect that the edge glow has visible tonal variation without overpowering the white canvas or top controls.

## 2026-05-07 - Do Not Fake Glass With A Stroke

- Correction: Do not give the AI Chat composer voice/action pill a visible stroke border when Figma expects Liquid Glass depth.
- Root cause: The first implementation used `strokeBorder` to create edge definition, which made the pill look like an outlined control instead of a glass insert.
- Prevention rule: For glass action pills, use native `glassEffect`, material/tint, specular gradients, and shadows for edge definition; avoid explicit strokes unless Figma has a real stroke property.
- Verification rule: Capture the composer in simulator and confirm the action pill reads as a dark glass surface with no attention-seeking outline.

## 2026-05-07 - Dark Inputs Need Visible Caret Tint

- Correction: Do not rely on the platform default TextField insertion cursor inside a dark custom glass composer.
- Root cause: The default caret could render black/dark, disappearing against the black composer shell when the input is focused.
- Prevention rule: Apply a light `.tint(...)` to dark-surface text fields so caret and selection affordances remain visible.
- Verification rule: Launch the focused composer state and confirm the insertion bar is visibly light against the dark input shell.

## 2026-05-07 - Tune Glass Controls As One Surface

- Correction: Do not tune the AI Chat voice/action pill separately from the composer shell when the Figma reference shows them as one coupled glass control.
- Root cause: The previous pass removed the explicit action-pill stroke but left the shell and insert material balance mismatched, so the result still looked far from Figma.
- Prevention rule: For nested glass controls, compose the native glass layer underneath the brand graphite stain, then tune shell stain, insert stain, specular highlights, and shadows together against a crop.
- Verification rule: Capture a simulator composer crop and compare it side by side with the Figma composer crop before calling the glass pass done.

## 2026-05-07 - Animate Chat State Thresholds

- Correction: Do not let AI Chat typing state changes remove suggestions or replace composer icons as raw conditional view swaps.
- Root cause: The draft-to-typing threshold changed `phase` without explicit transition ownership, so suggestions disappeared instantly and the voice icon snapped into the send arrow.
- Prevention rule: For chat threshold states, wrap phase changes in a component-scoped animation and keep icon slots stable with opacity/scale transitions rather than replacing whole branches.
- Verification rule: Capture initial and typed states, and review the code path for Reduce Motion so motion falls back to opacity-only transitions.

## 2026-05-07 - Persistent Containers Beat Removal Transitions

- Correction: Do not rely on removal transitions when the desired interaction is a morph-like collapse.
- Root cause: The suggestion stack was still conditionally removed at the typing threshold, so the animation felt like disappearance choreography instead of the suggestions shrinking away.
- Prevention rule: For morph exits, keep the source view in a stable container and animate visible properties such as scale, opacity, offset, hit testing, and reserved height.
- Verification rule: Verify both start and end states, and inspect that the view is not removed until its animated container has collapsed.

## 2026-05-07 - Prompt Chips Need Message Geometry

- Correction: Sent prompts and fallback suggestions must not use full-width capsules or arbitrary fixed widths.
- Root cause: The fallback suggestions reused fixed chip widths, including a `342pt` long chip, and the shared chip shape was still a capsule instead of the Figma message bubble.
- Prevention rule: Prompt-like chat chips should be trailing-aligned, capped at `65%` of device width, padded `16pt` horizontally and `12pt` vertically, and shaped with a sharp bottom-right corner.
- Verification rule: Capture the fallback response state after chip edits and confirm the third suggestion wraps inside the cap while sent and suggestion bubbles share the message-tail geometry.

## 2026-05-07 - Dense Chat Graphics Need Purpose-Built Modules

- Correction: Replace generic account-row cards in the `1:5165` credit-drop response with the exact Payment History bar timelines and Hard Inquiries row system.
- Root cause: The first deterministic credit-drop fixture used conceptual account rows before the exact Figma graphic anatomy was audited.
- Prevention rule: For each detailed AI Chat graphic, inventory every visible data mark, repeated row, overlay control, card height, and shadow before reusing a generic row component.
- Verification rule: Capture the target frame state and confirm the data marks themselves match Figma, not just the surrounding card shell.

## 2026-05-07 - Do Not Repeat Fixed Frame Overload Mistakes

- Correction: Chain SwiftUI fixed-height and flexible-width frames after the payment-history row initially used a nonexistent `.frame(maxWidth:height:alignment:)` overload.
- Root cause: A known SwiftUI overload issue reappeared while adding a new fixed-format row component.
- Prevention rule: When a new view needs fixed height plus flexible width, always write `.frame(height:alignment:)` followed by `.frame(maxWidth:alignment:)`.
- Verification rule: Run `xcodebuild` immediately after new fixed-frame components are introduced.

## 2026-05-07 - Scrolled Chat States Need A Top Scrim

- Correction: Add a shared top gradient/blur scrim so previous chat content does not leak under fixed chat top controls during scrolled response QA.
- Root cause: Earlier AI Chat states started below the top bar, so the missing Figma top overlay only became visible once a long response was scrolled.
- Prevention rule: Any chat state with scrollable history under fixed top controls must include the Figma top scrim/fade layer.
- Verification rule: Capture a scrolled chat response and inspect the status bar/top controls area for readable old content behind the chrome.

## 2026-05-07 - Route Exact Scenario Phrases Before Broad Words

- Correction: The monthly-spending prompt must route to the `budgetSpending` scenario, not the budget timeline scenario.
- Root cause: Broad substring checks such as `month` can accidentally match exact prompt phrases like `monthly spending` before the intended scenario branch runs.
- Prevention rule: In AI Chat scenario routing, check exact designed prompt phrases and high-signal nouns before broad time or category words.
- Verification rule: After router edits, launch every designed default prompt through the simulator or a focused route check and confirm it reaches the expected response fixture.

## 2026-05-07 - Chart Axis Labels Need Coordinate Proof

- Correction: The `$10k` heatmap label belongs at the chart top, not on the mid-guide line.
- Root cause: The chart guide line was mistaken for the axis-label anchor while translating the Figma heatmap into SwiftUI marks.
- Prevention rule: For dense data graphics, cross-check axis labels against screenshot position and sibling frame coordinates before coding the layout.
- Verification rule: Capture the target simulator state and inspect both top and baseline axis labels before marking a chart graphic complete.

## 2026-05-07 - Critical Chat Pills Need Runtime Text Verification

- Correction: Short sent prompts and compact filter pills can still wrap or truncate even when their Figma bounding boxes look sufficient.
- Root cause: SwiftUI runtime font metrics, Pro-device width caps, and Figma text bounds do not always line up exactly.
- Prevention rule: Keep critical one-line chips and filter controls at the component boundary with explicit line limits, reasonable minimum scale factors, and measured fixed text frames.
- Verification rule: Capture the final target state and confirm prompt bubbles, filter pills, and labels neither clip nor wrap unexpectedly.

## 2026-05-07 - Heatmaps Need Matrix Sampling

- Correction: Do not implement the `1:5397` budget heatmap as stacked values with broad y-threshold color bands.
- Root cause: The Figma graphic is a sampled matrix with explicit row colors and a universal empty row, so threshold-based drawing changed both color distribution and visual rhythm.
- Prevention rule: For dense Figma data graphics, sample mark centers, row positions, repeated colors, and empty rows before deciding whether the implementation is a stacked chart, heatmap matrix, or static illustration.
- Verification rule: Capture a simulator screenshot and create a side-by-side crop against the Figma reference after any dense-chart color or structure change.

## 2026-05-07 - Do Not Scale Pixel-Critical Mini Marks

- Correction: Do not scale the `1:5397` heatmap marks from `310pt` to the wider iPhone Pro card content width.
- Root cause: Scaling the chart made 8pt marks render at non-integer device-pixel sizes, changing rounded-rectangle antialiasing and perceived color even when source color constants were correct.
- Prevention rule: For tiny repeated Figma marks, preserve the baseline mark size, gap, and chart width unless the design explicitly defines responsive resizing.
- Verification rule: Sample rendered mark center pixels from the simulator screenshot and compare them to Figma center colors, not just the SwiftUI color constants.

## 2026-05-07 - Patch Only The Intended GeometryReader

- Correction: A broad patch accidentally changed unrelated `GeometryReader { proxy in ... }` closures to `_`, breaking build in the root chat view and edge glow.
- Root cause: The edit matched a generic `GeometryReader` pattern instead of anchoring to the heatmap component context.
- Prevention rule: When changing common SwiftUI closure names, patch with nearby struct/function context and inspect all remaining matches before building.
- Verification rule: Run `rg \"GeometryReader \\\\{ _ in|GeometryReader \\\\{ proxy in\"` and `xcodebuild` after common-layout mechanical edits.
