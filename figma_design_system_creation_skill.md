---
name: bon-figma-design-system-creation
description: Use when creating or updating BON's design-system page or library inside Figma from approved BON app screens. Covers Figma discovery, variables, styles, page structure, components, documentation, validation, and resumable MCP workflow.
---

# BON Figma Design System Creation Skill

## Purpose

Use this skill to create a polished BON design-system page or library in Figma from the approved product designs. It turns real BON screens into reusable Figma variables, styles, components, documentation pages, and QA artifacts.

This skill is for Figma canvas work and design-system structure. It does not replace `design_system_creation_skill.md`; use that file for the system thinking, token taxonomy, component contracts, and native iOS mapping.

## Required Inputs

- Figma file: `O2 Final`.
- Current approved source node: `61:1093`, unless the user provides a newer node.
- Target output: a new Figma page for BON design system, unless the user explicitly asks for a separate publishable Figma library file.
- Repo source of truth:
  - `design_system_creation_skill.md`
  - `DESIGN_SYSTEM.md`
  - `FIGMA_AUDIT.md`
  - `DESIGN_IMPLEMENTATION_WORKFLOW.md`
  - `BON/DesignSystem/*`
  - `tasks/lessons.md`
  - `tasks/todo.md`

## Mandatory Skill Stack

Before any Figma write:

1. Load the project-level BON design-system creation skill.
2. Load `figma-generate-library` for design-system build order.
3. Load `figma-use` before every `use_figma` call.
4. For read-only Figma MCP context, use the standard Figma skill flow: metadata, design context, variables, and screenshots.

Never call `use_figma` directly without `figma-use`.

## Non-Negotiable Start

1. Read `tasks/lessons.md`.
2. Update `tasks/todo.md`.
3. Confirm exact Figma source and target:
   - source screen/page/node IDs,
   - target page name,
   - whether this is documentation-only or a publishable library,
   - whether dark mode is token-reserved or built now.
4. Run discovery with no writes.
5. Present scope and wait for explicit approval before creating variables or pages.

## Phase 0: Discovery Only

Do not create anything in this phase.

Inspect:

- Existing Figma pages.
- Existing variables, collections, modes, styles, components, and naming.
- The approved design source node and surrounding frames.
- Repeated colors, typography, radius, shadows, glass, blur, gradients, spacing, icon sizes, and component anatomy.
- Existing docs in the repo and Swift token names.
- Conflicts between Figma and code.

Discovery output:

- Proposed page structure.
- Proposed token collections and modes.
- Proposed text styles and effect styles.
- Proposed component list in dependency order.
- Asset classification list.
- Open questions and risks.

Checkpoint question:

> "Here is the BON Figma design-system creation plan. Approve Phase 1 foundations before I create anything?"

## Phase 1: Foundations

Create foundations before components.

### Variable Collections

Recommended BON v1 collections:

- `BON Primitive`
  - raw colors, number values, radii, spacing, opacity, blur, shadow numbers.
  - one mode: `Value`.
- `BON Semantic`
  - aliases for app meaning: background, surface, text, border, accent, status, glass, chart.
  - modes: `Light`, `Dark Reserved` unless dark mode is approved now.
- `BON Component`
  - component anatomy values: nav, composer, hero, CTA, chat chip, cards, score modules.
  - modes: `Default`; add device modes only if the user approves responsive documentation.

Rules:

- Create primitives first.
- Semantic variables must alias primitives; do not duplicate raw values.
- Component variables may alias semantic values or hold documented anatomy-specific constants.
- Set scopes on every variable.
- Set iOS code syntax on every variable when possible, using Swift references such as `BONColor.accentLime`, `BONSpacing.xl`, or `BONRadius.hero`.
- Keep primitives hidden from day-to-day component users where Figma supports scoped discoverability.

### Styles

Create styles where Figma uses composite values:

- Text styles for typography roles:
  - screen title,
  - section title,
  - body,
  - caption,
  - nav label,
  - chip,
  - CTA,
  - numeric display.
