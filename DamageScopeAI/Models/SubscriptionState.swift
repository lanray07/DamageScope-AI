import Foundation
import SwiftData

@Model
final class SubscriptionState {
    @Attribute(.unique) var id: UUID
    var planRaw: String
    var isActive: Bool
    var renewsAt: Date?

    init(
        id: UUID = UUID(),
        plan: SubscriptionPlan = .free,
        isActive: Bool = false,
        renewsAt: Date? = nil
    ) {
        self.id = id
        self.planRaw = plan.rawValue
        self.isActive = isActive
        self.renewsAt = renewsAt
    }

    var plan: SubscriptionPlan {
        get { SubscriptionPlan(rawValue: planRaw) ?? .free }
        set { planRaw = newValue.rawValue }
    }
}
