# Build 9 preservation and reproduction

## Stable source checkpoints

- App: CloudTape `1.0.2 (9)`.
- Exact working-tree source snapshot: `5d1f033aef25066e4618611a7f5325d494de4634`.
- Local annotated tag: `cloudtape-1.0.2-build9-source`.
- Preservation branch: `preserve/cloudtape-build9-20261106`.
- Worktree: `/Volumes/repos/CloudTape-build9-preserved`.
- Original repository: `/Volumes/repos/CloudTape`, branch `main` at `df38ee1122a276484314ee12af1a7e44531460c1`.

The source snapshot includes all 10 modified and 3 untracked files from the original working tree. The later preservation commit only adds documentation and source-verification tooling. Original source bytes, index, and working-tree status were checked against a baseline; the original checkout was not cleaned, reset, staged, or switched.

For new feature work, create a separate worktree from the source tag. Do not edit this preservation worktree or reuse build 9 for a new upload.

```sh
git -C /Volumes/repos/CloudTape worktree add -b feature/my-next-change /Volumes/repos/CloudTape-next cloudtape-1.0.2-build9-source
```

## Link to the uploaded build

The upload-time `source-manifest.json`, recorded 2026-11-05 at 07:56:42 UTC, contains 13 file hashes. All 10 code, test, and project entries match the preserved source byte-for-byte, as does the customer release-note file. Only `RELEASE.md` and `docs/appstore/iap-review-investigation.md` differ, due to post-upload status records. Their pre-cleanup state remains in the source snapshot.

The existing IPA matches the SHA-256 recorded in the delivery receipt:

`909295d5061a6282b8165e7bf0aaaec154d6f387343f6c07e0132703d4a9069d`

The IPA's signature passes `codesign --verify --deep --strict`. Its metadata confirms version `1.0.2`, build `9`, bundle ID `io.github.junnakarai.cloudtape`, iPhone-only family, iOS 17.0 minimum, and no non-exempt encryption. The original archive executable and dSYM share UUID `E14C6562-A630-3407-9D09-7C4BE74D6925` (arm64). The original archive was unsigned; the exported IPA is distribution-signed. Both are preserved.

The upload-time manifest did not hash every repository file or record a commit, so it does not prove every unchanged file's historical bytes. The complete build-input hashes in `build9-source-manifest.json` were captured during this preservation task. They establish a stable future baseline, not additional historical proof. Rebuilding also does not reproduce Apple's processed distribution binary or the signed IPA bit-for-bit.

## Durable local recovery package

`/Users/jun/Documents/Codex/2026-11-06/cloudtape-build9-preservation/`

This contains the original release receipts and logs, signed IPA, original archive and dSYM, original test result bundle, baseline hashes and patch, source-comparison evidence, a portable Git bundle, fresh verification logs, and checksums. It does not depend on the old `/tmp` archive or test results surviving a reboot. Keep the package private and copy it to a user-chosen backup location if off-device recovery is required; no off-device copy or upload was made here.

Recovery from the Git bundle:

```sh
git clone --branch preserve/cloudtape-build9-20261106 /Users/jun/Documents/Codex/2026-11-06/cloudtape-build9-preservation/CloudTape-build9.bundle CloudTape-recovered
cd CloudTape-recovered
python3 scripts/verify-build9-source.py
```

## Reproduce locally without distribution

Use Xcode 27.2 (`27B52`) and the committed project. On this Mac set `DEVELOPER_DIR` because the global developer directory points to Command Line Tools. Source verification intentionally fails after source changes for a new feature.

```sh
export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
python3 scripts/verify-build9-source.py
xcrun simctl list devices available
# Replace DEVICE_ID with a compatible iOS Simulator identifier.
# Initialize the local StoreKit test catalog before running the whole suite.
xcodebuild -project CloudTape.xcodeproj -scheme CloudTape \
  -destination 'platform=iOS Simulator,id=DEVICE_ID' \
  -derivedDataPath /private/tmp/cloudtape-build9-check \
  -parallel-testing-enabled NO -test-timeouts-enabled YES \
  -maximum-test-execution-time-allowance 60 \
  -only-testing:CloudTapeTests/SupportDevelopmentStoreTests/testLocalConfigurationCatalog test
xcodebuild -project CloudTape.xcodeproj -scheme CloudTape \
  -destination 'platform=iOS Simulator,id=DEVICE_ID' \
  -derivedDataPath /private/tmp/cloudtape-build9-check \
  -parallel-testing-enabled NO -test-timeouts-enabled YES \
  -maximum-test-execution-time-allowance 60 test
xcodebuild -project CloudTape.xcodeproj -scheme CloudTape \
  -configuration Release -destination 'generic/platform=iOS' \
  -derivedDataPath /private/tmp/cloudtape-build9-release-check \
  CODE_SIGNING_ALLOWED=NO build
```

The tests use the local `SKTestSession` catalog, assert `.xcode` transaction environment, and incur no real charges. Do not add upload, export, account, or provisioning flags to these reproduction checks.

XcodeGen 2.46.0 regenerates all source/configuration inputs, but its `.pbxproj` serialization differs from the saved Xcode-edited project by two non-build-setting lines: it removes `compatibilityVersion = "Xcode 14.0"` and adds `productRefGroup`. The exact submitted project was restored in this preservation worktree before testing. The generator diff and regenerated file are saved in the recovery package. Do not call generation byte-for-byte identical.

## Verification

Verification on 2026-11-06 used Xcode 27.2 (`27B52`) and a dedicated iPhone 18 Pro / iOS 27.2 Simulator (`4C99DF74-F9FC-47E9-AE8F-353ACFB85D5E`):

- All 33 preserved build-input hashes pass. The verifier's clean, changed, missing, added Swift source, added resource, and restored-fixture checks pass.
- Unsigned Release build for generic iOS: passed. Its version, build, bundle identifier, minimum OS, device family, and encryption flag match build 9.
- Final full unit-test run: 25 passed, 0 failed, 0 skipped (`build9-retest-final.xcresult`). The two focused transaction tests also passed immediately before it.
- Original upload-time result bundle: independently read as 25 passed, 0 failed, 0 skipped.
- Exact saved IPA hash and code signature: passed. IPA, archive, and dSYM executable UUIDs match.
- `git diff --check`: passed.

The first run on the new Simulator stalled at Ask to Buy with an unexpected Apple Account sign-in prompt. It was interrupted without entering credentials or confirming a purchase. A focused `.xcode` local-catalog test passed. The next full run completed with 23 passed and two transaction-finish assertion failures, including a StoreKit `XcodeTest` internal error. Both failed tests then passed in isolation and the complete suite passed unchanged. These earlier logs and result bundles are retained; the successful final run does not erase this Simulator/StoreKit test instability or establish its exact cause. If an Apple Account prompt appears, stop the run rather than signing in. Do not weaken tests or alter the submitted code to make this archival verification pass.

This preservation task does not change the app UI and does not claim a new browser-mirror or live TestFlight purchase validation. The dedicated Simulator is shut down after verification.
