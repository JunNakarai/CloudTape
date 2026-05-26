# CloudTape App Store Submission Plan

This document is the handoff for taking CloudTape 1.0.1 with its optional support purchase to App Store submission-ready.

It is intentionally ordered by dependency so the next person can work top-to-bottom without guessing what unlocks what.

## Current repo-backed status

Already prepared in the repository:
- App version: `1.0.1`
- Build number in source: `5`
- Bundle ID: `io.github.junnakarai.cloudtape`
- Minimum OS: iOS 17.0
- Device family: iPhone only (`TARGETED_DEVICE_FAMILY = 1`)
- Background audio declared in `Info.plist`
- No non-exempt encryption declared in `Info.plist` (`ITSAppUsesNonExemptEncryption = false`)
- No account system, ads, analytics SDK, or tracking found in reviewed source
- Review demo asset and review-note drafts exist under `docs/appstore/` and `docs/review-assets/`
- App Store metadata drafts exist for `ja-JP` and `en-US`
- Final six screenshots have been generated and visually reviewed at `1242 x 2688` for the accepted iPhone 6.5-inch group
- App Store Connect currently has `1.0.1 (4)` submitted without an In-App Purchase item; the StoreKit completion update requires build `5`.

Still requires App Store Connect/release work:
- Create and complete the first In-App Purchase record.
- Add IAP review metadata and link it with the 1.0.1 app-version submission.
- Upload and select signed build `1.0.1 (5)`.
- Replace the current app-only review submission with the app plus IAP submission.

## Submission order

### 1. Freeze the submission content

Frozen decisions for this candidate:
- Keep the first-launch empty-state UI copy in the current source.
- Use the review shortcut button label `サンプル音源を試す`.
- Ship the optional support IAP `cloudtape.coffee.small` in 1.0.1.
- Do not make further UI string or layout changes after final screenshot capture.

Why first:
- Screenshots, metadata, and review notes should match the shipped UI exactly.

## 2. Finalize screenshots

Repo status:
- Existing captures in `docs/screenshots/`:
  - `iphone-01-library.png`
  - `iphone-02-mini-player.png`
  - `iphone-03-full-player.png`
  - `iphone-04-search.png`
  - `iphone-05-empty-state.png`
  - `iphone-06-dark-mode.png`
- Screenshot strategy notes live in `docs/screenshot-plan.md`.

Final selected order:
   1. Library
   2. Mini player
   3. Full player / shuffle playback
   4. Search
   5. First-launch folder / empty guidance state
   6. Dark Mode playback

Remaining App Store Connect tasks:
1. Upload the six selected `1242 x 2688` portrait files as the iPhone 6.5-inch set.
   - Apple permits one to ten screenshots and accepts `1242 x 2688` for the iPhone 6.5-inch display group.
   - Apple states the 6.5-inch set is required when a 6.9-inch set is not provided.
   - Specification verified 2026-05-25: https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications
2. Do not prepare iPad screenshots unless device support changes.

Verified locally:
- The selected screenshots contain only synthetic `CloudTape Demo Studio` media or the in-app empty state.
- No personal filenames, private folder names, or third-party artwork are shown.

Blocking rule:
- Do not upload the app for review until screenshot requirements are fully satisfied for the accepted device classes.

## 3. Complete App Store metadata in App Store Connect

Repo sources:
- `docs/appstore/metadata-ja-JP.md`
- `docs/appstore/metadata-en-US.md`
- `docs/appstore/release-notes.md`

Manual tasks:
1. Update the 1.0.1 app version record.
2. Enter localized metadata for at least:
   - Japanese (`ja-JP`)
   - English (`en-US`)
3. Paste the release notes into the version's “What’s New”.
4. Set category and age rating.
   - Expected: Music primary, 4+
5. Confirm URLs:
   - Support URL
   - Privacy Policy URL
   - Marketing URL
6. Ignore the public App Store URL placeholder for now.
   - That URL is only known after the listing exists publicly.
   - It is not a blocker for submission.

Recommended product decision:
- Treat the missing public App Store URL as a post-launch documentation follow-up, not a pre-submission blocker.

## 4. Set up the in-app purchase in App Store Connect

Repo-backed IAP details:
- Product ID: `cloudtape.coffee.small`
- Type: Consumable
- Intended Japan price: `¥160`
- Reference name: `CloudTape Coffee Support`
- ja-JP display name: `☕ コーヒー1杯分で応援`
- ja-JP description: `CloudTape の開発継続を応援できます。`
- en-US display name: `Support CloudTape with a coffee`
- en-US description: `Support continued development of CloudTape.`

