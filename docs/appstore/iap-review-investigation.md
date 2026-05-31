# CloudTape IAP Review Investigation

Date: 2026-05-29

Issue:
- App Store Review rejected CloudTape with Guideline 2.1(b), "Unable to purchase In-App Purchase."

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
