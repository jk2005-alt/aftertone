import SwiftUI

struct MetadataEditor: View {
    let heading: String
    @Binding var draft: MetadataDraft
    let confirmTitle: String
    let onConfirm: (URL?) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(heading).font(.title2.bold())

            VStack(spacing: 14) {
                field("SONG NAME", text: $draft.title, prompt: "e.g. Your Universe")
                field("ARTIST", text: $draft.artist, prompt: "e.g. Rico Blanco")
                field("ALBUM", text: $draft.album, prompt: "Your custom album name")
            }

            HStack {
                Button("Cancel", action: onCancel).keyboardShortcut(.cancelAction)
                Spacer()
                Button(confirmTitle) { onConfirm(nil) }
                    .keyboardShortcut(.defaultAction)
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.22, green: 0.58, blue: 0.34))
                    .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty
                              || draft.artist.trimmingCharacters(in: .whitespaces).isEmpty
                              || draft.album.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(26)
        .frame(width: 510)
        .background(AuralisTheme.background)
    }

    private func field(_ label: String, text: Binding<String>, prompt: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.system(size: 9, weight: .black, design: .rounded)).tracking(1.1).foregroundStyle(.secondary)
            TextField(prompt, text: text)
                .textFieldStyle(.plain)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 7))
                .overlay(RoundedRectangle(cornerRadius: 7).stroke(.white.opacity(0.1)))
        }
    }
}
