import SwiftUI

struct DamageCaseCard: View {
    var damageCase: DamageCase
    var photoCount: Int
    var urgentCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: damageCase.damageType.iconName)
                    .font(.title2)
                    .foregroundStyle(.tint)

                VStack(alignment: .leading, spacing: 4) {
                    Text(damageCase.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("\(damageCase.clientName) - \(damageCase.location)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Text(damageCase.status.displayName)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(Color(.tertiarySystemFill))
                    .clipShape(Capsule())
            }

            HStack(spacing: 12) {
                Label(damageCase.damageType.displayName, systemImage: "tag")
                Label("\(photoCount) photos", systemImage: "photo")
                if urgentCount > 0 {
                    Label("\(urgentCount) urgent", systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
