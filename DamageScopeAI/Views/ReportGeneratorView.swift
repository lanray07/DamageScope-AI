import SwiftData
import SwiftUI

struct ReportGeneratorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SubscriptionService.self) private var subscriptionService
    @Query(sort: \DamageCase.createdAt, order: .reverse) private var cases: [DamageCase]
    @Query(sort: \DamagePhoto.createdAt, order: .reverse) private var photos: [DamagePhoto]
    @Query(sort: \DamageFinding.createdAt, order: .reverse) private var findings: [DamageFinding]
    @State private var selectedCaseID: UUID?
    @State private var viewModel = ReportViewModel()
    @State private var shareItem: ShareItem?

    init(caseID: UUID? = nil) {
        _selectedCaseID = State(initialValue: caseID)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if cases.isEmpty {
                    EmptyStateView(
                        title: "No cases available",
                        message: "Create a case and approve findings before exporting a PDF report.",
                        systemImage: "doc.badge.plus"
                    )
                } else {
                    Picker("Case", selection: $selectedCaseID) {
                        Text("Select case").tag(Optional<UUID>.none)
                        ForEach(cases) { damageCase in
                            Text(damageCase.title).tag(Optional(damageCase.id))
                        }
                    }
                    .pickerStyle(.menu)

                    ReportPreviewView(
                        damageCase: selectedCase,
                        photos: selectedPhotos,
                        findings: selectedFindings,
                        priorities: viewModel.priorities,
                        summary: viewModel.summary
                    )

                    Button {
                        generateReport()
                    } label: {
                        if viewModel.isGenerating {
                            ProgressView()
                        } else {
                            Label("Generate Client PDF", systemImage: "square.and.arrow.up")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedCase == nil || viewModel.isGenerating)

                    if let pdfURL = viewModel.pdfURL {
                        Button {
                            shareItem = ShareItem(url: pdfURL)
                        } label: {
                            Label("Share PDF", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Report Generator")
        .onAppear {
            if selectedCaseID == nil {
                selectedCaseID = cases.first?.id
            }
        }
        .onChange(of: selectedCaseID) { _, _ in
            viewModel.summary = ""
            viewModel.priorities = []
            viewModel.reportText = ""
            viewModel.pdfURL = nil
        }
        .sheet(item: $shareItem) { item in
            ShareSheet(activityItems: [item.url])
        }
        .alert("Report error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var selectedCase: DamageCase? {
        guard let selectedCaseID else { return nil }
        return cases.first { $0.id == selectedCaseID }
    }

    private var selectedPhotos: [DamagePhoto] {
        guard let selectedCaseID else { return [] }
        return photos.filter { $0.caseId == selectedCaseID && $0.isRelevant }
    }

    private var selectedFindings: [DamageFinding] {
        guard let selectedCaseID else { return [] }
        return findings.filter { $0.caseId == selectedCaseID && $0.userApproved }
    }

    private func generateReport() {
        guard let selectedCase else { return }
        Task {
            await viewModel.generateReport(
                for: selectedCase,
                photos: selectedPhotos,
                findings: selectedFindings,
                plan: subscriptionService.currentPlan,
                in: modelContext
            )
        }
    }
}
