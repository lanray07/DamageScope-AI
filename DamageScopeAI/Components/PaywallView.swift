import StoreKit
import SwiftUI

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @State private var purchasingProductID: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

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

                restoreButton
                SubscriptionLegalLinksView()
                disclaimerList
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

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("DamageScope AI")
                .font(.largeTitle.bold())
            Text(subscriptionService.statusText)
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }

    private var restoreButton: some View {
        Button {
            Task { await subscriptionService.refreshEntitlements() }
        } label: {
            Label("Restore Purchases", systemImage: "arrow.clockwise")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
    }

    private var disclaimerList: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(AppConstants.disclaimers, id: \.self) { disclaimer in
                Label(disclaimer, systemImage: "checkmark.shield")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
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
    var subscriptionLength: String
    var billingUnit: String
    var features: [String]

    static let all = [
        PaywallPlan(
            plan: .free,
            name: "Free",
            placeholderPrice: "GBP 0",
            productID: "free",
            subscriptionLength: "No paid subscription",
            billingUnit: "free plan",
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
            placeholderPrice: "GBP 24.99",
            productID: AppConstants.proMonthlyProductID,
            subscriptionLength: "1 month",
            billingUnit: "month",
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
            placeholderPrice: "GBP 199.99",
            productID: AppConstants.proYearlyProductID,
            subscriptionLength: "1 year",
            billingUnit: "year",
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
            placeholderPrice: "GBP 89.99",
            productID: AppConstants.businessMonthlyProductID,
            subscriptionLength: "1 month",
            billingUnit: "month",
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
            planHeader

            if plan.plan != .free {
                subscriptionDisclosure
            }

            featureList
            purchaseButton
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var displayPrice: String {
        product?.displayPrice ?? plan.placeholderPrice
    }

    private var planHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(plan.name)
                    .font(.title3.bold())
                Text(displayPrice)
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
    }

    private var subscriptionDisclosure: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Auto-renewable subscription", systemImage: "arrow.triangle.2.circlepath")
            Label("Length: \(plan.subscriptionLength)", systemImage: "calendar")
            Label("Price: \(displayPrice) per \(plan.billingUnit)", systemImage: "tag")
            Label("Renews automatically until cancelled in your App Store account settings.", systemImage: "creditcard")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private var featureList: some View {
        ForEach(plan.features, id: \.self) { feature in
            Label(feature, systemImage: "checkmark")
                .font(.subheadline)
        }
    }

    private var purchaseButton: some View {
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
}

private struct SubscriptionLegalLinksView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Subscription terms")
                .font(.headline)

            Text("Purchases are charged to your Apple ID and renew automatically unless cancelled at least 24 hours before the end of the current period.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Link(destination: AppConstants.privacyPolicyURL) {
                    Label("Privacy Policy", systemImage: "lock.shield")
                }

                Link(destination: AppConstants.termsOfUseURL) {
                    Label("Terms of Use (EULA)", systemImage: "doc.text")
                }
            }
            .font(.caption.weight(.semibold))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
