import SwiftUI

struct DamageFindingCard: View {
    private var title: String
    private var description: String
    private var category: String
    private var severity: DamageSeverity
    private var confidence: Double
    private var suggestedAction: String
    private var approval: Binding<Bool>?

    init(finding: DamageFinding) {
        self.title = finding.title
        self.description = finding.findingDescription
        self.category = finding.category
        self.severity = finding.severity
        self.confidence = finding.confidence
        self.suggestedAction = finding.suggestedAction
        self.approval = nil
    }

    init(draft: DamageScanFinding, approval: Binding<Bool>? = nil) {
        self.title = draft.title
        self.description = draft.description
        self.category = draft.category
        self.severity = draft.severity
        self.confidence = draft.confidence
        self.suggestedAction = draft.suggestedAction
        self.approval = approval
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(category)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                SeverityBadge(severity: severity)
            }

            Text(description)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text("Suggested next action")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(suggestedAction)
                    .font(.subheadline)
            }

            HStack {
                Label("\(Int(confidence * 100))% confidence", systemImage: "gauge.with.dots.needle.50percent")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if let approval {
                    Toggle("Approve", isOn: approval)
                        .labelsHidden()
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
