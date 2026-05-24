---
name: bon-design-system-creation
description: Use when creating or rebuilding BON's design system from approved Figma product screens before native iOS implementation. Covers source audit, token taxonomy, component standards, motion, accessibility, governance, and verification gates.
---

# BON Design System Creation Skill

## Purpose

Use this skill to turn the approved BON product designs into a reusable design system before implementing or refactoring screens. The goal is a system that is visually exact, maintainable, and ready for both Figma library work and native SwiftUI implementation.

This skill is not for making one screen look close. It is for extracting the rules that make every future BON screen consistent.

## Required Inputs

- Current source Figma file: `O2 Final`.
- Current approved source node: `61:1093`, unless the user gives a newer source.
- Existing repo references:
  - `DESIGN_SYSTEM.md`
  - `FIGMA_AUDIT.md`
  - `DESIGN_IMPLEMENTATION_WORKFLOW.md`
  - `tasks/lessons.md`
  - `tasks/todo.md`
  - `BON/DesignSystem/*`
- Native target: SwiftUI iOS app, optimized for iPhone Pro while preserving Figma intent.

## Non-Negotiable Start

1. Read relevant entries in `tasks/lessons.md`.
2. Update `tasks/todo.md` with a checkable plan before changing docs, Figma, or Swift.
3. Confirm the exact Figma scope and node IDs.
4. Do not implement product screens while the design-system foundation is unresolved.
5. Ask the staff-engineer question before implementation: "Is there a simpler, more elegant system boundary?"

## Principles To Apply

### Apple-Native First

BON is a native iOS product. Use Apple platform conventions as the interaction baseline:

- Establish hierarchy with content, navigation, and controls clearly separated.
- Use Liquid Glass only for functional control/navigation layers, not as generic decoration.
- Respect safe areas, Dynamic Type, Reduce Motion, Reduce Transparency, Increase Contrast, and VoiceOver.
- Prefer native behaviors for navigation, sheets, keyboard, focus, haptics, and scrolling unless Figma intentionally defines a custom interaction.

### Token Layers

Use three token layers:

| Layer | Purpose | BON Example |
| --- | --- | --- |
| Primitive | Raw audited values | `lime/500 = #A1FF00`, `radius/56`, `shadow/nav = 0 12 12 rgba(...)` |
| Semantic | Product meaning | `color/accent/primary`, `surface/glass/dark`, `text/primary`, `border/subtle` |
| Component | Anatomy-specific decisions | `bottomNav/height/expanded`, `chatComposer/trailingButtonSize`, `hero/radius` |

Rules:

- Screen code must not consume raw hex values or unexplained point values.
- Repeated values must become named tokens or component properties.
- Component tokens can point to semantic tokens or intentionally preserve one-off Figma anatomy.
- If a value is visually critical but not reusable, document why it remains component-scoped.

### Component-Centric System

Model components by anatomy and behavior, not by visual atoms alone. A BON component spec must define:

- Purpose and usage.
- Anatomy.
- Variants.
- States.
- Responsive rules.
- Accessibility labels, traits, hit targets, and Dynamic Type behavior.
- Motion and haptics.
- Asset dependencies.
- SwiftUI API shape.
- Figma component/variant/property mapping.
- Pixel QA criteria.

### Minimal But Complete Documentation

Keep documentation close to implementation decisions. Avoid decorative design-system pages that are beautiful but unusable.

Every token/component entry should answer:

- What is it?
- When should it be used?
- What values does it map to?
- What states must exist?
- What must never be done?
- How do we verify it?

## Research-Derived Standards

Use these standards when making BON decisions:

- Apple HIG: hierarchy, harmony, consistency, platform convention, accessibility, materials, and restrained motion are the baseline for iOS quality.
- Apple Liquid Glass: use it as a functional layer for controls/navigation and preserve legibility; do not turn every card into glass.
- Figma Variables: use collections, groups, aliases, and modes for reusable values; use styles when a composite text/effect value is the real source of truth.
- Figma Components: use variants for predictable alternatives, component properties for customizable content/visibility, slots for flexible content areas, and auto layout for responsive behavior.
- Material: use reference, system, and component token layers as the mental model; do not copy Material visuals into BON.
- Airbnb DLS: define components as living product primitives with function, personality, required/optional elements, and cross-platform reuse.
- Uber Base: keep design and engineering artifacts connected; a design system should have clear code ownership and reusable implementation assets.
- Shopify Polaris: prefer semantic tokens and documented usage rules over raw values; spacing, color, and component decisions should be predictable at scale.

## Workflow

### 1. Source Audit

