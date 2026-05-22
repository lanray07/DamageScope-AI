import SwiftData
import SwiftUI

struct SavedCasesView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionService.self) private var subscriptionService
    @Query(sort: \DamageCase.createdAt, order: .reverse) private var cases: [DamageCase]
    @Query(sort: \DamagePhoto.createdAt, order: .reverse) private var photos: [DamagePhoto]
    @Query(sort: \DamageFinding.createdAt, order: .reverse) private var findings: [DamageFinding]
    @State private var searchText = ""
    @State private var damageTypeFilter: DamageType?
    @State private var statusFilter: DamageStatus?
    @State private var severityFilter: DamageSeverity?
    @State private var shareItem: ShareItem?
    @State private var errorMessage: String?

    var body: some View {
        List {
            Section {
                FilterPicker(title: "Damage", selection: $damageTypeFilter, values: DamageType.allCases, label: \.displayName)
                FilterPicker(title: "Status", selection: $statusFilter, values: DamageStatus.allCases, label: \.displayName)
                FilterPicker(title: "Severity", selection: $severityFilter, values: DamageSeverity.allCases, label: \.rawValue)
            }

            if filteredCases.isEmpty {
                EmptyStateView(
                    title: "No matching cases",
                    message: "Adjust filters or create a new case.",
                    systemImage: "magnifyingglass"
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(filteredCases) { damageCase in
                    NavigationLink(value: AppRoute.caseDetail(damageCase.id)) {
                        DamageCaseCard(
                            damageCase: damageCase,
                            photoCount: photos.filter { $0.caseId == damageCase.id }.count,
                            urgentCount: findings.filter { $0.caseId == damageCase.id && $0.severity == .urgent }.count
                        )
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            duplicateCase(damageCase)
                        } label: {
                            Label("Duplicate", systemImage: "plus.square.on.square")
                        }

                        Button {
                            Task { await exportCase(damageCase) }
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Saved Cases")
        .searchable(text: $searchText, prompt: "Client, location, or date")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: AppRoute.newCase) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("New damage case")
            }
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
        }
        .alert("Export error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var filteredCases: [DamageCase] {
        cases.filter { damageCase in
            let query = searchText.trimmed.lowercased()
            let searchable = [
                damageCase.title,
                damageCase.clientName,
                damageCase.location,
                damageCase.dateDiscovered.damageScopeShortDate
            ]
            .joined(separator: " ")
            .lowercased()

            let matchesSearch = query.isEmpty || searchable.contains(query)
            let matchesDamage = damageTypeFilter == nil || damageCase.damageType == damageTypeFilter
            let matchesStatus = statusFilter == nil || damageCase.status == statusFilter
            let matchesSeverity = severityFilter == nil || findings.contains { finding in
                finding.caseId == damageCase.id && finding.severity == severityFilter
            }

            return matchesSearch && matchesDamage && matchesStatus && matchesSeverity
        }
    }

    private func duplicateCase(_ damageCase: DamageCase) {
        let copy = DamageCase(
            title: "\(damageCase.title) Copy",
            clientName: damageCase.clientName,
            location: damageCase.location,
            damageType: damageCase.damageType,
            dateDiscovered: damageCase.dateDiscovered,
            notes: damageCase.notes,
            status: .open
        )
        modelContext.insert(copy)

        var photoIDMap: [UUID: UUID] = [:]
        photos.filter { $0.caseId == damageCase.id }.forEach { photo in
            let photoCopy = DamagePhoto(
                caseId: copy.id,
                imageData: photo.imageData,
                locationLabel: photo.locationLabel,
                caption: photo.caption,
                beforeAfterType: photo.beforeAfterType,
                areaGroup: photo.areaGroup,
                isRelevant: photo.isRelevant
            )
            photoIDMap[photo.id] = photoCopy.id
            modelContext.insert(photoCopy)
        }

        findings.filter { $0.caseId == damageCase.id }.forEach { finding in
            modelContext.insert(DamageFinding(
                caseId: copy.id,
                photoId: finding.photoId.flatMap { photoIDMap[$0] },
                title: finding.title,
                description: finding.findingDescription,
                category: finding.category,
                severity: finding.severity,
                confidence: finding.confidence,
                suggestedAction: finding.suggestedAction,
                userApproved: finding.userApproved
            ))
        }

        try? modelContext.save()
    }

    @MainActor
    private func exportCase(_ damageCase: DamageCase) async {
        do {
            let casePhotos = photos.filter { $0.caseId == damageCase.id && $0.isRelevant }
            let caseFindings = findings.filter { $0.caseId == damageCase.id && $0.userApproved }
            let aiService = MockAIService()
            let priorities = try await aiService.generateRepairPriorityList(for: damageCase, findings: caseFindings)
            let summary = try await aiService.generateDamageSummary(for: damageCase, findings: caseFindings)
            let url = try PDFReportGenerator.generate(
                damageCase: damageCase,
                photos: casePhotos,
                findings: caseFindings,
                priorities: priorities,
                summary: summary,
                plan: subscriptionService.currentPlan
            )
            modelContext.insert(DamageReport(
                caseId: damageCase.id,
                title: "\(damageCase.title) Report",
                summary: summary,
                pdfLocalURL: url.path
            ))
            try modelContext.save()
            shareItem = ShareItem(url: url)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

private struct FilterPicker<Value: Identifiable & Hashable>: View {
    var title: String
    @Binding var selection: Value?
    var values: [Value]
    var label: (Value) -> String

    var body: some View {
        Picker(title, selection: $selection) {
            Text("Any \(title.lowercased())").tag(Optional<Value>.none)
            ForEach(values) { value in
                Text(label(value)).tag(Optional(value))
            }
        }
    }
}
