import Combine
import StoreKit
import StoreKitTest
import XCTest
@testable import CloudTape

@MainActor
final class SupportDevelopmentStoreTests: XCTestCase {
    private var session: SKTestSession!

    override func setUpWithError() throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "CloudTape", withExtension: "storekit"))
        session = try SKTestSession(contentsOf: url)
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
    }

    override func tearDownWithError() throws {
        session.clearTransactions()
        session.resetToDefaultState()
        session = nil
    }

    func testLocalConfigurationCatalog() async throws {
        let transaction = try await session.buyProduct(identifier: SupportDevelopmentStore.coffeeSmallProductID, options: [])
        XCTAssertEqual(transaction.productID, SupportDevelopmentStore.coffeeSmallProductID)
        XCTAssertEqual(transaction.environment, .xcode)
        let products = try await Product.products(for: SupportDevelopmentStore.productIDs)
        XCTAssertEqual(products.count, 1)
    }

    func testMissingProductHasRetryGuidanceWithoutDeveloperInstructions() async {
        let store = SupportDevelopmentStore(productLoader: { [] }, observeTransactions: false)
        await store.loadProduct()
        XCTAssertNil(store.product)
        XCTAssertFalse(store.isLoading)
        XCTAssertTrue(store.errorMessage?.contains("もう一度") == true)
        XCTAssertFalse(store.errorMessage?.contains("App Store Connect") == true)
    }

    func testConcurrentLoadsShareOneRequest() async {
        var requests = 0
        let store = SupportDevelopmentStore(productLoader: {
            requests += 1
            try await Task.sleep(nanoseconds: 50_000_000)
            return []
        }, observeTransactions: false)
        async let first: Void = store.loadProduct()
        async let second: Void = store.loadProduct()
        _ = await (first, second)
        XCTAssertEqual(requests, 1)
        XCTAssertFalse(store.isLoading)
    }

    func testPurchaseWaitsForExistingLoadAndPreservesNetworkFailure() async {
        var requests = 0
        var purchases = 0
        let offline = URLError(.notConnectedToInternet)
        let store = SupportDevelopmentStore(productLoader: {
            requests += 1
            try await Task.sleep(nanoseconds: 50_000_000)
            throw offline
        }, purchaseProduct: { _ in
            purchases += 1
            return .userCancelled
        }, paymentsAllowed: { true }, observeTransactions: false)
        let loading = Task { await store.loadProduct() }
        await Task.yield()
        await store.purchaseCoffeeSupport()
        await loading.value
        XCTAssertEqual(requests, 1)
        XCTAssertEqual(purchases, 0)
        XCTAssertTrue(store.errorMessage?.contains(offline.localizedDescription) == true)
        XCTAssertFalse(store.isPurchasing)
    }

    func testConcurrentPurchaseRequestsOnlyOpenOnePurchase() async throws {
        var purchases = 0
        let store = SupportDevelopmentStore(purchaseProduct: { _ in
            purchases += 1
            try await Task.sleep(nanoseconds: 50_000_000)
            return .userCancelled
        }, paymentsAllowed: { true }, observeTransactions: false)
        await store.loadProduct()
        XCTAssertNotNil(store.product)
        async let first: Void = store.purchaseCoffeeSupport()
        async let second: Void = store.purchaseCoffeeSupport()
        _ = await (first, second)
        XCTAssertEqual(purchases, 1)
        XCTAssertNil(store.errorMessage)
        XCTAssertTrue(store.statusMessage?.contains("キャンセル") == true)
    }

    func testRestrictedPaymentsDoNotLoadOrPurchase() async {
        var requests = 0
        let store = SupportDevelopmentStore(productLoader: {
            requests += 1
            return []
        }, paymentsAllowed: { false }, observeTransactions: false)
        await store.purchaseCoffeeSupport()
        XCTAssertEqual(requests, 0)
        XCTAssertFalse(store.isPurchasing)
        XCTAssertTrue(store.errorMessage?.contains("購入制限") == true)
    }

    func testLocalStoreKitPurchaseFinishesTransaction() async {
        let store = SupportDevelopmentStore(paymentsAllowed: { true }, observeTransactions: false)
        await store.loadProduct()
        XCTAssertEqual(store.product?.id, SupportDevelopmentStore.coffeeSmallProductID)
        XCTAssertFalse(store.product?.displayPrice.isEmpty ?? true)
        await store.purchaseCoffeeSupport()
        XCTAssertEqual(store.message, "ありがとうございます")
        XCTAssertNil(store.errorMessage)
        XCTAssertFalse(store.isPurchasing)
        await assertNoUnfinishedSupportTransaction()
    }

    func testLocalStoreKitFailureCanBeRetried() async throws {
        let store = SupportDevelopmentStore(paymentsAllowed: { true }, observeTransactions: false)
        await store.loadProduct()
        try await session.setSimulatedError(.generic(.networkError(URLError(.notConnectedToInternet))), forAPI: .purchase)
        await store.purchaseCoffeeSupport()
        XCTAssertNotNil(store.errorMessage)
        XCTAssertNil(store.message)
        XCTAssertFalse(store.isPurchasing)
        try await session.setSimulatedError(nil, forAPI: .purchase)
        await store.purchaseCoffeeSupport()
        XCTAssertEqual(store.message, "ありがとうございます")
        XCTAssertNil(store.errorMessage)
        await assertNoUnfinishedSupportTransaction()
    }

    func testLocalStoreKitCancellationIsNotAnError() async throws {
        let store = SupportDevelopmentStore(paymentsAllowed: { true }, observeTransactions: false)
        await store.loadProduct()
        try await session.setSimulatedError(.generic(.userCancelled), forAPI: .purchase)
        await store.purchaseCoffeeSupport()
        XCTAssertNil(store.errorMessage)
        XCTAssertNil(store.message)
        XCTAssertTrue(store.statusMessage?.contains("キャンセル") == true)
        XCTAssertFalse(store.isPurchasing)
    }

    func testUnverifiedPurchaseIsNotAcknowledgedOrFinished() async throws {
        let store = SupportDevelopmentStore(paymentsAllowed: { true }, observeTransactions: false)
        await store.loadProduct()
        try await session.setSimulatedError(.verification(.invalidSignature), forAPI: .verification)
        await store.purchaseCoffeeSupport()
        XCTAssertNil(store.message)
        XCTAssertTrue(store.errorMessage?.contains("検証") == true)
        var unfinished = false
        for await verification in Transaction.unfinished {
            switch verification {
            case .verified(let transaction), .unverified(let transaction, _):
                if transaction.productID == SupportDevelopmentStore.coffeeSmallProductID {
                    unfinished = true
                }
            }
        }
        XCTAssertTrue(unfinished, "Unverified transactions must not be finished")
    }

    func testLocalAskToBuyApprovalCompletesThroughUpdates() async throws {
        session.askToBuyEnabled = true
        let store = SupportDevelopmentStore(paymentsAllowed: { true })
        await store.loadProduct()
        let completion = expectation(description: "Delayed transaction is acknowledged")
        let subscription = store.$message.compactMap { $0 }.prefix(1).sink { _ in completion.fulfill() }
        defer { subscription.cancel() }
        await store.purchaseCoffeeSupport()
        XCTAssertNil(store.message)
        XCTAssertTrue(store.statusMessage?.contains("保留中") == true)
        let pending = try XCTUnwrap(session.allTransactions().first(where: { $0.state == .deferred }))
        try session.approveAskToBuyTransaction(identifier: pending.identifier)
        await fulfillment(of: [completion], timeout: 10)
        XCTAssertEqual(store.message, "ありがとうございます")
        XCTAssertNil(store.statusMessage)
        XCTAssertNil(store.errorMessage)
        await assertNoUnfinishedSupportTransaction()
    }

    private func assertNoUnfinishedSupportTransaction() async {
        for await verification in Transaction.unfinished {
            if case .verified(let transaction) = verification {
                XCTAssertNotEqual(transaction.productID, SupportDevelopmentStore.coffeeSmallProductID)
            }
        }
    }
}
