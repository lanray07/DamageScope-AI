import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("selectedUserType") private var selectedUserTypeRaw = UserType.contractor.rawValue
    @State private var selectedUserType: UserType = .contractor

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("DamageScope AI")
                            .font(.largeTitle.bold())
                        Text("Document damage, organise evidence, and prepare client-ready repair reports.")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Select your work type")
                            .font(.title3.bold())

                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(UserType.allCases) { userType in
                                Button {
                                    selectedUserType = userType
                                    selectedUserTypeRaw = userType.rawValue
                                } label: {
                                    HStack {
                                        Text(userType.displayName)
                                            .font(.subheadline.weight(.semibold))
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                        if selectedUserType == userType {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.tint)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 54, alignment: .leading)
                                    .padding()
                                    .background(selectedUserType == userType ? Color.accentColor.opacity(0.12) : Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Review before using")
                            .font(.title3.bold())

                        ForEach(AppConstants.disclaimers, id: \.self) { disclaimer in
                            Label(disclaimer, systemImage: "checkmark.shield")
                                .font(.subheadline)
                                .foregroundStyle(.primary)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                    Button {
                        selectedUserTypeRaw = selectedUserType.rawValue
                        hasCompletedOnboarding = true
                    } label: {
                        Label("Continue", systemImage: "arrow.right")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
            }
            .navigationTitle("Welcome")
            .onAppear {
                selectedUserType = UserType(rawValue: selectedUserTypeRaw) ?? .contractor
            }
        }
    }
}
