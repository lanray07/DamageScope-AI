import Foundation

protocol AIService {
    func scanDamagePhoto(request: DamageScanRequest) async throws -> DamageScanResult
    func generateDamageSummary(for damageCase: DamageCase, findings: [DamageFinding]) async throws -> String
    func generateRepairPriorityList(for damageCase: DamageCase, findings: [DamageFinding]) async throws -> [RepairPriorityItem]
    func generateReportText(for damageCase: DamageCase, findings: [DamageFinding], priorities: [RepairPriorityItem]) async throws -> String
}

struct DamageScanRequest {
    var damageType: DamageType
    var locationLabel: String
    var userNotes: String
    var imageData: Data?
}

struct DamageScanResult {
    var findings: [DamageScanFinding]
    var summary: String
}

struct DamageScanFinding: Identifiable, Hashable {
    let id: UUID
    var title: String
    var description: String
    var category: String
    var severity: DamageSeverity
    var confidence: Double
    var suggestedAction: String

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        category: String,
        severity: DamageSeverity,
        confidence: Double,
        suggestedAction: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.severity = severity
        self.confidence = confidence
        self.suggestedAction = suggestedAction
    }
}

struct RepairPriorityItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var detail: String
    var severity: DamageSeverity
    var recommendation: String

    init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        severity: DamageSeverity,
        recommendation: String
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.severity = severity
        self.recommendation = recommendation
    }
}

enum AIServiceError: LocalizedError {
    case missingImage
    case invalidResponse
    case backendNotConfigured

    var errorDescription: String? {
        switch self {
        case .missingImage: "Add or capture a photo before scanning."
        case .invalidResponse: "The AI service returned an unreadable response."
        case .backendNotConfigured: "Configure a secure backend endpoint before enabling remote AI."
        }
    }
}
