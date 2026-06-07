# CatchLingo Vision Alignment Review

## Section 1: Current Strengths

### Home Screen

- The Home screen has a clear entry point with `Start Exploring`.
- The app already avoids a dense dashboard and keeps the first screen focused.
- The current visual style is modern, calm, and Material 3 aligned.
- The secondary route to `My Dictionary` supports the future Discover -> Catch -> Remember loop.

### Explore Mode

- Explore Mode is correctly treated as the core MVP screen.
- Mock detections already preview the future camera behavior better than a plain word list would.
- Tap-to-catch, translation reveal, duplicate prevention, and session counter all support the current MVP behavior.
- The catch feedback is immediate, so the user understands that a tap changed the word state.

### Dictionary

- The Dictionary already uses cards and empty-state guidance instead of a dense table.
- It is framed as a personal place for caught words rather than a generic database.
- The empty state points users back toward Explore, which supports the loop.

### Navigation

- Navigation is simple: Home -> Explore Mode / My Dictionary.
- No bottom navigation has been added prematurely.
- The app currently has enough structure for the MVP without feeling over-architected.

### Code and Component Foundation

- `app_theme.dart` gives the design system a central code anchor.
- `CatchWord`, `mockCatchWords`, `CatchWordChip`, and `CollectionCounter` are good early abstractions because they map to product concepts.
- Legacy vocabulary-prototype files have been separated from the current MVP path.

## Section 2: Current Weaknesses

### Home Screen

1. **What currently feels like a vocabulary manager?**
   - `My Dictionary` appears very early and prominently, which can make the app feel storage-oriented before discovery-oriented.
   - The status card still emphasizes having zero words rather than having no real-world discoveries yet.

2. **What currently feels disconnected from the new vision?**
   - The hero uses word chips, but it does not strongly suggest that words come from camera-based real-world encounters.
   - The app promise still leans toward "catching words" more than "pointing at real things and learning their words."

3. **What currently feels like placeholder/demo UI?**
   - The hero word chips are static and decorative.
   - There is no visual hint of a camera frame, lens, travel scene, room, market, or real-world surface.

4. **What currently supports the vision well?**
   - `Start Exploring` is the correct primary action.
   - The screen is calm and focused.
   - The copy is short and does not feel academic.

5. **What should be changed next?**
   - Reframe the Home status from "collection count" to "real-world discovery readiness."
   - Make the hero look more like a camera/discovery preview, not a collection shelf.
   - Use copy like `Point. Discover. Remember.` or `Discover words from real things around you.`

### Explore Mode

1. **What currently feels like a vocabulary manager?**
   - The lower `Words nearby` section can read like a selectable word list if the discovery panel is not visually dominant enough.
   - The session counter emphasizes count over context.

2. **What currently feels disconnected from the new vision?**
   - Mock words are not visually tied to objects, places, or situations.
   - The current discoveries are floating chips without enough environmental context.
   - `Mock discovery field` is honest for development but not product-feeling copy.

3. **What currently feels like placeholder/demo UI?**
   - The label `Mock discovery field` is explicitly demo-like.
   - The center focus icon is abstract and does not yet feel like a camera preview.
   - Repeated chips in both the discovery field and the list can feel like test data.

4. **What currently supports the vision well?**
   - The interaction sequence is directionally right: source word -> tap -> translated/caught word.
   - Duplicate prevention is clear and gentle.
   - The counter and feedback reinforce the catch moment.

5. **What should be changed next?**
   - Rename `Mock discovery field` to `Discovery preview` or `Camera preview coming soon`.
   - Tie mock words to object-like visual zones, e.g. `chair` near a simple room object, `coffee` near a cafe card.
   - Add contextual microcopy: `These words would come from things in your camera view.`
   - Reduce the feeling of a generic chip list by making the discovery area the main interaction surface.

### Dictionary

1. **What currently feels like a vocabulary manager?**
   - Filter pills (`All`, `New`, `Learning`, `Known`) evoke a vocabulary database or study app.
   - Preview cards can imply manually curated vocabulary rather than words caught from real encounters.

