import SwiftUI

struct APIKeyEntryView: View {
    @State private var apiKey = ""
    @State private var showKey = false
    @State private var isSaved = false
    @FocusState private var focused: Bool

    var body: some View {
        Form {
            Section {
                Group {
                    if showKey {
                        TextField("sk-ant-...", text: $apiKey)
                    } else {
                        SecureField("sk-ant-...", text: $apiKey)
                    }
                }
                .focused($focused)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .overlay(alignment: .trailing) {
                    Button {
                        showKey.toggle()
                    } label: {
                        Image(systemName: showKey ? "eye.slash" : "eye")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.trailing, 6)
                }

            } header: {
                Text("Anthropic API Key")
            } footer: {
                Text("Used only for Sunday weekly audits. Stored in iOS Keychain. Never transmitted except directly to api.anthropic.com.")
            }

            Section {
                Button {
                    let key = apiKey.trimmingCharacters(in: .whitespaces)
                    if !key.isEmpty {
                        KeychainService.saveAPIKey(key)
                        isSaved = true
                        focused = false
                    }
                } label: {
                    HStack {
                        Text("Save to Keychain")
                        Spacer()
                        if isSaved {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.brandGreen)
                        }
                    }
                }
                .disabled(apiKey.isEmpty)

                if KeychainService.hasAPIKey {
                    Button("Remove API Key", role: .destructive) {
                        KeychainService.deleteAPIKey()
                        apiKey = ""
                        isSaved = false
                    }
                }
            }
        }
        .navigationTitle("API Key")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let existing = KeychainService.loadAPIKey() {
                apiKey = existing
            }
        }
    }
}
