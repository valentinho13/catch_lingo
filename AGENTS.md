# AGENTS.md

## Project Identity

CatchLingo is not a normal vocabulary app.

CatchLingo is not primarily a dictionary.

CatchLingo is not primarily a translator.

CatchLingo is not primarily a flashcard app.

CatchLingo is a real-world word discovery experience.

The long-term idea:

> Point the camera at the world. Discover the words around you. Catch them. Remember them later.

## Product North Star

The app should make the user feel:

> “I discovered this word in the real world.”

Not:

> “I studied this word.”

Not:

> “I added an entry to a vocabulary database.”

## Required Reading Order

Before major changes, read:

1. `DESIGN_VISION.md` — **canonical** look, feel, and atmosphere. Overrides any
   conflicting visual guidance elsewhere.
2. `VISION.md`
3. `DESIGN_SYSTEM.md`
4. `UI_SPEC.md`
5. `TECHNICAL_DECISIONS.md`
6. `README.md`
7. `ROADMAP.md`

## Visual Direction (binding)

CatchLingo is **warm, sunlit, and lived-in**: a green-of-discovery and amber-of-reward
identity on a cream canvas, with real-world warmth and soft natural light. Each caught
word is a treasured find — a clean specimen card lifted over a warm photograph of the
world.

The earlier cool indigo/mint palette and dark, technical camera surface are **retired**.
Do not reintroduce cool/corporate blues, dark sci-fi camera HUDs, confidence readouts,
debug overlays, flashcard/school energy, or loud gamification. When any visual decision
is unclear, defer to `DESIGN_VISION.md`.

## Development Rules

Prefer:

- simple Flutter code
- readable widgets
- small files
- clear naming
- Material 3
- Android-first MVP
- small milestones
- no unnecessary packages

Avoid:

- premature architecture
- complex state management
- unnecessary dependencies
- future features before the core loop works
- generic vocabulary-app patterns
- school-app UX
- technical ML-demo language

## Current Product Focus

The current focus is:

- Home screen
- Explore Mode
- Dictionary
- mock word detection
- tap-to-catch
- translation reveal
- session counter
- catch feedback
- dictionary preview

The current focus is not:

- camera
- ML Kit
- cloud sync
- accounts
- AI explanations
- advanced review
- full spaced repetition
- social features

## UI Direction

The app should feel:

- modern
- calm
- playful
- lightweight
- visual
- discovery-oriented

The app should not feel:

- childish
- academic
- cluttered
- enterprise-like
- like a default Flutter demo
- like a word-table manager

## Core Loop

Every feature should support:

> Discover → Catch → Remember

or the expanded loop:

> Explore → Detect → Catch → Save → Review → Explore again

If a feature does not strengthen this loop, do not build it unless explicitly requested.

## Camera Principle

The camera is important, but the camera is not the product.

The product is the real-world word discovery experience.

Do not build camera functionality until requested.

Mock Explore Mode should still feel like a preview of future camera-based discovery.

## Catch Moment Principle

The catch moment is the heart of the MVP.

When a word is caught:

- feedback must be immediate
- the word state must change clearly
- the translation should be revealed
- the counter should update
- duplicate catching must be prevented

The user should never wonder whether a word was caught.

## Copywriting Rules

Prefer words like:

- discover
- catch
- caught
- explore
- real-world words
- remember
- session

Avoid words like:

- homework
- lesson
- database
- entry
- object detection demo
- vocabulary management

## Testing

After meaningful code changes:

- run `flutter analyze`
- run `flutter test`

If tests are updated, explain why.

## Do Not

Do not add new packages unless necessary.

Do not implement camera, ML Kit, cloud, accounts, or advanced review unless specifically requested.

Do not turn CatchLingo into a generic vocabulary manager.

Do not ignore `DESIGN_SYSTEM.md`.

## Final Rule

When in doubt:

Choose real-world discovery over vocabulary management.

Choose catching over manual adding.

Choose delight over complexity.

Choose the smallest useful step.
