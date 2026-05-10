# BON Implementation Standard

This project should be treated as a high-fidelity native iOS product build, not a Figma-to-code dump.

## Non-Negotiables

- Build native SwiftUI with Apple-platform behavior.
- Keep Figma as the visual source of truth.
- Keep Apple Human Interface Guidelines and SwiftUI native behavior as the interaction source of truth.
- Do not scale implementation to many screens until the golden screen passes visual review.
- Do not use generated React/Tailwind code directly.
- Do not use placeholder assets in completed screens.
- Record every intentional deviation from Figma.

## Operating Sequence

1. Run preflight.
2. Audit the Figma frame and sublayers.
3. Extract tokens and assets.
4. Implement the smallest useful SwiftUI unit.
5. Build on simulator.
6. Capture simulator screenshot.
7. Compare against Figma reference.
8. Tune.
9. Record outcome.

## Motion Standard

- Motion must explain continuity, state, or hierarchy.
- Prefer native `NavigationStack`, sheets, buttons, scroll views, and system materials.
- Use `matchedGeometryEffect`, zoom navigation transitions, scroll transitions, and Liquid Glass/material effects only where they make the product clearer.
- Keep gestures interruptible and physically plausible.
- Use haptics sparingly and semantically.
- Respect Reduce Motion.

## Pixel QA Standard

- Reference screenshot and simulator screenshot must use the same logical size and app state.
- Repeated layout drift greater than 1 pt requires investigation.
- Text line breaks and baselines must match unless an accessibility/native deviation is recorded.
- Flat colors should come from tokens.
- Shadows, blur, gradients, glass, and antialiasing require human review even when numeric diff is acceptable.
- Safe-area overlap is a blocker.

## Created Codex Skills

- `bon-ios-preflight`
- `bon-figma-audit`
- `bon-design-token-extraction`
- `bon-swiftui-screen-implementation`
- `bon-asset-pipeline`
- `bon-motion-polish`
- `bon-pixel-qa`

These live under `/Users/abhinavjain/.codex/skills` and were validated with the skill validator.
