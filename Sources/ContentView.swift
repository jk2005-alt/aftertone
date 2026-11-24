import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var library: LibraryStore
    @EnvironmentObject private var player: AudioController
    @EnvironmentObject private var lyrics: LyricsController
    @EnvironmentObject private var discord: DiscordPresenceController

    @State private var theatreMode = false
    @State private var lyricsFullscreen = false
    @State private var enteredNativeFullscreen = false
    @State private var fullscreenTransitioning = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shuffle = false
    @State private var power = true
    @State private var mainScreenMode: MainScreenMode = .lyrics
    @State private var categoryBrowserExpanded = false
    @State private var editingTrack: Track?
    @State private var editingDraft = MetadataDraft()
    @State private var removalTarget: Track?
    @State private var discordSettingsPresented = false
    @State private var lyricsEditingTrack: Track?

    var body: some View {
        ZStack {
            AuralisTheme.background.ignoresSafeArea()
              VStack(spacing: 0) {
                if !lyricsFullscreen { topBar }
                HStack(spacing: 0) {
                    if !theatreMode && !lyricsFullscreen { librarySidebar }
                    constellationArea
                }
            }
        }
        .onExitCommand { if lyricsFullscreen { toggleLyricsFullscreen() } }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didEnterFullScreenNotification)) { _ in
            if enteredNativeFullscreen { lyricsFullscreen = true }
            fullscreenTransitioning = false
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didExitFullScreenNotification)) { _ in
            lyricsFullscreen = false
            enteredNativeFullscreen = false
            fullscreenTransitioning = false
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.45, dampingFraction: 0.88), value: theatreMode)
        .sheet(item: $library.importCandidate) { candidate in
            MetadataEditor(
                heading: "Identify this MP3",
                draft: Binding(get: { candidate.draft }, set: { candidate.draft = $0 }),
                confirmTitle: "Add to Aftertone",
                onConfirm: { _ in library.commitImport(candidate, artworkURL: nil) },
                onCancel: { library.cancelCurrentImport() }
            )
        }
        .sheet(item: $editingTrack) { track in
            MetadataEditor(
                heading: "Edit track metadata",
                draft: $editingDraft,
                confirmTitle: "Save Metadata",
                onConfirm: { _ in
                    library.update(track, title: editingDraft.title, artist: editingDraft.artist, album: editingDraft.album, artworkURL: nil)
                    editingTrack = nil
                },
                onCancel: { editingTrack = nil }
            )
        }
        .sheet(isPresented: $discordSettingsPresented) {
            DiscordSettingsView(discord: discord)
        }
        .sheet(item: $lyricsEditingTrack) { track in
            SongLyricsEditor(track: track, initialText: library.cachedLyrics(for: track) ?? "") { text in
                guard let updated = library.saveLyrics(text, for: track) else { return false }
                if player.currentTrack?.id == track.id {
                    Task { await lyrics.prepare(for: updated, library: library, fetchIfMissing: false) }
                }
                return true
            }
        }
        .alert("Aftertone", isPresented: Binding(
            get: { library.alertMessage != nil || player.errorMessage != nil },
            set: { if !$0 { library.alertMessage = nil; player.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { library.alertMessage = nil; player.errorMessage = nil }
        } message: {
            Text(library.alertMessage ?? player.errorMessage ?? "Unknown error")
        }
        .alert("Remove this track?", isPresented: Binding(get: { removalTarget != nil }, set: { if !$0 { removalTarget = nil } })) {
            Button("Cancel", role: .cancel) { removalTarget = nil }
            Button("Remove", role: .destructive) {
                if let target = removalTarget {
                    if player.currentTrack?.id == target.id { player.unload() }
                    library.remove(target)
                }
                removalTarget = nil
            }
        } message: {
            Text(removalTarget?.isBundled == true
                 ? "This song will be hidden from your library."
                 : "The Aftertone copy and its saved lyrics will be deleted. Your original file will not be touched.")
        }
        .onAppear {
            player.onTrackEnded = { playNext() }
            discord.start(player: player)

        }
    }

    private var topBar: some View {
        WindowDragHandle().frame(height: 28)
    }

    private var librarySidebar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Button { library.requestImport() } label: { Label("Add", systemImage: "plus") }
                    .help("Add songs")
                Spacer(minLength: 0)
                Button {
                    if let track = library.selectedTrack { lyricsEditingTrack = track }
                } label: { Image(systemName: "text.alignleft") }
                    .help("Add or edit lyrics for the selected song")
                    .accessibilityLabel("Add or edit lyrics")
                    .disabled(library.selectedTrack == nil)
                Button { removalTarget = library.selectedTrack } label: { Image(systemName: "minus") }
                    .help("Remove the selected song")
                    .accessibilityLabel("Remove song")
                    .disabled(library.selectedTrack == nil)
            }
            .buttonStyle(.bordered).controlSize(.small).tint(.white.opacity(0.75))
            .padding(.horizontal, 14).padding(.top, 10)
            HStack {
                Text("LIBRARY").font(.system(size: 10, weight: .black, design: .rounded)).tracking(1.5)
                Text("\(library.filteredTracks.count)/\(library.tracks.count)").font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundStyle(.secondary)
                Spacer()
            }.padding(.horizontal, 15).padding(.top, 15).padding(.bottom, 10)

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search songs, artists, albums", text: $library.searchText).textFieldStyle(.plain)
            }
            .font(.system(size: 11, design: .rounded))
            .padding(.horizontal, 10).frame(height: 32)
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 7))
            .padding(.horizontal, 12).padding(.bottom, 10)

            categoryBank

            if library.tracks.isEmpty {
                VStack(spacing: 13) {
                    Spacer()
                    Image(systemName: "waveform.badge.plus").font(.system(size: 34)).foregroundStyle(AuralisTheme.phosphor.opacity(0.72))
                    Button("Add MP3") { library.requestImport() }.buttonStyle(OldActionButtonStyle())
                    Spacer()
                }.padding(24)
            } else if library.filteredTracks.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: library.selectedCategory == .anteikuCafe ? "cup.and.saucer.fill" : "waveform.slash")
                        .font(.system(size: 30))
                        .foregroundStyle(AuralisTheme.phosphor.opacity(0.66))
                    Text(library.searchText.isEmpty ? "No songs in this category" : "No matching songs")
                        .font(.callout).foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(24)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 4) {
                        ForEach(library.filteredTracks) { track in
                            trackRow(track)
                        }
                    }.padding(.horizontal, 8).padding(.bottom, 12)
                }
            }
        }
        .frame(width: 275)
        .background(Color(red: 0.025, green: 0.030, blue: 0.045))
        .overlay(alignment: .trailing) { Rectangle().fill(.white.opacity(0.06)).frame(width: 1) }
    }

    private var categoryBank: some View {
        VStack(alignment: .leading, spacing: 7) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    CategoryTab(
                        title: "ALL SONGS", count: library.trackCount(in: nil),
                        selected: library.selectedCategory == nil
                    ) { library.selectedCategory = nil }
                    ForEach(library.categories) { category in
                        CategoryTab(
                            title: category.rawValue, count: library.trackCount(in: category),
                            selected: library.selectedCategory == category
                        ) { library.selectedCategory = category }
                    }
                }
                .padding(.horizontal, 12)
            }
            HStack(spacing: 7) {
                Spacer(minLength: 4)
                Button { categoryBrowserExpanded = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "rectangle.grid.2x2").font(.system(size: 7, weight: .bold))
                        Text("Categories")
                    }
                    .font(.system(size: 7, weight: .black, design: .monospaced))
                    .foregroundStyle(AuralisTheme.phosphorDim)
                    .padding(.horizontal, 6).frame(height: 19)
                    .background(Color.black.opacity(0.32))
                    .overlay(Rectangle().stroke(AuralisTheme.phosphorDim.opacity(0.34)))
                }
                .buttonStyle(.plain)
                .help("Browse categories")
            }
            .padding(.horizontal, 15)
        }
        .padding(.bottom, 10)
        .animation(.easeOut(duration: 0.12), value: library.selectedCategory)
    }

    private func trackRow(_ track: Track) -> some View {
        let selected = player.currentTrack?.id == track.id
        return Button { select(track) } label: {
            HStack(spacing: 10) {
                TrackThumbnail(track: track, size: 42)
                VStack(alignment: .leading, spacing: 3) {
                    Text(track.displayTitle).font(.system(size: 12, weight: .bold, design: .rounded)).lineLimit(1)
                    Text(track.artist).font(.system(size: 10, weight: .medium, design: .rounded)).foregroundStyle(selected ? AuralisTheme.phosphor.opacity(0.8) : .secondary).lineLimit(1)
                    Text(track.album).font(.system(size: 9, design: .rounded)).foregroundStyle(.tertiary).lineLimit(1)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 7) {
                    if selected { Image(systemName: player.isPlaying ? "waveform" : "pause.fill").foregroundStyle(AuralisTheme.phosphor) }
                    Text(track.duration.clockString).font(.system(size: 8, weight: .medium, design: .monospaced)).foregroundStyle(.tertiary)
                }
            }
            .padding(8)
            .background(selected ? AuralisTheme.phosphor.opacity(0.09) : Color.clear, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(selected ? AuralisTheme.phosphor.opacity(0.16) : .clear))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .contextMenu {
            Menu("Move to Category") {
                ForEach(library.categories) { category in
                    Button(category.rawValue) { library.move(track, to: category) }
                }
                Divider()
                Button("All Songs only") { library.move(track, to: nil) }
            }
            Button("Add or Edit Lyrics…") { lyricsEditingTrack = track }
            if track.isBundled != true {
                Button("Edit Metadata…") { beginEditing(track) }
            }
            Divider()
            Button("Remove from Aftertone", role: .destructive) { removalTarget = track }
        }
    }

    private var constellationArea: some View {
        VStack(spacing: 8) {
            ZStack {
                if let track = player.currentTrack {
                    LunarStage(player: player, track: track, clock: player.clock, suggestions: lunarSuggestions, select: select, fullscreen: toggleLyricsFullscreen)
                        .id(track.id)
                } else {
                    ModernLyricStage(clock: player.clock, fullscreen: lyricsFullscreen, transitioning: fullscreenTransitioning, toggleFullscreen: toggleLyricsFullscreen)
                }
                if categoryBrowserExpanded {
                    CategoryBrowserOverlay(library: library, isPresented: $categoryBrowserExpanded)
                }
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
            if !lyricsFullscreen {
            HStack(spacing: 20) {
                Button { shuffle.toggle() } label: { Image(systemName: "shuffle").opacity(shuffle ? 1 : 0.35) }.help("Shuffle")
                Button { player.isLooping.toggle() } label: { Image(systemName: "repeat").opacity(player.isLooping ? 1 : 0.35) }.help("Repeat")
                Spacer()
                Image(systemName: "speaker.wave.2").foregroundStyle(.secondary)
                Slider(value: $player.volume, in: 0...1).frame(width: 100).help("Volume")
            }.buttonStyle(.plain)
            ModernPlaybackProgress(clock: player.clock, seek: { player.seek(to: $0) })
            }
        }
        .tint(AuralisTheme.phosphor)
        .foregroundStyle(AuralisTheme.paper)
        .padding(.horizontal, lyricsFullscreen ? 0 : 12)
        .padding(.top, lyricsFullscreen ? 0 : 8)
        .padding(.bottom, lyricsFullscreen ? 0 : 10)
        .background(AuralisTheme.background)
    }

    private func toggleLyricsFullscreen() {
        guard !fullscreenTransitioning, let window = NSApp.keyWindow else { return }
        if lyricsFullscreen {
            if enteredNativeFullscreen && window.styleMask.contains(.fullScreen) {
                fullscreenTransitioning = true
                window.toggleFullScreen(nil)
            } else {
                lyricsFullscreen = false
                enteredNativeFullscreen = false
            }
        } else {
            enteredNativeFullscreen = !window.styleMask.contains(.fullScreen)
            if enteredNativeFullscreen {
                fullscreenTransitioning = true
                window.toggleFullScreen(nil)
            } else { lyricsFullscreen = true }
        }
    }

    private var instrumentArea: some View {
        VStack(spacing: 13) {
            HStack(spacing: 12) {
                Text(mainScreenMode == .lyrics ? "LRC-72  ·  SYNCHRONIZED LYRIC CONSOLE" : "EVS-88  ·  EMOTIVE SIGNAL VISUALIZER")
                    .font(.system(size: 10, weight: .black, design: .rounded)).tracking(1.4)
                Spacer()
                Button { categoryBrowserExpanded = true } label: {
                    Label(library.selectedCategory?.rawValue ?? "CATEGORIES", systemImage: "square.grid.2x2")
                }
                .buttonStyle(TopButtonStyle(active: library.selectedCategory != nil))
                MainScreenSelector(selection: $mainScreenMode)
                HStack(spacing: 6) {
                    Circle().fill(power ? AuralisTheme.amber : Color.black.opacity(0.6)).frame(width: 7, height: 7).shadow(color: power ? AuralisTheme.amber : .clear, radius: 6)
                    Text(power ? "SIGNAL ONLINE" : "STANDBY").font(.system(size: 9, weight: .black, design: .monospaced))
                }
            }
            .foregroundStyle(AuralisTheme.ink)
            .padding(.horizontal, 16).padding(.top, 2)

            HStack(spacing: 14) {
                leftControlDeck
                scope
                    .opacity(power ? 1 : 0.16)
                    .overlay { if !power { Text("STANDBY").font(.system(size: 18, weight: .black, design: .monospaced)).tracking(3).foregroundStyle(AuralisTheme.phosphorDim) } }
                rightControlDeck
            }
            .padding(.horizontal, 14)

            TransportPanel(
                player: player, power: power
            )
                .padding(.horizontal, 14).padding(.bottom, 13)
        }
        .padding(.top, 12)
        .background(
            ZStack {
                LinearGradient(colors: [AuralisTheme.cabinetLight, AuralisTheme.cabinet, AuralisTheme.cabinetDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                Canvas { context, size in
                    var scratches = Path()
                    for index in 0..<34 {
                        let y = CGFloat((index * 71) % max(1, Int(size.height)))
                        scratches.move(to: CGPoint(x: 0, y: y)); scratches.addLine(to: CGPoint(x: size.width, y: y + 1))
                    }
                    context.stroke(scratches, with: .color(.black.opacity(0.025)), lineWidth: 0.6)
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: theatreMode ? 0 : 14))
        .overlay(RoundedRectangle(cornerRadius: theatreMode ? 0 : 14).stroke(.white.opacity(0.18), lineWidth: 1))
        .shadow(color: .black.opacity(0.75), radius: 20, y: 8)
        .padding(theatreMode ? 0 : 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var scope: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(red: 0.12, green: 0.115, blue: 0.09))
                .shadow(color: .black.opacity(0.95), radius: 11, y: 7)
            Group {
                if mainScreenMode == .lyrics {
                    LyricsScreenView(clock: player.clock)
                } else {
                    TrackAnimationView(
                        signal: player.visualizer,
                        clock: player.clock,
                        track: player.currentTrack,
                        active: player.isPlaying
                    )
                }
            }
            .padding(17)
            .transition(.opacity)
            .allowsHitTesting(!categoryBrowserExpanded)

            if categoryBrowserExpanded {
                CategoryBrowserOverlay(
                    library: library,
                    isPresented: $categoryBrowserExpanded
                )
                .padding(17)
                .transition(.opacity.combined(with: .scale(scale: 0.985)))
                .zIndex(4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.easeOut(duration: 0.16), value: mainScreenMode)
        .animation(.easeOut(duration: 0.18), value: categoryBrowserExpanded)
        .onTapGesture { if power && !categoryBrowserExpanded { player.togglePlayback() } }
        .help("Click the main screen to play or pause")
    }

    private var leftControlDeck: some View {
        VStack(spacing: 15) {
            Text("SOURCE").font(.system(size: 9, weight: .black, design: .rounded)).tracking(1)
            HStack(spacing: 9) {
                HardwareButton(title: "Prev", symbol: "backward.fill", action: playPrevious)
                HardwareButton(title: "Next", symbol: "forward.fill", action: playNext)
            }
            Divider().overlay(AuralisTheme.ink.opacity(0.3))
            RisingFader(title: "VOLUME", value: $player.volume)
            ToggleLever(title: "REPEAT", isOn: $player.isLooping)
            ToggleLever(title: "SHUFFLE", isOn: $shuffle)
            Spacer(minLength: 2)
            Button { power.toggle(); if !power { player.pause() } } label: {
                VStack(spacing: 5) {
                    Image(systemName: "power").font(.system(size: 18, weight: .black))
                    Text("POWER").font(.system(size: 8, weight: .black, design: .rounded)).tracking(1)
                }.foregroundStyle(power ? AuralisTheme.amber : AuralisTheme.ink)
            }.buttonStyle(.plain)
        }
        .padding(12).frame(width: 139).frame(maxHeight: .infinity)
        .foregroundStyle(AuralisTheme.ink)
        .background(AuralisTheme.panel.opacity(0.72), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.2)))
    }

    private var rightControlDeck: some View {
        PassiveSignalMonitor(signal: player.visualizer)
        .padding(12).frame(width: 139).frame(maxHeight: .infinity)
        .foregroundStyle(AuralisTheme.ink)
        .background(AuralisTheme.panel.opacity(0.72), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.2)))
    }

    private func select(_ track: Track) {
        library.selectedTrackID = track.id
        Task { await lyrics.prepare(for: track, library: library) }
        if player.currentTrack?.id == track.id { player.togglePlayback() }
        else { player.load(track: track, url: library.url(for: track)) }
    }

    private var lunarSuggestions: [Track] {
        let filtered = library.filteredTracks
        let queue = filtered.isEmpty ? library.alphabeticalTracks : filtered
        return queue.filter { $0.id != player.currentTrack?.id }
    }

    private func playNext() {
        let queue = library.filteredTracks.isEmpty ? library.alphabeticalTracks : library.filteredTracks
        guard !queue.isEmpty else { return }
        let next: Track
        if shuffle, queue.count > 1 {
            next = queue.filter { $0.id != player.currentTrack?.id }.randomElement() ?? queue[0]
        } else if let id = player.currentTrack?.id, let index = queue.firstIndex(where: { $0.id == id }) {
            next = queue[(index + 1) % queue.count]
        } else { next = queue[0] }
        select(next)
    }

    private func playPrevious() {
        let queue = library.filteredTracks.isEmpty ? library.alphabeticalTracks : library.filteredTracks
        guard !queue.isEmpty else { return }
        if player.currentTime > 3 { player.seek(to: 0); return }
        let previous: Track
        if let id = player.currentTrack?.id, let index = queue.firstIndex(where: { $0.id == id }) {
            previous = queue[(index - 1 + queue.count) % queue.count]
        } else { previous = queue[0] }
        select(previous)
    }

    private func beginEditing(_ track: Track) {
        editingDraft = MetadataDraft(title: track.title, artist: track.artist, album: track.album)
        editingTrack = track
    }
}

private struct CategoryTab: View {
    let title: String
    let count: Int
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Circle()
                    .fill(selected ? AuralisTheme.phosphor : Color.black.opacity(0.55))
                    .frame(width: 5, height: 5)
                    .shadow(color: selected ? AuralisTheme.phosphor.opacity(0.65) : .clear, radius: 3)
                Text(title)
                Text(String(format: "%02d", count)).foregroundStyle(selected ? AuralisTheme.phosphorDim : .secondary)
            }
            .font(.system(size: 7, weight: .black, design: .monospaced))
            .tracking(0.45)
            .foregroundStyle(selected ? AuralisTheme.paper : Color.secondary)
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(selected ? Color(red: 0.12, green: 0.14, blue: 0.10) : Color.black.opacity(0.26))
            .overlay(Rectangle().stroke(selected ? AuralisTheme.phosphorDim.opacity(0.6) : Color.white.opacity(0.07), lineWidth: 1))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(title)
    }
}

