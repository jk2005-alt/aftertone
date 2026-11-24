import SwiftUI
import AppKit
import QuartzCore

struct OscilloscopeView: View {
    let signal: VisualizerState
    let artist: String
    let title: String
    let album: String
    let mode: VisualizerMode
    let intensity: Double
    let glow: Double
    let rotationSpeed: Double
    let active: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(
                    RadialGradient(
                        colors: [Color(red: 0.052, green: 0.082, blue: 0.045), Color(red: 0.015, green: 0.021, blue: 0.012)],
                        center: .center, startRadius: 5, endRadius: 430
                    )
                )

            // This never-changing CRT layer is no longer redrawn with every audio frame.
            Canvas { context, size in
                drawGrid(context: &context, size: size)
                drawScanlines(context: &context, size: size)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))

            DynamicSignalCanvas(
                signal: signal,
                mode: mode,
                intensity: intensity,
                glow: glow,
                rotationSpeed: rotationSpeed
            )
            .clipShape(RoundedRectangle(cornerRadius: 22))

            VStack(spacing: 0) {
                VStack(spacing: 3) {
                    Text(artist.isEmpty ? "NO ARTIST" : artist.uppercased())
                        .font(.system(size: 14, weight: .bold, design: .monospaced)).tracking(1.6)
                    if !album.isEmpty {
                        Text(album.uppercased())
                            .font(.system(size: 8, weight: .medium, design: .monospaced)).tracking(1.2).opacity(0.62)
                    }
                }
                .padding(.top, 22)
                Spacer()
                Text(title.isEmpty ? "READY FOR SIGNAL" : title.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced)).tracking(1.4).lineLimit(1)
                    .padding(.horizontal, 28).padding(.bottom, 23)
            }
            .foregroundStyle(AuralisTheme.phosphor)
            .shadow(color: AuralisTheme.phosphor.opacity(0.55), radius: 3)

            RoundedRectangle(cornerRadius: 22)
                .fill(LinearGradient(colors: [AuralisTheme.paper.opacity(0.04), .clear, .black.opacity(0.24)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .blendMode(.screen)
            RoundedRectangle(cornerRadius: 22)
                .fill(RadialGradient(colors: [.clear, .black.opacity(0.38)], center: .center, startRadius: 120, endRadius: 520))
            RoundedRectangle(cornerRadius: 22)
                .stroke(Color.black.opacity(0.9), lineWidth: 13)
                .shadow(color: .black.opacity(0.95), radius: 10)
        }
        .aspectRatio(1.34, contentMode: .fit)
    }

    private func drawGrid(context: inout GraphicsContext, size: CGSize) {
        var grid = Path()
        let spacing: CGFloat = 44
        stride(from: spacing, to: size.width, by: spacing).forEach {
            grid.move(to: CGPoint(x: $0, y: 0)); grid.addLine(to: CGPoint(x: $0, y: size.height))
        }
        stride(from: spacing, to: size.height, by: spacing).forEach {
            grid.move(to: CGPoint(x: 0, y: $0)); grid.addLine(to: CGPoint(x: size.width, y: $0))
        }
        context.stroke(grid, with: .color(AuralisTheme.phosphorDim.opacity(0.095)), lineWidth: 0.65)
        var axes = Path()
        axes.move(to: CGPoint(x: size.width / 2, y: 0)); axes.addLine(to: CGPoint(x: size.width / 2, y: size.height))
        axes.move(to: CGPoint(x: 0, y: size.height / 2)); axes.addLine(to: CGPoint(x: size.width, y: size.height / 2))
        context.stroke(axes, with: .color(AuralisTheme.phosphorDim.opacity(0.15)), lineWidth: 0.8)
    }

    private func drawScanlines(context: inout GraphicsContext, size: CGSize) {
        var lines = Path()
        stride(from: CGFloat(1), to: size.height, by: 5).forEach {
            lines.move(to: CGPoint(x: 0, y: $0)); lines.addLine(to: CGPoint(x: size.width, y: $0))
        }
        context.stroke(lines, with: .color(.black.opacity(0.12)), lineWidth: 1)
        for index in 0..<42 {
            let x = CGFloat((index * 83 + 17) % max(1, Int(size.width)))
            let y = CGFloat((index * 47 + index * index + 11) % max(1, Int(size.height)))
            context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 0.7, height: 0.7)), with: .color(.black.opacity(0.08)))
        }
    }
}

