import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @State private var purchasingProductID: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("DamageScope AI")
                        .font(.largeTitle.bold())
                    Text(subscriptionService.statusText)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

                ForEach(PaywallPlan.all) { plan in
                    PaywallPlanCard(
                        plan: plan,
                        product: subscriptionService.product(for: plan.productID),
                        isCurrent: isCurrent(plan),
                        isPurchasing: purchasingProductID == plan.productID,
                        action: {
                            purchase(plan)
                        }
                    )
                }

                Button {
                    Task { await subscriptionService.refreshEntitlements() }
                } label: {
                    Label("Restore Purchases", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(AppConstants.disclaimers, id: \.self) { disclaimer in
                        Label(disclaimer, systemImage: "checkmark.shield")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Plan")
        .task {
            if subscriptionService.products.isEmpty {
                await subscriptionService.loadProducts()
            }
        }
        .alert("Subscription", isPresented: Binding(
            get: { subscriptionService.errorMessage != nil },
            set: { if !$0 { subscriptionService.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(subscriptionService.errorMessage ?? "")
        }
    }

    private func isCurrent(_ plan: PaywallPlan) -> Bool {
        switch plan.plan {
        case .free:
            subscriptionService.currentPlan == .free
        case .pro:
            subscriptionService.currentPlan == .pro && plan.productID != AppConstants.proYearlyProductID
        case .business:
            subscriptionService.currentPlan == .business
        }
    }

    private func purchase(_ plan: PaywallPlan) {
        guard let product = subscriptionService.product(for: plan.productID) else {
            subscriptionService.errorMessage = "StoreKit product \(plan.productID) is a placeholder until configured in App Store Connect or a StoreKit test file."
            return
        }

        purchasingProductID = plan.productID
        Task {
            await subscriptionService.purchase(product)
            purchasingProductID = nil
        }
    }
}

private struct PaywallPlan: Identifiable {
    var id: String { productID }
    var plan: SubscriptionPlan
    var name: String
    var placeholderPrice: String
    var productID: String
    var features: [String]

    static let all = [
        PaywallPlan(
            plan: .free,
            name: "Free",
            placeholderPrice: "£0",
            productID: "free",
            features: [
                "2 damage cases/month",
                "10 photo scans/month",
                "Basic PDF report",
                "DamageScope AI footer"
            ]
        ),
        PaywallPlan(
            plan: .pro,
            name: "Pro Monthly",
            placeholderPrice: "£24.99",
            productID: AppConstants.proMonthlyProductID,
            features: [
                "Unlimited cases",
                "250 AI scans/month",
                "Professional PDF reports",
                "Repair priority lists",
                "Custom branding placeholder"
            ]
        ),
        PaywallPlan(
            plan: .pro,
            name: "Pro Yearly",
            placeholderPrice: "£199.99",
            productID: AppConstants.proYearlyProductID,
            features: [
                "Annual Pro access",
                "Professional PDF reports",
                "Repair priority lists",
                "Custom branding placeholder"
            ]
        ),
        PaywallPlan(
            plan: .business,
            name: "Business Monthly",
            placeholderPrice: "£89.99",
            productID: AppConstants.businessMonthlyProductID,
            features: [
                "Unlimited scans/reports",
                "Advanced branding placeholder",
                "Multi-property and fleet support",
                "Contractor action lists",
                "Team workflow placeholder"
            ]
        )
    ]
}

private struct PaywallPlanCard: View {
    var plan: PaywallPlan
    var product: Product?
    var isCurrent: Bool
    var isPurchasing: Bool
    var action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(plan.name)
                        .font(.title3.bold())
                    Text(product?.displayPrice ?? plan.placeholderPrice)
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                if isCurrent {
                    Text("Current")
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.green.opacity(0.14))
                        .clipShape(Capsule())
                }
            }

            ForEach(plan.features, id: \.self) { feature in
                Label(feature, systemImage: "checkmark")
                    .font(.subheadline)
            }

            Button {
                action()
            } label: {
                if isPurchasing {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text(plan.plan == .free ? "Included" : "Choose \(plan.name)")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isCurrent || plan.plan == .free || isPurchasing)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
