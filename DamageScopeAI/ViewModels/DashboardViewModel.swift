import Foundation
import Observation

struct DashboardStats {
    var openCases: Int
    var urgentDamage: Int
    var reportsGenerated: Int
    var subscriptionStatus: String
}

@MainActor
@Observable
final class DashboardViewModel {
    func stats(
        cases: [DamageCase],
        findings: [DamageFinding],
        reports: [DamageReport],
        subscriptionStatus: String
    ) -> DashboardStats {
        DashboardStats(
            openCases: cases.filter { $0.status != .archived && $0.status != .repaired }.count,
            urgentDamage: findings.filter { $0.severity == .urgent && $0.userApproved }.count,
            reportsGenerated: reports.count,
            subscriptionStatus: subscriptionStatus
        )
    }
}
