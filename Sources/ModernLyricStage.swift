import SwiftUI

struct ModernLyricStage: View {
    @EnvironmentObject private var player: AudioController
    @EnvironmentObject private var lyrics: LyricsController
    @ObservedObject var clock: PlaybackClock
    var fullscreen = false
    var transitioning = false
    var toggleFullscreen: (() -> Void)? = nil

    var body: some View {
        ZStack {
            Color.black
            Canvas { context, size in
                for i in 0..<45 {
                    let x = Double((i * 137 + 23) % 997) / 997 * size.width
                    let y = Double((i * 211 + 59) % 991) / 991 * size.height
                    context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: i % 5 == 0 ? 2 : 1, height: i % 5 == 0 ? 2 : 1)), with: .color(AuralisTheme.phosphor.opacity(i % 5 == 0 ? 0.24 : 0.10)))
                }
            }.allowsHitTesting(false)
            Group {
                let active = lyrics.activeLineID(at: clock.currentTime)
                let center = lyrics.lines.firstIndex { $0.id == active }
                VStack(spacing: 24) {
                    if let center {
                        ForEach(max(0, center - 1)...min(lyrics.lines.count - 1, center + 1), id: \.self) { index in
                            Text(lyrics.lines[index].text)
                                .font(.system(size: index == center ? 27 : 17, weight: index == center ? .semibold : .regular))
                                .foregroundStyle(AuralisTheme.phosphor.opacity(index == center ? 1 : 0.30))
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        if player.currentTrack == nil {
                            Text("Aftertone").font(.system(size: 30, weight: .semibold))
                            Image(systemName: "sparkle").font(.system(size: 26))
                        } else {
                            Text("···").font(.system(size: 22, weight: .light))
                        }
                    }
                }.padding(.horizontal, 60)
                    .animation(.easeInOut(duration: 0.3), value: active)
            }
            if let track = player.currentTrack {
              VStack(spacing: 7) {
                Text(track.displayTitle)
                    .font(.system(size: 19, weight: .semibold))
                Text(track.artist)
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                Spacer()
                Text(player.currentTrack?.album ?? "")
                    .font(.system(size: 10)).foregroundStyle(.secondary)
            }.padding(35).allowsHitTesting(false)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(AuralisTheme.phosphor.opacity(fullscreen ? 0 : 0.14), lineWidth: 1))
        .overlay {
            if fullscreen && !transitioning { TravelingEdgeLight().allowsHitTesting(false) }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 2) { toggleFullscreen?() }
        .accessibilityAction(named: fullscreen ? "Exit fullscreen" : "Fullscreen lyrics") { toggleFullscreen?() }
        .help("Double-click for fullscreen · Esc to exit")
    }
}

private struct TravelingEdgeLight: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var origin = Date()
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: reduceMotion)) { timeline in
            let phase = reduceMotion ? 0 : timeline.date.timeIntervalSince(origin) * 36
            Canvas { context, size in
                let gradient = Gradient(stops: [
                    .init(color: .white.opacity(0), location: 0),
                    .init(color: .white.opacity(0), location: 0.38),
                    .init(color: .white.opacity(0.12), location: 0.42),
                    .init(color: .white.opacity(0.55), location: 0.46),
                    .init(color: .white, location: 0.50),
                    .init(color: .white.opacity(0.55), location: 0.54),
                    .init(color: .white.opacity(0.12), location: 0.58),
                    .init(color: .white.opacity(0), location: 0.62),
                    .init(color: .white.opacity(0), location: 1)
                ])
                let light = GraphicsContext.Shading.conicGradient(gradient,
                    center: CGPoint(x: size.width / 2, y: size.height / 2), angle: .degrees(phase))
                // A continuous inward falloff, rather than a thin outline with
                // discrete halos. Draw directly: no fullscreen blur surfaces.
                let spread = min(70.0, max(44.0, min(size.width, size.height) * 0.075))
                for band in 0..<48 {
                    let depth = Double(band) * spread / 48
                    let rect = CGRect(origin: .zero, size: size).insetBy(dx: 3 + depth, dy: 3 + depth)
                    guard rect.width > 0, rect.height > 0 else { continue }
                    var layer = context
                    layer.opacity = exp(-pow(depth / (spread * 0.38), 2)) * 0.94
                    layer.stroke(Path(roundedRect: rect, cornerRadius: max(3, 20 - depth * 0.4)),
                                 with: light, lineWidth: spread / 48 + 0.4)
                }
            }
        }
    }
}

struct ModernPlaybackProgress: View {
    @ObservedObject var clock: PlaybackClock
    let seek: (Double) -> Void
    @State private var scrubbing = false
    @State private var position = 0.0
    var body: some View {
        VStack(spacing: 5) {
            Slider(value: Binding(get: { scrubbing ? position : clock.currentTime }, set: { position = $0 }), in: 0...max(0.01, clock.duration)) { editing in
                scrubbing = editing
                if !editing { seek(position) }
            }.accessibilityLabel("Playback position")
            HStack {
                Text((scrubbing ? position : clock.currentTime).clockString)
                Spacer()
                Text(clock.duration.clockString)
            }.font(.system(size: 10, design: .monospaced)).foregroundStyle(.secondary)
        }
    }
}
