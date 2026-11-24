import SwiftUI
import UniformTypeIdentifiers

struct SongLyricsEditor: View {
    let track: Track
    let onSave: (String) -> Bool
    @Environment(\.dismiss) private var dismiss
    @State private var text: String
    @State private var error: String?

    init(track: Track, initialText: String, onSave: @escaping (String) -> Bool) {
        self.track = track
        self.onSave = onSave
        _text = State(initialValue: initialText)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lyrics").font(.title2.weight(.semibold))
            Text("\(track.displayTitle) · \(track.artist)")
                .font(.callout).foregroundStyle(.secondary).lineLimit(2)
            HStack {
                Text("Import an LRC file for timed lyrics, or paste plain text.")
                    .font(.caption).foregroundStyle(.secondary)
                Spacer()
                Button("Import File…", action: importFile)
            }
            TextEditor(text: $text)
                .font(.system(size: 13, design: .monospaced))
                .scrollContentBackground(.hidden)
                .padding(10)
                .background(.white.opacity(0.04), in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.1)))
                .accessibilityLabel("Song lyrics")
            if let error { Text(error).font(.caption).foregroundStyle(.red) }
            HStack {
                Button("Cancel") { dismiss() }.keyboardShortcut(.cancelAction)
                Spacer()
                Button("Save") {
                    guard !LyricsController.parse(text).isEmpty else {
                        error = "Add some lyrics before saving."
                        return
                    }
                    if onSave(text) { dismiss() }
                    else { error = "Couldn’t save the lyrics. Please try again." }
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(24).frame(width: 580, height: 490)
        .background(AuralisTheme.background)
    }

    private func importFile() {
        let panel = NSOpenPanel()
        panel.title = "Choose Lyrics"
        panel.allowedContentTypes = [UTType(filenameExtension: "lrc") ?? .plainText, .plainText]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            var encoding = String.Encoding.utf8
            text = try String(contentsOf: url, usedEncoding: &encoding)
            error = nil
        } catch { self.error = "This file couldn’t be read. Choose an LRC or text file." }
    }
}
