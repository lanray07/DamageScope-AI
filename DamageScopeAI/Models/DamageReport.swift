import Foundation
import SwiftData

@Model
final class DamageReport {
    @Attribute(.unique) var id: UUID
    var caseId: UUID
    var title: String
    var summary: String
    var pdfLocalURL: String?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        caseId: UUID,
        title: String,
        summary: String,
        pdfLocalURL: String?,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.caseId = caseId
        self.title = title
        self.summary = summary
        self.pdfLocalURL = pdfLocalURL
        self.createdAt = createdAt
    }

    var pdfURL: URL? {
        guard let pdfLocalURL else { return nil }
        return URL(fileURLWithPath: pdfLocalURL)
    }
}
