# Development

CloudTape is a personal SwiftUI iOS app generated with XcodeGen.

## Environment

- macOS with Xcode installed
- XcodeGen
- iOS 17.0 or later deployment target
- Optional: an Apple Developer account or personal Apple ID for device signing

Install XcodeGen:

```sh
brew install xcodegen
```

## XcodeGen

The checked-in source of truth is `project.yml`.

```sh
xcodegen generate
```

Regenerate `CloudTape.xcodeproj` after changing files, build settings, targets, or capabilities.

## Simulator Build

Use the local script:

```sh
./scripts/build-simulator.sh
```

Or run the commands directly:

```sh
xcodegen generate
xcodebuild \
  -project CloudTape.xcodeproj \
  -scheme CloudTape \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/cloudtape-derived \
  build
```

## Device Build

Device builds require signing and a connected trusted device:

```sh
xcodebuild \
  -project CloudTape.xcodeproj \
  -scheme CloudTape \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /private/tmp/cloudtape-device-derived \
  -allowProvisioningUpdates \
  build
```

Install with `xcrun devicectl` or from Xcode.

## DerivedData Location

Do not put DerivedData under iCloud Drive or other File Provider backed folders. Code signing can fail when generated bundles inherit File Provider attributes. Use `/private/tmp/cloudtape-derived` or another local non-iCloud path.

## Useful Commands

```sh
git status --short --branch
xcodegen generate
./scripts/build-simulator.sh
xcrun simctl install <simulator-id> /private/tmp/cloudtape-derived/Build/Products/Debug-iphonesimulator/CloudTape.app
xcrun simctl launch <simulator-id> io.github.junnakarai.cloudtape
```

## Troubleshooting

### Code Signing

Confirm the Xcode account is signed in, the team is selected, and automatic signing can create a development profile. For command line builds, use `-allowProvisioningUpdates`.

### iCloud Drive File Provider Attributes

If signing fails with unexpected bundle or file attribute errors, clean the build output and rebuild with `-derivedDataPath` outside iCloud Drive.

### Simulator File Selection

The simulator can open the Files picker, but it may not have the same iCloud Drive contents as the device. Use a local simulator folder for basic testing and verify iCloud behavior on device.

### Device Developer Mode

On a physical iPhone, enable Developer Mode, trust the Mac, and keep the device unlocked during install and launch. If CoreDevice resets the connection, retry the install once.

## Codex iOS Preview

CloudTape is configured for the Codex Build iOS Apps plugin with the
`cloudtape-ios` XcodeBuildMCP profile in `.xcodebuildmcp/config.yaml`.

Use the Build action or XcodeBuildMCP with:

- project: `CloudTape.xcodeproj`
- scheme: `CloudTape`
- configuration: `Debug`
- destination: `iPhone 17` / iOS 27.2 Simulator
- bundle ID: `io.github.junnakarai.cloudtape`

For a demo library and mini player, launch with:

```bash
-CloudTapeDemoFolder /Volumes/repos/CloudTape/docs/assets/demo-media -CloudTapeDemoAutoplay
```

For a deterministic empty library state, launch with:

```bash
-CloudTapeDemoEmptyLibrary
```

To mirror the active simulator into the Codex in-app browser:

```bash
./scripts/preview-simulator-browser.sh
```

Open the local URL printed by `serve-sim`, usually `http://localhost:3200`.

SwiftUI `#Preview` declarations are available for the main library surface,
empty state, track row, player bar, status row, and settings screen. The Codex
SwiftUI preview host currently requires a Swift Package target, so CloudTape's
app-target previews should be opened from Xcode Canvas; use the simulator mirror
above for Codex in-browser visual review.

After every UI change, follow the review checklist in `docs/ui-review-loop.md`.

## Library Sorting

See `docs/date-added-sort.md` for addition-date semantics, persistence, and tests.

## Canonical checkout

Use `/Volumes/repos/CloudTape` on `main` for development. Build-9 preservation and
addition-date sorting are integrated here; the old sibling checkouts are retired.
Use `/Volumes/repos/worktrees/` for future worktrees. Local review evidence lives
under `artifacts/local/` and generated build data under `build/`; neither creates
a sibling project folder or enters Git. See `releases/build9-preservation.md`
for the exact release-source tags and recovery instructions.

Consolidation verification on 2026-11-17: one local StoreKit catalog test,
all 45 unit tests, both sorting UI flows, and an unsigned generic-iOS Release
build passed. The app, tests, and build inputs match the sorting branch exactly;
the release tag still matches all 33 saved build-9 input hashes. Home, mini player,
settings, and empty-library screenshots were inspected; no new layout issue was
found (the existing artist/album subtitle uses normal ellipsis truncation).
Evidence is local-only in `build/consolidation-20261117/`, including test result
bundles, screenshots, relocation checksums, and logs. The Simulator was
`0E9E41B3-DCBC-4C9E-8F27-D1C9A5CD574D` on iOS 27.2. XcodeBuildMCP and node/npm/npx
were unavailable, so the prescribed `build_run_sim` and browser mirror were not
run; native xcodebuild/XCTest and exported Simulator screenshots were used.
This is local integration validation, not physical-device or distribution testing.