- Effect styles for reusable shadows/glows:
  - card shadow,
  - nav shadow,
  - CTA shadow,
  - lime glow,
  - soft inset highlight where Figma supports effect representation.

Rules:

- Typography must use the approved BON font families:
  - `Zalando Sans`,
  - `Geist Pixel`,
  - `Instrument Serif` only if still used in approved screens.
- Load fonts before writing text via plugin API.
- Preserve measured line height and letter spacing.
- Do not create text as vector outlines.

Exit criteria:

- Variables exist with correct names, modes, scopes, aliases, and code syntax.
- Text and effect styles exist for reusable composite values.
- `get_metadata` verifies structure.

Checkpoint:

> "Foundations are created. Review variables/styles before I create design-system pages?"

## Phase 2: Page Structure And Documentation

Create a new page named:

```text
BON Design System
```

If the name exists, use:

```text
BON Design System v2
```

Recommended page sections:

1. `00 Cover`
2. `01 Foundations`
3. `02 Color`
4. `03 Typography`
5. `04 Spacing Radius Effects`
6. `05 Motion Accessibility`
7. `06 Assets Icons`
8. `--- Components ---`
9. `10 App Chrome`
10. `11 Controls`
11. `12 Chat`
12. `13 Finance Modules`
13. `14 Cards Graphics`
14. `90 QA Handoff`
15. `99 Changelog`

Documentation rules:

- Use real component instances and variable-bound swatches, not detached decorative copies.
- Put usage notes next to the source component, not in a disconnected docs-only file.
- Keep docs short: purpose, anatomy, states, do/don't, implementation mapping, QA.
- Add node labels with Figma node IDs for source evidence where useful.
- Keep source screenshots/references clearly marked as references, not reusable components.

Exit criteria:

- Page structure exists.
- Foundation docs render correctly.
- Screenshot verifies no overlaps, missing fonts, or clipped labels.

Checkpoint:

> "The design-system page shell is ready. Review before I build components?"

## Phase 3: Components

Build components one family at a time. Do not batch all components in one call.

Recommended order:

1. Icons and icon slots.
2. Icon button.
3. CTA pill.
4. Mode pill.
5. Chat chip/message bubble.
6. Chat composer.
7. Top action bar.
8. Bottom nav expanded and compact.
9. Hero panel.
10. Feature card.
11. Response/card shell.
12. Finance rows.
13. Score/ring module.
14. Heatmap/chart modules.

For each component:

- Create a dedicated section or page area.
- Build the base component with auto layout.
- Bind fill, stroke, gap, padding, radius, and effect values to variables/styles wherever possible.
- Use component properties:
  - text property for labels,
  - boolean property for optional layers,
  - instance swap for icons,
  - variant property for state/size/style.
- Keep variant matrices small; split component families when combinations exceed roughly 30 variants.
- Document anatomy and states next to the component.
- Return all created/mutated node IDs from each `use_figma` call.
- Validate with metadata and screenshot before moving to the next component.

Required component states:

- default,
- pressed,
- disabled,
- selected/active where relevant,
- loading/thinking where relevant,
- error/warning/success where relevant,
- keyboard/focused where relevant,
- Reduce Motion or Reduce Transparency note where relevant.

Checkpoint per component:

> "Here is the [component name] component and variants. Approve before I move to the next component?"

## Phase 4: Assets And Icons

Classify every asset:

| Classification | Use When | Figma Handling | iOS Handling |
| --- | --- | --- | --- |
| SF Symbol | standard platform icon exists | instance or documented mapping | SF Symbol |
| Custom vector | small custom interface icon | vector component, 16pt source where applicable | PDF/SVG asset or SwiftUI shape |
| Raster artwork | complex static illustration | image component with source node | `Assets.xcassets` 1x/2x/3x |
| SwiftUI-drawn | live data or animated chart | documented spec and reference component | SwiftUI view |

