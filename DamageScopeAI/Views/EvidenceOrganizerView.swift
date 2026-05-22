import SwiftData
import SwiftUI

struct EvidenceOrganizerView: View {
    @Query(sort: \DamageCase.createdAt, order: .reverse) private var cases: [DamageCase]
    @Query(sort: \DamagePhoto.createdAt, order: .reverse) private var photos: [DamagePhoto]
    @State private var selectedCaseID: UUID?

    init(caseID: UUID? = nil) {
        _selectedCaseID = State(initialValue: caseID)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if cases.isEmpty {
                    EmptyStateView(
                        title: "No cases available",
                        message: "Create a damage case before organising evidence.",
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

                    if selectedPhotos.isEmpty {
                        EmptyStateView(
                            title: "No photos",
                            message: "Add photo evidence before building before/after comparisons.",
                            systemImage: "photo.stack"
                        )
                    } else {
                        BeforeAfterComparisonView(photos: selectedPhotos)

                        ForEach(groupedPhotoKeys, id: \.self) { key in
                            EvidenceGroupView(title: key, photos: groupedPhotos[key] ?? [])
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Evidence Organizer")
        .onAppear {
            if selectedCaseID == nil {
                selectedCaseID = cases.first?.id
            }
        }
    }

    private var selectedPhotos: [DamagePhoto] {
        guard let selectedCaseID else { return [] }
        return photos.filter { $0.caseId == selectedCaseID }
    }

    private var groupedPhotos: [String: [DamagePhoto]] {
        Dictionary(grouping: selectedPhotos) { photo in
            photo.areaGroup.isEmpty ? "General" : photo.areaGroup
        }
    }

    private var groupedPhotoKeys: [String] {
        groupedPhotos.keys.sorted()
    }
}

private struct BeforeAfterComparisonView: View {
    var photos: [DamagePhoto]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Before/after")
                .font(.title3.bold())

            if let beforePhoto, let afterPhoto {
                HStack(alignment: .top, spacing: 12) {
                    DamagePhotoCard(photo: beforePhoto)
                    DamagePhotoCard(photo: afterPhoto)
                }
            } else {
                Text("Mark photos as before and after to build a comparison pair.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var beforePhoto: DamagePhoto? {
        photos.first { $0.beforeAfterType == .before && $0.isRelevant }
    }

    private var afterPhoto: DamagePhoto? {
        photos.first { $0.beforeAfterType == .after && $0.isRelevant }
    }
}
