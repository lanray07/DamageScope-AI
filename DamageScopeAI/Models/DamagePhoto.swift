import Foundation
import SwiftData

@Model
final class DamagePhoto {
    @Attribute(.unique) var id: UUID
    var caseId: UUID
    @Attribute(.externalStorage) var imageData: Data?
    var locationLabel: String
    var caption: String
    var beforeAfterTypeRaw: String
    var areaGroup: String
    var isRelevant: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        caseId: UUID,
        imageData: Data?,
        locationLabel: String,
        caption: String,
        beforeAfterType: BeforeAfterType,
        areaGroup: String,
        isRelevant: Bool = true,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.caseId = caseId
        self.imageData = imageData
        self.locationLabel = locationLabel
        self.caption = caption
        self.beforeAfterTypeRaw = beforeAfterType.rawValue
        self.areaGroup = areaGroup
        self.isRelevant = isRelevant
        self.createdAt = createdAt
    }

    var beforeAfterType: BeforeAfterType {
        get { BeforeAfterType(rawValue: beforeAfterTypeRaw) ?? .during }
        set { beforeAfterTypeRaw = newValue.rawValue }
    }
}
