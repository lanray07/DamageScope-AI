import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct PhotoEvidenceUploadView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DamageCase.createdAt, order: .reverse) private var cases: [DamageCase]
    @State private var viewModel: PhotoEvidenceViewModel
    @State private var selectedItem: PhotosPickerItem?
    @State private var cameraImage: UIImage?
    @State private var showCamera = false
    @State private var alertMessage: String?

    private var alertIsPresented: Binding<Bool> {
        Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )
    }

    init(caseID: UUID? = nil) {
        _viewModel = State(initialValue: PhotoEvidenceViewModel(caseID: caseID))
    }

    var body: some View {
        Form {
            CasePickerSection(cases: cases, selectedCaseID: $viewModel.selectedCaseID)
            PhotoSection(
                photoData: viewModel.photoData,
                selectedItem: $selectedItem,
                showCamera: $showCamera
            )
            EvidenceDetailsSection(
                locationLabel: $viewModel.locationLabel,
                areaGroup: $viewModel.areaGroup,
                caption: $viewModel.caption,
                beforeAfterType: $viewModel.beforeAfterType,
                isRelevant: $viewModel.isRelevant
            )
        }
        .navigationTitle("Photo Evidence")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save", action: savePhoto)
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            loadSelectedPhoto(newItem)
        }
        .onAppear {
            selectDefaultCaseIfNeeded()
        }
        .onChange(of: cameraImage) { _, newImage in
            viewModel.setCameraImage(newImage)
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $cameraImage)
        }
        .alert("DamageScope AI", isPresented: alertIsPresented) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func loadSelectedPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }

        Task {
            await viewModel.loadPhotoData {
                try await item.loadTransferable(type: Data.self)
            }
        }
    }

    private func selectDefaultCaseIfNeeded() {
        if viewModel.selectedCaseID == nil {
            viewModel.selectedCaseID = cases.first?.id
        }
    }

    private func savePhoto() {
        if viewModel.savePhoto(in: modelContext) != nil {
            alertMessage = "Photo evidence saved."
        } else {
            alertMessage = viewModel.errorMessage
        }
    }
}

private struct CasePickerSection: View {
    let cases: [DamageCase]
    @Binding var selectedCaseID: UUID?

    var body: some View {
        Section("Case") {
            Picker("Damage case", selection: $selectedCaseID) {
                Text("Select case").tag(Optional<UUID>.none)
                ForEach(cases) { damageCase in
                    Text(damageCase.title).tag(Optional(damageCase.id))
                }
            }
        }
    }
}

private struct PhotoSection: View {
    let photoData: Data?
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var showCamera: Bool

    var body: some View {
        Section("Photo") {
            PhotoPreview(photoData: photoData)
            PhotoSourceControls(selectedItem: $selectedItem, showCamera: $showCamera)
        }
    }
}

private struct PhotoPreview: View {
    let photoData: Data?

    var body: some View {
        if let photoData, let image = UIImage(data: photoData) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, minHeight: 220, maxHeight: 260)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .accessibilityLabel("Selected damage photo")
        } else {
            EmptyStateView(
                title: "No photo selected",
                message: "Take or upload a photo to attach evidence.",
                systemImage: "photo"
            )
        }
    }
}

private struct PhotoSourceControls: View {
    @Binding var selectedItem: PhotosPickerItem?
    @Binding var showCamera: Bool

    var body: some View {
        HStack {
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("Upload", systemImage: "photo.on.rectangle")
            }
            .buttonStyle(.bordered)

            Button {
                showCamera = true
            } label: {
                Label("Camera", systemImage: "camera")
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct EvidenceDetailsSection: View {
    @Binding var locationLabel: String
    @Binding var areaGroup: String
    @Binding var caption: String
    @Binding var beforeAfterType: BeforeAfterType
    @Binding var isRelevant: Bool

    var body: some View {
        Section("Evidence details") {
            TextField("Location label", text: $locationLabel)
            TextField("Area group", text: $areaGroup)
            TextField("Caption", text: $caption, axis: .vertical)
                .lineLimit(3, reservesSpace: true)

            Picker("Stage", selection: $beforeAfterType) {
                ForEach(BeforeAfterType.allCases) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Relevant to report", isOn: $isRelevant)
        }
    }
}