private struct CategoryBrowserOverlay: View {
    @ObservedObject var library: LibraryStore
    @Binding var isPresented: Bool
    @State private var newCategoryName = ""
    @State private var removingCategory: MusicCategory?

    private let columns = [
        GridItem(.flexible(), spacing: 9),
        GridItem(.flexible(), spacing: 9)
    ]

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Text("Categories").font(.headline)
                Spacer()
                Button { isPresented = false } label: {
                    Image(systemName: "xmark").font(.system(size: 10, weight: .black))
                        .frame(width: 30, height: 27)
                        .foregroundStyle(AuralisTheme.paper)
                        .background(Color.black.opacity(0.42))
                        .overlay(Rectangle().stroke(Color.white.opacity(0.12)))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close categories")
            }

            ScrollView {
                LazyVGrid(columns: columns, spacing: 9) {
                    categoryCard(category: nil)
                    ForEach(library.categories) { category in
                        HStack(spacing: 2) {
                            categoryCard(category: category)
                            Button { removingCategory = category } label: {
                                Image(systemName: "minus.circle").foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain).padding(.trailing, 8)
                            .help("Remove \(category.rawValue)")
                            .accessibilityLabel("Remove \(category.rawValue)")
                        }
                    }
                }
            }
            .frame(maxHeight: 300)
            HStack(spacing: 10) {
                TextField("New category", text: $newCategoryName)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { addCategory() }
                Button { addCategory() } label: { Label("Add", systemImage: "plus") }
                    .disabled(newCategoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .controlSize(.small)
        }
        .alert("Remove category?", isPresented: Binding(get: { removingCategory != nil }, set: { if !$0 { removingCategory = nil } })) {
            Button("Cancel", role: .cancel) { removingCategory = nil }
            Button("Remove", role: .destructive) {
                if let category = removingCategory { library.removeCategory(category) }
                removingCategory = nil
            }
        } message: {
            Text("The category will be removed. Its songs will remain in All Songs.")
        }
        .frame(maxWidth: 640)
        .padding(17)
        .foregroundStyle(AuralisTheme.paper)
        .background {
            ZStack {
                Color(red: 0.025, green: 0.032, blue: 0.023)
                Canvas { context, size in
                    var grid = Path()
                    for row in stride(from: 0.0, through: Double(size.height), by: 18) {
                        grid.move(to: CGPoint(x: 0, y: CGFloat(row)))
                        grid.addLine(to: CGPoint(x: size.width, y: CGFloat(row)))
                    }
                    for column in stride(from: 0.0, through: Double(size.width), by: 28) {
                        grid.move(to: CGPoint(x: CGFloat(column), y: 0))
                        grid.addLine(to: CGPoint(x: CGFloat(column), y: size.height))
                    }
                    context.stroke(grid, with: .color(AuralisTheme.phosphorDim.opacity(0.055)), lineWidth: 0.6)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 13))
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(AuralisTheme.phosphorDim.opacity(0.55), lineWidth: 1.5))
        .shadow(color: .black.opacity(0.86), radius: 16, y: 8)
    }

