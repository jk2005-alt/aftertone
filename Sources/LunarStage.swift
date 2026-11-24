import SwiftUI
import AVFoundation

private let ivory = Color(red: 0.99, green: 0.955, blue: 0.85)

struct LunarStage: View {
    @ObservedObject var player: AudioController
    let track: Track
    @EnvironmentObject var library: LibraryStore
    @State private var artwork: NSImage?
    let clock: PlaybackClock
    let suggestions: [Track]
    let select: (Track) -> Void
    let fullscreen: () -> Void

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let disc = min(w * 0.33, h * 0.54) * 0.55
            let moonAnchor = min(70.0, h * 0.135)
            let center = CGPoint(x: moonAnchor * 0.56, y: h - moonAnchor * 0.65)
            ZStack(alignment: .topLeading) {
                LunarSky(playing: player.isPlaying)
                Color.clear.contentShape(Rectangle()).onTapGesture(count: 2, perform: fullscreen)
                LunarPhrase(clock: clock, width: w * 0.36)
                    .position(x: w * 0.77, y: h * 0.49)
                VStack(alignment: .leading, spacing: 5) {
                    Text(track.artist.uppercased()).font(.caption2.weight(.medium)).tracking(2.2)
                    Text(track.displayTitle).font(.headline)
                }.foregroundStyle(ivory.opacity(0.72)).padding(26).allowsHitTesting(false)
                let radius = disc / 2 + 25
                let orbitTop = center.y - radius * 2.2
                let orbitCenter = CGPoint(x: center.x, y: center.y - orbitTop)
                let panelWidth = max(1, min(340, w / 2 - 72))
                let rowWidth = max(1, panelWidth - center.x - radius - 4)
                OrbitSongList(tracks: suggestions, radius: radius, center: orbitCenter,
                              rowWidth: rowWidth, library: library, select: select)
                .frame(width: panelWidth, height: h - orbitTop)
                .clipped()
                .position(x: panelWidth / 2, y: (h + orbitTop) / 2)
                .accessibilityLabel("Browse songs")
                Button { player.togglePlayback() } label: {
                    CompactDisc(artwork: artwork, playing: player.isPlaying)
                        .frame(width: disc, height: disc)
                        .contentShape(Circle())
                }
                .buttonStyle(DiscPressStyle(playing: player.isPlaying))
                .accessibilityLabel(player.isPlaying ? "Pause" : "Play")
                .help(player.isPlaying ? "Pause" : "Play")
                .focusEffectDisabled()
                .frame(width: disc, height: disc)
                .mask(alignment: .topTrailing) {
                    // Keep the offstage part cropped even when the button gets focus.
                    Rectangle()
                        .frame(width: min(disc, center.x + disc / 2),
                               height: min(disc, h - center.y + disc / 2))
                }
                .position(center)
            }
        }.clipShape(RoundedRectangle(cornerRadius: 18))
        .task(id: track.id) {
            artwork = await library.coverImage(for: track)
        }
    }
}

struct TrackThumbnail: View {
    @EnvironmentObject private var library: LibraryStore
    let track: Track
    let size: CGFloat
    @State private var cover: NSImage?

    var body: some View {
        Group {
            if let cover {
                Image(nsImage: cover).resizable().scaledToFill()
            } else {
                Image(systemName: "music.note")
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 3))
        .accessibilityHidden(true)
        .task(id: track.id) {
            let image = await library.coverImage(for: track, thumbnail: true)
            if !Task.isCancelled { cover = image }
        }
    }
}

private struct DiscPressStyle: ButtonStyle {
    let playing: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay {
                Circle()
                    .fill(.black.opacity(configuration.isPressed ? 0.32 : (playing ? 0 : 0.15)))
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.14), value: configuration.isPressed)
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: playing)
                    .allowsHitTesting(false)
            }
    }
}

private struct CompactDisc: View {
    let artwork: NSImage?
    let playing: Bool
    @State private var elapsed: TimeInterval = 0
    @State private var started: TimeInterval?

