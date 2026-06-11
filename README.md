# CatchLingo

CatchLingo is a Flutter MVP for real-world vocabulary discovery.

The core idea:

> Point your camera at the world. Catch the words you see. Remember them later.

CatchLingo helps users learn words from real places, objects, travel moments, everyday environments, and personal experiences.

It is not primarily a dictionary, translator, school app, or flashcard app.

It is a real-world word discovery experience.

## Product Direction

CatchLingo should feel closer to:

- a camera-powered discovery tool
- a travel companion
- a personal word memory
- a lightweight learning experience
- a visual language companion

It should not feel like:

- homework
- a dense vocabulary dashboard
- a generic dictionary
- a technical object-detection demo
- a childish collection game

The long-term idea is:

> The world becomes the vocabulary source.

Users do not manually build word lists.

Users discover vocabulary by looking at the world.

## Core Loop

The product is designed around this loop:

1. Explore
2. Detect
3. Catch
4. Save
5. Review
6. Explore again

Short version:

> Discover → Catch → Remember

Every feature should strengthen this loop.

## Current MVP

The app currently focuses on proving that catching a word can feel satisfying before adding real camera and object-detection features.

Implemented so far:

- Flutter / Material 3 app structure
- Android-first MVP direction
- Warm field-journal visual direction (cream / leaf green / honey amber)
- Clean Home screen with live collection status
- Explore Mode with multiple mock scenes (Cafe, Market, Hotel)
- Mock detected words with stable ids
- Tap-to-catch interaction with catch reveal (translation as the reward)
- "Spotted again" micro-reward for already-caught words
- Local persistence via SharedPreferences (`caughtIDs`, `seenCount`, `lastSeenAt`)
- Dictionary built from actually caught words, grouped by category
- Spotted-count and last-seen info per word
- Lightweight Review flow (tap to reveal, self-assess, requeue)
- Session summary flow (finish session → new vs. already-known words, review entry)
- Session counter and collection feedback
- Duplicate collection prevention
- Central design system foundation and theme file
- Reusable catch word chip and collection counter
- Widget and unit tests for core MVP behavior

Example mock word:

```text
chair -> kursi
```

## Current Screens

- Home
- Explore Mode
- My Dictionary
- Review

Older manual vocabulary prototype files may still exist in `lib/legacy/` as reference material. They are not the current product direction.

## Not Built Yet

These are intentionally not part of the current MVP step:

- real camera integration
- ML Kit
- real object detection
- cloud sync
- user accounts
- full local database architecture
- full spaced repetition
- complex settings
- AI explanations
- multi-language marketplace

The camera is important, but it is still a tool.

The product is the discovery experience.

## Planned Milestones

Near-term:

- Polish catch animations and micro-interactions further
- Sharpen Home screen identity (icon / branding with cat + AR corners)
- Optional marker-tap variations in Explore

Later:

- Camera preview and permissions
- Real object detection
- Real vocabulary collection
- Local storage for sessions and collected words
- Review and flashcard flows
- Travel/session memory

## Tech Stack

- Flutter
- Dart
- Material 3
- Android-first MVP

## Development Principles

- Keep milestones small.
- Prefer simple, readable Flutter code.
- Avoid unnecessary packages.
- Do not implement future features before the core discovery loop feels good.
- When choosing between learning complexity and discovery experience, prefer discovery experience unless learning quality would clearly suffer.
- The app should feel instant.
- The app should feel visual.
- The app should feel like real-world vocabulary, not a school worksheet.

## Key Documents

- `VISION.md` describes the product vision.
- `UI_SPEC.md` describes the intended UI and interaction model.
- `DESIGN_SYSTEM.md` describes the design principles, visual language, components, and motion behavior.
- `TECHNICAL_DECISIONS.md` describes MVP sequencing and technical constraints.
- `ROADMAP.md` describes the high-level phased development.
- `AGENTS.md` gives coding agents project-specific guidance.
