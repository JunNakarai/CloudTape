# CloudTape IAP Review Investigation


## App Review submission completed after age-question approval

The user explicitly approved No for Social Media and Social Media unavailable to under-13s. Those two previously unanswered questions were saved; all other existing answers and the calculated 4+ rating were retained. No new agreement or account permissions were changed.

CloudTape 1.0.2 (9) and CloudTape Coffee Support were included in the same submission. Apple confirmed “2 items submitted”; after reloading the app version page, its status was Waiting for Review. The existing automatic release after approval setting remains selected. This is a review submission, not completed review or public release. A proposed review-note append was rejected by automatic approval review and was not transmitted; the existing review note was retained.

Evidence: /Users/jun/Documents/Codex/2026-11-02/task-4/iap-build9-release/app-review-submission-receipt.json and app-review-submitted-reloaded.json. Earlier pending/submission-blocked notes below are historical. Brave Apple Events JavaScript was verified OFF.


## 2026-11-05: repaired build 9 distributed to the existing internal tester

After explicit user approval, CloudTape 1.0.2 (9), including favorites and the support-purchase handling repair, was archived, automatically signed with the existing Apple Distribution team, and uploaded successfully at 07:57:21 UTC. The final original repository passed all 25 unit tests before export; signed IPA verification passed. No old certificates were revoked or keys imported.

Apple processing completed. Only build 9 was added to the existing internal group CloudTape - Jun, whose sole tester is the already authorized account jun.nakarai@icloud.com. A fresh page reload confirmed one tester, two builds (8 and 9), and build 9 Testing. No new tester or group was created. This confirms availability to the tester, not installation or successful sandbox purchase on their phone. New-build distribution is no longer pending approval; the earlier pending statements below are historical.

Remaining: install build 9 in TestFlight, verify live product/price loading and a sandbox purchase, cancellation, and repeated consumable purchase. Local StoreKit success does not prove live configuration. App Store review submission and public release were not performed. No real purchase, agreement consent, or permission change occurred. Brave window bounds were restored and Apple Events JavaScript was verified OFF.

Evidence: /Users/jun/Documents/Codex/2026-11-02/task-4/iap-build9-release/delivery-receipt.json, testflight-group-reloaded.json, export/CloudTape.ipa, source-manifest.json, and copied build/test/export/upload logs. Archive: /tmp/cloudtape-iap-build9.xcarchive. Test results: /tmp/cloudtape-iap-build9-tests.xcresult.


## 2026-11-05: agreement processing completed on refresh

Following the user's report that banking and the Paid Apps Agreement were processing, the existing Business page was reloaded using native browser controls. The refreshed page now shows the Paid Apps Agreement Active (all countries/regions, 2026-11-04 through 2027-07-15), Free Apps Agreement Active, U.S. Certificate of Foreign Status Active, and W-8BEN Active. This supersedes the earlier New/unsigned observation below. No contract, banking, tax, permission, or authentication changes were performed by the agent. Receipt: /Users/jun/Documents/Codex/2026-11-02/task-4/iap-verification/agreement-status.json.

The agreement prerequisite is now satisfied according to the current UI. Remaining validation is live product loading and a sandbox purchase using the repaired app, including cancellation, repeat consumable purchase, transaction completion, and payment restrictions. Build 8 does not include the repair. A signed build greater than 8 must be prepared and uploaded/distributed only after the user approves new-build distribution. Then validate on the user's TestFlight device with sandbox transactions, without any production purchase. Product review eligibility/status and its inclusion with the app review must be checked before any later review submission. No new build distribution or submission was performed during this check.

## 2026-11-05: purchase handling repair and current release boundary

The parent confirmed Apple notification emails: Developer Program License Agreement signed at 06:40 UTC, and CloudTape 1.0.2 Prepare for Submission at 06:48 UTC. These supersede the earlier app-version status observations below; neither email means submitted or published. Build 8 remains the already distributed TestFlight build and does not contain the repair described here.

At approximately 07:06 UTC, a read-only check of the existing App Store Connect Business page still showed Free Apps Agreement Active and Paid Apps Agreement New. The page explicitly requires updating legal-entity information before signing the paid agreement. No agreement, entity, banking, tax, permission, or authentication settings were changed. The earlier IAP product observation was Developer Rejected; it has not been resubmitted. The 2.1(b) rejection is confirmed, but the historical failure cannot be attributed uniquely to a code defect. The presently unsigned paid agreement is a concrete prerequisite blocking a trustworthy sandbox/TestFlight purchase validation.

The local repair shares concurrent product loads, holds the purchase-in-progress guard across product loading, preserves the actual loading error, handles purchase restrictions before requesting a product, and treats StoreKit's thrown cancellation as cancellation. Missing-product instructions now address the customer; diagnostic logging records product count or error domain/code without receipts or credentials. Verified transaction finishing and pending-transaction update handling retain their existing behavior.

