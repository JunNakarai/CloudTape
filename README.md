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
