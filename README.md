# BON

Native iOS SwiftUI implementation for the BON app.

## Source Design

- Figma file: `https://www.figma.com/design/SMVZkasMIx4TzoOMBxqSs9/O2-Final?node-id=1-627&m=dev`
- File key: `SMVZkasMIx4TzoOMBxqSs9`
- Starting node: `1-627`

## Build

```sh
xcodebuild -project BON.xcodeproj -scheme BON -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

## Workflow

See `DESIGN_IMPLEMENTATION_WORKFLOW.md` for the Figma-to-SwiftUI process, QA gates, asset pipeline, and screen tracker.
