# CatchLingo Roadmap

## Product North Star

CatchLingo helps users discover vocabulary from the real world.

The long-term experience:

> Point the camera at the world. Catch the words you see. Remember them later.

## Phase 1 — App Foundation

Status: done.

Goal:

Create a clean, modern MVP shell.

Includes:

- Home screen
- Explore screen
- Dictionary screen
- navigation
- Material 3
- design-system foundation
- simple tests

## Phase 2 — Mock Discovery Loop

Status: done (multiple mock scenes, catch reveal, seen-again micro-reward).

Goal:

Make catching a word feel satisfying before real camera detection exists.

Includes:

- mock detected words
- tap-to-catch
- translation reveal
- collected state
- duplicate prevention
- session counter
- catch feedback
- smooth micro animations

Success criteria:

- tapping a word feels responsive
- collected words are clearly marked
- the user understands the discovery loop
- the app feels like a preview of real camera exploration

## Phase 3 — Session Summary

Status: done (finish session → summary with new/known split; words save instantly on catch, so no separate save action).

Goal:

Make an Explore session feel complete.

Includes:

- finish session action
- session summary screen
- words caught count
- new / already known split
- save to dictionary action
- done / review action

Success criteria:

- after exploring, the user sees what they discovered
- the session feels like a small memory
- caught words feel worth keeping

## Phase 4 — Dictionary Connection

Status: done in a basic form (SharedPreferences persistence, category grouping; filters and word detail sheet still open).

Goal:

Make the Dictionary reflect caught words.

Includes:

- simple local persistence
- dictionary list from caught words
- empty state
- basic filters
- word detail bottom sheet

Success criteria:

- words caught in Explore appear in Dictionary
- Dictionary feels personal
- Dictionary does not feel like a generic word table

## Phase 5 — Camera Preview

Goal:

Replace mock discovery field with real camera preview.

Includes:

- camera permission
- permission explanation
- camera preview
- stable overlay UI
- no real object detection yet

Success criteria:

- user can open Explore Mode with camera
- UI remains smooth
- overlay feels natural

## Phase 6 — Object Detection

Goal:

Detect real-world objects and convert them into catchable words.

Includes:

- on-device detection
- throttled frame processing
- confidence threshold
- stable label handling
- object-to-word mapping
- tap-to-catch real detections

Success criteria:

- the app can detect simple objects
- detections are stable enough
- user can catch real-world words

## Phase 7 — Review

Status: basic version done (lightweight tap-to-reveal flashcards; no spaced repetition).

Goal:

Help users remember caught words.

Includes:

- simple review mode
- lightweight flashcards
- learned / review states
- basic progress feedback

Success criteria:

- user can review caught words
- review supports discovery instead of replacing it

## Future Ideas

Later, only after the core loop works:

- travel sessions
- location labels
- pronunciation
- example sentences
- AI-assisted explanations
- personalized discovery suggestions
- multi-language support
- sync
- profile
- community

## What Not To Do Now

Do not build:

- account system
- cloud sync
- complex flashcard engine
- real AR anchoring
- marketplace
- social feed
- advanced AI tutor
- heavy settings
- full travel journal

The MVP wins when the discovery loop feels good.
