import AVFoundation
import SwiftUI
import Combine

@MainActor
final class PlaybackClock: ObservableObject {
    @Published var currentTime: Double = 0
    @Published var duration: Double = 0
}

@MainActor
final class VisualizerState: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()
    private(set) var left = Array(repeating: Float.zero, count: 128)
    private(set) var right = Array(repeating: Float.zero, count: 128)
    private(set) var level: Float = 0
    private(set) var bassPulse: Float = 0
    private var lastPublishTime: TimeInterval = 0
    private var automaticGain: Float = 2

    func accept(left incomingLeft: [Float], right incomingRight: [Float]) {
        guard incomingLeft.count == left.count, incomingRight.count == right.count else { return }
        let inputPeak = max(
            incomingLeft.reduce(Float.zero) { max($0, abs($1)) },
            incomingRight.reduce(Float.zero) { max($0, abs($1)) }
        )
        let desiredGain: Float = inputPeak > 0.003 ? min(10, max(1.4, 0.88 / inputPeak)) : 1.4
        automaticGain = automaticGain * 0.86 + desiredGain * 0.14
        var temporalLeft = [Float](repeating: 0, count: left.count)
        var temporalRight = [Float](repeating: 0, count: right.count)
        for index in left.indices {
            let normalizedLeft = max(-1, min(1, incomingLeft[index] * automaticGain))
            let normalizedRight = max(-1, min(1, incomingRight[index] * automaticGain))
            temporalLeft[index] = left[index] * 0.48 + normalizedLeft * 0.52
            temporalRight[index] = right[index] * 0.48 + normalizedRight * 0.52
        }

        var nextLeft = temporalLeft
        var nextRight = temporalRight
        let count = temporalLeft.count
        for index in 0..<count {
            let previous = (index - 1 + count) % count
            let next = (index + 1) % count
            nextLeft[index] = temporalLeft[previous] * 0.22 + temporalLeft[index] * 0.56 + temporalLeft[next] * 0.22
            nextRight[index] = temporalRight[previous] * 0.22 + temporalRight[index] * 0.56 + temporalRight[next] * 0.22
        }

        let rms = sqrt(nextLeft.reduce(Float.zero) { $0 + $1 * $1 } / Float(count))
        var lowPassed: Float = 0
        var bassSum: Float = 0
        for sample in incomingLeft {
            let sample = max(-1, min(1, sample * automaticGain))
            lowPassed += 0.11 * (sample - lowPassed)
            bassSum += lowPassed * lowPassed
        }
        let bass = min(1, sqrt(bassSum / Float(count)) * 6.2)

        let now = ProcessInfo.processInfo.systemUptime
        if now - lastPublishTime >= 0.030 {
            objectWillChange.send()
            lastPublishTime = now
        }
        left = nextLeft
        right = nextRight
        level = level * 0.70 + min(1, rms * 4.2) * 0.30
        bassPulse = max(bassPulse * 0.78, bass)
    }

    func reset() {
        objectWillChange.send()
        left = Array(repeating: 0, count: left.count)
        right = Array(repeating: 0, count: right.count)
        level = 0
        bassPulse = 0
        lastPublishTime = 0
        automaticGain = 2
    }
}

@MainActor
final class AudioController: ObservableObject {
    @Published private(set) var currentTrack: Track?
    @Published private(set) var isPlaying = false
    @Published var volume: Double = 0.72 {
        didSet { engine.mainMixerNode.outputVolume = taperedOutputGain(for: volume) }
    }
    @Published var isLooping = false
    @Published var errorMessage: String?

    let clock = PlaybackClock()
    let visualizer = VisualizerState()
    var currentTime: Double {
        get { clock.currentTime }
        set { clock.currentTime = newValue }
    }
    var duration: Double { clock.duration }
    var onTrackEnded: (() -> Void)?

    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private let analysisMixer = AVAudioMixerNode()
    private var audioFile: AVAudioFile?
    private var displayTimer: Timer?
    private var startFrame: AVAudioFramePosition = 0
    private var fileSampleRate: Double = 44_100
    private var completionGeneration = 0

    init() {
        engine.attach(playerNode)
        engine.attach(analysisMixer)
        engine.connect(playerNode, to: analysisMixer, format: nil)
        engine.connect(analysisMixer, to: engine.mainMixerNode, format: nil)
        engine.mainMixerNode.outputVolume = taperedOutputGain(for: volume)
        installVisualizerTap(on: analysisMixer)
        do { try engine.start() }
        catch { errorMessage = "Audio engine could not start: \(error.localizedDescription)" }
        displayTimer = Timer.scheduledTimer(
            timeInterval: 0.05, target: self,
            selector: #selector(timerFired), userInfo: nil, repeats: true
        )
        displayTimer?.tolerance = 0.01
    }

    deinit { displayTimer?.invalidate() }

    private func taperedOutputGain(for position: Double) -> Float {
        let clamped = min(1, max(0, position))
        return Float(pow(clamped, 2.2))
    }

