import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var apiKey = ""
    @State private var showKey = false
    @FocusState private var keyFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 64))
                    .foregroundStyle(.brandGreen)

                VStack(spacing: 8) {
                    Text("Body Recomp")
                        .font(.largeTitle.bold())
                    Text("Your personal coaching app")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Anthropic API Key")
                        .font(.subheadline.weight(.semibold))

                    Group {
                        if showKey {
                            TextField("sk-ant-...", text: $apiKey)
                        } else {
                            SecureField("sk-ant-...", text: $apiKey)
                        }
                    }
                    .textFieldStyle(.roundedBorder)
                    .focused($keyFieldFocused)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .overlay(alignment: .trailing) {
                        Button {
                            showKey.toggle()
                        } label: {
                            Image(systemName: showKey ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                        .padding(.trailing, 8)
                    }

                    Text("Used only for weekly Claude audits. Stored securely in Keychain.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
            }
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    if !apiKey.isEmpty {
                        KeychainService.saveAPIKey(apiKey.trimmingCharacters(in: .whitespaces))
                    }
                    hasCompletedOnboarding = true
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(apiKey.isEmpty ? Color.brandGreen.opacity(0.4) : Color.brandGreen)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal)

                if apiKey.isEmpty {
                    Button("Skip for now — add later in Settings") {
                        hasCompletedOnboarding = true
                    }
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.bottom, 40)
        }
    }
}
