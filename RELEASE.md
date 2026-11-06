# CloudTape Release Notes


CloudTape 1.0.2 (9) was uploaded on 2026-11-05 and is Testing in the existing internal TestFlight group CloudTape - Jun (one tester). It contains favorites and the support-purchase repair. All 25 unit tests passed and the distribution signature was verified. Live sandbox purchase remains to be checked on TestFlight; no App Store submission or public release was performed. See docs/appstore/iap-review-investigation.md and the local iap-build9-release/delivery-receipt.json for evidence. Earlier build-8 notes below describe the prior distribution.

## Current Build Metadata

- Version: 1.0.2
- Build: 8
- Bundle ID: `io.github.junnakarai.cloudtape`
- Target device family: iPhone (`TARGETED_DEVICE_FAMILY = 1`)
- Minimum OS: iOS 17.0
- Export compliance: no non-exempt encryption (`ITSAppUsesNonExemptEncryption = false`)

## v1.0.2 Release Note Draft

- Mark individual tracks as favorites and keep the selection across launches.
- Show favorite tracks first in the library and search results.
- Start random playback with a shuffled pass through favorites, followed by a separately shuffled pass through other tracks.
- Favorite changes update the list immediately and apply to the next playback queue; an explicit track selection still plays that track first.

## Distribution Status (2026-11-05)

- Simulator build passed on Xcode 27.2 / iOS 27.2.
- All 14 unit tests passed. An isolated UI test passed favorite add/remove, relaunch persistence, list priority, favorite-first random start, and the four required screen captures.
- Build `1.0.2 (8)` was archived, exported with automatic distribution signing, and its IPA signature and identity were verified.
- App Store Connect accepted the upload and completed processing on 2026-11-05 at 03:51:21 UTC, confirmed by the Apple notification email for version 1.0.2, build 8.
- Apple confirmed this build can now be used for TestFlight testing or submitted for distribution.
- After explicit owner approval, internal TestFlight group `CloudTape - Jun` was created with manual build distribution, build `1.0.2 (8)` assigned, and exactly one owner tester invited. App Store Connect shows `Invited`; the Apple TestFlight invitation email was received on 2026-11-05 at 04:50:59 UTC. Invitation acceptance and installation are not yet verified.
- App Store version 1.0.2 remains Developer Rejected. Its editable draft now selects build 8 and contains the Japanese favorites release notes; both were verified after reload. Build 8 is not submitted for review. Only Japanese is registered for this version; no new localization was added.
- After the owner reported agreement acceptance, the Developer Program update warning cleared and the Free Apps Agreement is Active. The Paid Apps Agreement is still New (unsigned), and Business requests legal-entity information updates before signing it. Sandbox IAP testing requires an Active Paid Apps Agreement, so live purchase loading remains unverified.
- The prior build `7` must not be reused for this update.
- Check the existing optional support purchase in TestFlight before App Review resubmission; the historical IAP investigation remains in `docs/appstore/iap-review-investigation.md`.
- The Codex in-app browser mirror review remains incomplete; the four native Simulator screenshots were inspected.

On this Mac, command-line builds currently require `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer` because the global developer directory still points to Command Line Tools.

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

The current update candidate must be archived with bundle ID `io.github.junnakarai.cloudtape`, version `1.0.2 (8)`, iPhone-only device family, iOS 17.0 minimum OS, and `ITSAppUsesNonExemptEncryption = false`.

For App Store Connect, create a newly signed Release archive, then validate and upload it. Automatic distribution signing was verified on this Mac on 2026-11-05. Do not reuse an older uploaded build, because its version/device-family metadata may differ from the current candidate.
