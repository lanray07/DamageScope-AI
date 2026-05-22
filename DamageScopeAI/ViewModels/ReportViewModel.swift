import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class ReportViewModel {
    var priorities: [RepairPriorityItem] = []
    var summary = ""
    var reportText = ""
    var pdfURL: URL?
    var isGenerating = false
    var errorMessage: String?

    private let aiService: any AIService

    init(aiService: any AIService = MockAIService()) {
        self.aiService = aiService
    }

    func generatePriorities(for damageCase: DamageCase, findings: [DamageFinding]) async {
        isGenerating = true
        defer { isGenerating = false }

        do {
            priorities = try await aiService.generateRepairPriorityList(for: damageCase, findings: findings)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func generateReport(
        for damageCase: DamageCase,
        photos: [DamagePhoto],
        findings: [DamageFinding],
        plan: SubscriptionPlan,
        in context: ModelContext
    ) async {
        isGenerating = true
        defer { isGenerating = false }

        do {
            summary = try await aiService.generateDamageSummary(for: damageCase, findings: findings)
            priorities = try await aiService.generateRepairPriorityList(for: damageCase, findings: findings)
            reportText = try await aiService.generateReportText(for: damageCase, findings: findings, priorities: priorities)

            let url = try PDFReportGenerator.generate(
                damageCase: damageCase,
                photos: photos,
                findings: findings,
                priorities: priorities,
                summary: summary,
                plan: plan
            )
            pdfURL = url

            context.insert(DamageReport(
                caseId: damageCase.id,
                title: "\(damageCase.title) Report",
                summary: summary,
                pdfLocalURL: url.path
            ))
            try context.save()
        } catch {
            errorMessage = "Could not generate report. \(error.localizedDescription)"
        }
    }
}
