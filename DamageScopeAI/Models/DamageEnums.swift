import Foundation

enum UserType: String, CaseIterable, Identifiable, Codable {
    case contractor
    case landlord
    case propertyManager
    case roofer
    case fleetManager
    case restorationCompany
    case insuranceSupport

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .contractor: "Contractor"
        case .landlord: "Landlord"
        case .propertyManager: "Property manager"
        case .roofer: "Roofer"
        case .fleetManager: "Fleet manager"
        case .restorationCompany: "Restoration company"
        case .insuranceSupport: "Insurance support"
        }
    }
}

enum DamageType: String, CaseIterable, Identifiable, Codable {
    case roof
    case storm
    case waterLeak
    case dampMould
    case fireSmoke
    case vehicle
    case flooring
    case wallCeiling
    case exterior
    case equipment
    case other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .roof: "Roof"
        case .storm: "Storm"
        case .waterLeak: "Water leak"
        case .dampMould: "Damp/mould"
        case .fireSmoke: "Fire/smoke"
        case .vehicle: "Vehicle"
        case .flooring: "Flooring"
        case .wallCeiling: "Wall/ceiling"
        case .exterior: "Exterior"
        case .equipment: "Equipment"
        case .other: "Other"
        }
    }

    var iconName: String {
        switch self {
        case .roof: "house.lodge"
        case .storm: "cloud.bolt.rain"
        case .waterLeak: "drop.triangle"
        case .dampMould: "humidity"
        case .fireSmoke: "flame"
        case .vehicle: "car.side"
        case .flooring: "square.grid.3x3"
        case .wallCeiling: "rectangle.3.group"
        case .exterior: "building.2"
        case .equipment: "wrench.and.screwdriver"
        case .other: "questionmark.folder"
        }
    }
}

enum DamageStatus: String, CaseIterable, Identifiable, Codable {
    case open
    case inReview
    case quoted
    case repairScheduled
    case repaired
    case archived

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .open: "Open"
        case .inReview: "In review"
        case .quoted: "Quoted"
        case .repairScheduled: "Repair scheduled"
        case .repaired: "Repaired"
        case .archived: "Archived"
        }
    }
}

enum BeforeAfterType: String, CaseIterable, Identifiable, Codable {
    case before
    case during
    case after

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .before: "Before"
        case .during: "Current"
        case .after: "After"
        }
    }
}

enum DamageSeverity: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case urgent = "Urgent"

    var id: String { rawValue }

    var sortRank: Int {
        switch self {
        case .low: 0
        case .medium: 1
        case .high: 2
        case .urgent: 3
        }
    }
}

enum SubscriptionPlan: String, CaseIterable, Identifiable, Codable {
    case free
    case pro
    case business

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .free: "Free"
        case .pro: "Pro"
        case .business: "Business"
        }
    }
}
