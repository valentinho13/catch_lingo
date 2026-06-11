# CatchLingo UI Specification

## Purpose

This document describes the intended user interface, interaction model, camera behavior, buttons, animations, and visual direction for CatchLingo.

The goal is not to build everything at once.

The goal is to keep every implementation step aligned with the product vision:

> Real-world vocabulary discovery through camera-based exploration.

## Core UX Idea

The user should feel:

> “I am discovering words from the world around me.”

The user should not feel:

> “I am managing a vocabulary list.”

The UI must support this core fantasy even before the real camera exists.

Mock data should feel like a preview of a camera session, not like a random list of words.

## Product Feeling

CatchLingo should feel:

- simple
- visual
- calm
- playful
- modern
- lightweight
- travel-friendly
- discovery-oriented

It should not feel like:

- homework
- a technical ML demo
- a dense dashboard
- a school app
- a generic dictionary
- a childish toy

Core emotional goal:

> “I discovered a word from something I saw.”

## Visual Direction

### General Style

CatchLingo uses a clean Material 3 inspired design.

The UI should feel friendly, mobile-first, and smooth.

Avoid:

- too many controls
- dense settings
- heavy enterprise UI
- fake gamification clutter
- excessive badges
- aggressive particles
- casino-style rewards

Prefer:

- large touch targets
- clear hierarchy
- soft cards
- readable words
- gentle motion
- beautiful empty states
- strong visual focus on the catch moment

## Color Direction

CatchLingo uses a warm field-journal palette. This direction is locked.

- primary: leaf green (`#3F6B4A` seed)
- accent: honey amber (`#D99A2B`) — used sparingly
- background: warm cream paper (`#FAF6EB`)
- surface: warm near-white cards (`#FFFDF6`)
- text: warm dark brown-green, muted warm gray

Semantic color use:

- green: exploration, main action, caught / success
- amber: review, "spotted again" micro-rewards, attention
- muted warm gray: known / inactive

Retired directions — do not reintroduce:

- cool indigo / blue-violet / teal scanner look
- dark cyber-HUD optics

Avoid overly saturated toy colors.

## Typography

Text should be clear and readable.

Important words should be large enough to read quickly during camera use.

Hierarchy:

- App title: large, bold
- Screen title: medium-large
- Caught words: bold and highly readable
- Translations: smaller, calm
- Metadata: muted
- Helper text: short and clear

Avoid tiny text in Explore Mode.

Users may be moving, walking, or outside.

## Navigation Model

For MVP, use simple navigation:

- Home
- Explore Mode
- Dictionary

Do not add a full bottom navigation until the app has enough real modes to justify it.

Future navigation may include:

1. Explore
2. Dictionary
3. Review
4. Sessions / History
5. Profile / Settings

For now:

> Start simple. Keep the experience focused.

---

# Main Screens

## 1. Home Screen

### Purpose

The Home screen introduces CatchLingo and gives the user a clear start.

It should feel like opening a real product.

It should communicate:

> The world around you can become vocabulary.

### Required Elements

- App identity
- App name: `CatchLingo`
- Primary message
- Primary action: `Start Exploring`
- Secondary action: `My Dictionary`
- Short collection status
- visual hint of word discovery

### Preferred Copy

Title:

```text
CatchLingo
```

Subtitle options:

```text
Discover language in the real world.
```

or

```text
Point. Discover. Remember.
```

or

```text
Catch words from the world around you.
```

Primary button:

```text
Start Exploring
```

Secondary button:

```text
My Dictionary
```

Empty state:

```text
No words caught yet.
Start exploring to catch your first real-world words.
```

### Visual Direction

The Home screen may show:

- soft hero card
- app icon / camera-word symbol
- floating word chips
- gentle gradient
- discovery preview

The hero should not look like a random marketing card.

It should hint at the future camera experience.

### Animation

On app start:

- hero fades/slides in
- title follows
- actions appear with short stagger
- motion duration: 250-500 ms

No excessive bouncing.

---

## 2. Explore Mode

### Purpose

Explore Mode is the heart of CatchLingo.

Eventually, this screen will show the camera.

For now, mock detections should simulate a camera-based discovery session.

The user should understand:

> In the future, I will point the camera at real things and catch the words.

### MVP Explore Screen

Until real camera integration exists, Explore Mode should look like a discovery preview.

Avoid labeling it as a boring mock list.

Better labels:

```text
Discovery preview
```

```text
Camera preview coming soon
```

```text
Words nearby
```

The screen should show:

- a large discovery area
- mock detected word chips
- session counter
- catch feedback
- nearby word candidates
- clear tap-to-catch interaction

### Camera Preview Later

When camera is implemented:

- camera preview fills most of the screen
- overlay UI floats above it
- center stays mostly unobstructed
- detected words appear as stable chips
- collection feedback appears without blocking the camera

### Top Area

Suggested elements:

```text
← Explore Mode        3 caught
```

Top area should include:

- back button
- screen title
- session counter chip

### Discovery Area

For MVP:

- large rounded preview panel
- soft gradient or abstract world/camera background
- floating detected word chips
- label such as `Discovery preview`

For future:

- live camera preview
- overlay chips near detected objects or in a stable floating layer

### Word Candidate Chip

A detected word chip should have states:

#### Uncaught

Example:

```text
+ chair
tap to catch
```

Visual:

- white or soft surface
- plus icon
- calm border
- touchable
- clear affordance

