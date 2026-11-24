import SwiftUI

struct LyricsScreenView: View {
    @EnvironmentObject private var player: AudioController
    @EnvironmentObject private var lyrics: LyricsController
    @ObservedObject var clock: PlaybackClock

    private var activeID: Int? { lyrics.activeLineID(at: clock.currentTime) }
    private var activeIndex: Int? {
        guard let activeID else { return lyrics.lines.isEmpty ? nil : 0 }
        return lyrics.lines.firstIndex { $0.id == activeID }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(RadialGradient(
                    colors: [Color(red: 0.034, green: 0.060, blue: 0.031), Color(red: 0.010, green: 0.017, blue: 0.009)],
                    center: .center, startRadius: 10, endRadius: 520
                ))
            crtGrid
            lyricContent

            VStack(spacing: 2) {
                Text(player.currentTrack?.artist.uppercased() ?? "AFTERTONE")
                    .font(.system(size: 13, weight: .black, design: .monospaced)).tracking(1.5)
                Text(player.currentTrack?.displayTitle.uppercased() ?? "NO TAPE LOADED")
                    .font(.system(size: 8, weight: .bold, design: .monospaced)).tracking(1.0).opacity(0.58)
                Spacer()
                HStack {
                    Text(clock.currentTime.clockString)
                    Spacer()
                    Text(lyrics.sourceLabel.uppercased())
                    Spacer()
                    Text("−\(max(0, clock.duration - clock.currentTime).clockString)")
                }
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .opacity(0.55)
            }
            .foregroundStyle(AuralisTheme.phosphor)
            .padding(.horizontal, 29).padding(.vertical, 23)
            .allowsHitTesting(false)

            RoundedRectangle(cornerRadius: 22)
                .fill(LinearGradient(colors: [AuralisTheme.paper.opacity(0.035), .clear, .black.opacity(0.20)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blendMode(.screen).allowsHitTesting(false)
            RoundedRectangle(cornerRadius: 22)
                .fill(RadialGradient(colors: [.clear, .black.opacity(0.43)], center: .center, startRadius: 140, endRadius: 550))
                .allowsHitTesting(false)
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.black.opacity(0.92), lineWidth: 13)
                .shadow(color: .black.opacity(0.95), radius: 10)
                .allowsHitTesting(false)
        }
        .aspectRatio(1.34, contentMode: .fit)
        .animation(.easeOut(duration: 0.10), value: activeID)
    }

    private var crtGrid: some View {
        Canvas { context, size in
            var lines = Path()
            stride(from: CGFloat(0), through: size.height, by: 5).forEach {
                lines.move(to: CGPoint(x: 0, y: $0)); lines.addLine(to: CGPoint(x: size.width, y: $0))
            }
            context.stroke(lines, with: .color(.black.opacity(0.17)), lineWidth: 1)
            var guides = Path()
            for fraction in [0.2, 0.5, 0.8] {
                guides.move(to: CGPoint(x: size.width * fraction, y: 0))
                guides.addLine(to: CGPoint(x: size.width * fraction, y: size.height))
            }
            context.stroke(guides, with: .color(AuralisTheme.phosphorDim.opacity(0.055)), lineWidth: 0.7)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    @ViewBuilder private var lyricContent: some View {
        switch lyrics.state {
        case .idle:
            screenStatus("NO LYRIC TAPE", detail: "SELECT A TRACK TO LOAD TIMECODE")
        case .loading:
            VStack(spacing: 12) {
                ProgressView().controlSize(.small).tint(AuralisTheme.phosphor)
                Text("LOADING LYRIC TAPE…")
            }
            .font(.system(size: 11, weight: .black, design: .monospaced)).tracking(1)
            .foregroundStyle(AuralisTheme.phosphor)
        case .instrumental:
            screenStatus("INSTRUMENTAL", detail: "NO VOCAL TIMECODE")
        case .unavailable:
            screenStatus("NO SYNC FOUND", detail: "LYRICS WILL BE ADDED WITH THE TRACK")
        case .ready:
            if lyrics.lines.contains(where: { !$0.words.isEmpty }) {
                ConstellationLyrics(lines: lyrics.lines, time: clock.currentTime + lyrics.offset)
            } else {
                lyricStack
            }
        }
    }

    private var lyricStack: some View {
        let center = activeIndex ?? 0
        let lower = max(0, center - 3)
        let upper = min(lyrics.lines.count - 1, center + 3)
        return VStack(spacing: 17) {
            if !lyrics.lines.isEmpty {
                ForEach(Array(lower...upper), id: \.self) { index in
                    let line = lyrics.lines[index]
                    let distance = abs(index - center)
                    Button {
                        if let timestamp = line.timestamp { player.seek(to: max(0, timestamp - lyrics.offset)) }
                    } label: {
                        Text(line.text.uppercased())
                            .font(.system(
                                size: distance == 0 ? 22 : (distance == 1 ? 14 : 11),
                                weight: distance == 0 ? .black : .semibold,
                                design: .monospaced
                            ))
                            .tracking(distance == 0 ? 1.0 : 0.45)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(AuralisTheme.phosphor.opacity(distance == 0 ? 1 : (distance == 1 ? 0.43 : 0.18)))
                            .shadow(color: distance == 0 ? AuralisTheme.phosphor.opacity(0.62) : .clear, radius: 5)
                    }
                    .buttonStyle(.plain)
                    .disabled(line.timestamp == nil)
                }
            }
        }
        .padding(.horizontal, 52).padding(.vertical, 75)
    }

    private func screenStatus(_ title: String, detail: String) -> some View {
        VStack(spacing: 9) {
            Text(title).font(.system(size: 15, weight: .black, design: .monospaced)).tracking(2)
            Text(detail).font(.system(size: 8, weight: .bold, design: .monospaced)).tracking(1).opacity(0.48)
        }
        .foregroundStyle(AuralisTheme.phosphor)
    }
}

struct LyricsPanel: View {
    @EnvironmentObject private var player: AudioController
    @EnvironmentObject private var lyrics: LyricsController
    @ObservedObject var clock: PlaybackClock
    let onClose: () -> Void

    @State private var activeLineID: Int?

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().overlay(AuralisTheme.phosphorDim.opacity(0.28))
            lyricReader
        }
        .frame(width: 318)
        .background(Color(red: 0.050, green: 0.048, blue: 0.037))
        .overlay(alignment: .leading) { Rectangle().fill(.black.opacity(0.82)).frame(width: 3) }
    }

    private var header: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("LYRIC TELETYPE").font(.system(size: 11, weight: .black, design: .rounded)).tracking(1.7)
                    Text("MODEL LRC-72 · TIMECODE READER")
                        .font(.system(size: 7, weight: .bold, design: .monospaced)).tracking(0.8).foregroundStyle(.secondary)
                }
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark").font(.system(size: 10, weight: .black)).frame(width: 25, height: 24)
                        .background(Color(red: 0.25, green: 0.24, blue: 0.18), in: RoundedRectangle(cornerRadius: 2))
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(.black.opacity(0.8), lineWidth: 1.5))
                }.buttonStyle(.plain)
            }

            HStack(spacing: 14) {
                TapeReel(spinning: player.isPlaying, phase: clock.currentTime)
                VStack(alignment: .leading, spacing: 4) {
                    Text(player.currentTrack?.displayTitle.uppercased() ?? "NO TAPE LOADED")
                        .font(.system(size: 9, weight: .black, design: .monospaced)).lineLimit(1)
                    Text(lyrics.sourceLabel)
                        .font(.system(size: 7, weight: .bold, design: .monospaced)).tracking(0.7)
                        .foregroundStyle(AuralisTheme.phosphorDim)
                }
                Spacer()
                TapeReel(spinning: player.isPlaying, phase: -clock.currentTime * 0.87)
            }
        }
        .foregroundStyle(AuralisTheme.paper)
        .padding(14)
        .background(Color.black.opacity(0.20))
    }

    @ViewBuilder private var lyricReader: some View {
        ZStack {
            Color(red: 0.018, green: 0.030, blue: 0.016)
            grid
            contentForState
            LinearGradient(colors: [.black.opacity(0.64), .clear, .clear, .black.opacity(0.68)], startPoint: .top, endPoint: .bottom)
                .allowsHitTesting(false)
        }
        .frame(maxHeight: .infinity)
        .overlay(Rectangle().stroke(.black.opacity(0.9), lineWidth: 5))
    }

    private var grid: some View {
        Canvas { context, size in
            var lines = Path()
            stride(from: CGFloat(0), through: size.height, by: 4).forEach {
                lines.move(to: CGPoint(x: 0, y: $0)); lines.addLine(to: CGPoint(x: size.width, y: $0))
            }
            context.stroke(lines, with: .color(.black.opacity(0.17)), lineWidth: 1)
            var center = Path()
            center.move(to: CGPoint(x: 16, y: 0)); center.addLine(to: CGPoint(x: 16, y: size.height))
            center.move(to: CGPoint(x: size.width - 16, y: 0)); center.addLine(to: CGPoint(x: size.width - 16, y: size.height))
            context.stroke(center, with: .color(AuralisTheme.phosphorDim.opacity(0.12)), lineWidth: 1)
        }
    }

    @ViewBuilder private var contentForState: some View {
        switch lyrics.state {
        case .idle:
            statusView(symbol: "text.quote", title: "NO LYRIC TAPE", detail: "Play a track to load its synced lyrics automatically.")
        case .loading:
            VStack(spacing: 13) {
                ProgressView().controlSize(.small).tint(AuralisTheme.phosphor)
                Text("SEARCHING TIMECODE ARCHIVE…")
                    .font(.system(size: 8, weight: .black, design: .monospaced)).tracking(0.8).foregroundStyle(AuralisTheme.phosphor)
            }
        case .instrumental:
            statusView(symbol: "waveform", title: "INSTRUMENTAL", detail: "No vocal transcript is required.")
        case .unavailable(let message):
            statusView(symbol: "exclamationmark.triangle", title: "NO SYNC FOUND", detail: message)
        case .ready:
            scrollingLyrics
        }
    }

    private var scrollingLyrics: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading, spacing: 20) {
                    Color.clear.frame(height: 190)
                    ForEach(lyrics.lines) { line in
                        lyricLine(line)
                            .id(line.id)
                    }
                    Color.clear.frame(height: 220)
                }
                .padding(.horizontal, 25)
            }
            .onAppear { updateActiveLine(using: proxy, animated: false) }
            .onChange(of: clock.currentTime) { _, _ in updateActiveLine(using: proxy, animated: true) }
            .onChange(of: lyrics.lines.count) { _, _ in updateActiveLine(using: proxy, animated: false) }
        }
    }

    private func lyricLine(_ line: LyricLine) -> some View {
        let active = activeLineID == line.id
        return Button {
            if let time = line.timestamp { player.seek(to: max(0, time - lyrics.offset)) }
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 9) {
                Text(line.timestamp.map { $0.clockString } ?? "···")
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .frame(width: 29, alignment: .trailing)
                    .opacity(active ? 0.85 : 0.28)
                Text(line.text.uppercased())
                    .font(.system(size: active ? 14 : 11, weight: active ? .black : .semibold, design: .monospaced))
                    .tracking(active ? 0.7 : 0.3)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .foregroundStyle(active ? AuralisTheme.phosphor : AuralisTheme.phosphorDim.opacity(0.55))
            .shadow(color: active ? AuralisTheme.phosphor.opacity(0.55) : .clear, radius: 4)
            .animation(.easeOut(duration: 0.22), value: active)
        }
        .buttonStyle(.plain)
        .disabled(line.timestamp == nil)
    }

    private func statusView(symbol: String, title: String, detail: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: symbol).font(.system(size: 25)).foregroundStyle(AuralisTheme.phosphorDim)
            Text(title).font(.system(size: 10, weight: .black, design: .monospaced)).tracking(1)
            Text(detail).font(.system(size: 9, design: .monospaced)).foregroundStyle(.secondary).multilineTextAlignment(.center).lineSpacing(3)
        }.padding(28)
    }

    private func updateActiveLine(using proxy: ScrollViewProxy, animated: Bool) {
        let next = lyrics.activeLineID(at: clock.currentTime)
        guard next != activeLineID else { return }
        activeLineID = next
        guard let next else { return }
        if animated {
            withAnimation(.easeInOut(duration: 0.42)) { proxy.scrollTo(next, anchor: .center) }
        } else { proxy.scrollTo(next, anchor: .center) }
    }
}

private struct TapeReel: View {
    let spinning: Bool
    let phase: Double
    var body: some View {
        ZStack {
            Circle().fill(Color(red: 0.14, green: 0.13, blue: 0.10)).frame(width: 34, height: 34)
                .overlay(Circle().stroke(AuralisTheme.paper.opacity(0.24), lineWidth: 1))
            ForEach(0..<3, id: \.self) { spoke in
                Capsule().fill(AuralisTheme.paper.opacity(0.38)).frame(width: 3, height: 13).offset(y: -7)
                    .rotationEffect(.degrees(Double(spoke) * 120 + phase * (spinning ? 40 : 0)))
            }
            Circle().fill(Color.black).frame(width: 6, height: 6)
        }
    }
}
