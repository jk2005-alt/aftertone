import SwiftUI
import AVFoundation
import ImageIO
import UniformTypeIdentifiers

@MainActor
final class LibraryStore: ObservableObject {
    @Published private(set) var tracks: [Track] = []
    @Published var selectedTrackID: UUID?
    @Published var importCandidate: ImportCandidate?
    @Published var searchText = ""
    @Published var selectedCategory: MusicCategory?
    @Published private(set) var categories = MusicCategory.allCases
    @Published private var categoryAssignments: [String: String] = [:]
    @Published var alertMessage: String?

    private let thumbnailCache: NSCache<NSString, NSImage> = {
        let cache = NSCache<NSString, NSImage>()
        cache.countLimit = 256
        cache.totalCostLimit = 12 * 1024 * 1024
        return cache
    }()

    private var importQueue: [ImportCandidate] = []
    private let fileManager = FileManager.default
    let libraryDirectory: URL
    private let catalogURL: URL

    init() {
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        libraryDirectory = support.appendingPathComponent("Auralis/Library", isDirectory: true)
        catalogURL = support.appendingPathComponent("Auralis/catalog.json")
        try? fileManager.createDirectory(at: libraryDirectory, withIntermediateDirectories: true)
        loadCategorySettings()
        loadCatalog()
        loadBundledTracks()
    }

    var alphabeticalTracks: [Track] {
        tracks.sorted { left, right in
            let titleOrder = left.displayTitle.localizedStandardCompare(right.displayTitle)
            if titleOrder != .orderedSame { return titleOrder == .orderedAscending }
            let artistOrder = left.artist.localizedStandardCompare(right.artist)
            if artistOrder != .orderedSame { return artistOrder == .orderedAscending }
            return left.id.uuidString < right.id.uuidString
        }
    }

