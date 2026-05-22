import SwiftUI

struct SeverityBadge: View {
    var severity: DamageSeverity

    var body: some View {
        Text(severity.rawValue)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .foregroundStyle(severity.foregroundColor)
            .background(severity.tintColor.opacity(0.18))
            .clipShape(Capsule())
    }
}

extension DamageSeverity {
    var tintColor: Color {
        switch self {
        case .low: .green
        case .medium: .yellow
        case .high: .orange
        case .urgent: .red
        }
    }

    var foregroundColor: Color {
        switch self {
        case .medium: .black
        default: tintColor
        }
    }
}
