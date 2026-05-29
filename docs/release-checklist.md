# CloudTape Release Checklist

This file is the quick release gate.

For the full handoff plan with App Store Connect sequencing, manual steps, and dependency order, use:
- `docs/appstore/submission-plan.md`

For the Guideline 2.1(b) IAP rejection investigation and resubmission checklist, use:
- `docs/appstore/iap-review-investigation.md`

## Current repo-backed status

- [x] Version in source is `1.0.2`
- [x] Build in source is `6`
- [x] Bundle ID is `io.github.junnakarai.cloudtape`
- [x] Minimum OS is iOS 17.0
- [x] Device family is iPhone-only (`TARGETED_DEVICE_FAMILY = 1`)
- [x] Background audio capability is declared in `Info.plist`
- [x] Export compliance key declares no non-exempt encryption (`ITSAppUsesNonExemptEncryption = false`)
- [x] App Store metadata drafts exist in `docs/appstore/`
- [x] Review-note draft exists in `docs/appstore/app-review-notes.md`
- [x] Review demo asset exists in `docs/review-assets/`
- [x] Local simulator build passed
- [x] Local unsigned Release archive passes with effective metadata `1.0.2 (6)`, iPhone-only, iOS 17.0
- [x] No account system, ads, analytics SDK, or tracking found in reviewed source
- [x] No obvious privacy-permission usage strings found for the current feature set

## Submission blockers still requiring human work

### Submission candidate decisions
- [x] Keep the shipped first-launch empty-state copy
- [x] Use the App Review shortcut label `サンプル音源を試す`
- [x] Include the optional support IAP `cloudtape.coffee.small` in 1.0.2

### Screenshots
- [x] Finalize screenshot selection and order
- [x] Generate and visually inspect the final `1242 x 2688` iPhone 6.5-inch screenshot set
- [ ] App Store screenshots are attached to the 1.0.2 version

Current repo screenshot candidates:
- `docs/screenshots/iphone-01-library.png`
- `docs/screenshots/iphone-02-mini-player.png`
- `docs/screenshots/iphone-03-full-player.png`
- `docs/screenshots/iphone-04-search.png`
- `docs/screenshots/iphone-05-empty-state.png`
- `docs/screenshots/iphone-06-dark-mode.png`

Apple App Store Connect screenshot specifications checked on 2026-05-25:
- One to ten screenshots are accepted.
- `1242 x 2688` portrait images are accepted for the iPhone 6.5-inch display group.
- The 6.5-inch set is required only when a 6.9-inch set is not provided; this submission uses the accepted 6.5-inch set.
- Source: https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications

### App Store Connect metadata
- [ ] Enter localized metadata from `docs/appstore/metadata-ja-JP.md`
- [ ] Enter localized metadata from `docs/appstore/metadata-en-US.md`
- [ ] Enter release notes from `docs/appstore/release-notes.md`
- [ ] Confirm category, age rating, and URLs

### In-app purchase
- [ ] Create or verify consumable IAP `cloudtape.coffee.small`
- [ ] Add required localizations, pricing, and review screenshot/notes
- [ ] Link/submit the IAP with app version 1.0.2 as the first IAP submission
- [x] Verify successful support purchase and transaction finish in StoreKit Configuration
- [x] Verify user cancellation returns without an error state in StoreKit Configuration
- [x] Verify Ask to Buy pending state and approved completion through `Transaction.updates`
- [x] Verify unavailable-product loading displays retry and error UI
- [x] Surface product-fetch, purchase, cancellation, and transaction-verification states in the support screen
- [ ] Verify simulated purchase failure path in StoreKit Configuration
- [ ] Verify network-offline product loading behavior

### Privacy / compliance
- [ ] Complete App Privacy questionnaire in App Store Connect
- [x] Declare no non-exempt encryption in the candidate build
- [ ] Confirm export compliance answer in App Store Connect if prompted
- [ ] Confirm no tracking / no ads / no analytics answers remain accurate

### Signed build and upload
- [x] Verify a local unsigned archive from current source for `1.0.2 (6)`
- [x] Apple Distribution signing is available for the previously uploaded 1.0.1 build
- [x] Create signed archive for `1.0.2 (6)`
- [x] Validate archive
- [x] Upload build `1.0.2 (6)` to App Store Connect
- [x] Wait for build processing
- [x] Attach processed build 6 to version 1.0.2

### App Review and final QA
- [ ] Paste review notes from `docs/appstore/app-review-notes.md`
- [ ] Confirm review notes match shipped UI labels exactly
- [ ] Run final manual QA on folder selection, playback, search, background audio, and review shortcut
- [ ] Submit for review

## Quick manual QA pass

- [ ] First launch with no folder selected
- [ ] `サンプル音源を試す` works
- [ ] Choose folder from iCloud Drive / Files
- [ ] Relaunch restores folder bookmark
- [ ] Search works with Japanese and English metadata
- [ ] Shuffle playback works
- [ ] Mini player expand/collapse works
- [ ] Lock Screen / Control Center controls work
- [ ] Light Mode and Dark Mode look correct
- [ ] iCloud-not-downloaded / unavailable-file messaging is clear

## Notes

- Missing public App Store URL is not a submission blocker; add it to docs after launch.
- Do not use an older uploaded build if device-family metadata looks wrong; upload a newly signed archive from the current source.
- Do not prepare iPad screenshots unless device support changes from iPhone-only.

## Commands already run during release prep

```sh
git status --short --branch
./scripts/capture-screenshots.sh
security find-identity -v -p codesigning
xcodebuild -project CloudTape.xcodeproj -scheme CloudTape -configuration Release -destination 'generic/platform=iOS' -derivedDataPath /private/tmp/cloudtape-submission-derived -archivePath /private/tmp/cloudtape-submission-archive/CloudTape.xcarchive CODE_SIGNING_ALLOWED=NO archive
plutil -p /private/tmp/cloudtape-submission-archive/CloudTape.xcarchive/Info.plist
```
