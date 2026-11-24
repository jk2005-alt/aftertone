import SwiftUI
import Combine
import Darwin

@MainActor
final class DiscordPresenceController: ObservableObject {
    @Published private(set) var isEnabled: Bool
    @Published private(set) var applicationID: String
    @Published private(set) var statusText = "NOT CONFIGURED"
    @Published private(set) var isConnected = false

    private weak var player: AudioController?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private let ipc = DiscordIPCClient()

    private static let enabledKey = "discordPresenceEnabled"
    private static let applicationIDKey = "discordApplicationID"

    init() {
        let defaults = UserDefaults.standard
        let legacy = defaults.persistentDomain(forName: "com.local.auralis")
        let savedApplicationID = defaults.string(forKey: Self.applicationIDKey)
            ?? legacy?[Self.applicationIDKey] as? String
            ?? ""
        let savedEnabled = defaults.object(forKey: Self.enabledKey) as? Bool
            ?? legacy?[Self.enabledKey] as? Bool
            ?? true
        applicationID = savedApplicationID
        isEnabled = savedEnabled
        if defaults.string(forKey: Self.applicationIDKey) == nil, !savedApplicationID.isEmpty {
            defaults.set(savedApplicationID, forKey: Self.applicationIDKey)
            defaults.set(savedEnabled, forKey: Self.enabledKey)
        }
        updateIdleStatus()
    }

    func start(player: AudioController) {
        guard self.player !== player else { return }
        self.player = player
        cancellables.removeAll()

        Publishers.CombineLatest(player.$currentTrack, player.$isPlaying)
            .debounce(for: .milliseconds(180), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in self?.refresh() }
            .store(in: &cancellables)

        timer?.invalidate()
        let controller = self
        let timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { _ in
            Task { @MainActor in controller.refresh() }
        }
        timer.tolerance = 2
        self.timer = timer
        refresh()
    }

    func configure(applicationID newID: String, enabled: Bool) {
        let cleaned = newID.filter(\.isNumber)
        let previousID = applicationID
        applicationID = cleaned
        isEnabled = enabled
        UserDefaults.standard.set(cleaned, forKey: Self.applicationIDKey)
        UserDefaults.standard.set(enabled, forKey: Self.enabledKey)

        if previousID != cleaned { ipc.disconnect() }
        if enabled { refresh() }
        else {
            isConnected = false
            statusText = "ACTIVITY OFF"
            guard !previousID.isEmpty else { return }
            ipc.update(clientID: previousID, activity: nil) { _ in }
        }
    }

    func refresh() {
        guard isEnabled else {
            isConnected = false
            statusText = "ACTIVITY OFF"
            return
        }
        guard applicationID.count >= 17 else {
            isConnected = false
            statusText = "NEEDS APPLICATION ID"
            return
        }
        guard let player, let track = player.currentTrack else {
            statusText = "READY · NO TRACK"
            let controller = self
            ipc.update(clientID: applicationID, activity: nil) { result in
                Task { @MainActor in controller.apply(result) }
            }
            return
        }

        var activity: [String: Any] = [
            "details": track.displayTitle,
            "state": player.isPlaying
                ? "\(track.artist)  •  \(track.album)"
                : "Paused  •  \(track.artist)",
            "assets": [
                "large_image": "aftertone",
                "large_text": "Aftertone · Offline Signal Player"
            ],
            "instance": false
        ]
        if player.isPlaying {
            let now = Date().timeIntervalSince1970
            activity["timestamps"] = [
                "start": Int(now - max(0, player.currentTime)),
                "end": Int(now + max(0, player.duration - player.currentTime))
            ]
        }

        statusText = "CONNECTING…"
        let controller = self
        ipc.update(clientID: applicationID, activity: activity) { result in
            Task { @MainActor in controller.apply(result) }
        }
    }

    private func apply(_ result: DiscordIPCClient.Result) {
        switch result {
        case .connected:
            isConnected = true
            statusText = player?.currentTrack == nil ? "CONNECTED · IDLE" : "LIVE ON DISCORD"
        case .discordNotRunning:
            isConnected = false
            statusText = "OPEN DISCORD TO CONNECT"
        case .invalidApplication:
            isConnected = false
            statusText = "CHECK APPLICATION ID"
        case .failed:
            isConnected = false
            statusText = "RETRYING…"
        }
    }

