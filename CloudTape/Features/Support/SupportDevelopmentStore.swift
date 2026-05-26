import Foundation
import StoreKit

@MainActor
final class SupportDevelopmentStore: ObservableObject {
    static let coffeeSmallProductID = "cloudtape.coffee.small"

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
            let products = try await Product.products(for: [Self.coffeeSmallProductID])
            product = products.first { $0.id == Self.coffeeSmallProductID }

            if product == nil {
                errorMessage = "応援アイテムを取得できませんでした。時間をおいてもう一度お試しください。"
            }
        } catch {
            errorMessage = "応援アイテムを取得できませんでした。時間をおいてもう一度お試しください。"
        }
    }

    func purchaseCoffeeSupport() async {
        if product == nil {
            await loadProduct()
        }

        guard let product else { return }

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
                break
            @unknown default:
                errorMessage = "購入を完了できませんでした。時間をおいてもう一度お試しください。"
            }
        } catch {
            errorMessage = "購入を完了できませんでした。時間をおいてもう一度お試しください。"
        }
    }

    private func processTransactionUpdate(_ verification: VerificationResult<Transaction>) async {
        do {
            try await completeCoffeeSupportPurchase(verification)
        } catch {
            errorMessage = "購入を確認できませんでした。時間をおいてもう一度お試しください。"
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
}

private enum StoreError: Error {
    case unverifiedTransaction
}