    var body: some View {
        GeometryReader { geometry in
            let diameter = min(geometry.size.width, geometry.size.height)
            let foil = AngularGradient(colors: [.gray, .white, .gray, .black, .white, .gray], center: .center)
            ZStack {
                TimelineView(.animation(minimumInterval: 1.0 / 30, paused: !playing)) { _ in
                    let now = ProcessInfo.processInfo.systemUptime
                    let seconds = elapsed + (started.map { now - $0 } ?? 0)
                    Group {
                        if let artwork { Image(nsImage: artwork).resizable().scaledToFill() }
                        else { foil }
                    }
                        .frame(width: diameter, height: diameter)
                        .clipped().saturation(0).contrast(0.86).brightness(0.16)
                        .rotationEffect(.degrees(seconds * 12))
                }
                .mask(Circle().strokeBorder(lineWidth: diameter * 0.485))

                Canvas { context, size in
                    var grooves = Path()
                    let count = max(1, Int(diameter * 0.30))
                    for index in 1...count {
                        let inset = CGFloat(index) / CGFloat(count) * diameter * 0.475
                        grooves.addEllipse(in: CGRect(origin: .zero, size: size).insetBy(dx: inset, dy: inset))
                    }
                    context.stroke(grooves, with: .color(.white.opacity(0.18)), lineWidth: 0.45)
                }
                Circle().strokeBorder(foil.opacity(0.75), lineWidth: max(0.75, diameter * 0.006))
                Circle().strokeBorder(.white.opacity(0.32), lineWidth: 0.5)
                    .frame(width: diameter * 0.032, height: diameter * 0.032)
            }
        }
        .onChange(of: playing, initial: true) { _, active in
            let now = ProcessInfo.processInfo.systemUptime
            if active {
                started = started ?? now
            } else if let start = started {
                elapsed += now - start
                started = nil
            }
        }
    }
}

private struct LunarPhrase: View {
    @EnvironmentObject var lyrics: LyricsController
    @ObservedObject var clock: PlaybackClock
    let width: CGFloat
    var body: some View {
        let id = lyrics.activeLineID(at: clock.currentTime)
        let line = lyrics.lines.first(where: { $0.id == id })?.text ?? "···"
        if !lyrics.lines.isEmpty && lyrics.lines.allSatisfy({ $0.timestamp == nil }) {
            ScrollView {
                Text(lyrics.lines.map(\.text).joined(separator: "\n"))
                    .font(.system(size: 20, weight: .medium))
                    .lineSpacing(10).foregroundStyle(ivory)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: width, height: 320)
        } else {
        Text(line.uppercased()).font(.system(size: min(48, width * 0.098), weight: .heavy))
            .tracking(-0.7).foregroundStyle(ivory).multilineTextAlignment(.leading)
            .frame(width: width, alignment: .leading).id(id)
            .transition(.opacity).animation(.easeOut(duration: 0.15), value: id)
            .allowsHitTesting(false)
        }
    }
}

private struct LunarSky: View {
    let playing: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private static let earth = Bundle.main.url(forResource: "EarthHorizon", withExtension: "jpg")
        .flatMap { NSImage(contentsOf: $0) }

    var body: some View {
        ZStack {
            Color.black
            if let earth = Self.earth {
                Image(nsImage: earth).resizable()
                if !reduceMotion { EarthSurface(playing: playing) }
            }
            frameLight
        }.allowsHitTesting(false).accessibilityHidden(true)
    }

    private var frameLight: some View {
        Canvas { context, size in
            let bounds = CGRect(origin: .zero, size: size)
            let depth = min(size.width, size.height) * 0.10
            func edgeLight(from edge: CGPoint, to interior: CGPoint, strength: Double) {
                let falloff = Gradient(stops: [
                    .init(color: .white.opacity(strength), location: 0),
                    .init(color: .white.opacity(strength * 0.46), location: 0.14),
                    .init(color: .white.opacity(strength * 0.12), location: 0.55),
                    .init(color: .clear, location: 1)
                ])
                context.fill(Path(bounds), with: .linearGradient(falloff, startPoint: edge, endPoint: interior))
            }
            edgeLight(from: .zero, to: CGPoint(x: 0, y: depth), strength: 0.19)
            edgeLight(from: CGPoint(x: 0, y: size.height), to: CGPoint(x: 0, y: size.height - depth), strength: 0.11)
            edgeLight(from: .zero, to: CGPoint(x: depth * 0.55, y: 0), strength: 0.055)
            edgeLight(from: CGPoint(x: size.width, y: 0), to: CGPoint(x: size.width - depth * 0.55, y: 0), strength: 0.065)
        }.allowsHitTesting(false).accessibilityHidden(true)
    }
}
