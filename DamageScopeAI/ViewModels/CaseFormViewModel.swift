import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class CaseFormViewModel {
    var title = ""
    var clientName = ""
    var location = ""
    var damageType: DamageType = .waterLeak
    var dateDiscovered = Date()
    var notes = ""
    var status: DamageStatus = .open
    var errorMessage: String?

    var canSave: Bool {
        !title.trimmed.isEmpty && !clientName.trimmed.isEmpty && !location.trimmed.isEmpty
    }

    func save(in context: ModelContext) -> DamageCase? {
        guard canSave else {
            errorMessage = "Add a case title, client name, and location."
            return nil
        }

        let damageCase = DamageCase(
            title: title.trimmed,
            clientName: clientName.trimmed,
            location: location.trimmed,
            damageType: damageType,
            dateDiscovered: dateDiscovered,
            notes: notes.trimmed,
            status: status
        )

        context.insert(damageCase)

        do {
            try context.save()
            return damageCase
        } catch {
            errorMessage = "Could not save the case. \(error.localizedDescription)"
            return nil
        }
    }
}