Validation on iOS Simulator 27.2, device 95706EA6-853F-42EA-9076-94E098685944:

- All 25 unit tests passed, including 11 purchase tests: missing products, concurrent loading/purchasing, preserved network error, restrictions, local purchase success, cancellation, retry, invalid verification, and Ask to Buy approval via transaction updates. The test catalog explicitly asserts Transaction.environment == .xcode. Purchases used SKTestSession with dialogs disabled and serial execution, with no real charges.
- The initial local catalog run returned no products; a dedicated SKTestSession catalog transaction established local operation, and subsequent full execution passed. This is simulator evidence only, not evidence of live App Store product availability.
- One UI test passed in an isolated snapshot with the repaired store. It checks favorites persistence, priority playback and removal, plus home, mini player, settings, empty library, and the support sheet. Five screenshots were inspected with no overlap or clipping found. The support sheet showed the local test price of 160 yen; no purchase button was tapped. The UI snapshot retained its prior build number 7; the original source remains build 8.
- The original repository passed an unsigned Release build for generic iOS after the focused repair was applied. Existing favorites and other uncommitted changes were preserved using baseline hashes.
- Required build_run_sim and Codex browser mirror tooling are unavailable in this session; npm/npx are also absent. CLI Xcode build, XCTest, and exported simulator screenshots were used. Browser mirror review remains unfulfilled.

Evidence: /tmp/cloudtape-iap-fix-tests-3.xcresult, /tmp/cloudtape-iap-ui.xcresult, /tmp/cloudtape-iap-device-build.log, and /Users/jun/Documents/Codex/2026-11-02/task-4/iap-verification/screenshots/manifest.json. The focused UI test harness remains in the isolated release-ui-check copy; production unit tests and the StoreKit test resource references are included in the original repository.

Remaining steps: the account holder must complete the legal-entity/paid-agreement prerequisite, then confirm the agreement is Active and validate this product in sandbox/TestFlight. A new build number greater than 8, signed archive/upload, and selection of that build would be needed to distribute this code. No new upload, review submission, publication, real purchase, or contract consent was performed for this repair. Brave's JavaScript from Apple Events setting was verified OFF at completion.

Date: 2026-05-29

Issue:
- App Store Review rejected CloudTape with Guideline 2.1(b), "Unable to purchase In-App Purchase."

## 2026-11-05 Verification Update

Read-only review of the original Apple notification emails confirmed:

- May 28: version `1.0.2 (6)` was rejected under Guideline 2.1(b) because the optional In-App Purchase could not be purchased.
- June 1: version `1.0.2 (7)` was rejected under the same guideline because the products did not load and could not be purchased. Apple said the previously identified issue still required attention.
- June 1, 11:54:33 UTC: a later status email reported `Developer Rejected` for version `1.0.2`. This is the latest version-review status found in the notification history; the current App Store Connect UI state has not yet been verified.
- November 5, 03:51:21 UTC: Apple confirmed that the favorites candidate `1.0.2 (8)` completed processing and can be used for TestFlight or submitted for distribution. Processing completion does not confirm that the IAP issue is resolved or that the build is assigned to testers.

Apple's rejection messages explicitly state that products do not need prior approval to work during App Review sandbox testing. They request checking the product configuration, missing information, sandbox behavior, and whether the Paid Apps Agreement is in effect. These are checks, not a verified root cause. Accepting a new agreement requires separate user action/authorization.

The favorites changes do not modify `SupportDevelopmentStore.swift` or the product ID. Do not treat successful favorites tests, a signed upload, or completed processing as evidence that live StoreKit product loading works. Before resubmitting, verify the App Store Connect IAP and agreement state and test the optional purchase with the processed build in TestFlight/sandbox.

Subsequent authenticated App Store Connect inspection used existing System Events UI authorization; no new GUI access permission was added. The Brave JavaScript setting did not turn on via automation and remained off. Direct UI inspection confirmed:

- TestFlight build `1.0.2 (8)` is `Ready to Submit`, with 0 assigned groups and 0 assigned individual testers.
- The existing-group picker reports no eligible existing groups, and the existing-tester picker reports no registered testers. No new invitations were authorized or sent at that initial inspection; the later owner-authorized invitation is recorded below.
- App Store version `1.0.2` remains `Developer Rejected`, and its selected build is still `7`. Build `8` has not been submitted for review.
- Product `cloudtape.coffee.small` exists as a consumable and is `Developer Rejected`. Japanese and US English display names/descriptions, a Japan-based price schedule, and prices for 175 countries/regions are configured. No pricing or availability changes were made.
- The Business page says an updated Apple Developer Program License Agreement needs Account Holder acceptance before existing-app updates/new-app submissions. The user's Xcode screenshot showed Admin. A subsequent authoritative Users and Access check confirmed the approved owner account is both Account Holder and Admin.
- The Business page also says legal-entity information must be updated before signing the Paid Apps Agreement. Only the Free Apps Agreement was listed, with status `Active (New Agreement Available)`; an active Paid Apps Agreement was not verified.

