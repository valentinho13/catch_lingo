# CatchLingo Animation Audit

## Scope

This audit reviews the current Flutter UI with focus on screens, navigation,
buttons, cards, gestures, and animation opportunities. The goal is not more motion
for its own sake. Motion should make CatchLingo feel more responsive, crafted, and
emotionally rewarding while protecting the warm field-journal direction:

> Discover -> Catch -> Collect -> Celebrate -> Review

## Current Screens

### Active Product Screens

- `HomeScreen`
  - Warm start screen with morning header, cat hero card, statistics, categories,
    and bottom navigation.
- `ExploreScreen`
  - Camera/fallback discovery surface, active detection marker, bottom detection
    card, catch action, catch celebration overlay, session complete overlay.
- `DictionaryScreen`
  - Collected words grouped by category, filter chips, word cards, search icon,
    bottom navigation.
- `ReviewScreen`
  - One-card review flow with progress, answer reveal, round action buttons, bottom
    navigation.

### Present But Not Active Product Direction

- `lib/legacy/vocabulary_prototype/*`
  - Add word, word list, and training prototype screens. These are legacy reference
    files and should not drive animation priorities.

### Missing / Not Implemented

- Settings screen
  - A settings icon exists on Home, but it currently has no real settings flow.
- Word detail screen / bottom sheet
  - Mentioned in the product docs as possible future scope, not active now.

## Actions By Screen

### Home

- Tap `Start Exploring` in the hero card.
- Tap bottom nav: Discover, Dictionary, Review.
- Tap `View all` in categories.
- Tap settings icon.
- Cards shown: hero card, stat cards, category cards.

Current motion:
- Initial staggered fade/slide via `_HomeEntry`.

Good animation fits:
- Button press microinteraction on the primary CTA.
- Gentle cat/hero parallax or idle breathing, very subtle.
- Stat counters counting up when returning from Explore.
- Category cards fade/slide in with small stagger.
- Shared transition from hero CTA into Explore only if navigation is later cleaned
  up into a tab/shell flow.

### Explore / Discover

- Tap active detected word's `Catch`.
- Tap `Look around`.
- Tap back.
- Automatic mock detection appears.
- Catch celebration appears.
- Session complete overlay appears after enough catches.

Current motion:
- Detection panel swaps with `AnimatedSwitcher`.
- Detection marker animates size/surface.
- Catch celebration has entrance animation, continuous sparkles, gentle card/check
  motion, reward token pulse.
- Session complete overlay fades/slides in.

Good animation fits:
- Strong catch burst that expands from the detected word or catch button.
- Counter pulse when caught count changes.
- Detection marker breathing while active.
- `Look around` quick scene/card transition.
- Subtle camera depth vignette/parallax.
- Later AR phase: stable detection reticles, focus frame, object lock-on motion.

Avoid:
- Technical scanner/HUD sweeps, confidence bars, radar, neon outlines.
- Long blocking celebration.
- Loud confetti or casino-like particle floods.

### Dictionary / Collection

- Tap search icon.
- Tap filter chips.
- Scroll grouped word cards.
- Tap bottom nav.
- Empty state `Start Exploring`.

Current motion:
- Mostly static list.

Good animation fits:
- Staggered fade/slide for word cards.
- Filter chip selected-state motion.
- Card press lift/scale for future word detail.
- Bookmark icon soft pop if save/favorite becomes interactive.
- Shared element transition into future word detail card.

### Review / Training

- Tap reveal answer.
- Tap `Again`.
- Tap `Knew it`.
- Tap bottom nav.
- Empty state `Start Exploring`.

Current motion:
- Review card changes with `AnimatedSwitcher`.
- Answer text reveal uses `AnimatedSwitcher`.
- Round action buttons are static aside from Material feedback.

Good animation fits:
- Answer reveal as a small card flip/fade/slide, not a full flashcard gimmick.
- Progress bar pulse when moving to next word.
- Round action button press scale.
- Card slide to next word after `Again` / `Knew it`.
- Later: spaced repetition quality feedback, but kept calm.

### Navigation

- Current navigation uses `Navigator.push`, `pushReplacement`, and a custom bottom
  nav. There is no central tab shell yet.

Good animation fits:
- Bottom nav press/selection microinteraction.
- Fade-through between major sections.
- Shared element transitions later if screen ownership becomes centralized.

## Animation Type Fit

| Animation Type | Fit | Notes |
|---|---:|---|
| Hero animations | Medium | Best later for word card -> detail or Home hero -> Explore. Current navigation makes broad Hero use awkward. |
| Shared element transitions | Medium/Later | Strong fit for word specimens once word detail exists. |
| Implicit animations | High | Best default for cards, chips, counters, selection states. Low risk. |
| Physics / spring / bounce | Medium | Use only for catch moment and microinteractions. Avoid toy-like bounce. |
| Button microinteractions | High | Immediate premium feel, low risk. |
| Particles / celebration | High in Explore | Good for catch only. Keep warm, sparse, and short. |
| XP/counter animations | Medium | Use as "caught total", not gamified XP. |
| Scanner / AR overlay | Later | Only light focus framing. Avoid HUD language. |
| Rive/Lottie | Later | Could help with cat/companion or premium object stickers, but no package yet. |
| Blur / glass panels | Medium | Use sparingly. Warm translucent surfaces can work; cold glass HUD should not return. |
| Parallax / depth | Medium | Good for Home hero and Explore background if subtle. |

## Prioritized Roadmap

### Quick Wins

| Idea | UX Nutzen | Wow | Aufwand | Performance | Vision Fit |
|---|---:|---:|---:|---:|---:|
| Bottom nav press/selection scale | Medium | Low-Med | Low | Low | High |
| Dictionary word cards fade/slide stagger | Medium | Medium | Low | Low | High |
| Review answer/card transition refinement | Medium | Medium | Low | Low | High |
| Caught counter pulse in Explore | High | Medium | Low | Low | High |
| Primary CTA press scale | Medium | Low | Low | Low | High |

### Medium Effort

| Idea | UX Nutzen | Wow | Aufwand | Performance | Vision Fit |
|---|---:|---:|---:|---:|---:|
| Catch burst from detected marker/button | High | High | Medium | Low-Med | Very High |
| Review next-card slide after Again/Knew it | Medium | Medium | Medium | Low | High |
| Word card -> detail shared transition | High | High | Medium | Low | High |
| Home cat subtle idle motion/parallax | Low-Med | Medium | Medium | Low | Medium |
| Filter chip animated selection with real filtering | Medium | Medium | Medium | Low | High |

### Later / AR Phase

| Idea | UX Nutzen | Wow | Aufwand | Performance | Vision Fit |
|---|---:|---:|---:|---:|---:|
| Stable AR focus frame over detected object | High | High | High | Medium | High if non-HUD |
| Real camera depth/parallax treatment | Medium | High | High | Medium | High |
| Rive companion idle/reaction animations | Medium | High | High | Low-Med | High if tasteful |
| Lottie/Rive illustrated word stickers | Medium | High | High | Low-Med | High |
| Shader-based warm light overlays | Low-Med | High | High | Medium | Medium-High |

## First Implementation Steps

Start with small Flutter-native improvements:

1. Add bottom navigation press/selection scale.
2. Add staggered fade/slide entrance to dictionary word cards.
3. Refine Review card/answer transition with fade, slight slide, and scale.

These are safe because they do not alter app logic, color direction, navigation
structure, or product scope. They improve responsiveness and perceived craft without
slowing down the core loop.
