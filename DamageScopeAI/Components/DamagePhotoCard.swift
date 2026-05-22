import SwiftUI
import UIKit

struct DamagePhotoCard: View {
    var photo: DamagePhoto

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let data = photo.imageData, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            HStack {
                Text(photo.beforeAfterType.displayName)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(Capsule())
                Spacer()
                if !photo.isRelevant {
                    Text("Excluded")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }

            Text(photo.locationLabel.isEmpty ? photo.areaGroup : photo.locationLabel)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            if !photo.caption.isEmpty {
                Text(photo.caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
