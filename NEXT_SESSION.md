# Next Session - Handoff (2026-06-12)

This file exists to prevent a repeat of the 2026-06-11 evening incident.

## Critical Recovery Context

The real app state with camera preview was temporarily lost from `main`.
The phone APK still showed the correct app because it had been built from a
dangling Git tree, not from the then-current `HEAD`.

Recovered and committed:

- `4451fa4 restore camera discovery app state`
- `6496ce3 harden caught word storage fallback`
- `231768f refresh home after secondary flows`

Current polish commits on top of the recovery:

- `19c9749 polish camera loading and session progress`
- `695fc24 refine dictionary word details`
- `e3b0d4f add fading review hint on home`
- `6f272e8 add clothing and workspace discoveries`
- `0cc1d99 test dictionary word review flow`
- `916568b polish catch feedback glow`
- `5b11cdc handle camera preview lifecycle`
- `132a496 improve session summary counts`
- `76bc591 show summary when ending explore session`

Do not roll back past `4451fa4` unless the user explicitly asks.

## Current Real App State

The actual product now includes:

- Home screen with cat hero, app icon assets, stats, categories
- Bottom navigation: Discover / Dictionary / Review
- Explore screen with real camera preview via `camera`
- Camera permission flow handled by the camera plugin
- Warm full-screen camera overlay
- Mock detections over the camera
- Tap-to-catch with translation reveal
- Catch celebration overlay
- Dictionary fed from caught words
- Review flow
- Storage in `CaughtWordStorage`

## Storage Warning

Persisted data matters.

Current storage writes:

- `catch_lingo_caught_words`
- `caughtIDs`
- `seenCount`
- `lastSeenAt`

Never remove or rename these keys without a migration.

`CaughtWordStorage` can now recover from older stable keys if the rich JSON key
is missing or corrupt. Keep that fallback.

## Before Any Work Tomorrow

Run:

```powershell
git status --short
git log --oneline --max-count=8
flutter analyze
flutter test
```

Confirm `HEAD` is at or after:

```text
4451fa4 restore camera discovery app state
```

Confirm these files exist:

```text
lib/screens/explore_screen.dart
lib/data/caught_word_storage.dart
lib/data/detection_service.dart
lib/widgets/catch_lingo_bottom_nav.dart
assets/images/welcome_cat.png
```

Confirm `pubspec.yaml` still contains:

```yaml
camera: ^0.12.0+1
```

## Do Not Repeat

Do not trust an old agent report over the actual code.

Do not delete `build/` or reset branches just to "clean up" unless the user asks.
If a cleanup is needed, explain exactly what generated files are being removed.

Do not use:

```powershell
git reset --hard
git clean -fdx
git read-tree --reset -u ...
```

unless the user explicitly approves that exact recovery operation.

Do not replace the camera app with the older mock-only Explore UI.

Do not remove bottom navigation, cat branding, camera preview, or app icon assets
as "cleanup".

Do not remove `.codex-remote-attachments` manually; those are user-provided
screenshots and should remain untracked.

## If The App On Phone Differs From HEAD

First suspect stale APK/build artifacts or a lost dangling Git tree.

Useful checks:

```powershell
Get-Item build\app\outputs\flutter-apk\app-debug.apk
git fsck --lost-found --no-reflogs
```

To search dangling trees for the camera UI:

```powershell
$trees = git fsck --lost-found --no-reflogs 2>$null |
  Where-Object { $_ -match '^dangling tree ' } |
  ForEach-Object { ($_ -split ' ')[2] }

foreach ($tree in $trees) {
  $hit = git grep -n -I -E "Good morning|Something here|Look around|Found it|English hidden|CameraPreview" $tree -- 2>$null
  if ($hit) {
    Write-Output "TREE $tree"
    $hit | Select-Object -First 20
  }
}
```

Inspect before restoring. Do not blindly apply a dangling tree.

## Sensible Next Work

Work in small commits.

Good next steps:

- Test the latest APK on a real Android device, especially camera pause/resume,
  ending Explore early, and Dictionary -> Review.
- Keep catch animation performant and warm.
- Add tests around Explore summary behavior if the widget harness can cover it
  without depending on camera hardware.
- Continue small UI passes on Home/Dictionary density and text fit.
- Build a fresh APK after meaningful camera work:

```powershell
flutter build apk --debug
```

Then verify the timestamp:

```powershell
Get-Item build\app\outputs\flutter-apk\app-debug.apk
```

## Current Checks

As of this handoff:

- `flutter analyze` passes
- `flutter test` passes with 10 tests
- `flutter build apk --debug` passes