    private func addCategory() {
        if library.addCategory(newCategoryName) { newCategoryName = "" }
    }

    private func categoryCard(category: MusicCategory?) -> some View {
        let selected = library.selectedCategory == category
        let title = category?.rawValue ?? "ALL SONGS"
        let count = library.trackCount(in: category)
        return Button {
            library.selectedCategory = category
            isPresented = false
        } label: {
            HStack(spacing: 10) {
                ZStack {
                    Rectangle().fill(Color.black.opacity(0.48)).frame(width: 31, height: 31)
                        .overlay(Rectangle().stroke(selected ? AuralisTheme.phosphorDim : Color.white.opacity(0.10)))
                    Text(String(format: "%02d", count))
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundStyle(selected ? AuralisTheme.phosphor : AuralisTheme.paper.opacity(0.65))
                }
                Text(title).font(.system(size: 11, weight: .semibold))
                Spacer(minLength: 2)
                Circle().fill(selected ? AuralisTheme.phosphor : Color.black.opacity(0.55)).frame(width: 6, height: 6)
                    .shadow(color: selected ? AuralisTheme.phosphor.opacity(0.75) : .clear, radius: 4)
            }
            .padding(.horizontal, 10)
            .frame(height: 54)
            .foregroundStyle(AuralisTheme.paper)
            .background(selected ? Color(red: 0.10, green: 0.15, blue: 0.09) : Color.black.opacity(0.28))
            .overlay(Rectangle().stroke(selected ? AuralisTheme.phosphorDim.opacity(0.72) : Color.white.opacity(0.08)))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(count) songs")
    }
}

private struct MainScreenSelector: View {
    @Binding var selection: MainScreenMode

