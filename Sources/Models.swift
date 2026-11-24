import Foundation

enum VisualizerMode: String, Codable, CaseIterable, Identifiable {
    case orbit = "ORBIT"
    case lissajous = "LISSAJOUS"
    case bloom = "BLOOM"

    var id: String { rawValue }
}

enum MainScreenMode: String, CaseIterable, Identifiable {
    case lyrics = "LYRICS"
    case animation = "VISUALIZER"

    var id: String { rawValue }
}

struct MusicCategory: RawRepresentable, Hashable, Codable, CaseIterable, Identifiable {
    let rawValue: String
    init(rawValue: String) { self.rawValue = rawValue }
    static let lowFlame = MusicCategory(rawValue: "LOW FLAME")
    static let quietWeight = MusicCategory(rawValue: "QUIET WEIGHT")
    static let fadedMiles = MusicCategory(rawValue: "FADED MILES")
    static let firstLight = MusicCategory(rawValue: "FIRST LIGHT")
    static let openCharge = MusicCategory(rawValue: "OPEN CHARGE")
    static let highNoonDrive = MusicCategory(rawValue: "HIGH NOON DRIVE")
    static let scorchedEarth = MusicCategory(rawValue: "SCORCHED EARTH")
    static let signalDrift = MusicCategory(rawValue: "SIGNAL DRIFT")
    static let anteikuCafe = MusicCategory(rawValue: "ANTEIKU CAFÉ")

    var id: String { rawValue }

    static var allCases: [MusicCategory] {
        [.highNoonDrive, .fadedMiles, .quietWeight, .signalDrift, .anteikuCafe]
    }

    var subtitle: String {
        switch self {
        case .lowFlame: return "DESIRE · TENSION · QUIET HEAT"
        case .quietWeight: return "HEAVY · RESTRAINED · UNDERCURRENT"
        case .fadedMiles: return "NOSTALGIA · DISTANCE · LEFT BEHIND"
        case .firstLight: return "SOFT ACHE · RESTRAINT · HALF-LIGHT"
        case .openCharge: return "UNFILTERED · ELEVATED · RELEASE"
        case .highNoonDrive: return "BRIGHT · CONFIDENT · OPEN ROAD"
        case .scorchedEarth: return "ANGER · HEAT · NO COMPROMISE"
        case .signalDrift: return "INSTRUMENTAL · SCORE · BACKGROUND"
        case .anteikuCafe: return "ANIME OST · OPENINGS · ENDINGS"
        default: return ""
        }
    }
}

struct Track: Identifiable, Codable, Equatable {
    var id: UUID
    var filename: String
    var title: String
    var artist: String
    var album: String
    var artworkFilename: String?
    var lyricsFilename: String?
    var lyricsOffset: Double?
    var isBundled: Bool?
    var dateAdded: Date
    var duration: Double

    // Keep the versioned title available for lyric matching and playlist rules.
    private static let versionSuffix = try! NSRegularExpression(
        pattern: #"(?i)(?:\s*(?:\((?:feat\.?\s+[^()]+|with\s+[^()]+|(?:slowed|sped[ -]?up|live|reprise|remix|tv size|single version|extended version|(?:\d{4}\s+)?remaster(?:ed)?)(?:\s[^()]*)?)\)|\[(?:feat\.?\s+|with\s+|sped[ -]?up|slowed|remix|live\b)[^\[\]]*\])|\s+[-–—]\s+(?:remix|slowed|sped[ -]?up|live|remaster(?:ed)?)(?:\s+[^()\[\]]*)?)+$"#
    )

    var displayTitle: String {
        // Distinguish the live recording from the studio version in the library.
        if artist == "Tory Lanez", title == "The Color Violet (Live)" {
            return title
        }
        let range = NSRange(title.startIndex..., in: title)
        guard let match = Self.versionSuffix.firstMatch(in: title, range: range),
              let suffix = Range(match.range, in: title),
              suffix.lowerBound > title.startIndex else { return title }
        return String(title[..<suffix.lowerBound])
    }

    init(
        id: UUID = UUID(), filename: String, title: String, artist: String,
        album: String, artworkFilename: String? = nil, lyricsFilename: String? = nil,
        lyricsOffset: Double? = nil, isBundled: Bool? = nil, dateAdded: Date = Date(),
        duration: Double = 0
    ) {
        self.id = id
        self.filename = filename
        self.title = title
        self.artist = artist
        self.album = album
        self.artworkFilename = artworkFilename
        self.lyricsFilename = lyricsFilename
        self.lyricsOffset = lyricsOffset
        self.isBundled = isBundled
        self.dateAdded = dateAdded
        self.duration = duration
    }
}

