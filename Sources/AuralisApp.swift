import SwiftUI
import AppKit

@main
struct AftertoneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var library = LibraryStore()
    @StateObject private var player = AudioController()
    @StateObject private var lyrics = LyricsController()
    @StateObject private var discord = DiscordPresenceController()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(library)
                .environmentObject(player)
                .environmentObject(lyrics)
                .environmentObject(discord)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Add MP3…") { library.requestImport() }.keyboardShortcut("o", modifiers: .command)
            }
            CommandMenu("Playback") {
                Button(player.isPlaying ? "Pause" : "Play") { player.togglePlayback() }.keyboardShortcut(.space, modifiers: [])
                Button("Back 10 Seconds") { player.skip(seconds: -10) }.keyboardShortcut(.leftArrow, modifiers: .command)
                Button("Forward 10 Seconds") { player.skip(seconds: 10) }.keyboardShortcut(.rightArrow, modifiers: .command)
            }
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        // macOS 26 wraps legacy bundle icons in a pale compatibility plate.
        // Supplying the transparent artwork directly preserves Aftertone's dark
        // hardware silhouette without either a white plate or a square backdrop.
        if let iconURL = Bundle.main.url(forResource: "AftertoneIcon", withExtension: "png"),
           let dockIcon = NSImage(contentsOf: iconURL) {
            NSApp.applicationIconImage = dockIcon
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            guard let window = NSApp.windows.first else { return }
            window.title = "Aftertone"
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            // Only the real titlebar strip moves the window. Interactive instrument
            // surfaces must keep their drags for knobs, sliders, and controls.
            window.isMovableByWindowBackground = false
            window.backgroundColor = NSColor(red: 0.035, green: 0.032, blue: 0.027, alpha: 1)
            window.setContentSize(NSSize(width: 1360, height: 850))
            window.minSize = NSSize(width: 1100, height: 720)
            // The window already has an explicit minimum. Prevent NSHostingView from
            // recalculating the entire SwiftUI tree's intrinsic minimum every time
            // the audio trace publishes a frame.
            if let contentView = window.contentView {
                let setter = NSSelectorFromString("setSizingOptions:")
                if contentView.responds(to: setter), let implementation = contentView.method(for: setter) {
                    typealias SizingSetter = @convention(c) (AnyObject, Selector, UInt) -> Void
                    unsafeBitCast(implementation, to: SizingSetter.self)(contentView, setter, 0)
                }
            }
            window.center()
            window.makeKeyAndOrderFront(nil)
        }
    }
}
