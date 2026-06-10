# CatchLingo Design Diagnosis

> **Operative diagnosis for the next UI sprint.** This document describes why the
> current implementation feels different from the design vision, and what to change
> first. It is a snapshot, not an authority: `DESIGN_VISION.md` remains the canonical
> long-term design authority. When this diagnosis and the vision disagree, the vision
> wins. Once the sprint lands, this file should be re-validated against new screenshots.
>
> Scope: diagnosis only. No implementation is part of this document.

---

## Headline Finding

**The current app is not drifting from DESIGN_VISION.md. It is its photographic
negative.** The vision retired the dark, technical direction — and the shipped code
*is* that direction, almost item-for-item from the vision's "Elements That Would
Destroy This Direction" list:

- Near-black surfaces (`0xFF070908`) on Home, Explore, Dictionary, and Review.
- Neon mint on black, glowing borders, lens-frame HUD corners.
- Radar and science icons, a permanent "Prototype · simulated detection" badge.
- "Scanning scene" / "No detections loaded" status readouts.

Meanwhile `lib/app/app_theme.dart` still defines the retired indigo seed
(`0xFF5B5FEF`) and mint (`0xFF7DF1BD`). **There is not a single cream, warm-green,
or amber token anywhere in the code.** The vision exists only in markdown.

This is not a polish gap. It is an unimplemented identity.

---

## 1. Emotional Atmosphere

**Current:** A night operation. Opening the app feels like booting surveillance
equipment at 1 a.m. — black gradients, phosphor-mint accents, status text, a scanning
rig. Even the camera feed, the one warm real thing available, gets black scrims at
62% and 76% alpha laid over it. **The app literally darkens the world.**

**Vision:** A sunlit café table mid-morning. Warmth as baseline, light as the
emotional engine.

**Biggest mismatch: light.** The vision's entire thesis is "warm light makes noticing
the world feel valuable." The current app has zero light in it — no warmth, no soft
shadow, no atmosphere. Everything else is downstream of this.

---

## 2. Product Personality

**Current app as a person:** a drone operator demoing their kit. Competent, terse,
dressed in black, speaks in system status: *"Scanning scene. No detections loaded.
Prototype · simulated detection."* Impressive, slightly paranoid, not someone you'd
walk with.

**Vision as a person:** a warm, curious friend on a morning walk who touches your arm
and whispers *"look — kopi."*

**Why they differ:** the current app talks to the user **about itself** — its
scanning, its detections, its prototype status. The vision's companion talks **about
the world**. That is the entire personality gap in one sentence.

---

## 3. Visual Temperature

Cold / technical / tool-like spots, ranked by damage:

1. **Explore Mode is a cockpit.** Lens-frame corners, dual black scrims, radar icon,
   science badge, status overlay, glowing marker, glass control panel — seven
   instrument layers on one screen.
2. **The cards are HUD glass.** Dark translucent panels, 1px neon borders, mint bloom
   shadows. The vision's cards are warm, white, solid, with soft *real* shadow —
   objects you could pick up. Nothing in the current app feels solid enough to own.
3. **Typography shouts.** Nearly everything is `FontWeight.w900`. When everything is
   maximum-bold, nothing is precious — it reads as an engineering poster, not an
   editorial page.
4. **Dictionary is inventory.** Dark grouped lists, check icons, category headers.
   Database energy.

Warm spots: none. Truly zero.

---

## 4. Discovery Energy

**"I am operating a system."** Unambiguously.

