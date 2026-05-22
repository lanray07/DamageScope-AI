import SwiftData
import SwiftUI

struct RepairPriorityListView: View {
    @Query(sort: \DamageCase.createdAt, order: .reverse) private var cases: [DamageCase]
    @Query(sort: \DamageFinding.createdAt, order: .reverse) private var findings: [DamageFinding]
    @State private var selectedCaseID: UUID?
    @State private var viewModel = ReportViewModel()

    init(caseID: UUID? = nil) {
        _selectedCaseID = State(initialValue: caseID)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if cases.isEmpty {
                    EmptyStateView(
                        title: "No cases available",
                        message: "Create and scan a case before generating repair priorities.",
                        systemImage: "folder.badge.plus"
                    )
                } else {
                    Picker("Case", selection: $selectedCaseID) {
                        Text("Select case").tag(Optional<UUID>.none)
                        ForEach(cases) { damageCase in
                            Text(damageCase.title).tag(Optional(damageCase.id))
                        }
                    }
                    .pickerStyle(.menu)

                    Button {
                        generatePriorities()
                    } label: {
                        if viewModel.isGenerating {
                            ProgressView()
                        } else {
                            Label("Generate Priority List", systemImage: "wand.and.stars")
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedCase == nil || viewModel.isGenerating)

                    if viewModel.priorities.isEmpty {
                        EmptyStateView(
                            title: "No priorities generated",
                            message: "Generate a list after approving AI findings for this case.",
                            systemImage: "list.bullet.clipboard"
                        )
                    } else {
                        ForEach(viewModel.priorities) { priority in
                            RepairPriorityView(priority: priority)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Repair Priorities")
        .onAppear {
            if selectedCaseID == nil {
                selectedCaseID = cases.first?.id
            }
            if viewModel.priorities.isEmpty {
                generatePriorities()
            }
        }
        .onChange(of: selectedCaseID) { _, _ in
            viewModel.priorities = []
        }
        .alert("Priority list error", isPresented: Binding(
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

    private var selectedFindings: [DamageFinding] {
        guard let selectedCaseID else { return [] }
        return findings.filter { $0.caseId == selectedCaseID }
    }

    private func generatePriorities() {
        guard let selectedCase else { return }
        Task {
            await viewModel.generatePriorities(for: selectedCase, findings: selectedFindings)
        }
    }
}
