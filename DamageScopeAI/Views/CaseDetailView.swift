import SwiftData
import SwiftUI

struct CaseDetailView: View {
    let caseID: UUID

    @Query(sort: \DamageCase.createdAt, order: .reverse) private var cases: [DamageCase]
    @Query(sort: \DamagePhoto.createdAt, order: .reverse) private var photos: [DamagePhoto]
    @Query(sort: \DamageFinding.createdAt, order: .reverse) private var findings: [DamageFinding]
    @Query(sort: \DamageReport.createdAt, order: .reverse) private var reports: [DamageReport]

    var body: some View {
        Group {
            if let damageCase {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        DamageCaseCard(
                            damageCase: damageCase,
                            photoCount: casePhotos.count,
                            urgentCount: urgentFindings.count
                        )

                        CaseStatusControl(damageCase: damageCase)

                        ActionGrid(caseID: damageCase.id)

                        DetailSection(title: "Overview") {
                            DetailRow(label: "Client", value: damageCase.clientName)
                            DetailRow(label: "Location", value: damageCase.location)
                            DetailRow(label: "Damage type", value: damageCase.damageType.displayName)
                            DetailRow(label: "Date discovered", value: damageCase.dateDiscovered.damageScopeShortDate)
                            if !damageCase.notes.isEmpty {
                                Text(damageCase.notes)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        DetailSection(title: "Approved findings") {
                            if caseFindings.isEmpty {
                                EmptyStateView(
                                    title: "No approved findings",
                                    message: "Run a scan and approve relevant findings before generating the final report.",
                                    systemImage: "checklist.unchecked"
                                )
                            } else {
                                ForEach(caseFindings) { finding in
                                    DamageFindingCard(finding: finding)
                                }
                            }
                        }

                        DetailSection(title: "Reports") {
                            if caseReports.isEmpty {
                                Text("No reports generated yet.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(caseReports) { report in
                                    Label(report.title, systemImage: "doc.text")
                                        .font(.subheadline.weight(.semibold))
                                }
                            }
                        }
                    }
                    .padding()
                }
            } else {
                EmptyStateView(
                    title: "Case not found",
                    message: "This case may have been deleted or archived.",
                    systemImage: "folder.badge.questionmark"
                )
                .padding()
            }
        }
        .navigationTitle(damageCase?.title ?? "Case")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var damageCase: DamageCase? {
        cases.first { $0.id == caseID }
    }

    private var casePhotos: [DamagePhoto] {
        photos.filter { $0.caseId == caseID }
    }

    private var caseFindings: [DamageFinding] {
        findings.filter { $0.caseId == caseID && $0.userApproved }
    }

    private var urgentFindings: [DamageFinding] {
        caseFindings.filter { $0.severity == .urgent }
    }

    private var caseReports: [DamageReport] {
        reports.filter { $0.caseId == caseID }
    }
}

private struct ActionGrid: View {
    var caseID: UUID

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            CaseAction(title: "Add photos", systemImage: "photo.badge.plus", route: .photoEvidence(caseID))
            CaseAction(title: "AI scan", systemImage: "sparkles", route: .aiScan(caseID))
            CaseAction(title: "Organise evidence", systemImage: "square.grid.2x2", route: .evidenceOrganizer(caseID))
            CaseAction(title: "Repair priorities", systemImage: "list.bullet.clipboard", route: .repairPriority(caseID))
            CaseAction(title: "Generate report", systemImage: "doc.richtext", route: .reportGenerator(caseID))
        }
    }
}

private struct CaseAction: View {
    var title: String
    var systemImage: String
    var route: AppRoute

    var body: some View {
        NavigationLink(value: route) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
                .padding(.horizontal)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

private struct CaseStatusControl: View {
    @Bindable var damageCase: DamageCase

    var body: some View {
        Picker("Status", selection: $damageCase.statusRaw) {
            ForEach(DamageStatus.allCases) { status in
                Text(status.displayName).tag(status.rawValue)
            }
        }
        .pickerStyle(.menu)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct DetailSection<Content: View>: View {
    var title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title3.bold())
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DetailRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}