    private func updateIdleStatus() {
        if !isEnabled { statusText = "ACTIVITY OFF" }
        else if applicationID.count < 17 { statusText = "NEEDS APPLICATION ID" }
    }
}

final class DiscordIPCClient: @unchecked Sendable {
    enum Result { case connected, discordNotRunning, invalidApplication, failed }

    private let queue = DispatchQueue(label: "aftertone.discord-presence", qos: .utility)
    private var descriptor: Int32 = -1
    private var connectedClientID = ""

    func update(clientID: String, activity: [String: Any]?, completion: @escaping @Sendable (Result) -> Void) {
        queue.async { [weak self] in
            guard let self else { return }
            guard self.ensureConnected(clientID: clientID) else {
                let discordAvailable = self.socketPaths.contains { FileManager.default.fileExists(atPath: $0) }
                completion(discordAvailable ? .invalidApplication : .discordNotRunning)
                return
            }

            let activityValue: Any = activity.map { $0 as Any } ?? NSNull()
            let payload: [String: Any] = [
                "cmd": "SET_ACTIVITY",
                "args": ["pid": ProcessInfo.processInfo.processIdentifier, "activity": activityValue],
                "nonce": UUID().uuidString
            ]
            guard self.send(opcode: 1, payload: payload), let response = self.receive() else {
                self.closeConnection()
                completion(.failed)
                return
            }
            if let event = response["evt"] as? String, event == "ERROR" {
                self.closeConnection()
                completion(.invalidApplication)
            } else {
                completion(.connected)
            }
        }
    }

    func disconnect() {
        queue.async { [weak self] in self?.closeConnection() }
    }

    private var socketPaths: [String] {
        var roots = ["/tmp"]
        if let temporary = ProcessInfo.processInfo.environment["TMPDIR"] {
            roots.insert(URL(fileURLWithPath: temporary).standardizedFileURL.path, at: 0)
        }
        return roots.flatMap { root in (0..<10).map { "\(root)/discord-ipc-\($0)" } }
    }

    private func ensureConnected(clientID: String) -> Bool {
        if descriptor >= 0, connectedClientID == clientID { return true }
        closeConnection()
        guard openSocket() else { return false }
        guard send(opcode: 0, payload: ["v": 1, "client_id": clientID]),
              let response = receive() else {
            closeConnection()
            return false
        }
        guard (response["evt"] as? String) == "READY" else {
            closeConnection()
            return false
        }
        connectedClientID = clientID
        return true
    }

