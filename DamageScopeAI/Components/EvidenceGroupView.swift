import SwiftUI

struct EvidenceGroupView: View {
    var title: String
    var photos: [DamagePhoto]

    private let columns = [
        GridItem(.adaptive(minimum: 220), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(photos) { photo in
                    EvidencePhotoEditor(photo: photo)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct EvidencePhotoEditor: View {
    @Bindable var photo: DamagePhoto

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DamagePhotoCard(photo: photo)

            TextField("Caption", text: $photo.caption, axis: .vertical)
                .textFieldStyle(.roundedBorder)

            TextField("Area", text: $photo.areaGroup)
                .textFieldStyle(.roundedBorder)

            Picker("Stage", selection: $photo.beforeAfterTypeRaw) {
                ForEach(BeforeAfterType.allCases) { type in
                    Text(type.displayName).tag(type.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Toggle("Relevant to report", isOn: $photo.isRelevant)
        }
    }
}
