# CatchLingo UI Specification

## Purpose of this document

This document describes the intended user interface, interaction model, camera behavior, buttons, animations, and visual direction for CatchLingo.

It should help AI coding agents and human developers understand what the app should feel like before implementing features.

The goal is not to build everything at once.
The goal is to keep every implementation step aligned with the product vision.

---

## Product Feeling

CatchLingo should feel simple, playful, modern, and exploratory.

The user should not feel like they are using a technical object-recognition tool.
The user should feel like they are catching words from the world.

The app should feel closer to:

- a discovery game
- a travel companion
- a personal vocabulary collection
- a lightweight learning tool

It should not feel like:

- a school app
- a complicated translator
- a developer demo
- a dashboard full of settings

Core emotional goal:

> “I discovered new words today.”

---

## Visual Direction

### General Style

CatchLingo should use a clean Material 3 inspired design.

The UI should feel:

- friendly
- modern
- calm
- lightweight
- slightly playful
- mobile-first

Avoid heavy enterprise-style UI.
Avoid too many controls on one screen.
Avoid dense settings screens early in development.

---

## Color Direction

The MVP can use a simple seed color system.

Suggested primary direction:

- Indigo / blue-violet as primary app color
- White or near-white backgrounds in light mode
- Deep dark navy / charcoal backgrounds in dark mode later
- Accent highlights for collected words

Example visual associations:

- primary: exploration, technology, trust
- green highlight: newly collected word
- amber highlight: word needs review
- muted gray: already known word

The first MVP does not need a full custom design system.
Material 3 theming is enough.

---

## Typography

Text should be clear and readable.

Important words should be large enough to read quickly during camera use.

Suggested hierarchy:

- App title: large, bold
- Screen title: medium-large, bold
- Word labels: bold and very readable
- Subtitles: soft, calm, medium size
- Metadata: smaller and muted

Avoid tiny text in camera mode.
Users may be walking, moving, or outside in daylight.

---

## Navigation Model

The app should start simple.

Main navigation should eventually include:

1. Explore
2. Dictionary
3. Review
4. Profile / Settings

For MVP, avoid a full bottom navigation if it is not needed.
Start with a home screen that routes to future modes.

Future version can use bottom navigation once multiple areas exist.

---

# Main Screens

## 1. Home Screen

### Purpose

The home screen introduces CatchLingo and gives the user a clear starting point.

It should not be crowded.
It should make the app feel like a real product instead of the default Flutter demo.

### Layout

From top to bottom:

1. App logo or icon placeholder
2. App name: `CatchLingo`
3. Subtitle: `Catch words from the world around you.`
4. Primary button: `Start Exploring`
5. Secondary button: `My Dictionary`
6. Small status text, for example: `No words collected yet.`

### Buttons

#### Start Exploring

Primary action.
Large filled button.
Should open Explore Mode.

For early MVP, it can navigate to a placeholder Explore screen.

#### My Dictionary

Secondary action.
Outlined or tonal button.
Should open Dictionary screen.

For early MVP, it can navigate to a placeholder Dictionary screen.

### Animation

On app start:

- Logo/icon fades in
- Title slides/fades in slightly
- Buttons appear with a short delay

Animation should be subtle.
No excessive bouncing, particles, or childish effects.

Suggested duration:

- 250-500 ms

---

## 2. Explore Mode

### Purpose

Explore Mode is the heart of CatchLingo.

The user points the camera at the world.
The app detects possible objects or visual concepts.
Detected words are collected into the current session.

This mode should feel like casting a net over the environment and catching words.

### Core Behavior

Explore Mode should:

- show a live camera preview
- analyze frames at a controlled rate
- detect objects or labels
- show detected word candidates
- collect new words into the current session
- avoid duplicate words within the same session
- show feedback when a new word is collected

### Important Principle

The camera is not the product.
The collection loop is the product.

The UI should focus on:

- what was discovered
- what was collected
- what is new
- what can be reviewed later

---

## Explore Mode Layout

### Camera Preview