Rules:

- Do not use contaminated visible-state crops as production assets.
- Do not use localhost Figma asset URLs as a production dependency.
- Do not rasterize small interface icons unless vector rendering is visually proven impossible.
- For BON nav and chat icons, preserve the intended 16pt visual size and stroke weight.
- Add asset names that match `Assets.xcassets`.

## Phase 5: QA And Handoff

Run a design-system QA pass:

- No raw unbound colors on reusable components unless documented.
- No missing fonts.
- No duplicated component names.
- No unnamed production nodes.
- No huge variant matrices.
- No clipped text.
- No detached instances masquerading as source components.
- Variable modes switch cleanly.
- Component states are visible and documented.
- Touch target sizes are documented.
- iOS code syntax is attached where possible.
- Figma screenshot matches the approved design source for key components.

Update repo docs:

- `FIGMA_AUDIT.md`: source frames and extracted patterns.
- `DESIGN_SYSTEM.md`: final token/component decisions.
- `DESIGN_IMPLEMENTATION_WORKFLOW.md`: any workflow changes.
- `tasks/todo.md`: verification results and review notes.

Checkpoint:

> "The BON Figma design-system page is ready for review. Here are the screenshots, known deviations, and open questions."

## Figma MCP Rules

Use read-only MCP before writes:

- `get_metadata` for structure.
- `get_design_context` for exact node representation.
- `get_variable_defs` for variables.
- `get_screenshot` for visual reference.

For write actions with `use_figma`:

- Load `figma-use` first.
- Use small, sequential calls.
- Use top-level `await`.
- Return IDs; do not rely on `console.log`.
- Do not use `figma.notify()`.
- Use colors in 0-1 range.
- Clone and reassign fills/strokes.
- Load fonts before text writes.
- Use `await figma.setCurrentPageAsync(page)` for page switching.
- Validate after every create/mutate step.
- Never parallelize Figma write calls.
- Never hallucinate node IDs.

## State Ledger

Maintain a local state file for long runs:

```text
/tmp/bon-figma-ds-state-{runId}.json
```

Track:

- run ID,
- source file and node IDs,
- target page ID,
- created collections and variables,
- created styles,
- created pages/sections/components,
- pending validation,
- approved phases,
- open issues.

At the start of a resumed session:

1. Read the state file if it exists.
2. Run read-only Figma inspection.
3. Reconcile IDs.
4. Continue from the last approved phase.

## Naming

Use existing BON/Figma naming if present. If creating fresh:

Variables:

```text
primitive/lime/500
semantic/color/accent/primary
semantic/color/text/primary
component/chat/composer/height
component/bottom-nav/expanded/height
```

Text styles:

```text
BON/Screen Title
BON/Body
BON/Caption
BON/CTA
BON/Numeric Display
```

Components:

```text
BON/Icon Button
BON/CTA Pill
BON/Chat Composer
BON/Bottom Nav
BON/Hero Panel
BON/Finance Row
```

Variants:

```text
State=Default, Size=Medium, Style=Dark
Variant=Expanded, State=Selected
```

Internal helper components:

```text
_BON/Icon Slot
_BON/Nav Item
_BON/Chart Mark
```

## Anti-Patterns

- Creating everything in one Figma script.
- Starting components before variables/styles.
- Creating a variant per icon instead of using instance swap.
- Using raw colors repeatedly in components.
- Ignoring code syntax and scope on variables.
- Making documentation pages that drift from actual source components.
- Flattening text into vectors.
- Building glass effects as attention-seeking borders when the design calls for material depth.
- Publishing or marking complete without screenshots and metadata validation.

## Done Criteria

This task is done only when:

- The new Figma design-system page/library exists.
- Foundations are variable/style-backed.
- Priority components are built with variants/properties.
- Documentation is concise and colocated.
- Screenshots and metadata were captured at each milestone.
- Repo docs reflect the created system.
- `tasks/todo.md` records verification and open risks.