#### Catching

Short transitional state after tap.

Visual:

- slight scale
- brief glow or brighten
- quick response

#### Caught

Example:

```text
✓ kursi
caught · chair
```

Visual:

- soft green background
- check icon
- target word prominent
- source meaning visible
- no duplicate count increase

#### Already Caught

If tapped again:

- do not count again
- subtle feedback only

Example:

```text
Already caught
```

### Catch Behavior

When user taps an uncaught word:

1. Chip reacts immediately
2. Word becomes caught
3. Translation becomes visible
4. Session counter increments
5. Counter pulses briefly
6. Feedback appears

Example feedback:

```text
+ kursi caught
```

or

```text
New word caught: kursi
```

This should feel satisfying but not childish.

### Translation Reveal

Before catching, the chip can show source word:

```text
chair
tap to catch
```

After catching, reveal target word and source meaning:

```text
kursi
caught · chair
```

This makes catching feel like unlocking the word.

### Collection Feedback

Feedback should be:

- visible
- friendly
- short-lived
- in-app styled
- not a generic system snackbar if possible

Suggested placement:

- below discovery panel
- above `Words nearby`
- or floating bottom notification

Duration:

- 1.5-2 seconds

### Counter Animation

When a word is caught:

- session counter briefly scales to 1.05 or 1.1
- returns smoothly
- duration: 150-250 ms

### Duplicate Prevention

Already caught words must not be counted again.

The UI should make the state obvious.

---

## 3. Session Summary Screen

### Purpose

After exploring, the user sees what was caught.

This is the reward screen.

It should feel like:

> Here are the words from this moment.

Not:

> Here is a database export.

### Layout

Header:

```text
Session Complete
```

Summary:

- words caught
- new words
- already known words

Example:

```text
18 words caught
7 new
11 already known
```

List:

```text
kursi — chair
meja — table
botol — bottle
```

Actions:

- `Review Now`
- `Save to Dictionary`
- `Done`

### Future Context

Later, session summaries may include:

- date
- location label
- session name
- travel memory
- photo snapshot
- category

Do not build this too early.

---

## 4. Dictionary Screen

### Purpose

The Dictionary is the personal memory of caught words.

It should feel like a collection of real-world discoveries.

Not like a school vocabulary table.

### Layout

Top:

- title: `My Dictionary`
- optional search field later
- filter chips

Filters:

- All
- New
- Learning
- Known

Word card:

- target word
- source meaning
- category
- status
- caught context later

Example:

```text
kursi
chair
Home · New
```

### Empty State

If no real words are collected:

```text
No words caught yet.
Start exploring to catch your first real-world words.
```

Button:

```text
Start Exploring
```

### Dictionary Tone

Use words like:

- caught
- discovered
- found
- remembered
- review

Avoid words like:

- database
- entries
- manual vocabulary
- lesson list

---

## 5. Word Detail

Word detail can be a bottom sheet.

Content:

- target word
- source meaning
- category
- status
- pronunciation later
- caught date/session later
- review action later

For MVP, keep it simple.

---

## 6. Review / Flashcard Mode

Review exists to help remember caught words.

It is not the main product identity.

A simple future flashcard:

Front:

```text
kursi
```

Back:

```text
chair
```

Actions:

- `I knew this`
- `Review again`

Do not build full spaced repetition too early.

---

# Buttons and Interactions

## Primary Buttons

Use for main actions:

- Start Exploring
- Review Now
- Save to Dictionary

Style:

- filled
- large
- clear
- accessible

## Secondary Buttons

Use for supporting actions:

- My Dictionary
- Done
- Later

Style:

- outlined or tonal

## Destructive Buttons

Rare:

- delete word
- clear session

Always confirm.

---

# Motion Principles

Motion should support discovery.

Use motion for:

- catch confirmation
- translation reveal
- counter pulse
- screen transitions
- bottom sheet appearance
- session summary

Avoid motion that:

- slows the user down
- feels childish
- hurts performance
- distracts from camera use

Preferred durations:

- micro interaction: 100-250 ms
- screen transition: 250-400 ms
- feedback notification: 1.5-2 seconds

---

# Camera Behavior Later

When camera is added:

- request permission clearly
- explain why camera is needed
- start camera only after permission
- analyze at a controlled rate
- do not process every frame
- avoid overheating
- keep UI responsive

Suggested early detection rate:

- around 1 frame per second

Detection should avoid flicker.

A word should only appear or be caught if:

- confidence is high enough
- result is stable enough
- or user taps to confirm

MVP can be simpler.

---

# MVP UI Scope

Current useful MVP scope:

1. Home screen
2. Explore Mode without real camera
3. Mock detected word chips
4. Tap-to-catch
5. Translation reveal
6. Session counter
7. Collection feedback
8. Dictionary preview
9. Clean Material 3 styling

Not yet:

- real camera
- ML Kit
- accounts
- cloud
- complex review
- advanced settings

---

# Codex Implementation Guidance

When coding from this UI specification, Codex should:

1. Read `AGENTS.md` first.
2. Read `DESIGN_SYSTEM.md` second.
3. Read `VISION.md` third.
4. Implement only the requested milestone.
5. Avoid unnecessary packages.
6. Keep Flutter code simple.
7. Prefer small widgets.
8. Run `flutter analyze`.
9. Run `flutter test`.
10. Do not implement future features unless explicitly requested.
