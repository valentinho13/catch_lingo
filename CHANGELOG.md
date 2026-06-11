# Changelog

All notable changes to CatchLingo.

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

### Review (new)

- Lightweight flashcard review over caught words: tap to reveal, "Knew it" / "Again later" self-assessment, "Again later" requeues the word once.
- Entry point from the Dictionary; intentionally no spaced repetition yet.

### Home

- Collection status card shows the real persisted count.
- Count refreshes when returning from Explore or Dictionary.

### Tests

- Updated widget tests for the new copy and flow.
- New unit tests for `CollectionStore` (new catch, repeat spots, lastSeenAt, corrupt data).
- New widget tests for the Review screen.

## Earlier

- Real-world discovery prototype: Home, Explore with mock scene, Dictionary preview, catch chips, design docs (see git history).
- Legacy manual vocabulary prototype kept under `lib/legacy/` for reference.
