import Foundation
import SwiftData

@Model
final class DamageFinding {
    @Attribute(.unique) var id: UUID
    var caseId: UUID
    var photoId: UUID?
    var title: String
    var findingDescription: String
    var category: String
    var severityRaw: String
    var confidence: Double
    var suggestedAction: String
    var userApproved: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        caseId: UUID,
        photoId: UUID?,
        title: String,
        description: String,
        category: String,
        severity: DamageSeverity,
        confidence: Double,
        suggestedAction: String,
        userApproved: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.caseId = caseId
        self.photoId = photoId
        self.title = title
        self.findingDescription = description
        self.category = category
        self.severityRaw = severity.rawValue
        self.confidence = confidence
        self.suggestedAction = suggestedAction
        self.userApproved = userApproved
        self.createdAt = createdAt
    }

    var severity: DamageSeverity {
        get { DamageSeverity(rawValue: severityRaw) ?? .medium }
        set { severityRaw = newValue.rawValue }
    }
}