extension Track {
    /// Hand-curated exclusive emotional shelves. Every bundled song has one home.
    var musicCategories: Set<MusicCategory> {
        switch title.lowercased() {
        case "letter home": return [.fadedMiles]
        case "les": return [.lowFlame]
        case "stress relief": return [.fadedMiles]
        case "harvey": return [.fadedMiles]
        case "hotel room": return [.fadedMiles]
        case "hate that i made you love me": return [.quietWeight]
        case "doubt": return [.quietWeight]
        case "sweater weather": return [.lowFlame]
        case "diamonds": return [.firstLight]
        case "hips don't lie": return [.highNoonDrive]
        case "chantaje": return [.lowFlame]
        case "can't remember to forget you": return [.scorchedEarth]
        case "lean on": return [.firstLight]
        case "swimming pools (drank) (extended version)": return [.quietWeight]
        case "janice stfu": return [.scorchedEarth]
        case "legendary lovers": return [.lowFlame]
        case "kiss me more": return [.lowFlame]
        case "ivy": return [.quietWeight]
        case "flatline": return [.quietWeight]
        case "confident (feat. chance the rapper)": return [.openCharge]
        case "american wedding": return [.fadedMiles]
        case "heartbeat": return [.openCharge]
        case "smells like teen spirit": return [.scorchedEarth]
        case "so high": return [.lowFlame]
        case "heart-shaped box": return [.scorchedEarth]
        case "bye bye bye": return [.openCharge]
        case "nights like this": return [.quietWeight]
        case "someone like you": return [.quietWeight]
        case "skyfall": return [.openCharge]
        case "something about you": return [.fadedMiles]
        case "she": return [.lowFlame]
        case "maneater": return [.lowFlame]
        case "out of touch": return [.highNoonDrive]
        case "dark red": return [.quietWeight]
        case "bad habit": return [.fadedMiles]
        case "you are the right one": return [.lowFlame]
        case "car's outside": return [.quietWeight]
        case "self aware": return [.openCharge]
        case "earrings": return [.fadedMiles]
        case "out of my league": return [.highNoonDrive]
        case "luxury": return [.highNoonDrive]
        case "look after you": return [.firstLight]
        case "what it is (block boy) [feat. kodak black]": return [.highNoonDrive]
        case "mirrors": return [.lowFlame]
        case "back to the old house (2011 remaster)": return [.fadedMiles]
        case "slipping through my fingers": return [.fadedMiles]
        case "smooth operator (2011 remastered)": return [.lowFlame]
        case "baby come back": return [.fadedMiles]
        case "baby i'm back": return [.openCharge]
        case "baby by me": return [.highNoonDrive]
        case "sailor song": return [.quietWeight]
        case "invisible": return [.scorchedEarth]
        case "chicago": return [.fadedMiles]
        case "mind over matter (reprise)": return [.firstLight]
        case "end of beginning": return [.fadedMiles]
        case "wham bam shang-a-lang": return [.highNoonDrive]
        case "outside": return [.openCharge]
        case "love me (feat. drake & future)": return [.lowFlame]
        case "beauty and a beat (feat. nicki minaj)": return [.openCharge]
        case "boyfriend": return [.lowFlame]
        case "shut up my mom's calling": return [.quietWeight]
        case "i wanna be yours": return [.lowFlame]
        case "no. 1 party anthem": return [.fadedMiles]
        case "do i wanna know?": return [.lowFlame]
        case "v. 3005": return [.firstLight]
        case "feel it": return [.firstLight]
        case "chamber of reflection": return [.quietWeight]
        case "softcore": return [.lowFlame]
        case "reflections": return [.quietWeight]
        case "the color violet": return [.lowFlame]
        case "my all": return [.quietWeight]
        case "wildflower": return [.quietWeight]
        case "blue": return [.quietWeight]
        case "sienna": return [.fadedMiles]
        case "from the start": return [.firstLight]
        case "viva la vida": return [.fadedMiles]
        case "hymn for the weekend": return [.highNoonDrive]
        case "something just like this": return [.firstLight]
        case "duvet": return [.quietWeight]
        case "chasing pavements": return [.quietWeight]
        case "k.": return [.lowFlame]
        case "ku lo sa (with camila cabello)": return [.highNoonDrive]
        case "cool for the summer": return [.openCharge]
        case "die for you (with ariana grande) - remix": return [.quietWeight]
        case "is there someone else?": return [.quietWeight]
        case "timeless (feat. playboi carti)": return [.openCharge]
        case "no role modelz": return [.scorchedEarth]
        case "the party & the after party (slowed cut)": return [.lowFlame]
        case "breakin' my heart (pretty brown eyes) [sped up + reverb]": return [.lowFlame]
        case "high enough (slowed edit)": return [.firstLight]
        case "play date": return [.lowFlame]
        case "sucker": return [.highNoonDrive]
        case "placing the blame": return [.quietWeight]
        case "everything in its right place": return [.quietWeight]
        case "let down": return [.quietWeight]
        case "blue light": return [.firstLight]
        case "all i need": return [.lowFlame]
        case "here": return [.scorchedEarth]
        case "lisztomania": return [.highNoonDrive]
        case "4 raws": return [.scorchedEarth]
        case "the color violet (live)": return [.scorchedEarth]
        case "big罪罪罪罪罪罪罪": return [.anteikuCafe]
        case "meant to be (slowed)": return [.fadedMiles]
        case "or what": return [.scorchedEarth]
        case "mantra": return [.signalDrift]
        case "redbone": return [.fadedMiles]
        case "come and get your love (single version)": return [.highNoonDrive]
        case "i say a little prayer": return [.fadedMiles]
        case "love your voice": return [.highNoonDrive]
        case "main chick (feat. chris brown)": return [.highNoonDrive]
        case "oh yeah?": return [.highNoonDrive]
        case "you love me": return [.quietWeight]
        case "eyes without a face": return [.fadedMiles]
        case "when i close my eyes": return [.quietWeight]
        case "secret door": return [.fadedMiles]
        case "一緒なら", "青のすみか", "inferno (tv size)", "ashes on the fire",
             "you say run", "livingroom", "in the pool", "cóunter・attàck-mˈænkάɪnd",
             "call your name", "licht und schatten", "glassy sky", "call of silence":
            return [.anteikuCafe]
        default: return []
        }
    }

