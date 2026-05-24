import Foundation
import StoreKit

@MainActor
final class SupportDevelopmentStore: ObservableObject {
    static let coffeeSmallProductID = "cloudtape.coffee.small"

    @Published private(set) var product: Product?
    @Published private(set) var isLoading = false
    @Published private(set) var isPurchasing = false
    @Published var message: String?
    @Published var errorMessage: String?

    func loadProduct() async {
        guard product == nil else { return }

        isLoading = true
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
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try verified(verification)
                await transaction.finish()
                message = "ありがとうございます"
            case .pending:
                errorMessage = "購入は保留中です。完了すると App Store から通知されます。"
            case .userCancelled:
                break
            @unknown default:
                errorMessage = "購入を完了できませんでした。時間をおいてもう一度お試しください。"
            }
        } catch {
            errorMessage = "購入を完了できませんでした。時間をおいてもう一度お試しください。"
        }
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