Do not submit the update until the Account Holder resolves the required agreement state and the live purchase-loading issue is checked in TestFlight/sandbox. Accepting agreements, changing legal/financial information, making a real purchase, or inviting a new tester requires the relevant explicit authorization. None of those actions was performed. The actual cause of the historical StoreKit failure is not proven solely by these current account conditions.

Cleanup verified Brave Apple Events JavaScript is off (execution returns browser error 12), and the temporary browser window-size change was restored. Existing code and release assets were preserved.

### Later authorized TestFlight distribution

The owner explicitly authorized a TestFlight invitation to their specified existing App Store Connect account. That exact account was verified in Users and Access as Account Holder/Admin. Internal group `CloudTape - Jun` was created with automatic distribution disabled; only build `1.0.2 (8)` was assigned, and only the approved owner was added. The UI reports one tester, one build, and tester status `Invited`. Apple's TestFlight invitation email arrived on 2026-11-05 at 04:50:59 UTC. Acceptance and installation remain the owner's next steps.

No other people were invited, no App Store Connect roles were changed, no agreement was accepted, and no purchase was made. The release still needs the agreement/IAP checks described above before App Store resubmission. The browser JavaScript setting was verified off after the operation, and the original browser window bounds were restored.

### Follow-up after owner-reported agreement acceptance

Authenticated UI inspection after the owner reported accepting the agreement confirmed that the Developer Program update warning is gone and the Free Apps Agreement is Active. A Paid Apps Agreement now appears with status New. Apple defines New as unsigned; the Business page still requires legal-entity information updates before signing that agreement. No additional agreement, legal information, banking information, or tax information was accepted or changed by the agent.

Apple's In-App Purchase setup documentation explicitly requires the Paid Apps Agreement to be Active for sandbox testing. Product `cloudtape.coffee.small` remains Developer Rejected, so successful product loading is still unverified. This account prerequisite must be resolved before relying on a TestFlight/sandbox purchase test or resubmitting the app with its optional support purchase.

The App Store 1.0.2 draft was prepared by changing its selected build from 7 to 8 and saving the Japanese favorites release notes. Both changes were confirmed after reloading the page. Only Japanese is registered for this app-version record; an English localization was not added. The draft remains Developer Rejected and was not added to App Review.

Sources: https://developer.apple.com/help/app-store-connect/manage-agreements/view-agreements-status/ and https://developer.apple.com/help/app-store-connect/configure-in-app-purchase-settings/overview-for-configuring-in-app-purchases/

## Executive finding

The app-side StoreKit2 implementation uses the same product identifier as the local StoreKit configuration:

- App code: `cloudtape.coffee.small`
- StoreKit test configuration: `cloudtape.coffee.small`
- Product type: Consumable
- Bundle ID: `io.github.junnakarai.cloudtape`
- Candidate version/build: `1.0.2 (7)`
- Device family in build settings: iPhone only (`TARGETED_DEVICE_FAMILY = 1`)

No app-side product ID mismatch was found.

The most likely App Store Review failure is App Store Connect state, especially one of these:

1. The first IAP was not selected in the app version's "In-App Purchases and Subscriptions" section before resubmission.
2. The IAP was not in `Ready to Submit`, `Waiting for Review`, `In Review`, or `Pending Binary Approval` with the app version.
3. Required IAP metadata was incomplete, especially review screenshot, localization, price, or availability.
4. Paid Apps agreement, tax, banking, or regional availability blocked StoreKit from returning the product to the review device.

Apple's App Store Connect help says the first IAP must be submitted with a new app version, and the IAP must be `Ready to Submit` before review. Apple's StoreKit troubleshooting note says `Product.products(for:)` returns products that match App Store Connect product IDs, and an empty result can mean the product does not exist, is unapproved, or is unavailable in the current storefront.

## App-side investigation

### 1. Product ID match

Result: Pass.

Evidence:
- `SupportDevelopmentStore.coffeeSmallProductID` is `cloudtape.coffee.small`.
- `Configuration/CloudTape.storekit` contains one Consumable with product ID `cloudtape.coffee.small`.
- Repo submission docs also use `cloudtape.coffee.small`.

### 2. Product.products(for:) path

Result: App implementation is structurally correct. Live App Store Connect product retrieval still needs a TestFlight/sandbox device check after App Store Connect state is corrected.

Evidence:
- `loadProduct()` calls `Product.products(for: SupportDevelopmentStore.productIDs)`.
- The product list is filtered by exact `Product.id`.
- Missing product now shows an App Store Connect-focused error instead of a generic retry message.