struct MiniVisualizerView: View {
    let signal: VisualizerState
    let mode: VisualizerMode
    let intensity: Double
    let glow: Double
    let rotationSpeed: Double

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(RadialGradient(
                    colors: [Color(red: 0.045, green: 0.075, blue: 0.040), Color(red: 0.010, green: 0.016, blue: 0.009)],
                    center: .center, startRadius: 1, endRadius: 80
                ))
            Canvas { context, size in
                var grid = Path()
                for fraction in [0.25, 0.5, 0.75] {
                    grid.move(to: CGPoint(x: size.width * fraction, y: 0))
                    grid.addLine(to: CGPoint(x: size.width * fraction, y: size.height))
                    grid.move(to: CGPoint(x: 0, y: size.height * fraction))
                    grid.addLine(to: CGPoint(x: size.width, y: size.height * fraction))
                }
                context.stroke(grid, with: .color(AuralisTheme.phosphorDim.opacity(0.10)), lineWidth: 0.5)
            }
            DynamicSignalCanvas(
                signal: signal, mode: mode, intensity: intensity,
                glow: glow * 0.65, rotationSpeed: rotationSpeed
            )
            .padding(3)
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.black.opacity(0.9), lineWidth: 4)
                .overlay(RoundedRectangle(cornerRadius: 5).inset(by: 3).stroke(AuralisTheme.phosphorDim.opacity(0.18), lineWidth: 1))
        }
        .accessibilityLabel("Music visualizer")
    }
}

private struct SignalSnapshot {
    let left: [Float]
    let right: [Float]
    let bassPulse: Float
}

private struct LegacyDynamicSignalCanvas: View {
    @ObservedObject var signal: VisualizerState
    let mode: VisualizerMode
    let intensity: Double
    let glow: Double
    let rotationSpeed: Double

    var body: some View {
        let snapshot = SignalSnapshot(left: signal.left, right: signal.right, bassPulse: signal.bassPulse)
        Canvas { context, size in
            drawSignal(snapshot, context: &context, size: size, time: Date().timeIntervalSinceReferenceDate)
        }
    }

    private func drawSignal(_ signal: SignalSnapshot, context: inout GraphicsContext, size: CGSize, time: TimeInterval) {
        guard !signal.left.isEmpty else { return }
        switch mode {
        case .orbit:
            stroke(orbitPath(signal, size: size, time: time), context: &context, opacity: 0.93, width: 1.05)
        case .lissajous:
            stroke(lissajousPath(signal, size: size, time: time), context: &context, opacity: 0.90, width: 1.0)
        case .bloom:
            for ring in 0..<4 {
                let opacity = 0.72 - Double(ring) * 0.12
                stroke(bloomPath(signal, size: size, time: time, ring: ring), context: &context, opacity: opacity, width: ring == 0 ? 1.1 : 0.75)
            }
        }
    }

    private func stroke(_ path: Path, context: inout GraphicsContext, opacity: Double, width: CGFloat) {
        context.stroke(path, with: .color(AuralisTheme.phosphor.opacity(opacity * 0.16)), lineWidth: width + CGFloat(glow) * 2.3)
        context.stroke(path, with: .color(AuralisTheme.phosphor.opacity(opacity)), lineWidth: width)
    }