2. **What currently feels disconnected from the new vision?**
   - Dictionary words do not show where/how they were discovered.
   - There is no notion of session, place, moment, or encounter.
   - `Collection shelf preview` is closer to collection-game language than real-world memory language.

3. **What currently feels like placeholder/demo UI?**
   - Preview cards are static examples.
   - The empty Dictionary and preview list coexist, which can feel contradictory.

4. **What currently supports the vision well?**
   - The empty state sends users to Explore.
   - Cards are friendly and not table-like.
   - Target word and source meaning hierarchy is readable.

5. **What should be changed next?**
   - Replace `Collection shelf preview` with a memory-oriented preview like `Words you catch will appear here`.
   - Avoid filters until real words exist.
   - When dictionary data becomes real, show context such as `Caught in Explore`, `Today`, `Cafe`, or `Travel session`.

### Navigation

1. **What currently feels like a vocabulary manager?**
   - Direct Home access to Dictionary is useful but can overemphasize storage.

2. **What currently feels disconnected from the new vision?**
   - Navigation does not yet communicate that Explore is camera-first in the long term.

3. **What currently feels like placeholder/demo UI?**
   - No navigation issue is strongly demo-like, but the screens behind navigation still contain mock cues.

4. **What currently supports the vision well?**
   - Simple Home -> Explore / Dictionary routing fits the MVP.
   - No premature Review tab or bottom navigation.

5. **What should be changed next?**
   - Keep navigation simple.
   - Make Explore visually and semantically dominant.
   - Treat Dictionary as supporting memory, not equal product identity.

### Empty States

1. **What currently feels like a vocabulary manager?**
   - `No words collected yet` is close to inventory language.

2. **What currently feels disconnected from the new vision?**
   - Empty states do not emphasize real-world discovery strongly enough.

3. **What currently feels like placeholder/demo UI?**
   - Dictionary preview cards below an empty state feel like sample/demo content.

4. **What currently supports the vision well?**
   - Empty states guide action.
   - They avoid generic `No data`.

5. **What should be changed next?**
   - Use `No real-world words caught yet.`
   - Add `Start exploring to catch words from things around you.`

### Component Naming

1. **What currently feels like a vocabulary manager?**
   - `Dictionary` is acceptable, but it should consistently mean memory of discovered words, not manual word storage.

2. **What currently feels disconnected from the new vision?**
   - `mockCatchWords` and `CatchWord` are fine for MVP, but future data should probably include context: source object, session, and discovery origin.

3. **What currently feels like placeholder/demo UI?**
   - Names containing `mock` are appropriate in data/code but should not leak into user-facing copy.

4. **What currently supports the vision well?**
   - `CatchWordChip` and `CollectionCounter` map to MVP interaction concepts.
   - Legacy vocabulary files are now isolated.

5. **What should be changed next?**
   - Keep code names like `CatchWord`, but plan a future `DiscoveryWord` or `CaughtWord` model with context fields.
   - Remove user-facing `Mock` copy.

### User Flow

1. **What currently feels like a vocabulary manager?**
   - Flow can still be read as Home -> choose words -> store/view words.

2. **What currently feels disconnected from the new vision?**
   - Flow lacks environmental context, even simulated.
   - There is no "camera-like" moment yet, only abstract discovery.

3. **What currently feels like placeholder/demo UI?**
   - Static mock chips do not strongly simulate camera-based detection.

4. **What currently supports the vision well?**
   - Discover/catch/remember skeleton exists.
   - Duplicate prevention and translation reveal are good MVP behaviors.

5. **What should be changed next?**
   - Make Explore feel like a camera-session preview before adding a real camera.
   - Add contextual mock scenes, not new features: room, cafe, street, market.

### Copywriting

1. **What currently feels like a vocabulary manager?**
   - `Dictionary`, `Words nearby`, and `Words collected this session` can sound inventory-like.

2. **What currently feels disconnected from the new vision?**
   - Copy rarely mentions real objects, camera, surroundings, or the world.

3. **What currently feels like placeholder/demo UI?**
   - `Mock discovery field`.

4. **What currently supports the vision well?**
   - `Start Exploring`, `caught`, and `tap to catch` are aligned.