    var body: some View {
        HStack(spacing: 0) {
            ForEach(MainScreenMode.allCases) { mode in
                Button {
                    selection = mode
                } label: {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(selection == mode ? AuralisTheme.phosphor : Color.black.opacity(0.55))
                            .frame(width: 5, height: 5)
                        Text(mode.rawValue)
                            .font(.system(size: 7, weight: .black, design: .monospaced))
                            .tracking(0.7)
                    }
                    .foregroundStyle(AuralisTheme.ink)
                    .padding(.horizontal, 9)
                    .frame(height: 24)
                    .background(selection == mode ? Color.black.opacity(0.17) : Color.clear)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Show \(mode.rawValue.lowercased())")
            }
        }
        .background(AuralisTheme.panel.opacity(0.55), in: RoundedRectangle(cornerRadius: 3))
        .overlay(RoundedRectangle(cornerRadius: 3).stroke(Color.black.opacity(0.65), lineWidth: 1.5))
    }
}

private struct TrackGlyph: View {
    let size: CGFloat
    var active = false
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(Color(red: 0.10, green: 0.105, blue: 0.075))
                .overlay(RoundedRectangle(cornerRadius: 3).stroke(active ? AuralisTheme.phosphorDim.opacity(0.7) : .white.opacity(0.10), lineWidth: 1))
            HStack(alignment: .center, spacing: 2) {
                ForEach([0.35, 0.65, 1.0, 0.58, 0.82, 0.42], id: \.self) { amount in
                    Capsule().fill(active ? AuralisTheme.phosphor : AuralisTheme.phosphorDim)
                        .frame(width: 2, height: max(4, size * 0.42 * amount))
                }
            }
        }
        .frame(width: size, height: size)
    }
}

