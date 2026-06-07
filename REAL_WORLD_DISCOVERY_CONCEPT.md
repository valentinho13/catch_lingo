# Real-World Discovery Concept

## Core Reframe

CatchLingo should not begin with the idea that the user discovers words.

The user discovers:

- objects
- places
- scenes
- situations
- travel moments
- everyday surroundings

Words are the language layer attached to those discoveries.

This matters because the emotional memory is not:

> I collected the word `kursi`.

It is:

> I saw a chair in this room, and now I know it is `kursi`.

The real-world encounter gives the word meaning.

## 1. Explore Mode If Scenes Are Primary

If scenes are the primary concept, Explore Mode should feel less like a list of available words and more like a live environmental surface.

The screen should answer:

> What am I looking at right now?

Not:

> Which vocabulary items are available?

### Scene-First Layout

A scene-first Explore Mode could be structured like this:

```text
Explore Mode
Hotel Room                         3 caught

[large visual scene preview]

chair        bottle
lamp         table

Latest discovery
chair -> kursi
```

The scene is the anchor.

Word chips are annotations on the scene.

The caught word is the result of interacting with something in that scene.

### What The User Should Feel

The user should feel:

- I am scanning my surroundings.
- The app notices meaningful things.
- I choose which discoveries matter.
- The language appears because I noticed the object.

The user should not feel:

- I am browsing a vocabulary list.
- I am choosing flashcards.
- I am managing database entries.

### MVP Without Camera

Even before camera exists, Explore Mode can represent scenes through:

- illustrated or abstract scene cards
- contextual labels such as `Cafe table`, `Hotel room`, `Street corner`
- grouped object chips inside the scene area
- soft overlays that imply camera framing
- a "Discovery preview" label instead of "mock data"

The goal is not realism.

The goal is to make the user understand:

> These words come from something I am looking at.

## 2. Object Discovery vs Word Collection

Object discovery and word collection are related, but they are not the same.

### Word Collection

Word collection asks:

- What word did I add?
- How many words do I have?
- Can I review this word later?

This is useful, but it can become abstract and detached.

### Object Discovery

Object discovery asks:

- What did I notice?
- Where did I see it?
- What situation was I in?
- What word represents it in the target language?

This creates stronger memory because the word is tied to perception.

### Product Difference

Word collection is inventory.

Object discovery is experience.

CatchLingo should use collection mechanics only to preserve discoveries, not to make collection itself the fantasy.

The product should treat a word as:

> the language representation of a real-world discovery

not:

> a collectible item that happens to have a translation

### UI Consequences

If object discovery is primary:

- object/scene labels should appear before or alongside words
- the discovery surface should be visually dominant
- dictionary entries should eventually include context
- "caught" should mean "captured from a real encounter"
- session memory matters more than raw word count

## 3. Previewing Future Camera Without Camera

The MVP can preview a future camera experience without using the camera by simulating the structure of camera discovery.

The important part is not the camera feed.

The important part is the relationship:

```text
scene -> detected object -> language representation -> saved memory
```

### Better Camera Preview Patterns

#### Scene Card

Show a large rounded panel titled:

```text
Discovery preview
```

Inside it, use a simple scene:

```text
Cafe table

[coffee] [cup] [table] [chair]
```

This implies that the words came from a coherent place.

#### Lens Frame

Use a subtle focus frame or camera-lens overlay.

Avoid technical UI such as:

- confidence debug labels
- bounding boxes everywhere
- frame analysis status
- ML pipeline language

The preview should say:

> This is what Explore will feel like.

Not:

> This is where the camera API will go.

#### Stable Discovery Chips

Mock detections should feel stable.

They should not look like random chips below a panel.

They should appear in or near the scene area, as if attached to discovered objects.

#### Latest Discovery Panel

After tapping:

```text
You noticed: chair
Indonesian: kursi
```

or:

```text
chair found nearby
kursi caught
```

This keeps the real-world object in the story.

## 4. Context As Part Of The Experience

Context is one of CatchLingo's biggest advantages over normal vocabulary apps.

A generic vocabulary app teaches:

```text
chair -> kursi
```

CatchLingo should remember:

```text
chair -> kursi
caught in: Hotel Room
```

or later:

```text
coffee -> kopi
caught at: Cafe
```

### Context Types

Useful early context types:

- room
- cafe
- hotel
- market
- airport
- street
- restaurant
- station
- home
- beach

These do not need real location services at first.

They can begin as mock scene labels.

### Why Context Matters

Context helps users remember because it links vocabulary to:

- visual memory
- place memory
- travel memory
- personal relevance
- situation

The user may forget a random word list.

They are more likely to remember:

> I learned `kopi` when I was looking at coffee in a cafe.

### Scene-Based Sessions

Future sessions could be named by context:

- Hotel Room
- Cafe Table
- Airport Morning
- Street Market
- Train Station

This is stronger than generic sessions like:

- Session 1
- Word List A
- Lesson 3

### Dictionary With Context

Dictionary cards should eventually answer:

```text
kursi
chair
Hotel Room · caught today
```

The dictionary should feel like a memory shelf, not a vocabulary spreadsheet.

## 5. Real-World UI vs Language UI

CatchLingo needs two layers of UI:

1. real-world layer
2. language layer

They should be visually distinct but connected.

## Real-World Layer

The real-world layer represents what the user sees.

It should include:

- scene preview
- camera/lens frame
- object chips
- place/session label
- object category
- discovery state

Examples:

```text
Cafe table
coffee
cup
chair
```

The real-world layer should feel visual, spatial, and contextual.

It answers:

> What did I encounter?

## Language Layer

The language layer represents what the object means in the target language.

It should include:

- translated word
- source meaning
- pronunciation later
- review status later
- saved/caught state

Examples:

```text
kopi
coffee
```

The language layer should feel clear, readable, and calm.

It answers:

> What is the word for this?

## Connecting The Layers

The catch interaction should connect both layers:

Before catch:

```text
coffee
tap to catch
```

After catch:

```text
kopi
caught · coffee
```

The object remains visible.

The word becomes the reward.

## UI Ownership

### Real-world UI elements

These should represent reality/context:

- discovery preview panel
- scene label
- object chips before catch
- camera frame
- session context
- nearby object group
- future location/session metadata

### Language UI elements

These should represent learning/memory:

- target-language word
- source meaning
- translation reveal
- dictionary card
- review action
- known/learning status

### Hybrid elements

These connect both:

- catch chip
- latest discovery banner
- session summary
- dictionary entry with context

The strongest CatchLingo UI elements will be hybrid elements because they connect the real world to language.

## Product Implications

### Explore Should Be Scene-Led

Explore should start with:

> Where am I looking?

Then:

> What objects are here?

Then:

> What are the words for them?

### Dictionary Should Be Memory-Led

Dictionary should start with:

> What have I encountered?

Then:

> What words do I remember from those encounters?

### Review Should Be Encounter-Led

Review should eventually ask:

> Do you remember the word from that scene?

Not only:

> What is the translation?

## Practical MVP Direction

The next MVP design step should not add camera or new features.

It should make the mock Explore experience more scene-based.

Suggested next design experiment:

```text
Discovery preview
Scene: Cafe table

[coffee] [cup] [table] [chair]

Tap an object to reveal the word.
```

After tap:

```text
coffee found nearby
kopi caught
```

This would align the MVP more strongly with the new vision:

> The real world becomes the vocabulary source.

## Final Principle

CatchLingo should not make users feel they are collecting words from an app.

It should make them feel they are noticing the world more clearly.

The word is the souvenir of that noticing.
