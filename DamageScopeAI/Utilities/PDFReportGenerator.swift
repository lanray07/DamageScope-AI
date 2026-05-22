import UIKit

enum PDFReportGenerator {
    static func generate(
        damageCase: DamageCase,
        photos: [DamagePhoto],
        findings: [DamageFinding],
        priorities: [RepairPriorityItem],
        summary: String,
        plan: SubscriptionPlan
    ) throws -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileName = safeFileName("\(damageCase.title)-\(Formatters.fileSafeDate.string(from: Date())).pdf")
        let url = documents.appendingPathComponent(fileName)
        let pageRect = CGRect(x: 0, y: 0, width: 595, height: 842)
        let margin: CGFloat = 42
        let contentWidth = pageRect.width - (margin * 2)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)
        try renderer.writePDF(to: url) { context in
            var y = margin

            func beginPageIfNeeded(_ requiredHeight: CGFloat) {
                if y + requiredHeight > pageRect.height - margin {
                    context.beginPage()
                    y = margin
                }
            }

            func addText(_ text: String, font: UIFont, color: UIColor = .label, spacing: CGFloat = 10) {
                let paragraph = NSMutableParagraphStyle()
                paragraph.lineBreakMode = .byWordWrapping
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: color,
                    .paragraphStyle: paragraph
                ]
                let size = text.boundingRect(
                    with: CGSize(width: contentWidth, height: .greatestFiniteMagnitude),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                beginPageIfNeeded(ceil(size.height) + spacing)
                text.draw(
                    with: CGRect(x: margin, y: y, width: contentWidth, height: ceil(size.height)),
                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                    attributes: attributes,
                    context: nil
                )
                y += ceil(size.height) + spacing
            }

            func addRule() {
                beginPageIfNeeded(18)
                UIColor.separator.setStroke()
                let path = UIBezierPath()
                path.move(to: CGPoint(x: margin, y: y))
                path.addLine(to: CGPoint(x: pageRect.width - margin, y: y))
                path.stroke()
                y += 18
            }

            func addImage(_ image: UIImage, caption: String) {
                let maxHeight: CGFloat = 220
                let scale = min(contentWidth / image.size.width, maxHeight / image.size.height)
                let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                beginPageIfNeeded(targetSize.height + 48)
                image.draw(in: CGRect(x: margin, y: y, width: targetSize.width, height: targetSize.height))
                y += targetSize.height + 6
                addText(caption, font: .systemFont(ofSize: 10), color: .secondaryLabel, spacing: 8)
            }

            context.beginPage()

            addText("DamageScope AI Damage Report", font: .boldSystemFont(ofSize: 24), spacing: 6)
            addText(damageCase.title, font: .boldSystemFont(ofSize: 18), color: .secondaryLabel)
            addRule()

            addText("Case overview", font: .boldSystemFont(ofSize: 16))
            addText("""
            Client: \(damageCase.clientName)
            Location: \(damageCase.location)
            Damage type: \(damageCase.damageType.displayName)
            Status: \(damageCase.status.displayName)
            Date discovered: \(damageCase.dateDiscovered.damageScopeShortDate)
            Created: \(damageCase.createdAt.damageScopeShortDate)
            """, font: .systemFont(ofSize: 12))

            if !damageCase.notes.isEmpty {
                addText("Case notes", font: .boldSystemFont(ofSize: 14))
                addText(damageCase.notes, font: .systemFont(ofSize: 12))
            }

            addText("Damage summary", font: .boldSystemFont(ofSize: 16))
            addText(summary.isEmpty ? "No generated summary available." : summary, font: .systemFont(ofSize: 12))

            addText("Severity breakdown", font: .boldSystemFont(ofSize: 16))
            let breakdown = DamageSeverity.allCases.map { severity in
                "\(severity.rawValue): \(findings.filter { $0.severity == severity }.count)"
            }
            .joined(separator: "\n")
            addText(breakdown, font: .systemFont(ofSize: 12))

            addText("Repair priority list", font: .boldSystemFont(ofSize: 16))
            if priorities.isEmpty {
                addText("No repair priorities generated.", font: .systemFont(ofSize: 12))
            } else {
                for priority in priorities {
                    addText("\(priority.severity.rawValue): \(priority.title)\n\(priority.detail)\nNext action: \(priority.recommendation)", font: .systemFont(ofSize: 12))
                }
            }

            addText("Photo evidence", font: .boldSystemFont(ofSize: 16))
            if photos.isEmpty {
                addText("No relevant photo evidence attached.", font: .systemFont(ofSize: 12))
            } else {
                for photo in photos {
                    if let data = photo.imageData, let image = UIImage(data: data) {
                        let caption = [
                            photo.areaGroup,
                            photo.locationLabel,
                            photo.beforeAfterType.displayName,
                            photo.caption
                        ]
                        .filter { !$0.isEmpty }
                        .joined(separator: " - ")
                        addImage(image, caption: caption)
                    }
                }
            }

            addText("Recommended next actions", font: .boldSystemFont(ofSize: 16))
            addText("Review all AI-assisted findings against site conditions. Escalate urgent safety concerns to qualified professionals immediately. Confirm repair sequencing, scope, cost, and compliance through appropriate trade or professional review.", font: .systemFont(ofSize: 12))

            addText("Disclaimer", font: .boldSystemFont(ofSize: 16))
            addText(AppConstants.disclaimers.joined(separator: "\n"), font: .systemFont(ofSize: 11), color: .secondaryLabel)

            addText("Signature placeholder", font: .boldSystemFont(ofSize: 16))
            addText("Prepared by: ________________________________\nDate: ________________________________", font: .systemFont(ofSize: 12))

            if plan == .free {
                addRule()
                addText(AppConstants.reportFooter, font: .systemFont(ofSize: 10), color: .secondaryLabel)
            }
        }

        return url
    }

    private static func safeFileName(_ value: String) -> String {
        value.replacingOccurrences(of: "[^A-Za-z0-9._-]", with: "-", options: .regularExpression)
    }
}