    private func orbitPath(_ signal: SignalSnapshot, size: CGSize, time: TimeInterval) -> Path {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let base = min(size.width, size.height) * (0.225 + CGFloat(signal.bassPulse) * 0.045)
        let phase = time * rotationSpeed * 0.32
        let points = signal.left.indices.map { index -> CGPoint in
            let fraction = Double(index) / Double(signal.left.count)
            let angle = fraction * .pi * 2 - .pi / 2 + phase
            let sample = max(-1, min(1, Double(signal.left[index])))
            let radius = base * CGFloat(1 + sample * intensity * 0.30)
            return CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius)
        }
        return smoothPath(points)
    }

    private func lissajousPath(_ signal: SignalSnapshot, size: CGSize, time: TimeInterval) -> Path {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let count = signal.left.count
        let breathing = 0.94 + Double(signal.bassPulse) * 0.13
        let points = (0..<count).map { index -> CGPoint in
            let delayed = (index + 13) % count
            let phase = Double(index) / Double(count) * .pi * 2
            let x = (Double(signal.left[index]) * intensity * 0.68 + cos(phase * 2 + time * 0.10) * 0.018) * breathing
            let y = (Double(signal.right[delayed]) * intensity * 0.68 + sin(phase * 3) * 0.018) * breathing
            return CGPoint(x: center.x + CGFloat(x) * size.width * 0.34, y: center.y + CGFloat(y) * size.height * 0.42)
        }
        return smoothPath(points)
    }

    private func bloomPath(_ signal: SignalSnapshot, size: CGSize, time: TimeInterval, ring: Int) -> Path {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let base = min(size.width, size.height) * CGFloat(0.105 + Double(ring) * 0.042)
        let bass = Double(signal.bassPulse)
        let phase = time * (0.08 + Double(ring) * 0.018) * rotationSpeed
        let points = signal.left.indices.map { index -> CGPoint in
            let fraction = Double(index) / Double(signal.left.count)
            let angle = fraction * .pi * 2 - .pi / 2 + phase * (ring.isMultiple(of: 2) ? 1 : -1)
            let audio = Double(abs(signal.left[index])) * intensity * 0.13
            let petals = sin(angle * Double(3 + ring)) * (0.018 + bass * 0.028)
            let radius = base * CGFloat(1 + audio + petals + bass * 0.10)
            return CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius)
        }
        return smoothPath(points)
    }

    private func smoothPath(_ points: [CGPoint]) -> Path {
        guard points.count > 2 else { return Path() }
        func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
            CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
        }
        var path = Path()
        path.move(to: midpoint(points[points.count - 1], points[0]))
        for index in points.indices {
            let next = points[(index + 1) % points.count]
            path.addQuadCurve(to: midpoint(points[index], next), control: points[index])
        }
        path.closeSubpath()
        return path
    }
}

private struct DynamicSignalCanvas: NSViewRepresentable {
    @ObservedObject var signal: VisualizerState
    let mode: VisualizerMode
    let intensity: Double
    let glow: Double
    let rotationSpeed: Double

    func makeNSView(context: Context) -> SignalTraceView {
        SignalTraceView()
    }

    func updateNSView(_ view: SignalTraceView, context: Context) {
        view.render(
            SignalSnapshot(left: signal.left, right: signal.right, bassPulse: signal.bassPulse),
            mode: mode,
            intensity: intensity,
            glow: glow,
            rotationSpeed: rotationSpeed
        )
    }
}