    var filteredTracks: [Track] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        return alphabeticalTracks.filter { track in
            let matchesCategory = selectedCategory.map { self.category(for: track) == $0 } ?? true
            let matchesSearch = query.isEmpty
                || track.title.localizedCaseInsensitiveContains(query)
                || track.artist.localizedCaseInsensitiveContains(query)
                || track.album.localizedCaseInsensitiveContains(query)
            return matchesCategory && matchesSearch
        }
    }

    func trackCount(in category: MusicCategory?) -> Int {
        guard let category else { return tracks.count }
        return tracks.filter { self.category(for: $0) == category }.count
    }

    func category(for track: Track) -> MusicCategory? {
        if let name = categoryAssignments[track.id.uuidString] {
            let category = MusicCategory(rawValue: name)
            return categories.contains(category) ? category : nil
        }
        guard let category = track.shelfCategory, categories.contains(category) else { return nil }
        return category
    }

    @discardableResult
    func addCategory(_ name: String) -> Bool {
        let clean = name.split(whereSeparator: \.isWhitespace).joined(separator: " ").uppercased()
        guard !clean.isEmpty, clean.count <= 40, clean != "ALL SONGS",
              !categories.contains(where: { $0.rawValue.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) == clean.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current) }) else {
            alertMessage = "Choose a unique category name of 1–40 characters."
            return false
        }
        return saveCategorySettings(categories + [MusicCategory(rawValue: clean)], assignments: categoryAssignments)
    }

    func removeCategory(_ category: MusicCategory) {
        var assignments = categoryAssignments
        for track in tracks where self.category(for: track) == category {
            assignments[track.id.uuidString] = ""
        }
        if saveCategorySettings(categories.filter { $0 != category }, assignments: assignments), selectedCategory == category {
            selectedCategory = nil
        }
    }

    func move(_ track: Track, to category: MusicCategory?) {
        guard category == nil || categories.contains(category!) else { return }
        var assignments = categoryAssignments
        assignments[track.id.uuidString] = category?.rawValue ?? ""
        _ = saveCategorySettings(categories, assignments: assignments)
    }

    private struct CategorySettings: Codable {
        var categories: [MusicCategory]
        var assignments: [String: String]
    }

    private var categorySettingsURL: URL {
        catalogURL.deletingLastPathComponent().appendingPathComponent("categories.json")
    }

    private func loadCategorySettings() {
        guard let data = try? Data(contentsOf: categorySettingsURL),
              let settings = try? JSONDecoder().decode(CategorySettings.self, from: data) else { return }
        categories = settings.categories
        categoryAssignments = settings.assignments
    }

    private func saveCategorySettings(_ updated: [MusicCategory], assignments: [String: String]) -> Bool {
        do {
            let data = try JSONEncoder().encode(CategorySettings(categories: updated, assignments: assignments))
            try data.write(to: categorySettingsURL, options: .atomic)
            categories = updated
            categoryAssignments = assignments
            return true
        } catch {
            alertMessage = "Couldn’t save the category changes. Please try again."
            return false
        }
    }

    var selectedTrack: Track? {
        tracks.first { $0.id == selectedTrackID }
    }

    func url(for track: Track) -> URL {
        if track.isBundled == true,
           let resource = Bundle.main.resourceURL?.appendingPathComponent("Music").appendingPathComponent(track.filename),
           fileManager.fileExists(atPath: resource.path) {
            return resource
        }
        return libraryDirectory.appendingPathComponent(track.filename)
    }

    func artworkURL(for track: Track) -> URL? {
        guard let name = track.artworkFilename else { return nil }
        if track.isBundled == true,
           let resource = Bundle.main.resourceURL?.appendingPathComponent("Music").appendingPathComponent(name),
           fileManager.fileExists(atPath: resource.path) {
            return resource
        }
        return libraryDirectory.appendingPathComponent(name)
    }

    func coverImage(for track: Track, thumbnail: Bool = false) async -> NSImage? {
        if track.isBundled == true,
           let url = Bundle.main.url(forResource: track.id.uuidString, withExtension: "jpg",
                                     subdirectory: thumbnail ? "QueueArt" : "AlbumArt") {
            guard thumbnail else { return NSImage(contentsOf: url) }
            let key = url.path as NSString
            if let cached = thumbnailCache.object(forKey: key) { return cached }
            let bitmap = await Task.detached(priority: .utility) {
                guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil as CGImage? }
                return CGImageSourceCreateThumbnailAtIndex(source, 0, [
                    kCGImageSourceCreateThumbnailFromImageAlways: true,
                    kCGImageSourceThumbnailMaxPixelSize: 96,
                    kCGImageSourceShouldCacheImmediately: true
                ] as CFDictionary)
            }.value
            guard let bitmap else { return nil }
            let image = NSImage(cgImage: bitmap, size: NSSize(width: bitmap.width, height: bitmap.height))
            thumbnailCache.setObject(image, forKey: key, cost: bitmap.bytesPerRow * bitmap.height)
            return image
        }
        if let url = artworkURL(for: track), let image = NSImage(contentsOf: url) { return image }
        let asset = AVURLAsset(url: url(for: track))
        guard let items = try? await asset.load(.commonMetadata),
              let item = items.first(where: { $0.commonKey == .commonKeyArtwork }),
              let data = try? await item.load(.dataValue) else { return nil }
        return NSImage(data: data)
    }

    func cachedLyrics(for track: Track) -> String? {
        guard let name = track.lyricsFilename else { return nil }
        let cached = libraryDirectory.appendingPathComponent(name)
        if fileManager.fileExists(atPath: cached.path) {
            return try? String(contentsOf: cached, encoding: .utf8)
        }
        if track.isBundled == true,
           let resource = Bundle.main.resourceURL?.appendingPathComponent("Music").appendingPathComponent(name) {
            return try? String(contentsOf: resource, encoding: .utf8)
        }
        return nil
    }

    @discardableResult
    func saveLyrics(_ contents: String, for track: Track) -> Track? {
        guard let index = tracks.firstIndex(where: { $0.id == track.id }) else { return nil }
        do {
            let name = "\(track.id.uuidString).lrc"
            try contents.write(to: libraryDirectory.appendingPathComponent(name), atomically: true, encoding: .utf8)
            tracks[index].lyricsFilename = name
            saveCatalog()
            return tracks[index]
        } catch {
            alertMessage = "The lyrics could not be cached locally."
            return nil
        }
    }

    func setLyricsOffset(_ offset: Double, for trackID: UUID) {
        guard let index = tracks.firstIndex(where: { $0.id == trackID }) else { return }
        tracks[index].lyricsOffset = offset
        saveCatalog()
    }

    func requestImport() {
        let panel = NSOpenPanel()
        panel.title = "Add music to Aftertone"
        panel.prompt = "Choose MP3s"
        panel.allowedContentTypes = [UTType.mp3]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK else { return }
        importQueue = panel.urls.map(ImportCandidate.init(sourceURL:))
        advanceImportQueue()
    }

    func commitImport(_ candidate: ImportCandidate, artworkURL: URL?) {
        let draft = candidate.draft
        guard !draft.title.trimmingCharacters(in: .whitespaces).isEmpty,
              !draft.artist.trimmingCharacters(in: .whitespaces).isEmpty,
              !draft.album.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Song, artist, and album are all required."
            return
        }

        do {
            let id = UUID()
            let destinationName = "\(id.uuidString).mp3"
            let destination = libraryDirectory.appendingPathComponent(destinationName)
            try fileManager.copyItem(at: candidate.sourceURL, to: destination)

            var artworkFilename: String?
            var artworkData: Data?
            if let artworkURL {
                let ext = artworkURL.pathExtension.isEmpty ? "jpg" : artworkURL.pathExtension.lowercased()
                let name = "\(id.uuidString)-cover.\(ext)"
                let target = libraryDirectory.appendingPathComponent(name)
                try fileManager.copyItem(at: artworkURL, to: target)
                artworkFilename = name
                artworkData = try Data(contentsOf: target)
            }

            try ID3TagWriter.write(
                title: draft.title, artist: draft.artist, album: draft.album,
                artwork: artworkData, to: destination
            )
            let importedFile = try AVAudioFile(forReading: destination)
            let seconds = Double(importedFile.length) / importedFile.processingFormat.sampleRate
            let track = Track(
                id: id, filename: destinationName,
                title: draft.title.trimmingCharacters(in: .whitespacesAndNewlines),
                artist: draft.artist.trimmingCharacters(in: .whitespacesAndNewlines),
                album: draft.album.trimmingCharacters(in: .whitespacesAndNewlines),
                artworkFilename: artworkFilename,
                duration: seconds.isFinite ? seconds : 0
            )
            tracks.insert(track, at: 0)
            selectedTrackID = track.id
            saveCatalog()
            importCandidate = nil
            advanceImportQueue()
        } catch {
            alertMessage = "Couldn’t import this MP3: \(error.localizedDescription)"
        }
    }

    func cancelCurrentImport() {
        importCandidate = nil
        advanceImportQueue()
    }

    func update(_ track: Track, title: String, artist: String, album: String, artworkURL: URL?) {
        guard let index = tracks.firstIndex(where: { $0.id == track.id }) else { return }
        do {
            var updated = track
            updated.title = title
            updated.artist = artist
            updated.album = album
            var artworkData: Data?
            if let artworkURL {
                if let old = updated.artworkFilename {
                    try? fileManager.removeItem(at: libraryDirectory.appendingPathComponent(old))
                }
                let ext = artworkURL.pathExtension.isEmpty ? "jpg" : artworkURL.pathExtension.lowercased()
                let name = "\(track.id.uuidString)-cover.\(ext)"
                let target = libraryDirectory.appendingPathComponent(name)
                try fileManager.copyItem(at: artworkURL, to: target)
                updated.artworkFilename = name
                artworkData = try Data(contentsOf: target)
            } else if let existing = updated.artworkFilename {
                artworkData = try? Data(contentsOf: libraryDirectory.appendingPathComponent(existing))
            }
            try ID3TagWriter.write(title: title, artist: artist, album: album, artwork: artworkData, to: url(for: updated))
            tracks[index] = updated
            saveCatalog()
        } catch {
            alertMessage = "Couldn’t update the metadata: \(error.localizedDescription)"
        }
    }

    func remove(_ track: Track) {
        if track.isBundled == true {
            var hidden = Set(UserDefaults.standard.stringArray(forKey: "hiddenBundledTrackIDs") ?? [])
            hidden.insert(track.id.uuidString)
            UserDefaults.standard.set(Array(hidden), forKey: "hiddenBundledTrackIDs")
        } else {
            do {
                try fileManager.removeItem(at: libraryDirectory.appendingPathComponent(track.filename))
            } catch {
                alertMessage = "Couldn’t remove this song: \(error.localizedDescription)"
                return
            }
            for name in [track.artworkFilename, track.lyricsFilename].compactMap({ $0 }) {
                try? fileManager.removeItem(at: libraryDirectory.appendingPathComponent(name))
            }
        }
        tracks.removeAll { $0.id == track.id }
        if selectedTrackID == track.id { selectedTrackID = tracks.first?.id }
        saveCatalog()
    }

    private func advanceImportQueue() {
        guard importCandidate == nil, !importQueue.isEmpty else { return }
        importCandidate = importQueue.removeFirst()
    }

    private func loadCatalog() {
        guard let data = try? Data(contentsOf: catalogURL),
              let decoded = try? JSONDecoder().decode([Track].self, from: data) else { return }
        tracks = decoded.filter { fileManager.fileExists(atPath: url(for: $0).path) }
        selectedTrackID = tracks.first?.id
    }

    private func loadBundledTracks() {
        let saved = Dictionary(tracks.filter { $0.isBundled == true }.map { ($0.id, $0) }, uniquingKeysWith: { _, latest in latest })
        let hidden = Set(UserDefaults.standard.stringArray(forKey: "hiddenBundledTrackIDs") ?? [])
        tracks.removeAll { $0.isBundled == true }
        guard let manifestURL = Bundle.main.resourceURL?.appendingPathComponent("Music/bundled-tracks.json"),
              let data = try? Data(contentsOf: manifestURL),
              let records = try? JSONDecoder().decode([BundledTrackRecord].self, from: data) else { return }
        let bundled = records.compactMap { record -> Track? in
            guard !hidden.contains(record.id.uuidString) else { return nil }
            let audioURL = Bundle.main.resourceURL?.appendingPathComponent("Music").appendingPathComponent(record.filename)
            guard let audioURL, fileManager.fileExists(atPath: audioURL.path) else { return nil }
            let customLyrics = saved[record.id]?.lyricsFilename.flatMap { name in
                fileManager.fileExists(atPath: libraryDirectory.appendingPathComponent(name).path) ? name : nil
            }
            return Track(
                id: record.id, filename: record.filename, title: record.title,
                artist: record.artist, album: record.album,
                artworkFilename: record.artworkFilename,
                lyricsFilename: customLyrics ?? record.lyricsFilename,
                lyricsOffset: saved[record.id]?.lyricsOffset ?? 0,
                isBundled: true, dateAdded: record.dateAdded, duration: record.duration
            )
        }
        tracks.insert(contentsOf: bundled, at: 0)
        if selectedTrackID == nil { selectedTrackID = tracks.first?.id }
    }

    private func saveCatalog() {
        do {
            try fileManager.createDirectory(at: catalogURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            try encoder.encode(tracks).write(to: catalogURL, options: .atomic)
        } catch {
            alertMessage = "The library catalog could not be saved."
        }
    }
}

private struct BundledTrackRecord: Decodable {
    let id: UUID
    let filename: String
    let title: String
    let artist: String
    let album: String
    let artworkFilename: String?
    let lyricsFilename: String?
    let dateAdded: Date
    let duration: Double
}
