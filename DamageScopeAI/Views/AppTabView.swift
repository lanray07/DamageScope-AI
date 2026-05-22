import SwiftUI

enum AppRoute: Hashable {
    case newCase
    case caseDetail(UUID)
    case photoEvidence(UUID?)
    case aiScan(UUID?)
    case evidenceOrganizer(UUID?)
    case repairPriority(UUID?)
    case reportGenerator(UUID?)
    case savedCases
    case paywall
}

struct AppTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label("Dashboard", systemImage: "gauge.with.dots.needle.67percent")
            }

            NavigationStack {
                SavedCasesView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label("Cases", systemImage: "folder")
            }

            NavigationStack {
                RepairPriorityListView(caseID: nil)
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label("Priorities", systemImage: "list.bullet.clipboard")
            }

            NavigationStack {
                PaywallView()
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                    }
            }
            .tabItem {
                Label("Plan", systemImage: "creditcard")
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .newCase:
            NewDamageCaseView()
        case .caseDetail(let id):
            CaseDetailView(caseID: id)
        case .photoEvidence(let id):
            PhotoEvidenceUploadView(caseID: id)
        case .aiScan(let id):
            AIDamageScanView(caseID: id)
        case .evidenceOrganizer(let id):
            EvidenceOrganizerView(caseID: id)
        case .repairPriority(let id):
            RepairPriorityListView(caseID: id)
        case .reportGenerator(let id):
            ReportGeneratorView(caseID: id)
        case .savedCases:
            SavedCasesView()
        case .paywall:
            PaywallView()
        }
    }
}