Manual tasks:
1. Open App Store Connect > CloudTape > In-App Purchases.
2. Create a Consumable product with Product ID `cloudtape.coffee.small` if it does not already exist.
3. Add at least `ja-JP` and `en-US` localizations using the repo strings above.
4. Set pricing tier.
5. Add the required review screenshot for the IAP if App Store Connect requests one.
   - Safest capture: the in-app support purchase UI showing the product title and price.
6. Attach review notes clarifying:
   - It is optional.
   - It does not unlock features.
   - It does not change app behavior.
7. Submit the first IAP together with app version 1.0.1, as required for an app's first IAP.

Dependency note:
- If the IAP is not fully configured, submission can stall even if the app binary is ready.

## 5. Privacy and compliance questionnaire

Repo-backed expectation:
- No privacy permission usage descriptions found.
- No analytics, ads, account system, or tracking found in reviewed code.
- Background audio is the only notable capability already identified.
- The candidate build declares `ITSAppUsesNonExemptEncryption = false`; no custom encryption usage was found in reviewed source.

Manual App Store Connect tasks:
1. Complete the App Privacy questionnaire.
   - Expected outcome: likely no data collected by the developer/app itself.
2. Confirm export compliance if App Store Connect prompts despite the candidate build declaration.
3. Complete content rights questions accurately.
   - CloudTape plays user-selected files; it does not provide licensed catalog content.
4. Complete advertising identifier / tracking questions accurately.
   - Expected answer: no tracking / no ads / no third-party analytics.

## 6. Create the signed archive and upload the build

Already established:
- The previously signed and uploaded `1.0.1 (4)` proved App Store upload signing is available on this Mac.
- Build `5` is required after the StoreKit completion handling improvement.

Remaining:
1. Verify the Release archive metadata for build `1.0.1 (5)`.
2. Archive and upload a signed build `5`.
3. Wait for App Store Connect processing to finish.
4. Attach processed build `5` to version `1.0.1`.

Critical checks during Organizer validation:
- Bundle ID is still `io.github.junnakarai.cloudtape`
- Version/build shown by Organizer match `1.0.1 (5)`
- Device support still resolves as iPhone-only
- No unexpected entitlements or capabilities appear

Dependency note:
- If device support appears wrong in App Store Connect, do not reuse an older build. Upload a newly signed archive from the current source.

## 7. Enter App Review notes

Repo source:
- `docs/appstore/app-review-notes.md`

Manual tasks:
1. Paste the review notes into the App Review Information field.
2. Ensure the shipped UI labels still match the note exactly.
3. If the sample-audio shortcut remains in the build, explicitly mention:
   - Open app
   - Tap `サンプル音源を試す`
   - Verify playback / mini player / background audio / Lock Screen controls
4. If the review team also needs the normal flow, mention:
   - Tap `フォルダを選ぶ`
   - Choose a folder from iCloud Drive or Files containing supported audio files

## 8. Final pre-submit manual QA

Minimum human regression pass:
- First launch with no folder selected
- `サンプル音源を試す` works
- Folder selection from iCloud Drive works
- Relaunch restores prior folder bookmark
- Search works with Japanese and English metadata
- Shuffle playback works
- Mini player expands and collapses correctly
- Full player works in Light and Dark Mode
- Background playback works
- Lock Screen / Control Center controls work
- Offline/already-downloaded file case behaves correctly
- Unavailable iCloud-file error state is understandable

If any UI text changes during QA:
- Re-check screenshots
- Re-check metadata wording consistency
- Re-check review notes

## 9. Submit for review

Submit only after all of the following are true:
- Screenshots uploaded and accepted
- Metadata filled
- Privacy questionnaire completed
- IAP configured and linked as needed
- Signed build processed and attached
- Review notes entered
- Manual QA passed

## Remaining blockers, in true dependency order

1. Keep the already entered 1.0.1 metadata and screenshots attached
2. IAP creation/completion in App Store Connect
3. Privacy/compliance questionnaire completion in App Store Connect
4. Signed build 5 archive creation, validation, and upload
5. Build processing + attaching build 5 to version 1.0.1
6. Replace the app-only submission with version 1.0.1 plus the IAP

## Recommended next human actions

If only one focused work session is available, do this exact sequence:
1. Create/finish the IAP in App Store Connect.
2. Confirm the existing 1.0.1 metadata and screenshots remain attached.
3. Complete the privacy questionnaire.
4. Archive and upload signed build 5.
5. Attach build 5, paste updated review notes, and submit the app version together with the IAP.
