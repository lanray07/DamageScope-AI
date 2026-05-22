import Foundation

struct RemoteAIService: AIService {
    var endpoint: URL = AppConstants.backendEndpoint
    private let fallback = MockAIService()

    func scanDamagePhoto(request: DamageScanRequest) async throws -> DamageScanResult {
        guard endpoint.absoluteString != "https://YOUR_BACKEND_URL.com/damagescope-ai" else {
            throw AIServiceError.backendNotConfigured
        }

        let payload = RemoteDamageScanRequest(
            damageType: request.damageType.displayName,
            locationLabel: request.locationLabel,
            userNotes: request.userNotes,
            imageBase64: request.imageData?.base64EncodedString() ?? ""
        )

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw AIServiceError.invalidResponse
        }

        let decoded = try JSONDecoder().decode(RemoteDamageScanResponse.self, from: data)
        let findings = decoded.findings.map { finding in
            DamageScanFinding(
                title: finding.title,
                description: finding.description,
                category: finding.category,
                severity: DamageSeverity(rawValue: finding.severity) ?? .medium,
                confidence: finding.confidence,
                suggestedAction: finding.suggestedAction
            )
        }

        return DamageScanResult(findings: findings, summary: decoded.summary)
    }

    func generateDamageSummary(for damageCase: DamageCase, findings: [DamageFinding]) async throws -> String {
        try await fallback.generateDamageSummary(for: damageCase, findings: findings)
    }

    func generateRepairPriorityList(for damageCase: DamageCase, findings: [DamageFinding]) async throws -> [RepairPriorityItem] {
        try await fallback.generateRepairPriorityList(for: damageCase, findings: findings)
    }

    func generateReportText(for damageCase: DamageCase, findings: [DamageFinding], priorities: [RepairPriorityItem]) async throws -> String {
        try await fallback.generateReportText(for: damageCase, findings: findings, priorities: priorities)
    }
}

private struct RemoteDamageScanRequest: Encodable {
    var damageType: String
    var locationLabel: String
    var userNotes: String
    var imageBase64: String
}

private struct RemoteDamageScanResponse: Decodable {
    var findings: [RemoteDamageFinding]
    var summary: String
}

private struct RemoteDamageFinding: Decodable {
    var title: String
    var description: String
    var category: String
    var severity: String
    var confidence: Double
    var suggestedAction: String
}
