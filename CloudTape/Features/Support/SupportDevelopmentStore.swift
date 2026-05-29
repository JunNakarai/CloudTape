import Foundation
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

    init() {
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
    }

    func loadProduct() async {
        guard product == nil else { return }

        isLoading = true
        statusMessage = nil
        errorMessage = nil
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: Self.productIDs)
            product = products.first { $0.id == Self.coffeeSmallProductID }

            if product == nil {
                errorMessage = Self.productUnavailableMessage
            }
        } catch {
            errorMessage = Self.productLoadFailureMessage(error)
        }
    }

    func purchaseCoffeeSupport() async {
        if product == nil {
            await loadProduct()
        }

        guard let product else {
            errorMessage = Self.productUnavailableMessage
            return
        }

        isPurchasing = true
        message = nil
        statusMessage = nil
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

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
        "応援アイテムを取得できませんでした。App Store Connect の Product ID、IAP の提出状態、販売国/地域を確認してください。"
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