Evidence: the user *reads machine status* ("Scanning scene", "Looking for words
around you"), *pushes operator buttons* ("Scan next", radar icon), and *waits for the
machine to report findings*. Discovery is something the system does and the user
supervises. Worse: catching happens in a bottom control panel — the user's eyes leave
the world to operate the console.

In the vision, the user notices, and the app simply *names* what they noticed.

---

## 5. Perceived Value

**What makes the reference premium:** one hero per screen; warm directional light; a
card with weight and believable shadow; a disciplined three-color emotional palette;
hand-drawn illustration (a care signal money can't fake); calm type; space.

**What currently makes CatchLingo feel cheaper than it should:**

- **The caught word never becomes an object.** It appears as text in a dark panel,
  then becomes a list row. That is the kill shot — the treasure is never *held*.
- Glow borders and mint bloom = gadget juice, not craft.
- Universal `w900` = no hierarchy = no reverence.
- The reveal ("Caught!" in small mint caps) celebrates in the system's voice, at
  label size, inside glass.
- "Prototype · simulated detection" permanently on screen — honesty delivered as a
  debug readout instead of quiet confidence.

---

## The 10 Highest-Impact Changes (ranked)

| # | Change | Why it matters | Emotion improved | Impact | Effort |
|---|--------|----------------|------------------|--------|--------|
| 1 | **The specimen card.** Caught word becomes a warm-white card with soft real shadow, floating center-screen over the world — not a bottom console panel | This IS the brand gesture; without it no screen is CatchLingo | Ownership, wonder | Massive | Medium |
| 2 | **Let there be light.** Cream canvas on Home/Dictionary/Review; remove the black scrims over the camera, replace with a subtle warm edge vignette | Light is the vision's emotional engine; currently absent | Warmth | Massive | Low–Med |
| 3 | **Implement the palette as tokens.** Cream/green/amber in `app_theme.dart`; delete indigo seed + mint | Every screen inherits it; the vision finally exists in code | Warmth, coherence | High | Low |
| 4 | **De-HUD Explore.** Delete prototype badge, radar/science icons, status overlay, lens frame; one soft green framing gesture remains | Removes the entire "destroy this direction" list | Calm confidence | High | Low |
| 5 | **Amber celebration.** Reveal = word huge on the card, soft sparkle, small amber token; ~1.5 s of held attention | The emotional peak currently happens at label size in mint caps | Delight, reward | High | Medium |
| 6 | **Companion voice copy.** "Scanning scene" → "Something here…"; kill "No detections loaded", "Scan next", "simulated detection" | Words are the cheapest personality transplant available | Companionship | Med–High | Very low |
| 7 | **Calm the typography.** One huge hero word per screen; everything else w500–w700, muted | Restores hierarchy → makes the word precious | Premium calm | Med–High | Low |
| 8 | **One hero per screen.** Explore shows the frame OR the card, never five layers at once; Home gets one hero + one CTA | Space = reverence = value | Focus, reverence | High | Medium |
| 9 | **Dictionary → field journal.** Warm cards, "Caught Tuesday · Café table" context, word prominent, no check icons | Where-and-when turns inventory into memory | Ownership, memory | Med–High | Medium |
| 10 | **Deploy the cat.** `assets/images/welcome_cat.png` already exists — use it on Home, empty states, celebration | A face creates attachment; it is sitting unused | Attachment, warmth | Medium | Low |

---

## Recommended Next Sprint: Light, Catch Card, Voice

If only three things may change in the next sprint:

1. **Change the light** (#2 + #3). Token swap plus killing the darkness. Nothing
   else can read as warm while the canvas is black — every other fix is wasted until
   this lands. Mostly find-and-replace.
2. **Change the catch** (#1 + #5). The specimen card with amber reveal. This is the
   signature gesture, the emotional peak, and the one moment users would describe to
   a friend. One widget, one animation.
3. **Change the voice** (#4 + #6). De-HUD plus copy rewrite. Almost pure *deletion* —
   the cheapest work in the list, and it removes everything `DESIGN_VISION.md`
   explicitly forbids.

In one line each: **the light makes it warm, the card makes it valuable, the voice
makes it a companion.** Everything else is refinement.

---

## Emotional Score

**3/10.**

The current app is not lazy — the haptics, the easeOutBack reveal, the state
discipline are real craft. But it is craft in the wrong genre: it produces *gadget
satisfaction* where the vision demands *quiet wonder*, and its emotional peak — the
catch — happens in a dark glass console at caption size. The single change that
raises the score most: make the caught word a warm, solid, softly-shadowed card the
user feels they are *holding*.

---

## Sprint Interpretation

How to read this document during the sprint:

- **This is a diagnosis, not a spec.** Exact values (colors, radii, shadows, copy)
  come from `DESIGN_VISION.md` and `DESIGN_SYSTEM.md`, not from this file.
- **Order matters.** Light first, catch card second, voice third. The catch card only
  reads as warm and valuable on a warm canvas; the voice only lands once the HUD is
  gone.
- **Most of the sprint is deletion.** Scrims, badges, status overlays, radar icons,
  glow borders, and w900 weights are removed, not redesigned. Resist replacing each
  deleted element with a new one — the empty space *is* the design.
- **Definition of done is emotional, not visual:** a first-time user should describe
  Explore as "I'm looking at my world and it names things," not "the app scans for
  words." If the catch moment doesn't feel like holding something, the sprint isn't
  done.
- **Out of scope:** real camera/ML work, review mechanics, illustrations per word,
  the companion as a character system. The cat image may be reused as-is; nothing new
  is drawn this sprint.
