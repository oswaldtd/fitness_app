import SwiftUI

struct ChecklistRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    @Binding var isChecked: Bool
    var isWarningFlag: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(isWarningFlag ? .brandRed : .brandGreen)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(isWarningFlag ? .brandRed : .primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isChecked)
                .labelsHidden()
                .tint(isWarningFlag ? .brandRed : .brandGreen)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { isChecked.toggle() }
    }
}
