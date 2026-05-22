import SwiftData
import SwiftUI

struct NewDamageCaseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CaseFormViewModel()

    var body: some View {
        Form {
            Section("Case details") {
                TextField("Case title", text: $viewModel.title)
                TextField("Client name", text: $viewModel.clientName)
                TextField("Property/location", text: $viewModel.location, axis: .vertical)

                Picker("Damage type", selection: $viewModel.damageType) {
                    ForEach(DamageType.allCases) { damageType in
                        Label(damageType.displayName, systemImage: damageType.iconName)
                            .tag(damageType)
                    }
                }

                DatePicker("Date discovered", selection: $viewModel.dateDiscovered, displayedComponents: .date)
            }

            Section("Notes and status") {
                TextField("Notes", text: $viewModel.notes, axis: .vertical)
                    .lineLimit(4, reservesSpace: true)

                Picker("Status", selection: $viewModel.status) {
                    ForEach(DamageStatus.allCases) { status in
                        Text(status.displayName).tag(status)
                    }
                }
            }
        }
        .navigationTitle("New Damage Case")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    if viewModel.save(in: modelContext) != nil {
                        dismiss()
                    }
                }
                .disabled(!viewModel.canSave)
            }
        }
        .alert("Case not saved", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}
