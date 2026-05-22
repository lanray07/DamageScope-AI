import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class SubscriptionService {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var currentPlan: SubscriptionPlan = .free
    var isActive = false
    var isLoading = false
    var errorMessage: String?

    var statusText: String {
        isActive ? "\(currentPlan.displayName) active" : "Free plan"
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: AppConstants.subscriptionProductIDs)
                .sorted { $0.displayName < $1.displayName }
            await refreshEntitlements()
        } catch {
            errorMessage = "StoreKit products are unavailable in this environment. Placeholder pricing remains visible."
        }
    }

    func purchase(_ product: Product) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
            case .pending:
                errorMessage = "Purchase is pending approval."
            case .userCancelled:
                break
            @unknown default:
                errorMessage = "Purchase could not be completed."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refreshEntitlements() async {
        var activeIDs = Set<String>()

        for await entitlement in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(entitlement), transaction.revocationDate == nil {
                activeIDs.insert(transaction.productID)
            }
        }

        purchasedProductIDs = activeIDs
        if activeIDs.contains(AppConstants.businessMonthlyProductID) {
            currentPlan = .business
        } else if activeIDs.contains(AppConstants.proMonthlyProductID) || activeIDs.contains(AppConstants.proYearlyProductID) {
            currentPlan = .pro
        } else {
            currentPlan = .free
        }
        isActive = currentPlan != .free
    }

    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitVerificationError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

enum StoreKitVerificationError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        "StoreKit could not verify the transaction."
    }
}