private struct TransportPanel: View {
    @ObservedObject private var player: AudioController
    @ObservedObject private var clock: PlaybackClock
    let power: Bool

    init(player: AudioController, power: Bool) {
        _player = ObservedObject(wrappedValue: player)
        _clock = ObservedObject(wrappedValue: player.clock)
        self.power = power
    }

    var body: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(player.currentTrack?.displayTitle ?? "No track loaded").font(.system(size: 13, weight: .heavy, design: .rounded)).lineLimit(1)
                Text(player.currentTrack.map { "\($0.artist)  ·  \($0.album)" } ?? "Add an MP3 to begin")
                    .font(.system(size: 10, weight: .medium, design: .rounded)).foregroundStyle(.secondary).lineLimit(1)
            }.frame(width: 230, alignment: .leading)

            HardwareButton(title: "Back 10", symbol: "gobackward.10") { player.skip(seconds: -10) }
            Button { if power { player.togglePlayback() } } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 21, weight: .black)).frame(width: 54, height: 47)
            }
            .buttonStyle(TransportPlayStyle())
            .disabled(player.currentTrack == nil || !power)
            HardwareButton(title: "Fwd 10", symbol: "goforward.10") { player.skip(seconds: 10) }

            VStack(spacing: 4) {
                Slider(value: $clock.currentTime, in: 0...max(0.01, clock.duration)) { editing in
                    if !editing { player.seek(to: clock.currentTime) }
                }.tint(AuralisTheme.phosphor)
                HStack {
                    Text(clock.currentTime.preciseClockString)
                    Spacer()
                    Text("−\(max(0, clock.duration - clock.currentTime).preciseClockString)")
                }.font(.system(size: 9, weight: .bold, design: .monospaced)).foregroundStyle(AuralisTheme.ink.opacity(0.72))
            }

            TransportLevelMeter(signal: player.visualizer)
        }
        .padding(11)
        .background(AuralisTheme.panel.opacity(0.78), in: RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.white.opacity(0.18)))
        .foregroundStyle(AuralisTheme.ink)
    }
}

