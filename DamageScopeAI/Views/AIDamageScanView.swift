import SwiftData
import SwiftUI
import UIKit

struct AIDamageScanView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DamageCase.createdAt, order: .reverse) private var cases: [DamageCase]
    @Query(sort: \DamagePhoto.createdAt, order: .reverse) private var photos: [DamagePhoto]
    @State private var viewModel = DamageScanViewModel()
    @State private var selectedCaseID: UUID?
    @State private var selectedPhotoID: UUID?
    @State private var approvedFindingIDs = Set<UUID>()
    @State private var alertMessage: String?

    init(caseID: UUID? = nil) {
        _selectedCaseID = State(initialValue: caseID)
    }

    var body: some View {
        Form {
            if cases.isEmpty {
                EmptyStateView(
                    title: "No cases available",
                    message: "Create a damage case before scanning photo evidence.",
                    systemImage: "folder.badge.plus"
                )
            } else {
                Section("Scan target") {
                    Picker("Case", selection: $selectedCaseID) {
                        Text("Select case").tag(Optional<UUID>.none)
                        ForEach(cases) { damageCase in
                            Text(damageCase.title).tag(Optional(damageCase.id))
                        }
                    }

                    Picker("Photo", selection: $selectedPhotoID) {
                        Text("Select photo").tag(Optional<UUID>.none)
                        ForEach(casePhotos) { photo in
                            Text(photo.locationLabel.isEmpty ? photo.createdAt.damageScopeShortDate : photo.locationLabel)
                                .tag(Optional(photo.id))
                        }
                    }
                }

                if let selectedPhoto, let data = selectedPhoto.imageData, let image = UIImage(data: data) {
                    Section("Selected photo") {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 8))

                        Button {
                            runScan()
                        } label: {
                            if viewModel.isScanning {
                                ProgressView()
                            } else {
                                Label("Scan Photo", systemImage: "sparkles")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewModel.isScanning || selectedCase == nil)
                    }
                } else {
                    Section {
                        EmptyStateView(
                            title: "No photo selected",
                            message: "Add photo evidence to this case or select another case with photos.",
                            systemImage: "photo.badge.exclamationmark"
                        )
                    }
                }

                if !viewModel.summary.isEmpty {
                    Section("AI summary") {
                        Text(viewModel.summary)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if !viewModel.draftFindings.isEmpty {
                    Section("Review findings") {
                        ForEach(viewModel.draftFindings) { finding in
                            DamageFindingCard(
                                draft: finding,
                                approval: Binding(
                                    get: { approvedFindingIDs.contains(finding.id) },
                                    set: { isApproved in
                                        if isApproved {
                                            approvedFindingIDs.insert(finding.id)
                                        } else {
                                            approvedFindingIDs.remove(finding.id)
                                        }
                                    }
                                )
                            )
                        }

                        Button {
                            approveFindings()
                        } label: {
                            Label("Save Approved Findings", systemImage: "checkmark.circle")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
            }
        }
        .navigationTitle("AI Damage Scan")
        .onAppear {
            if selectedCaseID == nil {
                selectedCaseID = cases.first?.id
            }
            if selectedPhotoID == nil {
                selectedPhotoID = casePhotos.first?.id
            }
        }
        .onChange(of: selectedCaseID) { _, _ in
            selectedPhotoID = casePhotos.first?.id
            viewModel.draftFindings = []
            viewModel.summary = ""
            approvedFindingIDs = []
        }
        .alert("DamageScope AI", isPresented: Binding(
            get: { alertMessage != nil || viewModel.errorMessage != nil },
            set: { if !$0 { alertMessage = nil; viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? viewModel.errorMessage ?? "")
        }
    }

    private var selectedCase: DamageCase? {
        guard let selectedCaseID else { return nil }
        return cases.first { $0.id == selectedCaseID }
    }

    private var casePhotos: [DamagePhoto] {
        guard let selectedCaseID else { return [] }
        return photos.filter { $0.caseId == selectedCaseID }
    }

    private var selectedPhoto: DamagePhoto? {
        guard let selectedPhotoID else { return nil }
        return photos.first { $0.id == selectedPhotoID }
    }

    private func runScan() {
        guard let selectedCase, let selectedPhoto else { return }

        Task {
            await viewModel.scan(photo: selectedPhoto, damageCase: selectedCase)
            approvedFindingIDs = Set(viewModel.draftFindings.map(\.id))
        }
    }

    private func approveFindings() {
        guard let selectedCaseID, let selectedPhotoID else { return }
        let count = viewModel.approveFindings(
            ids: approvedFindingIDs,
            caseID: selectedCaseID,
            photoID: selectedPhotoID,
            in: modelContext
        )
        alertMessage = count == 1 ? "1 finding saved." : "\(count) findings saved."
    }
}
