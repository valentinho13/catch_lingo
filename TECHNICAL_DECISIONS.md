# Technical Decisions

## Current MVP Direction

The goal is to validate the CatchLingo concept as quickly as possible.

The MVP should prove that discovering and catching words from the real world can feel useful, pleasant, and motivating.

The MVP does not need real object detection immediately.

It needs to make the discovery loop feel good first.

## Platform Strategy

Phase 1:

- Android-first
- Flutter
- Material 3
- local state / simple local storage later

Other platforms can be considered later.

Flutter may generate iOS, web, desktop, and other platform folders, but the product focus is Android-first.

Do not optimize for desktop or web during the MVP.

## Development Philosophy

Prefer:

- simple code
- readable code
- maintainable widgets
- small milestones
- visible UX progress
- no unnecessary dependencies

Avoid:

- premature abstraction
- complex architecture
- unnecessary packages
- large state-management frameworks
- future features before the core loop feels good

## MVP Feature Order

### Stage 1 — Foundation

- Home Screen
- Explore Screen
- Dictionary Screen
- Navigation
- Design-system foundation
- Basic tests

### Stage 2 — Mock Discovery Loop

- Mock detected words
- Tap-to-catch
- Translation reveal
- Session counter
- Catch feedback
- Duplicate prevention
- Discovery animations

### Stage 3 — Session Feeling

- Finish session button
- Session summary
- Save caught words to simple local storage
- Dictionary reflects caught words

### Stage 4 — Camera Preview

- Camera permission
- Camera preview
- No full object detection yet
- UI remains responsive

### Stage 5 — Object Detection

- ML Kit or alternative on-device detection
- Throttled frame analysis
- stable label handling
- object-to-word mapping

### Stage 6 — Review

- simple review flow
- lightweight flashcards
- known / learning states

## Object Detection

The product vision is independent from the exact detection technology.

Current likely direction:

- Flutter camera
- Google ML Kit
- on-device processing

This can change.

Do not overbuild the detection layer before the mock discovery loop feels good.

## Storage

Phase 1:

- in-memory state is acceptable

Next:

- simple local persistence

Possible future options:

- SQLite
- Hive
- Isar

Cloud storage is not required for MVP validation.

## Performance Goals

The application should feel instant.

Priorities:

1. smooth Explore Mode
2. smooth catch animations
3. responsive UI
4. no lag during discovery
5. no heavy processing on every frame later

Users should never feel lag during discovery.

## Camera Performance Rules Later

When camera is implemented:

- do not analyze every frame
- throttle detection
- ignore frames while detection is already running
- cache recent results
- avoid repeated duplicate processing
- keep animations lightweight
- keep device temperature reasonable

Suggested first detection rate:

- around 1 frame per second

## Architecture Rule

Build the smallest working version first.

Only add complexity when the product proves it is necessary.

The goal is not to build the most advanced language-learning app.

The goal is to build the most enjoyable real-world word discovery experience.

## Testing Rule

After meaningful changes:

- run `flutter analyze`
- run `flutter test`

Tests should protect the core MVP behavior:

- app starts
- Home screen shows core actions
- Explore Mode catches a word
- duplicate catch does not increase count
- Dictionary screen opens

## Do Not Build Too Early

Avoid implementing too early:

- accounts
- cloud sync
- payment
- advanced AI explanations
- multi-language marketplace
- complex spaced repetition
- real AR anchoring
- video recording
- social/community features
- full travel journal

Build the loop first.