private struct TransportLevelMeter: View {
    @ObservedObject var signal: VisualizerState

    var body: some View {
        VStack(spacing: 4) {
            InstrumentLabel(text: "LEVEL")
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(0..<8, id: \.self) { index in
                    Capsule()
                        .fill(Double(signal.level) * 9 > Double(index) ? (index > 5 ? AuralisTheme.amber : AuralisTheme.phosphor) : AuralisTheme.ink.opacity(0.18))
                        .frame(width: 5, height: CGFloat(7 + index * 2))
                }
            }
            .frame(height: 25, alignment: .bottom)
        }
    }
}

private struct TransportPlayStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(AuralisTheme.phosphor)
            .background(Color(red: 0.13, green: 0.17, blue: 0.115), in: RoundedRectangle(cornerRadius: 2))
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.black.opacity(0.76), lineWidth: 2))
            .shadow(color: .black.opacity(0.72), radius: configuration.isPressed ? 0 : 1, y: configuration.isPressed ? 0 : 2)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .offset(y: configuration.isPressed ? 1 : 0)
            .animation(.easeOut(duration: 0.075), value: configuration.isPressed)
    }
}

struct TopButtonStyle: ButtonStyle {
    var active = false
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .padding(.horizontal, 11).frame(height: 30)
            .foregroundStyle(active ? AuralisTheme.paper : Color.white.opacity(0.70))
            .background(active ? Color(red: 0.13, green: 0.18, blue: 0.12) : Color(red: 0.11, green: 0.105, blue: 0.085), in: RoundedRectangle(cornerRadius: 2))
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.black.opacity(0.82), lineWidth: 1.5))
            .overlay(alignment: .top) { Rectangle().fill(AuralisTheme.paper.opacity(0.10)).frame(height: 1).padding(.horizontal, 3) }
    }
}

struct OldActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 9, weight: .black, design: .rounded))
            .tracking(0.9)
            .foregroundStyle(AuralisTheme.paper)
            .padding(.horizontal, 15).frame(height: 34)
            .background(Color(red: 0.17, green: 0.20, blue: 0.14), in: RoundedRectangle(cornerRadius: 2))
            .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.black.opacity(0.82), lineWidth: 2))
            .shadow(color: .black.opacity(0.75), radius: configuration.isPressed ? 0 : 1, y: configuration.isPressed ? 0 : 2)
            .offset(y: configuration.isPressed ? 1 : 0)
    }
}

/// A deliberate drag surface used only behind the top equipment header.
/// Buttons layered above it retain normal hit testing.
struct WindowDragHandle: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { DragSurface() }
    func updateNSView(_ nsView: NSView, context: Context) {}

    final class DragSurface: NSView {
        override func mouseDown(with event: NSEvent) {
            window?.performDrag(with: event)
        }
    }
}
