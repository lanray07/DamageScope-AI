import SwiftUI

struct ReportPreviewView: View {
    var damageCase: DamageCase?
    var photos: [DamagePhoto]
    var findings: [DamageFinding]
    var priorities: [RepairPriorityItem]
    var summary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Report preview")
                .font(.title3.bold())

            if let damageCase {
                ReportPreviewRow(label: "Case", value: damageCase.title)
                ReportPreviewRow(label: "Client", value: damageCase.clientName)
                ReportPreviewRow(label: "Location", value: damageCase.location)
                ReportPreviewRow(label: "Damage type", value: damageCase.damageType.displayName)
            } else {
                Text("Select a case to preview report sections.")
                    .foregroundStyle(.secondary)
            }

            Divider()

            ReportPreviewRow(label: "Photo evidence", value: "\(photos.count) included")
            ReportPreviewRow(label: "Approved findings", value: "\(findings.count)")
            ReportPreviewRow(label: "Repair priorities", value: "\(priorities.count)")

            if !summary.isEmpty {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Included disclaimer")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                ForEach(AppConstants.disclaimers.prefix(5), id: \.self) { disclaimer in
                    Text("- \(disclaimer)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct ReportPreviewRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
    }
}
