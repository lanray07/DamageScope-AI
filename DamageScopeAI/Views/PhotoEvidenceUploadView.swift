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

    init(caseID: UUID? = nil) {
        _viewModel = State(initialValue: PhotoEvidenceViewModel(caseID: caseID))
    }

    var body: some View {
        Form {
            Section("Case") {
                Picker("Damage case", selection: $viewModel.selectedCaseID) {
                    Text("Select case").tag(Optional<UUID>.none)
                    ForEach(cases) { damageCase in
                        Text(damageCase.title).tag(Optional(damageCase.id))
                    }
                }
            }

            Section("Photo") {
                if let data = viewModel.photoData, let image = UIImage(data: data) {
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

            Section("Evidence details") {
                TextField("Location label", text: $viewModel.locationLabel)
                TextField("Area group", text: $viewModel.areaGroup)
                TextField("Caption", text: $viewModel.caption, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)

                Picker("Stage", selection: $viewModel.beforeAfterType) {
                    ForEach(BeforeAfterType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Relevant to report", isOn: $viewModel.isRelevant)
            }
        }
        .navigationTitle("Photo Evidence")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    if viewModel.savePhoto(in: modelContext) != nil {
                        alertMessage = "Photo evidence saved."
                    } else {
                        alertMessage = viewModel.errorMessage
                    }
                }
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                await viewModel.loadTransferable(from: newItem)
            }
        }
        .onAppear {
            if viewModel.selectedCaseID == nil {
                viewModel.selectedCaseID = cases.first?.id
            }
        }
        .onChange(of: cameraImage) { _, newImage in
            viewModel.setCameraImage(newImage)
        }
        .sheet(isPresented: $showCamera) {
            CameraPicker(image: $cameraImage)
        }
        .alert("DamageScope AI", isPresented: Binding(
            get: { alertMessage != nil },
            set: { if !$0 { alertMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage ?? "")
        }
    }
}
