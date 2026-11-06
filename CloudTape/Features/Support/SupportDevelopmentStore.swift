import Combine
import Foundation
import OSLog
import StoreKit

@MainActor
final class SupportDevelopmentStore: ObservableObject {
    static let coffeeSmallProductID = "cloudtape.coffee.small"
    static let productIDs: Set<String> = [coffeeSmallProductID]

    @Published private(set) var product: Product?
    @Published private(set) var isLoading = false
    @Published private(set) var isPurchasing = false
    @Published var message: String?
    @Published var statusMessage: String?
    @Published var errorMessage: String?
    private var transactionUpdatesTask: Task<Void, Never>?
    private var productLoadTask: Task<Void, Never>?
    private let productLoader: @MainActor () async throws -> [Product]
    private let purchaseProduct: @MainActor (Product) async throws -> Product.PurchaseResult
    private let paymentsAllowed: @MainActor () -> Bool
    private static let logger = Logger(subsystem: "io.github.junnakarai.cloudtape", category: "SupportPurchase")

    init(
        productLoader: @escaping @MainActor () async throws -> [Product] = {
            try await Product.products(for: SupportDevelopmentStore.productIDs)
        },
        purchaseProduct: @escaping @MainActor (Product) async throws -> Product.PurchaseResult = {
            try await $0.purchase()
        },
        paymentsAllowed: @escaping @MainActor () -> Bool = { AppStore.canMakePayments },
        observeTransactions: Bool = true
    ) {
        self.productLoader = productLoader
        self.purchaseProduct = purchaseProduct
        self.paymentsAllowed = paymentsAllowed
        guard observeTransactions else { return }
        transactionUpdatesTask = Task { [weak self] in
            for await verification in Transaction.unfinished {
                guard let self else { return }
                await self.processTransactionUpdate(verification)
            }

            for await verification in Transaction.updates {
                guard let self else { return }
                await self.processTransactionUpdate(verification)
            }
        }
    }

    deinit {
        transactionUpdatesTask?.cancel()
        productLoadTask?.cancel()
    }

    func loadProduct() async {
        guard product == nil else { return }
        if let productLoadTask {
            await productLoadTask.value
            return
        }

        isLoading = true
        statusMessage = nil
        errorMessage = nil
        let loader = productLoader
        let task = Task { [weak self] in
            do {
                let products = try await loader()
                guard let self else { return }
                product = products.first { $0.id == Self.coffeeSmallProductID }
                if product == nil {
                    Self.logger.error("Support product was absent from the StoreKit response (count: \(products.count)). Check the paid agreement, product configuration, and storefront in App Store Connect.")
                    errorMessage = Self.productUnavailableMessage
                }
            } catch {
                guard let self else { return }
                let nsError = error as NSError
                Self.logger.error("Support product load failed: \(nsError.domain, privacy: .public) code \(nsError.code)")
                errorMessage = Self.productLoadFailureMessage(error)
            }
        }
        productLoadTask = task
        await task.value
        productLoadTask = nil
        isLoading = false
    }

    func purchaseCoffeeSupport() async {
        guard !isPurchasing else { return }
        message = nil
        statusMessage = nil
        errorMessage = nil
        guard paymentsAllowed() else {
            errorMessage = "この端末ではApp内課金が許可されていません。スクリーンタイムなどの購入制限を確認してください。"
            return
        }

        isPurchasing = true
        defer { isPurchasing = false }

        if product == nil {
            await loadProduct()
        }
        guard let product else {
            // Keep the actual loading error so retry guidance is not lost.
            if errorMessage == nil { errorMessage = Self.productUnavailableMessage }
            return
        }

        do {
            let result = try await purchaseProduct(product)

            switch result {
            case .success(let verification):
                try await completeCoffeeSupportPurchase(verification)
            case .pending:
                statusMessage = "購入は保留中です。完了すると App Store から通知されます。"
            case .userCancelled:
                statusMessage = "購入はキャンセルされました。"
            @unknown default:
                errorMessage = "購入を完了できませんでした。時間をおいてもう一度お試しください。"
            }
        } catch StoreKitError.userCancelled {
            statusMessage = "購入はキャンセルされました。"
        } catch {
            errorMessage = Self.purchaseFailureMessage(error)
        }
    }

    private func processTransactionUpdate(_ verification: VerificationResult<Transaction>) async {
        do {
            try await completeCoffeeSupportPurchase(verification)
        } catch {
            errorMessage = Self.transactionVerificationFailureMessage(error)
        }
    }

    private func completeCoffeeSupportPurchase(_ verification: VerificationResult<Transaction>) async throws {
        let transaction = try verified(verification)
        guard transaction.productID == Self.coffeeSmallProductID else { return }

        await transaction.finish()
        statusMessage = nil
        errorMessage = nil
        message = "ありがとうございます"
    }

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw StoreError.unverifiedTransaction
        }
    }

    private static var productUnavailableMessage: String {
        "現在、応援アイテムを利用できません。時間をおいて、もう一度読み込んでください。"
    }

    private static func productLoadFailureMessage(_ error: Error) -> String {
        "応援アイテムを取得できませんでした: \(error.localizedDescription)"
    }

    private static func purchaseFailureMessage(_ error: Error) -> String {
        "購入を完了できませんでした: \(error.localizedDescription)"
    }

    private static func transactionVerificationFailureMessage(_ error: Error) -> String {
        "購入を確認できませんでした: \(error.localizedDescription)"
    }
}

private enum StoreError: LocalizedError {
    case unverifiedTransaction

    var errorDescription: String? {
        switch self {
        case .unverifiedTransaction:
            "App Store の取引を検証できませんでした。"
        }
    }
}
