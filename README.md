# CloudTape

CloudTape is a minimal iOS music player for shuffling owned audio files stored in iCloud Drive or the Files app.

It is built as a quiet personal music space: no ads, no tracking, no accounts, and no recommendation algorithms.

## Features

- Choose an iCloud Drive or Files folder
- Scan supported audio files
- Read track metadata and artwork
- Start random playback without selecting a track first
- Background audio playback
- Lock screen and Control Center transport controls
- Floating mini player
- Expanded Now Playing view

## Tech Stack

- SwiftUI
- AVFoundation / AVPlayer
- MediaPlayer
- XcodeGen

## Project Layout

```text
CloudTape/
├── App/
├── Assets.xcassets/
├── Features/
│   ├── Library/
│   └── Player/
├── Models/
├── Services/
├── SupportingFiles/
└── Views/
```

## Setup

Install XcodeGen:

```sh
brew install xcodegen
```

Generate the Xcode project:

```sh
xcodegen generate
```

Open the project:

```sh
open CloudTape.xcodeproj
```

## Build

Simulator build:

```sh
./scripts/build-simulator.sh
```

The script uses `/private/tmp/cloudtape-derived` for DerivedData so build output stays outside iCloud Drive.

## Installing on iPhone

For physical device installs:

- Sign in to Xcode with an Apple ID
- Keep automatic signing enabled
- Select your development team in Xcode for local device installs
- Enable Developer Mode on the iPhone
- Trust the Mac and keep the device unlocked during install

Command line device builds can use:

```sh
xcodebuild \
  -project CloudTape.xcodeproj \
  -scheme CloudTape \
  -destination 'generic/platform=iOS' \
  -derivedDataPath /private/tmp/cloudtape-device-derived \
  -allowProvisioningUpdates \
  build
```

## iCloud Drive Notes

CloudTape stores access to the selected folder with a security-scoped bookmark. If access fails after moving folders or changing iCloud state, choose the folder again.

iCloud Drive files that are not downloaded locally may need time to become playable. CloudTape requests downloads when scanning, but device-side behavior can vary with network and iCloud state.

## Release Preparation

CloudTape is being prepared for v1.0 TestFlight and App Store release.

Release materials live in:

- `docs/privacy-policy.md`
- `docs/app-store-metadata.md`
- `docs/release-checklist.md`
- `docs/screenshot-plan.md`

### App Store Screenshots

Use the local screenshot script to build the Debug simulator app, install it on a 6.5-inch App Store-compatible simulator, seed screenshot-only demo media, and capture the five required states into `docs/screenshots/`.

Default simulator:

```text
CloudTape App Store 6.5 iPhone 11 Pro Max
```

The simulator is created from the `iPhone 11 Pro Max` device type when needed. That device captures at `1242 x 2688`, which is one of the accepted iPhone 6.5-inch App Store Connect screenshot sizes.

Run from the repository root:

```sh
./scripts/capture-screenshots.sh
```

The script launches the app with Debug-only demo arguments, then captures:

```sh
xcrun simctl io booted screenshot docs/screenshots/iphone-01-library.png
xcrun simctl io booted screenshot docs/screenshots/iphone-02-mini-player.png
xcrun simctl io booted screenshot docs/screenshots/iphone-03-full-player.png
xcrun simctl io booted screenshot docs/screenshots/iphone-04-search.png
xcrun simctl io booted screenshot docs/screenshots/iphone-05-folder-state.png
```

Check the generated sizes:

```sh
sips -g pixelWidth -g pixelHeight docs/screenshots/*.png
```

Upload these files to App Store Connect:

- `docs/screenshots/iphone-01-library.png`
- `docs/screenshots/iphone-02-mini-player.png`
- `docs/screenshots/iphone-03-full-player.png`
- `docs/screenshots/iphone-04-search.png`
- `docs/screenshots/iphone-05-folder-state.png`

## GitHub Pages Site

The public CloudTape introduction site is a static HTML/CSS site in `docs/`.
It has no build step and no external dependencies.

Pages files:

- `docs/index.html`
- `docs/privacy-policy.html`
- `docs/support.html`
- `docs/styles.css`
- `docs/assets/`
- `docs/.nojekyll`

To enable GitHub Pages:

1. Open the repository on GitHub.
2. Go to Settings > Pages.
3. Set Source to "Deploy from a branch".
4. Select the `main` branch and the `/docs` folder.
5. Save the settings.

After GitHub Pages finishes publishing, the site will be available at:

```text
https://junnakarai.github.io/CloudTape/
```