The camera preview should fill most or all of the screen.

Overlay elements should float above the camera preview.

The UI should not block the center of the camera view unnecessarily.

### Top Area

Suggested elements:

- Back button or close button
- Current session name or generic label: `Exploring`
- Small counter: `12 words caught`

Example:

`← Exploring     12 caught`

### Center Area

This area shows camera content.

Detected object labels may appear as floating chips or small cards.

Example:

- `kursi`
- `meja`
- `botol`

Labels should not constantly flicker.
They should appear stable and smooth.

### Bottom Area

Suggested bottom panel:

- current latest collected word
- session progress
- button to pause/stop session

Example:

`+ kursi added`

Buttons:

- `Pause`
- `Finish`

For MVP, a simple bottom bar is enough.

---

## Object Label UI

### Detected Candidate Chip

When the app detects an object, it can show a chip near the object or in a floating list.

Example:

`chair 92%`

After mapping to the target language:

`kursi`

Optional subtitle:

`chair · 92%`

### States

#### New Word

Visual style:

- highlighted chip
- green or primary accent
- small plus icon

Example:

`+ kursi`

#### Already Collected

Visual style:

- muted chip
- check icon

Example:

`✓ kursi`

#### Low Confidence

Visual style:

- muted / dotted / warning subtle
- not automatically collected

Example:

`chair?`

Low-confidence words should not be added automatically unless confirmed.

---

## Collection Behavior

### Auto Collect Mode

In Auto Collect Mode, the app automatically adds newly detected words to the current session if:

- confidence is high enough
- the object is recognized consistently
- the word is not already in the session
- the word is not already known by the user, depending on settings

Suggested MVP rule:

- collect if confidence is above threshold
- ignore duplicates in current session

### Tap Mode

In Tap Mode, detected words are shown but not collected until the user taps them.

Tap Mode is better for accuracy.
Auto Collect Mode is better for magic.

Both modes should exist eventually.

### Session Collection

Each Explore session should store:

- timestamp
- optional location label later
- list of discovered words
- detected source labels
- target-language translation
- whether word was new or already known

For MVP, local in-memory or simple local storage is enough.

---

## Explore Mode Animations

### Word Caught Animation

When a new word is collected:

1. Detected chip appears
2. Chip briefly expands or brightens
3. A small `+ word` notification appears
4. Word moves or fades toward the bottom collection area
5. Counter increases

This should feel satisfying but not distracting.

Suggested duration:

- chip feedback: 150-250 ms
- notification: 1.5-2 seconds
- counter update: instant or subtle scale pulse

### Counter Animation

When a new word is collected:

- counter briefly scales to 1.05 or 1.1
- returns to normal

Avoid aggressive animation.

### Session End Animation

When the user taps `Finish`:

- camera fades or blurs slightly
- session summary panel slides up

---

## Camera Functional Behavior

### MVP Camera Rules

The camera should:

- start only after permission is granted
- show a clear permission explanation if needed
- analyze frames at a low rate
- avoid analyzing every frame
- prevent device overheating
- keep UI responsive

Suggested MVP analysis frequency:

- 1 frame per second

Later versions can adjust dynamically.

### Performance Rules

The app should not attempt to run detection at full video frame rate.

The app should:

- throttle detection
- ignore frames while detection is already running
- cache recent results
- avoid repeated duplicate processing
- keep animations lightweight

### Detection Stability

To avoid flickering, a label should only be shown or collected if:

- confidence is high enough
- result appears consistently
- or user taps to confirm it

Future rule example:

- same label detected 2 times within 3 seconds

MVP can be simpler.

---

## 3. Session Summary Screen

### Purpose

After exploring, the user sees what was collected.

This is the reward screen.
It should make the user feel progress.

### Layout

Header:

`Session Complete`

Summary:

- `18 words caught`
- `7 new words`
- `11 already known`

List:

- kursi — chair / Stuhl
- meja — table / Tisch
- botol — bottle / Flasche

Actions:

- `Review Now`
- `Save to Dictionary`
- `Done`

### Animation

