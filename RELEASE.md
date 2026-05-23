# CloudTape Release Notes

## Current Build Metadata

- Version: 1.0.0
- Build: 1
- Bundle ID: `io.github.junnakarai.cloudtape`
- Target device family: iPhone (`TARGETED_DEVICE_FAMILY = 1`)
- Minimum OS: iOS 17.0

## v1.0.0 Release Note Draft

CloudTape 1.0.0 is the first public release.

- Play audio files stored in iCloud Drive or the Files app.
- Choose a folder and start shuffle playback quickly.
- Browse/search the selected library.
- Continue playback in the background.
- Control playback from the Lock Screen, Control Center, and headphones.
- Use a focused mini player and expanded Now Playing screen.
- Keep listening private with no accounts, analytics, advertising, or CloudTape server.

## v1.0.0 Tag And GitHub Release Commands

Do not run these until the final App Store listing URL and release notes are confirmed:

```sh
git status --short --branch
git tag -a v1.0.0 -m "CloudTape v1.0.0"
git push origin v1.0.0
gh release create v1.0.0 --title "CloudTape v1.0.0" --notes-file RELEASE.md
```

## App Store Connect Device Family

CloudTape is currently prepared as an iPhone-only app.

- `TARGETED_DEVICE_FAMILY` must be `1`.
- Do not add iPad screenshots unless iPad support is intentionally enabled later.
- The iPad-specific orientation key `UISupportedInterfaceOrientations~ipad` is intentionally omitted.

After changing device-family support, upload a new archive to App Store Connect so the supported-device metadata is recalculated for the new build.

Local unsigned archive verification command:

```sh
xcodebuild \
  -project CloudTape.xcodeproj \
  -scheme CloudTape \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -archivePath /private/tmp/cloudtape-iphone-only-archives/CloudTape.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  archive
```

For App Store Connect, create or distribute a newly signed Release archive from Xcode Organizer using the existing Apple Distribution setup, then upload that new build. Do not reuse an older uploaded build, because its device-family metadata can still require iPad screenshots.
