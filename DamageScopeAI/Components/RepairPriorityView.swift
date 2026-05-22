import SwiftUI

struct RepairPriorityView: View {
    var priority: RepairPriorityItem

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(priority.title)
                    .font(.headline)
                Spacer()
                SeverityBadge(severity: priority.severity)
            }

            Text(priority.detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Label(priority.recommendation, systemImage: "arrow.forward.circle")
                .font(.subheadline.weight(.semibold))
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