Audit the approved Figma area before creating tokens.

Capture:

- Page/section names and node IDs.
- Baseline frame sizes.
- Product states and scenarios.
- Repeated colors, typography, radius, shadows, effects, and spacing.
- Component candidates.
- Icon, illustration, raster, and vector assets.
- Motion/prototype expectations.
- Accessibility risks.
- Unknowns and questions for the user.

Evidence requirements:

- Save or reference screenshots for audited frames.
- Extract design context/metadata where available.
- Record risky values and one-off exceptions in `FIGMA_AUDIT.md`.

### 2. Foundation Extraction

Create or update foundations in this order:

1. Color primitives and semantic roles.
2. Typography families, sizes, line heights, weights, letter spacing, and Dynamic Type policy.
3. Spacing and layout rules.
4. Radius and shape rules.
5. Effects: shadow, blur, glass, inset highlight, glow, gradients.
6. Iconography and asset rules.
7. Motion and haptics.
8. Accessibility requirements.

Do not create a token because it looks neat. Create it because it reduces duplication, encodes meaning, or protects pixel accuracy.

### 3. Component Taxonomy

Group BON components into these families:

- App chrome: top bars, bottom nav, floating nav, page shells.
- Controls: icon buttons, pills, CTAs, toggles, chips, segmented controls.
- Chat: top bar, composer, prompt bubbles, suggestions, response cards, thinking states.
- Finance modules: score/rings, payment rows, transaction rows, budgeting heatmaps, cash/balance cards.
- Cards: hero panels, feature cards, task/progress cards, insight cards, promo/security cards.
- Graphics: reusable chart primitives, exported illustrations, logo/badge treatments.

For each component, decide whether it should be:

- A Figma main component.
- A SwiftUI reusable view.
- A tokenized style only.
- An exported asset.
- A one-off screen composition.

### 4. Figma-To-Code Mapping

For every approved component, maintain this mapping:

| Figma | SwiftUI |
| --- | --- |
| Variable collection/group | `BONColor`, `BONSpacing`, `BONRadius`, etc. |
| Text style | `BONTypography` role |
| Effect style | `BONShadow` or `BONEffects` |
| Main component | `BON...` SwiftUI component |
| Variant/property | Swift enum or view parameter |
| Asset | `Assets.xcassets` image/vector set |

Mapping rules:

- Do not depend on Figma localhost URLs at runtime.
- Do not screenshot text or simple controls.
- Export complex decorative graphics only when rebuilding them would be fragile or non-semantic.
- Keep tiny interface icons vector-backed where possible.
- Rebuild data-like graphics in SwiftUI when they represent live or animated data.

### 5. Verification Gates

Before marking design-system work complete:

- `tasks/todo.md` has current plan, progress, verification, and review notes.
- `DESIGN_SYSTEM.md` reflects the current approved Figma source.
- `FIGMA_AUDIT.md` records source frames, node IDs, and unresolved risks.
- Swift token files build if changed.
- Figma page/library work has visual screenshots or manual QA notes if changed.
- Every component has states, accessibility, asset strategy, and QA criteria.

If Swift files changed, run:

```bash
xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

If only Markdown/workflow files changed, run:

```bash
git diff --check
```

## Questions To Ask When Ambiguous

Ask the user only when the answer materially changes the system:

- Is this Figma area the new source of truth for all screens, or only a subset?
- Should dark mode be implemented now or only token-reserved?
- Which typography treatment is final if Figma has inconsistent text styles?
- Should a complex graphic be live-data SwiftUI or exported artwork?
- Is a component meant to be reusable or a single campaign/state?
- Should the new Figma page be a publishable library or an internal documentation page first?

## Anti-Patterns

- Hardcoding raw Figma values directly in screens.
- Creating a design-system token for every observed value without semantic meaning.
- Making static screenshots of interactive controls.
- Building a Figma library with detached instances and no component properties.
- Applying Liquid Glass as decorative card styling instead of functional UI hierarchy.
- Treating iPhone `390 x 845` Figma frames as fixed production canvases on wider Pro devices.
- Marking a component done without states, accessibility, asset strategy, and QA evidence.

## Deliverables

A complete BON design-system pass produces:

- Updated `DESIGN_SYSTEM.md`.
- Updated `FIGMA_AUDIT.md`.
- Updated `DESIGN_IMPLEMENTATION_WORKFLOW.md` when workflow or gates change.
- Updated Swift design-system token files when implementation is in scope.
- Figma design-system page/library when canvas work is in scope.
- A review section in `tasks/todo.md` with evidence, decisions, and open questions.
