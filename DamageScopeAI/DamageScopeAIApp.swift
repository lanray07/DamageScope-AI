import SwiftData
import SwiftUI

@main
struct DamageScopeAIApp: App {
    @State private var subscriptionService = SubscriptionService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(subscriptionService)
                .task {
                    await subscriptionService.loadProducts()
                }
        }
        .modelContainer(for: [
            DamageCase.self,
            DamagePhoto.self,
            DamageFinding.self,
            DamageReport.self,
            SubscriptionState.self
        ])
    }
}