    func load(track: Track, url: URL, autoplay: Bool = true) {
        do {
            completionGeneration += 1
            playerNode.stop()
            let file = try AVAudioFile(forReading: url)
            audioFile = file
            currentTrack = track
            fileSampleRate = file.processingFormat.sampleRate
            clock.duration = Double(file.length) / fileSampleRate
            clock.currentTime = 0
            startFrame = 0
            schedule(from: 0)
            if autoplay { play() }
        } catch {
            errorMessage = "This audio file could not be played: \(error.localizedDescription)"
        }
    }

    func togglePlayback() { isPlaying ? pause() : play() }

    func play() {
        guard audioFile != nil else { return }
        if currentTime >= max(0, duration - 0.05) {
            seek(to: 0, resume: true)
            return
        }
        if !engine.isRunning { try? engine.start() }
        playerNode.play()
        isPlaying = true
    }

    func pause() {
        updateClock()
        playerNode.pause()
        isPlaying = false
    }

    func unload() {
        stop()
        currentTrack = nil
        audioFile = nil
        clock.duration = 0
    }

    func stop() {
        completionGeneration += 1
        playerNode.stop()
        clock.currentTime = 0
        startFrame = 0
        isPlaying = false
        visualizer.reset()
    }

    func seek(to seconds: Double, resume: Bool? = nil) {
        guard let file = audioFile else { return }
        let shouldResume = resume ?? isPlaying
        completionGeneration += 1
        playerNode.stop()
        let clamped = min(max(0, seconds), duration)
        let frame = min(file.length, AVAudioFramePosition(clamped * fileSampleRate))
        clock.currentTime = clamped
        startFrame = frame
        schedule(from: frame)
        if shouldResume && frame < file.length { playerNode.play(); isPlaying = true }
        else { isPlaying = false }
    }

    func skip(seconds: Double) { seek(to: currentTime + seconds) }

    private func schedule(from frame: AVAudioFramePosition) {
        guard let file = audioFile, frame < file.length else { return }
        let generation = completionGeneration
        let count = AVAudioFrameCount(file.length - frame)
        playerNode.scheduleSegment(
            file, startingFrame: frame, frameCount: count, at: nil,
            completionCallbackType: .dataPlayedBack
        ) { [weak self] _ in
            Task { @MainActor in
                guard let self, generation == self.completionGeneration else { return }
                self.isPlaying = false
                self.clock.currentTime = self.duration
                if self.isLooping { self.seek(to: 0, resume: true) }
                else { self.onTrackEnded?() }
            }
        }
    }

    private func updateClock() {
        guard isPlaying,
              let nodeTime = playerNode.lastRenderTime,
              let playerTime = playerNode.playerTime(forNodeTime: nodeTime) else { return }
        let renderSampleRate = playerTime.sampleRate > 0
            ? playerTime.sampleRate
            : engine.outputNode.outputFormat(forBus: 0).sampleRate
        guard renderSampleRate > 0, fileSampleRate > 0 else { return }
        let scheduledStartSeconds = Double(startFrame) / fileSampleRate
        let renderedSeconds = Double(playerTime.sampleTime) / renderSampleRate
        clock.currentTime = min(duration, scheduledStartSeconds + renderedSeconds)
    }

    @objc private func timerFired() { updateClock() }

    private nonisolated func reducedSamples(from buffer: AVAudioPCMBuffer) -> ([Float], [Float]) {
        guard let channels = buffer.floatChannelData else { return ([], []) }
        let frameCount = Int(buffer.frameLength)
        guard frameCount > 0 else { return ([], []) }
        let outputCount = 128
        let channelCount = Int(buffer.format.channelCount)
        var left = [Float](repeating: 0, count: outputCount)
        var right = [Float](repeating: 0, count: outputCount)
        for index in 0..<outputCount {
            let start = index * frameCount / outputCount
            let end = max(start + 1, (index + 1) * frameCount / outputCount)
            var leftPeak: Float = 0
            var rightPeak: Float = 0
            for source in start..<min(end, frameCount) {
                let leftSample = channels[0][source]
                let rightSample = channelCount > 1 ? channels[1][source] : leftSample
                if abs(leftSample) > abs(leftPeak) { leftPeak = leftSample }
                if abs(rightSample) > abs(rightPeak) { rightPeak = rightSample }
            }
            left[index] = leftPeak
            right[index] = rightPeak
        }
        return (left, right)
    }

    private func installVisualizerTap(on mixer: AVAudioMixerNode) {
        let format = mixer.outputFormat(forBus: 0)
        // 1536 frames at 48 kHz lands close to 31 Hz: visibly fluid without driving
        // the UI at display-refresh rates while music is playing.
        mixer.installTap(onBus: 0, bufferSize: 1536, format: format) { [weak self] buffer, _ in
            guard let self else { return }
            let samples = self.reducedSamples(from: buffer)
            guard !samples.0.isEmpty else { return }
            Task { @MainActor in
                guard self.isPlaying else { return }
                self.visualizer.accept(left: samples.0, right: samples.1)
            }
        }
    }
}
