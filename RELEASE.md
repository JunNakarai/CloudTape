# CloudTape 1.0.2 (9)

## Recorded distribution status

- Build 9 was uploaded on 2026-11-05 at 07:57:21 UTC and made available to the existing internal TestFlight group.
- On 2026-11-06 at 13:58:38 UTC, CloudTape 1.0.2 (9) and the existing Coffee Support consumable were submitted together. Apple confirmed two submitted items and, after reload, `Waiting for Review`.
- The existing automatic release after approval setting was retained. Submission is not approval or proof of public availability. This preservation task did not refresh App Store Connect or change its state.
- Live TestFlight product loading, sandbox purchase, cancellation, and repeat consumable purchase are not verified by local StoreKit tests.

## Build metadata

- Version: `1.0.2`
- Build: `9`
- Bundle ID: `io.github.junnakarai.cloudtape`
- Device family: iPhone only (`1`)
- Minimum OS: iOS `17.0`
- Export compliance: `ITSAppUsesNonExemptEncryption = false`
- Build tools used for the submitted archive: Xcode `27.2` (`27B52`), iOS SDK `27.2` (`24B8118`)

## Changes in this submission

- Persist track favorites across launches and show favorites first in the library and search results.
- Start random playback with one shuffled pass through favorites, followed by one shuffled pass through other tracks. Explicit track selection still plays that track first.
- Repair concurrent support-product loading and purchasing, purchase restrictions, cancellation, and error handling.

Customer-facing Japanese and English text is in [App Store release notes](docs/appstore/release-notes.md). The [IAP investigation](docs/appstore/iap-review-investigation.md) retains historical account, test, and submission observations; older entries are not current-state claims.

## Preserved local source and artifacts

The exact pre-cleanup working-tree snapshot is local tag `cloudtape-1.0.2-build9-source`, commit `5d1f033aef25066e4618611a7f5325d494de4634`. The original `main` working tree and index were left unchanged. No remote branch, tag, GitHub release, or App Store change was made by this task.

See [build 9 preservation and reproduction](docs/releases/build9-preservation.md) for source checks, artifact locations, commands, limitations, and verification results. Build 8 and build 7 are historical and must not be substituted for this submission. Future distribution requires a new build number and separate authorization.
