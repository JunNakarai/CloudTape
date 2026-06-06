# CloudTape UI Review Loop

Use this loop after every CloudTape UI change.

## Build and Mirror

1. Use the Build iOS Apps plugin with the `cloudtape-ios` profile.
2. Run `build_run_sim` for the demo-media state:

```text
-CloudTapeDemoFolder /Users/jun/Documents/CloudTape/docs/assets/demo-media -CloudTapeDemoAutoplay
```

3. Start the simulator mirror:

```sh
./scripts/preview-simulator-browser.sh
```

4. Open the printed `serve-sim` URL in the Codex in-app browser.

The Simulator mirror is the source of truth for Codex in-browser review. The
SwiftUI Preview browser host is out of scope while CloudTape remains an app
target in an `.xcodeproj` instead of a Swift Package target.

## Required Screens

Capture a screenshot and inspect layout for each screen:

- Home screen with `demo-media` loaded.
- Mini player after `-CloudTapeDemoAutoplay`.
- Settings screen from the library menu.
- Empty library screen after relaunching with:

```text
-CloudTapeDemoEmptyLibrary
```

## Visual Checks

Check every required screen for:

- Broken layout, clipped text, or overlapping controls.
- Excessive or inconsistent spacing.
- Buttons that are too small or too close to neighboring controls.
- Navigation bar and toolbar hit targets.
- Mini player readability, progress text, artwork, and play/pause button.
- Demo-media rows: artwork, title, subtitle, duration, and tap target height.
- Settings toggles, picker row, version row, and links.
- Empty library title, description, and action buttons.

## Diff Check

Before reporting completion:

```sh
git diff --check
git status --short --branch
git diff --stat
```

Report:

- Build/run status.
- Simulator UDID and mirror URL.
- Screenshot paths.
- Any visual issues found, or that none were found.
- Files changed by the UI task.
