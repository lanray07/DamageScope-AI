import SwiftUI

struct UpgradeBanner: View {
    var statusText: String

    var body: some View {
        NavigationLink(value: AppRoute.paywall) {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.tint)

                VStack(alignment: .leading, spacing: 4) {
                    Text(statusText)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text("Upgrade for higher scan limits, priority lists, and professional reports.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}
