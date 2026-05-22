import Foundation
import Observation
import PhotosUI
import SwiftData
import UIKit

@MainActor
@Observable
final class PhotoEvidenceViewModel {
    var selectedCaseID: UUID?
    var locationLabel = ""
    var caption = ""
    var beforeAfterType: BeforeAfterType = .during
    var areaGroup = "General"
    var isRelevant = true
    var photoData: Data?
    var isLoading = false
    var errorMessage: String?
    var successMessage: String?

    init(caseID: UUID? = nil) {
        selectedCaseID = caseID
    }

    func loadTransferable(from item: PhotosPickerItem?) async {
        guard let item else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                photoData = data
            } else {
                errorMessage = "The selected image could not be loaded."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func setCameraImage(_ image: UIImage?) {
        guard let image else { return }
        photoData = ImageUtilities.jpegData(from: image)
    }

    func savePhoto(in context: ModelContext) -> DamagePhoto? {
        guard let selectedCaseID else {
            errorMessage = "Choose a case before saving evidence."
            return nil
        }

        guard let photoData else {
            errorMessage = "Add or capture a photo first."
            return nil
        }

        let photo = DamagePhoto(
            caseId: selectedCaseID,
            imageData: photoData,
            locationLabel: locationLabel.trimmed,
            caption: caption.trimmed,
            beforeAfterType: beforeAfterType,
            areaGroup: areaGroup.trimmed.isEmpty ? "General" : areaGroup.trimmed,
            isRelevant: isRelevant
        )

        context.insert(photo)

        do {
            try context.save()
            successMessage = "Photo evidence saved."
            resetEvidenceFields(keepCase: true)
            return photo
        } catch {
            errorMessage = "Could not save photo evidence. \(error.localizedDescription)"
            return nil
        }
    }

    private func resetEvidenceFields(keepCase: Bool) {
        if !keepCase {
            selectedCaseID = nil
        }
        locationLabel = ""
        caption = ""
        beforeAfterType = .during
        areaGroup = "General"
        isRelevant = true
        photoData = nil
    }
}
