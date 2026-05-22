import Foundation

struct MockAIService: AIService {
    func scanDamagePhoto(request: DamageScanRequest) async throws -> DamageScanResult {
        try await Task.sleep(nanoseconds: 700_000_000)

        let severity = suggestedSeverity(for: request.damageType, notes: request.userNotes)
        let category = request.damageType.displayName
        let location = request.locationLabel.isEmpty ? "documented area" : request.locationLabel

        let primary = DamageScanFinding(
            title: "Possible \(category.lowercased()) damage at \(location)",
            description: "The image appears to show visible signs that may be consistent with \(category.lowercased()) damage. This is a non-diagnostic visual suggestion and should be checked against site conditions.",
            category: category,
            severity: severity,
            confidence: confidence(for: severity),
            suggestedAction: suggestedAction(for: severity, damageType: request.damageType)
        )

        let secondary = DamageScanFinding(
            title: "Documentation quality check",
            description: "Capture wider context and close-up detail from the same angle where possible. Include a measuring reference when safe and practical.",
            category: "Evidence quality",
            severity: .low,
            confidence: 0.72,
            suggestedAction: "Add a second photo showing the surrounding area and any visible source or affected boundary."
        )

        return DamageScanResult(
            findings: [primary, secondary],
            summary: "Mock AI found visible, non-diagnostic signs requiring \(severity.rawValue.lowercased()) priority review. Findings use cautious language and require professional verification."
        )
    }

    func generateDamageSummary(for damageCase: DamageCase, findings: [DamageFinding]) async throws -> String {
        try await Task.sleep(nanoseconds: 300_000_000)
        let approved = findings.filter(\.userApproved)
        let count = approved.count == 1 ? "1 approved finding" : "\(approved.count) approved findings"
        let highest = approved.map(\.severity).max(by: { $0.sortRank < $1.sortRank }) ?? .low
        return "\(damageCase.title) includes \(count) for \(damageCase.damageType.displayName.lowercased()) damage at \(damageCase.location). The current highest visual priority is \(highest.rawValue.lowercased()). AI findings are suggestions only and should be reviewed by a qualified professional."
    }

    func generateRepairPriorityList(for damageCase: DamageCase, findings: [DamageFinding]) async throws -> [RepairPriorityItem] {
        try await Task.sleep(nanoseconds: 350_000_000)
        let approvedFindings = findings.filter(\.userApproved)
        let sourceFindings = approvedFindings.isEmpty ? findings : approvedFindings

        let generated = sourceFindings
            .sorted { $0.severity.sortRank > $1.severity.sortRank }
            .map { finding in
                RepairPriorityItem(
                    title: finding.title,
                    detail: finding.findingDescription,
                    severity: finding.severity,
                    recommendation: finding.suggestedAction
                )
            }

        if generated.isEmpty {
            return [
                RepairPriorityItem(
                    title: "Capture and review damage evidence",
                    detail: "No approved AI findings are currently attached to this case.",
                    severity: .medium,
                    recommendation: "Add labelled photos, run a scan, then approve relevant findings before issuing a client report."
                )
            ]
        }

        let safetyItem = RepairPriorityItem(
            title: "Professional review checkpoint",
            detail: "Before repair work begins, review visible findings against site conditions and relevant safety requirements.",
            severity: .high,
            recommendation: "Escalate urgent safety concerns to qualified professionals immediately."
        )

        return [safetyItem] + generated
    }

    func generateReportText(for damageCase: DamageCase, findings: [DamageFinding], priorities: [RepairPriorityItem]) async throws -> String {
        try await Task.sleep(nanoseconds: 300_000_000)
        let summary = try await generateDamageSummary(for: damageCase, findings: findings)
        let priorityText = priorities.prefix(3).map { "\($0.severity.rawValue): \($0.title)" }.joined(separator: "\n")
        return """
        DamageScope AI report for \(damageCase.title)

        Client: \(damageCase.clientName)
        Location: \(damageCase.location)
        Damage type: \(damageCase.damageType.displayName)

        Summary:
        \(summary)

        Priority highlights:
        \(priorityText)
        """
    }

    private func suggestedSeverity(for damageType: DamageType, notes: String) -> DamageSeverity {
        let loweredNotes = notes.lowercased()
        if loweredNotes.contains("unsafe") || loweredNotes.contains("urgent") || loweredNotes.contains("collapse") {
            return .urgent
        }

        switch damageType {
        case .fireSmoke, .roof, .storm, .waterLeak:
            return .high
        case .dampMould, .vehicle, .wallCeiling, .equipment:
            return .medium
        case .flooring, .exterior, .other:
            return .low
        }
    }

    private func confidence(for severity: DamageSeverity) -> Double {
        switch severity {
        case .urgent: 0.81
        case .high: 0.78
        case .medium: 0.74
        case .low: 0.68
        }
    }

    private func suggestedAction(for severity: DamageSeverity, damageType: DamageType) -> String {
        switch severity {
        case .urgent:
            return "Restrict access if safe to do so and arrange immediate review by a qualified professional."
        case .high:
            return "Schedule professional inspection and document surrounding areas before repair work proceeds."
        case .medium:
            return "Monitor, capture additional evidence, and request trade review before closing the case."
        case .low:
            return "Add supporting photos and include the item in routine maintenance review."
        }
    }
}