5. **What should be changed next?**
   - Prefer `Words from things around you`, `Discovery preview`, `Point your camera at real objects soon`, and `Caught from this session`.

### Information Architecture

1. **What currently feels like a vocabulary manager?**
   - Dictionary has filter/status concepts before real discovery context exists.

2. **What currently feels disconnected from the new vision?**
   - No IA layer for sessions/context exists yet, though the documents clearly point toward session memory later.

3. **What currently feels like placeholder/demo UI?**
   - Dictionary preview content is not backed by caught words.

4. **What currently supports the vision well?**
   - `app/`, `screens/`, `models/`, `data/`, and `widgets/` give a clean base.
   - Legacy code is isolated.

5. **What should be changed next?**
   - Do not add new screens yet.
   - In future, evolve `CatchWord` into contextual caught-word data before building heavy dictionary features.

## Section 3: Vision Mismatches

1. **Collection still sometimes feels like the goal.**
   - The new docs clarify that collection exists because words were discovered in context.
   - Current UI can still be interpreted as "collect words from a list."

2. **Explore does not yet feel camera-adjacent enough.**
   - It has a discovery field, but not a strong sense of camera, object, or environment.

3. **Dictionary lacks real-world memory.**
   - It should eventually answer: "Where did I encounter this word?"
   - Current preview answers only: "What word is in the collection?"

4. **Mock content is too abstract.**
   - Words like chair/table/bottle are correct, but they need perceived surroundings.

5. **Some copy is outdated relative to the new vision.**
   - `Mock discovery field`, `Collection shelf preview`, and `Words collected this session` should be softened toward real-world discovery language.

6. **The Home hero does not yet communicate camera-based real-world vocabulary.**
   - It communicates brand and word chips, but not enough "point at the world."

7. **Status/filter UI risks study-app energy.**
   - `New`, `Learning`, `Known` are useful later, but early exposure can feel like language-course management.

8. **The current MVP has no simulated source context.**
   - Even before camera, mock detections should feel tied to a room, cafe, street, or market.

## Section 4: Top 10 UX Improvements

Ranked by impact and implementation effort.

| Rank | Improvement | Impact | Effort | Why |
|---:|---|---|---|---|
| 1 | Replace user-facing `Mock discovery field` with `Discovery preview` / `Camera preview coming soon` | High | Low | Removes demo language immediately. |
| 2 | Reframe Home copy toward real-world vocabulary: `Point. Discover. Remember.` | High | Low | Aligns first impression with new vision. |
| 3 | Change empty state copy to `No real-world words caught yet.` | High | Low | Stops sounding like generic vocabulary inventory. |
| 4 | Make Explore discovery panel visually imply a camera/session surface | High | Medium | The MVP must preview future camera discovery. |
| 5 | Reduce or hide Dictionary filter preview until real words exist | Medium | Low | Avoids vocabulary-manager/study-app feeling. |
| 6 | Add contextual labels to mock detections, e.g. `Room`, `Cafe`, `Street` | Medium | Low | Makes words feel encountered, not listed. |
| 7 | Make caught feedback mention source context: `Caught from nearby: kursi` | Medium | Low | Reinforces discovery origin. |
| 8 | Rename `Collection shelf preview` to `Word memory preview` or remove it | Medium | Low | Moves away from collection as self-purpose. |
| 9 | Add a short Home status about the current MVP: `Explore real-world words soon` | Medium | Low | Sets expectation without adding features. |
| 10 | Plan model evolution from `CatchWord` to contextual `CaughtWord` with session/source fields | High later | Medium | Needed before real Dictionary/storage work. |

## Section 5: The Single Most Important Next Milestone

The next milestone should be:

> Make Explore Mode feel like a real-world camera discovery preview, without implementing the camera.

This means the user should understand the future experience from the current MVP:

1. I am in an Explore session.
2. The app is showing words that would come from things around me.
3. I tap a detected word.
4. The translation unlocks.
5. The word is saved as something I encountered.

This is more important than adding session summary, persistence, review, or more dictionary features right now.

The current product risk is not missing functionality.

The current product risk is that the MVP still feels like selecting vocabulary from a styled list instead of discovering words from the real world.

Fix that perception first.
