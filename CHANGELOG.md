# Changelog

All notable changes to CatchLingo.

## Unreleased - 2026-06-12 (design-direction update: automatic collection)

### Explore

- Words are now collected automatically: a noticed word floats up in the scene and gets gently pulled into a central session counter (vacuum feel) — no tap needed. Tap-to-catch is no longer the interaction model.
- New central circular session counter over the camera with a soft progress ring toward the session goal; it pulses when a word arrives.
- The full-screen catch celebration was replaced by a calmer specimen reveal card under the counter (translation as reward, "Spotted again" for known words).
- Removed scene-anchored detection markers at fixed mock positions, so the camera view no longer pins labels onto objects that may not be there. The noticed chip floats freely and is pulled in.
- Removed the bottom detection panel with Catch / Look around buttons; a small "Looking around…" hint sits at the bottom while scanning.
- Duplicate prevention and caught-word storage are unchanged.
- A hold-to-collect control was deliberately NOT implemented (not final per design direction).

### Explore polish (after on-device feedback)

- The suction animation is much slower and more deliberate (3.2s instead of 1.5s): the word appears, bobs gently for a moment, then gets pulled in with a small anticipation pop, a slight sideways drift, and a late fade — slow enough to actually watch.
- Gentle haptics: a soft tick when the pull grips the card, a light impact when it lands in the counter (was a single medium impact).
- The grip haptic is now a clear medium impact (the selection tick was too subtle on device).
- Removed the leftover amber glow-pulse ring from the reveal: on device it read as a stray orange circle appearing before the word card. The counter pulse and the card entry carry the moment now.

### Review

- New Easy Mode / Hard Mode toggle. Easy shows the little picture hint on the card; Hard shows just the word, from memory. Friendly copy, no school energy.

### Home

- Hero copy now reflects automatic collection: "Wander around — the camera gathers the words you see."

### Tests

- Explore tests rewritten for automatic collection; new Hard Mode test; review tests run on a phone-sized test surface. 13 tests pass, `flutter analyze` clean.

## Unreleased - 2026-06-12 (evening sprint)

### Review

- "Again" now keeps the word in the current round and brings it back later, instead of behaving exactly like "Knew it" and ending the review. Remembering a word is now required to finish it.

### Dictionary

- The word-detail sheet now shows when a word was first caught ("First caught · 11 days ago"), giving each find its when-context from the design vision.

### Home

- The greeting now follows the time of day (morning / afternoon / evening) instead of always saying "Good morning".
- "Your categories" shows the three largest collections instead of the three most recently touched ones.

### Code health

- Removed the dead `_CatchRevealCard` widget and the unused `mockSceneName` constant.
- Simplified detection-marker rendering in Explore to render the single active detection directly.

### Tests

- Updated the review-flow test for the new "Again" behavior and added a test that a word marked "Again" returns later in the round.
- Current checks: `flutter analyze` clean, `flutter test` passes with 12 tests.

## Unreleased - 2026-06-12

### Recovery and safety

- Restored the real camera-based discovery app state from the recovered Git tree.
- Hardened caught-word storage so `catch_lingo_caught_words` mirrors and can recover from `caughtIDs`, `seenCount`, and `lastSeenAt`.
- Added handoff guardrails so future sessions do not replace the camera app with an older mock-only state.

### Explore

- Added a warm camera-loading state and friendlier camera fallback/retry panel.
- Added visible session progress for new catches and known words spotted again.
- Made session ending show the summary when there is session activity, including Android back and the Explore back button.
- Added new-vs-seen-again counts to the session summary.
- Replaced the louder repeating catch sparkle layer with a short, subtle glow pulse and reduced continuous motion.
- Added camera preview lifecycle handling for Android pause/resume.

### Dictionary and Review

- Added a word-detail bottom sheet with category, sighting count, last-seen info, and a direct "Review this word" action.
- Review can now start from a specific dictionary word.
- Review gently prioritizes older last-seen words and marks them as fading without adding a spaced-repetition system.
- Home now shows a small review recommendation based on last-seen data.

### Discovery data

- Added Clothing and Workspace word groups with stable new IDs and matching icons.

### Tests

- Added a widget test for Dictionary word detail into Review.
- Current checks: `flutter analyze`, `flutter test`, and debug APK build pass.
## Unreleased — 2026-06-11

### Visual direction

- Migrated the whole app to the locked warm field-journal palette: cream paper background, leaf-green primary, honey-amber accent (`lib/app/app_theme.dart` is the canonical token source).
- Removed the cool indigo/teal scanner look, including the scan-line overlay in Explore.
- Updated `DESIGN_SYSTEM.md` and `UI_SPEC.md` to document the warm palette as locked and the cool/dark directions as retired.

### Collection persistence

- New `CollectionStore` service (`lib/services/collection_store.dart`) on SharedPreferences with stable keys `caughtIDs`, `seenCount`, `lastSeenAt`. Defensive decoding: corrupt values never crash the app.
- `CatchWord` gained a stable `id` (e.g. `cafe.coffee`) used for persistence.
- Caught words now survive app restarts and appear across Home, Explore, and Dictionary.

### Explore

- Three mock scenes (Cafe table, Street market, Hotel room) with a "Next scene" switcher; each scene holds four catchable words.
- Catch reveal: the Indonesian word is shown as the reward after catching ("Caught! · kopi · coffee").
- Micro-reward for spotting an already-caught word: amber "you know this one!" card with spotted count instead of a dull duplicate message.
- Scene-complete state with a friendly nudge to the next scene.

### Dictionary

- Now built from actually caught words instead of fake preview data; removed the non-functional filter pills and "preview" labels.
- Words grouped by category with icons; each card shows the Indonesian word first, plus spotted count and last-seen day.
- Journal summary card ("X words caught · Y more waiting in the scenes").
- Honest empty state shown only when the collection is actually empty.
- Tapping a word opens a simple detail bottom sheet (word, meaning, category, spot info).

### Session summary (new)

- "Finish session" appears in Explore once the session has activity; leads to a summary screen with new vs. spotted-again split, the session's words, and Review / Done actions.
- Words still save instantly on catch — the summary is a reward moment, not a save step.

### Review (new)

- Lightweight flashcard review over caught words: tap to reveal, "Knew it" / "Again later" self-assessment, "Again later" requeues the word once.
- Entry point from the Dictionary; intentionally no spaced repetition yet.

### Home

- Collection status card shows the real persisted count.
- Count refreshes when returning from Explore or Dictionary.

### Polish

- Catch chips now pop with a subtle overshoot (easeOutBack) when caught.
- ROADMAP.md phase statuses updated (phases 1–4 done, basic review done).

### Tests

- Updated widget tests for the new copy and flow.
- New unit tests for `CollectionStore` (new catch, repeat spots, lastSeenAt, corrupt data).
- New widget tests for the Review screen and the session summary flow.

## Earlier

- Real-world discovery prototype: Home, Explore with mock scene, Dictionary preview, catch chips, design docs (see git history).
- Legacy manual vocabulary prototype kept under `lib/legacy/` for reference.
