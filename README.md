<p align="center">
  <img src="docs/assets/app-icon.png" alt="CloudTape app icon" width="128">
</p>

# CloudTape

CloudTape is a minimal iOS music player for playing audio files you already keep in iCloud Drive or the Files app.

It is built as a quiet personal music space: no ads, no tracking, no accounts, no subscriptions, and no recommendation feed.

## Features

- Choose a folder from iCloud Drive or the Files app
- Scan supported audio files and read track metadata/artwork
- Start shuffle playback quickly
- Browse and search the selected library
- Continue playback in the background
- Use Lock Screen, Control Center, and headphone transport controls
- Switch between a compact mini player and an expanded Now Playing view
- Restore folder access with a local security-scoped bookmark

## Screenshots

Screenshots for the public page and App Store materials are kept in:

- `docs/screenshots/`

App Store screenshot capture notes are in `docs/screenshot-plan.md`.

## App Store

- App Store: https://apps.apple.com/us/app/cloudtape/id6770509865
- Support: https://junnakarai.github.io/CloudTape/support.html
- Privacy Policy: https://junnakarai.github.io/CloudTape/privacy-policy.html

## Requirements

- iPhone app
- iOS 17.0 or later
- Xcode for local builds
- XcodeGen for regenerating `CloudTape.xcodeproj`

## Development Background

CloudTape was made for people who already manage their own music files in iCloud Drive and want a simple native player that stays out of the way. The project intentionally avoids accounts, analytics, advertising, backend services, and streaming-service features.

## Development

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

Run a simulator build:

```sh
./scripts/build-simulator.sh
```

The build script uses `/private/tmp/cloudtape-derived` for DerivedData so build output stays outside iCloud Drive.

More development notes are in `docs/DEVELOPMENT.md`.

## In-App Purchase

CloudTape includes an optional consumable support item. It does not unlock additional features.

- Product ID: `cloudtape.coffee.small`
- Type: Consumable
- Intended Japan price: `¥160`
- Display name: `☕ コーヒー1杯分で応援`
- StoreKit test configuration: `Configuration/CloudTape.storekit`

Before App Store distribution, create the same Consumable product in App Store Connect:

1. Open App Store Connect > Apps > CloudTape > In-App Purchases.
2. Create a Consumable product with Product ID `cloudtape.coffee.small`.
3. Set the display name to `☕ コーヒー1杯分で応援`.
4. Set the description to `CloudTape の開発継続を応援できます。`.
5. Configure pricing, localization, screenshot/review notes as required, then submit it with the app version.

## Release Materials

- `docs/app-store-metadata.md`
- `docs/appstore/`
- `docs/privacy-policy.md`
- `docs/privacy-policy.html`
- `docs/support.html`
- `docs/release-checklist.md`
- `RELEASE.md`

## GitHub Pages

The public CloudTape site is a static HTML/CSS site in `docs/`. It has no build step and no external dependencies.

To enable GitHub Pages:

1. Open the repository on GitHub.
2. Go to Settings > Pages.
3. Set Source to "Deploy from a branch".
4. Select the `main` branch and the `/docs` folder.
5. Save the settings.

Expected public URLs:

- https://junnakarai.github.io/CloudTape/
- https://junnakarai.github.io/CloudTape/privacy-policy.html
- https://junnakarai.github.io/CloudTape/support.html

## License

MIT License. See `LICENSE`.
