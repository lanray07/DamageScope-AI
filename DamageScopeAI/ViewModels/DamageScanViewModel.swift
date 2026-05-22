import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class DamageScanViewModel {
    var draftFindings: [DamageScanFinding] = []
    var summary = ""
    var isScanning = false
    var errorMessage: String?

    private let aiService: any AIService

    init(aiService: any AIService = MockAIService()) {
        self.aiService = aiService
    }

    func scan(photo: DamagePhoto, damageCase: DamageCase) async {
        guard photo.imageData != nil else {
            errorMessage = AIServiceError.missingImage.localizedDescription
            return
        }

        isScanning = true
        errorMessage = nil
        defer { isScanning = false }

        do {
            let request = DamageScanRequest(
                damageType: damageCase.damageType,
                locationLabel: photo.locationLabel,
                userNotes: [damageCase.notes, photo.caption].filter { !$0.isEmpty }.joined(separator: "\n"),
                imageData: photo.imageData
            )
            let result = try await aiService.scanDamagePhoto(request: request)
            draftFindings = result.findings
            summary = result.summary
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func approveFindings(
        ids: Set<UUID>,
        caseID: UUID,
        photoID: UUID,
        in context: ModelContext
    ) -> Int {
        let approvedDrafts = draftFindings.filter { ids.contains($0.id) }

        approvedDrafts.forEach { draft in
            context.insert(DamageFinding(
                caseId: caseID,
                photoId: photoID,
                title: draft.title,
                description: draft.description,
                category: draft.category,
                severity: draft.severity,
                confidence: draft.confidence,
                suggestedAction: draft.suggestedAction,
                userApproved: true
            ))
        }

        do {
            try context.save()
            return approvedDrafts.count
        } catch {
            errorMessage = "Could not save approved findings. \(error.localizedDescription)"
            return 0
        }
    }
}