private final class SignalTraceView: NSView {
    private let traces = (0..<4).map { _ in CAShapeLayer() }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.masksToBounds = true
        for trace in traces {
            trace.fillColor = nil
            trace.lineCap = .round
            trace.lineJoin = .round
            trace.shadowColor = NSColor(red: 0.72, green: 0.95, blue: 0.56, alpha: 1).cgColor
            trace.shadowOpacity = 0.22
            trace.shadowRadius = 4
            trace.shadowOffset = .zero
            layer?.addSublayer(trace)
        }
    }

    required init?(coder: NSCoder) { nil }

    override func layout() {
        super.layout()
        traces.forEach { $0.frame = bounds }
    }

    func render(_ signal: SignalSnapshot, mode: VisualizerMode, intensity: Double, glow: Double, rotationSpeed: Double) {
        guard bounds.width > 1, bounds.height > 1, !signal.left.isEmpty else { return }
        let time = Date().timeIntervalSinceReferenceDate
        let paths: [CGPath]
        switch mode {
        case .orbit:
            paths = [orbit(signal, time: time, intensity: intensity, rotationSpeed: rotationSpeed)]
        case .lissajous:
            paths = [lissajous(signal, time: time, intensity: intensity)]
        case .bloom:
            paths = (0..<4).map { bloom(signal, time: time, ring: $0, intensity: intensity, rotationSpeed: rotationSpeed) }
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        for index in traces.indices {
            let trace = traces[index]
            trace.frame = bounds
            trace.path = index < paths.count ? paths[index] : nil
            trace.strokeColor = NSColor(red: 0.72, green: 0.95, blue: 0.56, alpha: index == 0 ? 0.94 : 0.68 - CGFloat(index) * 0.10).cgColor
            trace.lineWidth = index == 0 ? 1.2 : 0.85
            trace.shadowRadius = 2.5 + glow * 2.0
        }
        CATransaction.commit()
    }

    private func orbit(_ signal: SignalSnapshot, time: TimeInterval, intensity: Double, rotationSpeed: Double) -> CGPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let base = min(bounds.width, bounds.height) * (0.215 + CGFloat(signal.bassPulse) * 0.075)
        let phase = time * rotationSpeed * 0.32
        var points: [CGPoint] = []
        points.reserveCapacity(signal.left.count)
        for index in signal.left.indices {
            let angle = Double(index) / Double(signal.left.count) * .pi * 2 - .pi / 2 + phase
            let sample = max(-1, min(1, Double(signal.left[index])))
            let radius = base * CGFloat(1 + sample * intensity * 0.48)
            points.append(CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius))
        }
        return smooth(points)
    }

    private func lissajous(_ signal: SignalSnapshot, time: TimeInterval, intensity: Double) -> CGPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let count = signal.left.count
        let breathing = 0.94 + Double(signal.bassPulse) * 0.13
        return smooth((0..<count).map { index in
            let delayed = (index + 13) % count
            let phase = Double(index) / Double(count) * .pi * 2
            let x = (Double(signal.left[index]) * intensity * 0.68 + cos(phase * 2 + time * 0.10) * 0.018) * breathing
            let y = (Double(signal.right[delayed]) * intensity * 0.68 + sin(phase * 3) * 0.018) * breathing
            return CGPoint(x: center.x + CGFloat(x) * bounds.width * 0.34, y: center.y + CGFloat(y) * bounds.height * 0.42)
        })
    }

    private func bloom(_ signal: SignalSnapshot, time: TimeInterval, ring: Int, intensity: Double, rotationSpeed: Double) -> CGPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let base = min(bounds.width, bounds.height) * CGFloat(0.105 + Double(ring) * 0.042)
        let bass = Double(signal.bassPulse)
        let phase = time * (0.08 + Double(ring) * 0.018) * rotationSpeed
        return smooth(signal.left.indices.map { index in
            let fraction = Double(index) / Double(signal.left.count)
            let angle = fraction * .pi * 2 - .pi / 2 + phase * (ring.isMultiple(of: 2) ? 1 : -1)
            let radius = base * CGFloat(1 + Double(abs(signal.left[index])) * intensity * 0.28 + sin(angle * Double(3 + ring)) * (0.025 + bass * 0.05) + bass * 0.16)
            return CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius)
        })
    }

    private func smooth(_ points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        guard points.count > 2 else { return path }
        func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint { CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2) }
        path.move(to: midpoint(points[points.count - 1], points[0]))
        for index in points.indices {
            let next = points[(index + 1) % points.count]
            path.addQuadCurve(to: midpoint(points[index], next), control: points[index])
        }
        path.closeSubpath()
        return path
    }
}