    /// The five visible shelves. Anteiku remains intact; every other song has
    /// exactly one broad emotional home. Signal Drift is reserved for non-anime
    /// instrumentals and background pieces as they are added.
    var shelfCategory: MusicCategory? {
        if artist == "Gabriel Piano" && title == "oh yeah?" { return .signalDrift }

        if musicCategories.contains(.anteikuCafe) {
            return .anteikuCafe
        }

        if musicCategories.contains(.signalDrift) {
            return .signalDrift
        }

        switch title.lowercased() {
        case "ちゅ、多様性。", "i really want to stay at your house", "ma meilleure ennemie":
            return .anteikuCafe

        case "theme of laura", "papaoutai", "it's snowing like it's the end of the world", "killswitch lullaby":
            return .signalDrift

        case "loser", "why you leave me", "rosyln", "mary",
             "letter home", "stress relief", "harvey", "hotel room",
             "hate that i made you love me", "doubt", "ivy", "flatline",
             "nights like this", "someone like you", "dark red", "car's outside",
             "look after you", "sailor song", "back to the old house (2011 remaster)",
             "slipping through my fingers", "shut up my mom's calling",
             "no. 1 party anthem", "chamber of reflection", "softcore", "reflections",
             "mind over matter (reprise)", "my all", "wildflower", "blue", "sienna",
             "duvet", "chasing pavements", "die for you (with ariana grande) - remix",
             "is there someone else?", "high enough (slowed edit)",
             "breakin' my heart (pretty brown eyes) [sped up + reverb]",
             "placing the blame", "everything in its right place", "let down",
             "i can't handle change", "sad girl", "summertime sadness",
             "say yes to heaven", "beanie", "how to save a life",
             "line without a hook", "join me in death",
             "somebody that i used to know", "telephones", "cannot get over you",
             "suffocation", "army dreamers", "blue hair", "tek it",
             "no other heart", "treat you better", "stitches",
             "you love me", "when i close my eyes", "m.":
            return .quietWeight

        case "be like a woman", "silver soul", "this love",
             "american wedding", "something about you", "bad habit", "earrings",
             "baby come back", "chicago", "end of beginning", "viva la vida",
             "v. 3005", "k.", "the party & the after party (slowed cut)",
             "blue light", "meant to be (slowed)", "redbone", "i say a little prayer",
             "just the two of us", "as it was", "disco", "teenage dirtbag",
             "young", "for the first time", "golden brown", "loving machine",
             "do ya like x resonance", "pope is a rockstar", "ulterior motives",
             "4:00 a.m.", "eyes without a face", "secret door":
            return .fadedMiles

        case "hey daddy (daddy's home)", "oh yeah?":
            return .highNoonDrive

        default:
            return .highNoonDrive
        }
    }
}

struct MetadataDraft {
    var title = ""
    var artist = ""
    var album = ""
}

final class ImportCandidate: Identifiable {
    let id = UUID()
    let sourceURL: URL
    var draft: MetadataDraft

    init(sourceURL: URL) {
        self.sourceURL = sourceURL
        self.draft = MetadataDraft(
            title: sourceURL.deletingPathExtension().lastPathComponent,
            artist: "",
            album: ""
        )
    }
}

extension TimeInterval {
    var clockString: String {
        guard isFinite, self >= 0 else { return "0:00" }
        let total = Int(self.rounded(.down))
        return String(format: "%d:%02d", total / 60, total % 60)
    }

    var preciseClockString: String {
        guard isFinite, self >= 0 else { return "0:00.0" }
        let totalTenths = Int((self * 10).rounded(.down))
        let minutes = totalTenths / 600
        let seconds = (totalTenths / 10) % 60
        let tenths = totalTenths % 10
        return String(format: "%d:%02d.%d", minutes, seconds, tenths)
    }
}
