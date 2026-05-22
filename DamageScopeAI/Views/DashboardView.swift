import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Query(sort: \DamageCase.createdAt, order: .reverse) private var cases: [DamageCase]
    @Query(sort: \DamagePhoto.createdAt, order: .reverse) private var photos: [DamagePhoto]
    @Query(sort: \DamageFinding.createdAt, order: .reverse) private var findings: [DamageFinding]
    @Query(sort: \DamageReport.createdAt, order: .reverse) private var reports: [DamageReport]
    @State private var viewModel = DashboardViewModel()

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                UpgradeBanner(statusText: subscriptionService.statusText)

                LazyVGrid(columns: columns, spacing: 12) {
                    QuickActionLink(title: "New Damage Case", systemImage: "plus.circle", route: .newCase)
                    QuickActionLink(title: "Scan Photo", systemImage: "camera.viewfinder", route: .aiScan(nil))
                    QuickActionLink(title: "Generate Report", systemImage: "doc.richtext", route: .reportGenerator(nil))
                    QuickActionLink(title: "Repair Priority List", systemImage: "list.bullet.rectangle", route: .repairPriority(nil))
                    QuickActionLink(title: "Saved Cases", systemImage: "folder", route: .savedCases)
                }

                let stats = viewModel.stats(
                    cases: cases,
                    findings: findings,
                    reports: reports,
                    subscriptionStatus: subscriptionService.statusText
                )

                LazyVGrid(columns: columns, spacing: 12) {
                    StatTile(title: "Open cases", value: "\(stats.openCases)", systemImage: "tray.full")
                    StatTile(title: "Urgent damage", value: "\(stats.urgentDamage)", systemImage: "exclamationmark.triangle")
                    StatTile(title: "Reports", value: "\(stats.reportsGenerated)", systemImage: "doc.text")
                    StatTile(title: "Plan", value: stats.subscriptionStatus, systemImage: "creditcard")
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent cases")
                        .font(.title3.bold())

                    if cases.isEmpty {
                        EmptyStateView(
                            title: "No cases yet",
                            message: "Create your first damage case to start organising photo evidence and repair notes.",
                            systemImage: "folder.badge.plus"
                        )
                    } else {
                        ForEach(cases.prefix(4)) { damageCase in
                            NavigationLink(value: AppRoute.caseDetail(damageCase.id)) {
                                DamageCaseCard(
                                    damageCase: damageCase,
                                    photoCount: photoCount(for: damageCase.id),
                                    urgentCount: urgentCount(for: damageCase.id)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
    }

    private func photoCount(for caseID: UUID) -> Int {
        photos.filter { $0.caseId == caseID }.count
    }

    private func urgentCount(for caseID: UUID) -> Int {
        findings.filter { $0.caseId == caseID && $0.severity == .urgent && $0.userApproved }.count
    }
}

private struct QuickActionLink: View {
    var title: String
    var systemImage: String
    var route: AppRoute

    var body: some View {
        NavigationLink(value: route) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(.tint)
                Text(title)
                    .font(.headline)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

private struct StatTile: View {
    var title: String
    var value: String
    var systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold())
                .lineLimit(2)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
