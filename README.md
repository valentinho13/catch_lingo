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

The app currently focuses on making real-world word discovery feel good with a
real camera preview and mock detections over that preview.

Implemented so far:

- Flutter / Material 3 app structure
- Android-first MVP direction
- Warm Home screen with cat branding
- Explore Mode with real camera preview
- Camera permission through the Flutter camera plugin
- Mock detected words over the camera
- Tap-to-catch interaction
- Collected word state
- Translation reveal after collection
- Session counter
- Collection feedback
- Duplicate collection prevention
- Bottom navigation for Discover / Dictionary / Review
- Central design system foundation
- Central theme file
- Reusable catch word chip
- Reusable collection counter
- Widget tests for core MVP behavior

Example mock word:

```text
chair -> kursi
```

## Current Screens

- Home / Discover
- Explore Mode with camera preview
- Dictionary
- Review

Older manual vocabulary prototype files may still exist in `lib/legacy/` as reference material. They are not the current product direction.

## Not Built Yet

These are intentionally not part of the current MVP step:

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

- Polish camera loading and permission fallback
- Make the catch moment feel even more satisfying without heavy effects
- Improve Dictionary as a personal word memory
- Keep storage compatible with existing caught-word data

Later:

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
