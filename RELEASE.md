# CloudTape Release Notes

## Current Build Metadata

- Version: 1.0.2
- Build: 6
- Bundle ID: `io.github.junnakarai.cloudtape`
- Target device family: iPhone (`TARGETED_DEVICE_FAMILY = 1`)
- Minimum OS: iOS 17.0
- Export compliance: no non-exempt encryption (`ITSAppUsesNonExemptEncryption = false`)

## v1.0.2 Release Note Draft

CloudTape 1.0.2 is a maintenance update prepared from the latest committed source.

- Includes minor playback experience refinements.
- Handles completion updates for the optional support purchase.
- Maintains private playback with no accounts, analytics, advertising, or CloudTape server.

## v1.0.2 Tag And GitHub Release Commands

Do not run these until the final App Store listing URL and release notes are confirmed:

```sh
git status --short --branch
git tag -a v1.0.2 -m "CloudTape v1.0.2"
git push origin v1.0.2
gh release create v1.0.2 --title "CloudTape v1.0.2" --notes-file RELEASE.md
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
  -derivedDataPath /private/tmp/cloudtape-submission-derived \
  -archivePath /private/tmp/cloudtape-submission-archive/CloudTape.xcarchive \
  CODE_SIGNING_ALLOWED=NO \
  archive
```

The current update candidate must be archived with bundle ID `io.github.junnakarai.cloudtape`, version `1.0.2 (6)`, iPhone-only device family, iOS 17.0 minimum OS, and `ITSAppUsesNonExemptEncryption = false`.

For App Store Connect, create a newly signed Release archive, then validate and upload it. An Apple Distribution identity was available on this Mac on 2026-05-26. Do not reuse an older uploaded build, because its version/device-family metadata may differ from the current candidate.
