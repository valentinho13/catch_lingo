# CatchLingo Design System

## Purpose

This document defines the practical UX and component direction for CatchLingo.

For the emotional and visual identity — color meaning, atmosphere, warmth, and the
overall feel — `DESIGN_VISION.md` is the **canonical authority**. Read it first. Where
this document and `DESIGN_VISION.md` disagree, `DESIGN_VISION.md` wins.

It should guide Codex, AI assistants, and human developers when building UI.

CatchLingo must not become a generic Flutter vocabulary app.

It must feel like a warm, real-world word discovery experience — sunlit and inviting,
never cool, dark, or technical.

## Design North Star

> The world becomes the vocabulary source.

The user should feel:

> “I pointed at something real and learned the word for it.”

Every screen should support this feeling.

## Product Personality

CatchLingo should feel:

- warm
- curious
- calm
- modern
- visual
- lightweight
- friendly
- travel-ready
- useful
- slightly magical
- premium / quietly crafted

It should not feel:

- childish
- academic
- cluttered
- like homework
- like a dictionary database
- like a machine-learning demo

## UX Principles

### 1. Real-world first

The UI should always hint that words come from the real world.

Even mock data should feel like a camera-session preview.

Avoid screens that feel like manually typed vocabulary.

### 2. Catching should feel immediate

When the user catches a word, feedback must be instant.

No ambiguity.

The user must know:

- the tap worked
- the word was caught
- the collection changed

### 3. Reveal meaning through action

Before catching:

```text
chair
tap to catch
```

After catching:

```text
kursi
caught · chair
```

This makes the word feel unlocked.

### 4. Keep learning lightweight

Do not overload screens with grammar, explanations, or study mechanics.

Learning should feel like the natural result of noticing things.

### 5. Reduce friction

The user should not configure much.

The app should open, guide, and respond.

### 6. Avoid fake gamification

Do not add coins, XP bars, badges, streak pressure, or casino reward effects too early.

Discovery itself is the reward.

## Visual Style

### Overall

Use Material 3 as the base.

Style should be:

- soft
- rounded
- spacious
- readable
- touch-friendly
- calm but not boring

### Surfaces

Use large rounded cards for:

- hero sections
- discovery preview
- empty states
- dictionary cards
- session summaries

Cards should feel elevated but not heavy.

### Corners

Use generous border radii.

Suggested values in code:

- small: 12
- medium: 20
- large: 28
- extra large: 36

### Spacing

Use consistent spacing.

Suggested values:

- xs: 4
- sm: 8
- md: 16
- lg: 24
- xl: 32
- xxl: 48

### Color System

The palette is warm and naturally lit. See `DESIGN_VISION.md` for the full color
philosophy; this is the practical mapping.

Base:

- canvas: warm cream / soft warm neutrals (the default mood of every screen)
- surface: warm off-white cards (never stark white, never dark)
- primary / discovery: a living, growing green — finding, "go," the alive thing
- reward / treasure: a warm amber — the caught word, progress tokens, the companion
- muted: warm grays for inactive / already-known

Use color semantically:

- green = discovery / main action / something worth noticing
- amber = reward / caught / a treasured find
- cream + warm neutrals = the calm canvas everything rests on
- warm gray = inactive / already known

Color is emotional, not decorative — each hue means something and is used sparingly.

Avoid: cool corporate blues / indigo / lavender, cold grays, dark "night" surfaces,
neon, and loud rainbow palettes. The old indigo + mint direction is retired.

## Typography

Typography should be bold where it matters.

Word labels must be easy to read.

Suggested hierarchy:

- App title: very large, bold
- Screen title: large, medium/bold
- Section title: bold
- Word target: bold
- Translation/source meaning: medium, muted
- Metadata: smaller, muted

Avoid tiny text in Explore Mode.

## Icons

Icons should support meaning, not decorate randomly.

Useful icon meanings:

- camera / lens = explore
- sparkle = discovery
- plus = catch
- check = caught
- book = dictionary
- cards = review
- location = future session context
- clock = recent / history

Use icons consistently.

## Core Components

### Primary Action Button

Used for:

- Start Exploring
- Review Now
- Save to Dictionary

Style:

- filled
- large
- rounded
- strong label
- optional icon
- minimum height around 56

### Secondary Action Button

Used for:

- My Dictionary
- Done
- Later

Style:

- outlined or tonal
- rounded
- clear label
- optional icon

### Catch Word Chip

States:

#### Idle

Shows source word and action.

Example:

```text
chair
tap to catch
```

Visual:

- white / surface background
- plus icon
- soft border
- subtle shadow

#### Catching

Short transition state.

Visual:

- slight scale
- slight brighten
- quick feedback

#### Caught

Shows target word and meaning.

Example:

```text
kursi
caught · chair
```

Visual:

- soft green background
- green border
- check icon
- target word emphasized

#### Already Caught

No duplicate count.

Subtle feedback only.

### Collection Counter

Shows session catch count.

Example:

```text
3 caught
```

Behavior:

- updates immediately
- pulses briefly after new catch
- no aggressive bounce

### Discovery Area

For MVP:

- large rounded panel
- soft gradient
- floating chips
- label like `Discovery preview`
- should feel like a camera placeholder, not a random list

For future:

- camera preview
- overlay chips

### Empty State Card

Empty states should be encouraging.

Bad:

```text
No data.
```

Good:

```text
No words caught yet.
Start exploring to catch your first real-world words.
```

## Motion System

Motion should be subtle and rewarding.

Suggested durations:

- micro feedback: 100-200 ms
- chip transition: 150-250 ms
- screen transition: 250-400 ms
- feedback toast: 1.5-2 seconds

Use motion for:

- catch feedback
- counter pulse
- chip state transition
- home entry
- summary slide-up

Avoid:

- particles everywhere
- excessive bounce
- slow animations
- random movement
- animations that block input

## Explore Mode Design Rules

Explore Mode must be the strongest screen.

It should always communicate:

> Words are being discovered from the world.

Rules:

- discovery area is visually dominant
- caught count is always visible
- caught words look clearly different
- no duplicate ambiguity
- feedback appears immediately
- mock mode still feels like a future camera session

Avoid:

- plain list of words
- too many repeated sections
- technical labels like `mock data` unless necessary
- visual clutter

## Dictionary Design Rules

Dictionary is a personal word memory.

It should feel like:

> words I discovered

not:

> rows in a database

Rules:

- use cards
- show target word prominently
- show source meaning clearly
- show status chips
- empty state encourages exploration
- later group by session/recent/category

## Home Design Rules

Home should communicate the product quickly.

User should understand:

- this app helps me discover words
- Explore is the main action
- Dictionary stores caught words

Home should not be overloaded.

Use:

- hero card
- clear title
- one primary action
- one secondary action
- collection status

## Copywriting

Preferred words:

- discover
- catch
- caught
- real-world words
- explore
- remember
- session
- dictionary
- review

Avoid:

- study
- lesson
- homework
- database
- entries
- manual vocabulary
- object detection demo

## Accessibility

- large touch targets
- good contrast
- readable font sizes
- no information by color only
- icons should support labels
- animations should be short

## Codex Rules

When editing UI:

1. Read `AGENTS.md`.
2. Read this file.
3. Do not add unnecessary packages.
4. Use existing theme tokens where possible.
5. Prefer small widgets.
6. Keep code readable.
7. Do not build future features unless asked.
8. Run `flutter analyze`.
9. Run `flutter test`.

## Final Design Rule

CatchLingo should not feel like a prettier vocabulary list.

It should feel like the first version of an app where the real world becomes a language-learning surface.
