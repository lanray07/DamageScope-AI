import Foundation
import SwiftData

@Model
final class DamageCase {
    @Attribute(.unique) var id: UUID
    var title: String
    var clientName: String
    var location: String
    var damageTypeRaw: String
    var dateDiscovered: Date
    var notes: String
    var statusRaw: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        clientName: String,
        location: String,
        damageType: DamageType,
        dateDiscovered: Date,
        notes: String,
        status: DamageStatus = .open,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.clientName = clientName
        self.location = location
        self.damageTypeRaw = damageType.rawValue
        self.dateDiscovered = dateDiscovered
        self.notes = notes
        self.statusRaw = status.rawValue
        self.createdAt = createdAt
    }

    var damageType: DamageType {
        get { DamageType(rawValue: damageTypeRaw) ?? .other }
        set { damageTypeRaw = newValue.rawValue }
    }

    var status: DamageStatus {
        get { DamageStatus(rawValue: statusRaw) ?? .open }
        set { statusRaw = newValue.rawValue }
    }
}