### 3. iPad purchase screen

Result: No iPad-specific blocker found in source. The app is currently iPhone-only.

Evidence:
- `TARGETED_DEVICE_FAMILY = 1` in `project.yml`.
- Generated Xcode project also sets `TARGETED_DEVICE_FAMILY = 1`.
- The support purchase UI is presented as a SwiftUI sheet from the library menu and uses `NavigationStack` + `Form`, with no iPad popover-only control.

App Store Connect check:
- Confirm the processed build selected for review is build `1.0.2 (7)` or newer from this source.
- Confirm App Store Connect does not still show universal/iPad support from an older uploaded build.

### 4. purchase() call

Result: Pass.

Evidence:
- The visible price row is a `Button`.
- Its action creates a `Task` and awaits `store.purchaseCoffeeSupport()`.
- `purchaseCoffeeSupport()` awaits `product.purchase()`.
- `isPurchasing` disables duplicate taps while the purchase is in progress.

### 5. Sandbox failure cases

Result: Local StoreKit configuration covers success, cancellation, pending completion, and unavailable product handling per existing checklist. Live sandbox/TestFlight still needs a final device pass after App Store Connect fixes.

Required pass before resubmission:
1. Install the selected TestFlight/App Review build.
2. Open CloudTape.
3. Menu > `開発を応援する`.
4. Confirm the product price loads from App Store Connect.
5. Tap the purchase row.
6. Confirm the App Store purchase sheet appears.
7. Cancel once and confirm the app returns to the support screen.
8. Purchase once with a sandbox tester and confirm `ありがとうございます` appears.

### 6. Error handling

Result: Fixed.

Before:
- Product load failures, purchase failures, and transaction verification failures all showed generic messages.
- If `loadProduct()` returned no product and purchase was requested again, the guard returned without a fresh diagnostic.
- User cancellation produced no visible state.

After:
- Empty product fetch explicitly points to Product ID, IAP submission state, and country/region availability.
- Thrown StoreKit errors include `localizedDescription`.
- Purchase cancellation shows a neutral cancellation status.
- Unverified transactions use a localized error.

### 7. StoreKit2 implementation

Result: No blocking StoreKit2 misuse found.

Evidence:
- Uses StoreKit2 `Product`, `Product.products(for:)`, `product.purchase()`, `VerificationResult`, and `Transaction`.
- Finishes verified transactions with `await transaction.finish()`.
- Handles `.success`, `.pending`, `.userCancelled`, and unknown future results.
- Listens for unfinished and updated transactions and routes them through the same verification path.
- Ignores unrelated product IDs before finishing.

Residual note:
- This consumable does not unlock durable app state, so no entitlement restore UI is required.

### 8. App Store Connect checklist

These items cannot be verified from the local repository because no App Store Connect API key or logged-in App Store Connect session is stored in this checkout. Verify them manually before resubmission:

1. In Apps > CloudTape > Monetization > In-App Purchases, product ID is exactly `cloudtape.coffee.small`.
2. Type is Consumable.
3. Reference name is `CloudTape Coffee Support`.
4. Price is set.
5. At least one country/region is available, including the review storefront.
6. Localizations exist for `ja-JP` and `en-US`.
7. Review screenshot is uploaded and clearly shows the in-app support purchase UI with product title and price.
8. Review notes state that the IAP is optional, consumable, does not unlock features, and does not change app behavior.
9. IAP status is not `Missing Metadata`, `Developer Action Needed`, `Developer Removed from Sale`, `Removed from Sale`, or `Rejected`.
10. If this is CloudTape's first IAP, open the 1.0.2 app version page, scroll to "In-App Purchases and Subscriptions", and select `cloudtape.coffee.small` before submitting the app version.
11. Paid Apps agreement is active, and tax/banking setup is complete.
12. The app version submitted for review uses the current processed build, not an older build that predates the IAP.

## Recommended resubmission steps

1. Fix any App Store Connect IAP status issue until the product is `Ready to Submit`.
2. Attach/select the IAP on the 1.0.2 app version page.
3. Upload/select a current build if App Store Connect was using an older build.
4. Test the selected build in TestFlight with a sandbox tester.
5. Confirm `Product.products(for:)` returns the product and the purchase sheet appears.
6. Resubmit the app version and IAP together.

## App Review response draft

CloudTape's optional consumable In-App Purchase uses Product ID `cloudtape.coffee.small`. We verified the app binary uses the same Product ID as App Store Connect and improved the in-app StoreKit error handling so product availability and purchase errors are surfaced clearly.

Please review with the following path:

1. Launch CloudTape.
2. Tap the top-right menu button.
3. Tap `開発を応援する`.
4. Wait for the product price to load.
5. Tap `応援する`.
6. The App Store purchase sheet should appear.

This purchase is optional, consumable, and does not unlock any additional app features.