    private func openSocket() -> Bool {
        for path in socketPaths {
            guard FileManager.default.fileExists(atPath: path) else { continue }
            let candidate = Darwin.socket(AF_UNIX, SOCK_STREAM, 0)
            guard candidate >= 0 else { continue }

            var timeout = timeval(tv_sec: 2, tv_usec: 0)
            setsockopt(candidate, SOL_SOCKET, SO_RCVTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))
            setsockopt(candidate, SOL_SOCKET, SO_SNDTIMEO, &timeout, socklen_t(MemoryLayout<timeval>.size))

            var address = sockaddr_un()
            address.sun_family = sa_family_t(AF_UNIX)
            let bytes = Array(path.utf8)
            let pathOffset = MemoryLayout<sockaddr_un>.offset(of: \.sun_path) ?? 2
            guard bytes.count + 1 <= MemoryLayout.size(ofValue: address.sun_path) else {
                Darwin.close(candidate)
                continue
            }
            withUnsafeMutableBytes(of: &address.sun_path) { buffer in
                buffer.initializeMemory(as: UInt8.self, repeating: 0)
                buffer.copyBytes(from: bytes)
            }
            address.sun_len = UInt8(pathOffset + bytes.count + 1)
            let addressLength = socklen_t(address.sun_len)
            let connected = withUnsafePointer(to: &address) { pointer in
                pointer.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                    Darwin.connect(candidate, $0, addressLength)
                }
            }
            if connected == 0 {
                descriptor = candidate
                return true
            }
            Darwin.close(candidate)
        }
        return false
    }

    private func send(opcode: UInt32, payload: [String: Any]) -> Bool {
        guard descriptor >= 0,
              let data = try? JSONSerialization.data(withJSONObject: payload) else { return false }
        var op = opcode.littleEndian
        var length = UInt32(data.count).littleEndian
        var frame = Data(bytes: &op, count: 4)
        frame.append(Data(bytes: &length, count: 4))
        frame.append(data)
        return writeAll(frame)
    }

    private func receive() -> [String: Any]? {
        guard let header = readExactly(8) else { return nil }
        let opcode = header.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: 0, as: UInt32.self).littleEndian }
        let length = header.withUnsafeBytes { $0.loadUnaligned(fromByteOffset: 4, as: UInt32.self).littleEndian }
        guard opcode == 1, length > 0, length < 1_048_576,
              let payload = readExactly(Int(length)),
              let object = try? JSONSerialization.jsonObject(with: payload) as? [String: Any] else { return nil }
        return object
    }

    private func writeAll(_ data: Data) -> Bool {
        data.withUnsafeBytes { rawBuffer in
            guard let base = rawBuffer.baseAddress else { return false }
            var sent = 0
            while sent < data.count {
                let count = Darwin.send(descriptor, base.advanced(by: sent), data.count - sent, 0)
                guard count > 0 else { return false }
                sent += count
            }
            return true
        }
    }

    private func readExactly(_ count: Int) -> Data? {
        var data = Data(count: count)
        let success = data.withUnsafeMutableBytes { rawBuffer -> Bool in
            guard let base = rawBuffer.baseAddress else { return false }
            var received = 0
            while received < count {
                let amount = Darwin.recv(descriptor, base.advanced(by: received), count - received, 0)
                guard amount > 0 else { return false }
                received += amount
            }
            return true
        }
        return success ? data : nil
    }

    private func closeConnection() {
        if descriptor >= 0 { Darwin.close(descriptor) }
        descriptor = -1
        connectedClientID = ""
    }
}

struct DiscordSettingsView: View {
    @ObservedObject var discord: DiscordPresenceController
    @Environment(\.dismiss) private var dismiss
    @State private var applicationID: String
    @State private var enabled: Bool

    init(discord: DiscordPresenceController) {
        self.discord = discord
        _applicationID = State(initialValue: discord.applicationID)
        _enabled = State(initialValue: discord.isEnabled)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("DISCORD ACTIVITY").font(.system(size: 17, weight: .black, design: .rounded)).tracking(1.8)
                    Text("SHOW THE CURRENT AFTERTONE SIGNAL").font(.system(size: 8, weight: .bold, design: .monospaced)).foregroundStyle(.secondary)
                }
                Spacer()
                Circle().fill(discord.isConnected ? Color.green : Color.orange).frame(width: 9, height: 9)
                Text(discord.statusText).font(.system(size: 9, weight: .bold, design: .monospaced))
            }

            Toggle("Share listening activity", isOn: $enabled).toggleStyle(.switch)

            VStack(alignment: .leading, spacing: 7) {
                Text("DISCORD APPLICATION ID").font(.system(size: 9, weight: .black, design: .rounded)).tracking(1)
                TextField("Paste the numeric Application ID", text: $applicationID)
                    .textFieldStyle(.roundedBorder)
                Text("Create an application named Aftertone in Discord’s Developer Portal, then copy its Application ID from General Information.")
                    .font(.system(size: 10, design: .rounded)).foregroundStyle(.secondary).lineSpacing(2)
                Link("OPEN DISCORD DEVELOPER PORTAL", destination: URL(string: "https://discord.com/developers/applications")!)
                    .font(.system(size: 9, weight: .black, design: .rounded))
            }

            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Button("Save & Connect") {
                    discord.configure(applicationID: applicationID, enabled: enabled)
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(enabled && applicationID.filter(\.isNumber).count < 17)
            }
        }
        .padding(24)
        .frame(width: 520)
        .background(AuralisTheme.background)
        .preferredColorScheme(.dark)
    }
}