The summary should slide up from the bottom or fade in.
The number of collected words can count up quickly.

Keep it elegant.
No casino-machine effect.

---

## 4. Dictionary Screen

### Purpose

The Dictionary is the user’s personal collection of discovered words.

It should feel personal and rewarding.

### Layout

Top:

- title: `My Dictionary`
- search field
- filter chips

Filters:

- All
- New
- Learned
- Needs Review
- Categories later

Word list item:

- target word: `kursi`
- source meaning: `chair / Stuhl`
- category: `Home`
- status indicator: new / learning / known

### Empty State

If no words exist:

`No words collected yet.`

Subtitle:

`Start exploring to catch your first words.`

Button:

`Start Exploring`

---

## 5. Word Detail Screen / Bottom Sheet

### Purpose

When a user taps a word, they should see more information.

### Content

- target word
- source language meaning
- pronunciation button
- example sentence later
- category
- learned status
- button to add/remove from flashcards

Example:

`kursi`

`chair · Stuhl`

Buttons:

- `Play pronunciation`
- `Add to Flashcards`
- `Mark as Known`

For MVP, this can be a simple bottom sheet.

---

## 6. Flashcard Mode

### Purpose

Flashcard Mode turns collected words into learning material.

### Basic Card

Front:

`kursi`

Back:

`chair / Stuhl`

Optional later:

- image snapshot
- example sentence
- pronunciation

### Buttons

- `I knew this`
- `Review again`

For MVP, flashcards can be a placeholder.

---

# Buttons and Interactions

## Primary Buttons

Used for main actions:

- Start Exploring
- Review Now
- Save to Dictionary

Visual style:

- filled
- large touch target
- clear icon if helpful

## Secondary Buttons

Used for supportive actions:

- My Dictionary
- Done
- Later

Visual style:

- outlined or tonal

## Destructive Buttons

Used rarely:

- Delete word
- Clear session

Should require confirmation.

---

# Animation Principles

Animations should support the feeling of discovery.

Use animations for:

- word collected
- counter increase
- screen transitions
- bottom sheet appearance
- session summary

Avoid animations that:

- slow down interaction
- distract from camera use
- make the app feel childish
- reduce performance

Animation should be quick, smooth, and subtle.

Preferred durations:

- micro-interaction: 100-250 ms
- screen transition: 250-400 ms
- feedback notification: 1.5-2 seconds

---

# MVP UI Scope

The first useful UI milestone should include only:

1. Home screen
2. Placeholder Explore screen
3. Placeholder Dictionary screen
4. Clean navigation between those screens
5. Modern Material 3 styling
6. No camera implementation yet

The second UI milestone can include:

1. Camera permission screen
2. Camera preview
3. Fake detected word chips
4. Session counter
5. Finish session button

The third UI milestone can include:

1. Real object detection
2. Real collection behavior
3. Session summary
4. Local session storage

---

# Do Not Build Yet

Avoid implementing these too early:

- login
- cloud sync
- payment
- user accounts
- advanced AI explanations
- complex settings
- full spaced repetition system
- multi-language marketplace
- real AR anchoring
- video recording

These are future features.
The MVP must stay small.

---

# Codex Implementation Guidance

When coding from this UI specification, Codex should:

1. Read `VISION.md` first.
2. Read this file second.
3. Implement only the requested milestone.
4. Avoid adding unnecessary packages.
5. Keep Flutter code simple and readable.
6. Prefer small widgets over one giant `main.dart` file as the app grows.
7. Run `flutter analyze` after changes.
8. Do not implement future features unless explicitly requested.

---

# First Practical Task

The first implementation task should be:

Replace the default Flutter counter app with a modern CatchLingo home screen.

Required elements:

- App name: CatchLingo
- Subtitle: Catch words from the world around you.
- Primary button: Start Exploring
- Secondary button: My Dictionary
- Empty state text: No words collected yet.
- Material 3 enabled
- Debug banner disabled
- No additional packages

This should be committed as:

`Replace demo counter with CatchLingo home screen`
