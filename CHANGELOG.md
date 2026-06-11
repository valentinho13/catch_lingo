# Changelog

All notable changes to CatchLingo.

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
