import SwiftUI
import UniformTypeIdentifiers

struct LyricLine: Identifiable, Equatable {
    let id: Int
    let timestamp: Double?
    let text: String
    var words: [LyricWord] = []
}

struct LyricWord: Identifiable, Equatable {
    let id: Int
    let timestamp: Double
    let text: String
}

@MainActor
final class LyricsController: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case ready(synced: Bool)
        case instrumental
        case unavailable(String)
    }

    @Published private(set) var lines: [LyricLine] = []
    @Published private(set) var state: State = .idle
    @Published var offset: Double = 0
    @Published private(set) var sourceLabel = "LOCAL CACHE"

    private var trackID: UUID?
    private var requestGeneration = 0
    private var earliestRequestTime = Date.distantPast

    func prepare(for track: Track, library: LibraryStore, fetchIfMissing: Bool = true) async {
        requestGeneration += 1
        let generation = requestGeneration
        trackID = track.id
        offset = track.lyricsOffset ?? 0

        if let cached = library.cachedLyrics(for: track) {
            apply(cached, source: "OFFLINE CACHE")
            return
        }
        lines = []
        state = .idle
        guard fetchIfMissing else { return }
        await fetch(for: track, library: library, generation: generation)
    }

    func retry(for track: Track, library: LibraryStore) async {
        requestGeneration += 1
        await fetch(for: track, library: library, generation: requestGeneration)
    }

    func activeLineID(at playbackTime: Double) -> Int? {
        let adjusted = playbackTime + offset
        return lines.last(where: { ($0.timestamp ?? .infinity) <= adjusted })?.id
    }

    func persistOffset(for track: Track, library: LibraryStore) {
        library.setLyricsOffset(offset, for: track.id)
    }

    func importLRC(for track: Track, library: LibraryStore) {
        let panel = NSOpenPanel()
        panel.title = "Import synchronized lyrics"
        panel.prompt = "Use Lyrics"
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "lrc") ?? .plainText, .plainText]
        guard panel.runModal() == .OK, let url = panel.url,
              let text = try? String(contentsOf: url, encoding: .utf8) else { return }
        if library.saveLyrics(text, for: track) != nil { apply(text, source: "IMPORTED LRC") }
    }

    private func fetch(for track: Track, library: LibraryStore, generation: Int) async {
        state = .loading
        sourceLabel = "LRCLIB SEARCH"
        do {
            var components = URLComponents(string: "https://lrclib.net/api/search")!
            components.queryItems = [
                URLQueryItem(name: "track_name", value: track.title),
                URLQueryItem(name: "artist_name", value: track.artist)
            ]
            var request = URLRequest(url: components.url!)
            request.setValue("Aftertone/1.0 (private native macOS music player)", forHTTPHeaderField: "User-Agent")
            request.timeoutInterval = 18

            // LRCLIB asks clients to space requests out and honor 429 Retry-After.
            let now = Date()
            let spacingDelay = max(0, earliestRequestTime.timeIntervalSince(now))
            earliestRequestTime = now.addingTimeInterval(spacingDelay + 0.35)
            if spacingDelay > 0 {
                try await Task.sleep(nanoseconds: UInt64(spacingDelay * 1_000_000_000))
            }
            let first = try await URLSession.shared.data(for: request)
            var data = first.0
            var response = first.1
            if let throttled = response as? HTTPURLResponse, throttled.statusCode == 429 {
                let retrySeconds = Double(throttled.value(forHTTPHeaderField: "Retry-After") ?? "1") ?? 1
                try await Task.sleep(nanoseconds: UInt64(max(0.25, retrySeconds) * 1_000_000_000))
                let retry = try await URLSession.shared.data(for: request)
                data = retry.0
                response = retry.1
            }
            guard generation == requestGeneration, trackID == track.id else { return }
            guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            let records = try JSONDecoder().decode([LyricsRecord].self, from: data)
            guard let best = bestMatch(in: records, for: track) else {
                state = .unavailable("No matching lyrics were found for this version.")
                return
            }
            if best.instrumental {
                lines = []
                state = .instrumental
                return
            }
            guard let lyrics = best.syncedLyrics ?? best.plainLyrics, !lyrics.isEmpty else {
                state = .unavailable("The track was found, but it has no usable lyrics.")
                return
            }
            if library.saveLyrics(lyrics, for: track) != nil {
                apply(lyrics, source: best.syncedLyrics == nil ? "LRCLIB · PLAIN" : "LRCLIB · SYNCED")
            }
        } catch {
            guard generation == requestGeneration else { return }
            state = .unavailable("Lyrics lookup needs an internet connection. Cached lyrics still work offline.")
        }
    }

    private func bestMatch(in records: [LyricsRecord], for track: Track) -> LyricsRecord? {
        let normalizedTitle = normalize(track.title)
        let normalizedArtist = normalize(track.artist)
        return records.sorted { lhs, rhs in
            score(lhs, normalizedTitle: normalizedTitle, normalizedArtist: normalizedArtist, duration: track.duration)
                < score(rhs, normalizedTitle: normalizedTitle, normalizedArtist: normalizedArtist, duration: track.duration)
        }.first
    }

    private func score(_ record: LyricsRecord, normalizedTitle: String, normalizedArtist: String, duration: Double) -> Double {
        var value = abs(record.duration - duration)
        if normalize(record.trackName) != normalizedTitle { value += 45 }
        if !normalize(record.artistName).contains(normalizedArtist) && !normalizedArtist.contains(normalize(record.artistName)) { value += 65 }
        if record.syncedLyrics == nil { value += 18 }
        return value
    }

    private func normalize(_ value: String) -> String {
        value.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
    }

    private func apply(_ text: String, source: String) {
        let parsed = Self.parse(text)
        lines = parsed
        sourceLabel = source
        state = .ready(synced: parsed.contains { $0.timestamp != nil })
    }

    static func parse(_ text: String) -> [LyricLine] {
        let expression = try? NSRegularExpression(pattern: #"\[(\d{1,3}):(\d{2})(?:[\.:](\d{1,3}))?\]"#)
        var timed: [(Double, String)] = []
        var plain: [String] = []
        for rawLine in text.components(separatedBy: .newlines) {
            let nsLine = rawLine as NSString
            let matches = expression?.matches(in: rawLine, range: NSRange(location: 0, length: nsLine.length)) ?? []
            let lyric = expression?.stringByReplacingMatches(in: rawLine, range: NSRange(location: 0, length: nsLine.length), withTemplate: "")
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? rawLine
            if matches.isEmpty {
                if !lyric.isEmpty && !lyric.hasPrefix("[") { plain.append(lyric) }
                continue
            }
            for match in matches {
                let minutes = Double(nsLine.substring(with: match.range(at: 1))) ?? 0
                let seconds = Double(nsLine.substring(with: match.range(at: 2))) ?? 0
                var fraction = 0.0
                if match.range(at: 3).location != NSNotFound {
                    let digits = nsLine.substring(with: match.range(at: 3))
                    fraction = (Double(digits) ?? 0) / pow(10, Double(digits.count))
                }
                timed.append((minutes * 60 + seconds + fraction, lyric.isEmpty ? "· · ·" : lyric))
            }
        }
        if !timed.isEmpty {
            return timed.sorted { $0.0 < $1.0 }.enumerated().map { entry in
                let raw = entry.element.1 as NSString
                let pattern = try! NSRegularExpression(pattern: #"<(\d+):(\d+(?:\.\d+)?)>([^<]*)"#)
                let matches = pattern.matches(in: raw as String, range: NSRange(location: 0, length: raw.length))
                let words = matches.enumerated().compactMap { index, match -> LyricWord? in
                    let text = raw.substring(with: match.range(at: 3)).trimmingCharacters(in: .whitespaces)
                    guard !text.isEmpty else { return nil }
                    let seconds = (Double(raw.substring(with: match.range(at: 1))) ?? 0) * 60 + (Double(raw.substring(with: match.range(at: 2))) ?? 0)
                    return LyricWord(id: index, timestamp: seconds, text: text)
                }
                return LyricLine(id: entry.offset, timestamp: entry.element.0,
                                 text: words.isEmpty ? entry.element.1 : words.map(\.text).joined(separator: " "), words: words)
            }
        }
        return plain.enumerated().map { LyricLine(id: $0.offset, timestamp: nil, text: $0.element) }
    }
}

private struct LyricsRecord: Decodable {
    let trackName: String
    let artistName: String
    let albumName: String
    let duration: Double
    let instrumental: Bool
    let plainLyrics: String?
    let syncedLyrics: String?
}
