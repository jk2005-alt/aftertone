import SwiftUI

struct InstrumentLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 9, weight: .black, design: .rounded))
            .tracking(1.2)
            .foregroundStyle(AuralisTheme.ink.opacity(0.92))
    }
}

struct HardwareButton: View {
    let title: String
    let symbol: String
    var active = false
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: symbol)
                    .font(.system(size: 14, weight: .bold))
                Text(title.uppercased())
                    .font(.system(size: 8, weight: .black, design: .rounded))
                    .tracking(0.7)
            }
            .frame(width: 55, height: 45)
        }
        .buttonStyle(MechanicalButtonStyle(active: active))
        .accessibilityLabel(title)
    }
}

private struct MechanicalButtonStyle: ButtonStyle {
    let active: Bool
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(active ? AuralisTheme.paper : AuralisTheme.ink.opacity(0.92))
            .background(
                RoundedRectangle(cornerRadius: 2)
                    .fill(active ? Color(red: 0.16, green: 0.20, blue: 0.13) : Color(red: 0.34, green: 0.33, blue: 0.25))
                    .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.black.opacity(0.75), lineWidth: 2))
                    .overlay(alignment: .top) { Rectangle().fill(AuralisTheme.paper.opacity(configuration.isPressed ? 0.05 : 0.15)).frame(height: 1).padding(.horizontal, 3) }
                    .shadow(color: .black.opacity(0.82), radius: configuration.isPressed ? 0 : 1, y: configuration.isPressed ? 0 : 2)
            )
            .scaleEffect(configuration.isPressed ? 0.955 : 1)
            .offset(y: configuration.isPressed ? 1 : 0)
            .animation(.easeOut(duration: 0.075), value: configuration.isPressed)
    }
}

struct ToggleLever: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Button { isOn.toggle() } label: {
            VStack(spacing: 7) {
                InstrumentLabel(text: title)
                ZStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.055, green: 0.052, blue: 0.040))
                        .frame(width: 34, height: 50)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(Color.black.opacity(0.92), lineWidth: 2))
                    VStack(spacing: 0) {
                        Text("I")
                            .foregroundStyle(isOn ? AuralisTheme.amber : AuralisTheme.paper.opacity(0.32))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(isOn ? Color(red: 0.19, green: 0.18, blue: 0.13) : Color(red: 0.11, green: 0.105, blue: 0.08))
                            .overlay(alignment: .top) { Rectangle().fill(AuralisTheme.paper.opacity(isOn ? 0.05 : 0.18)).frame(height: 1) }
                        Rectangle().fill(Color.black.opacity(0.85)).frame(height: 2)
                        Text("O")
                            .foregroundStyle(!isOn ? AuralisTheme.paper.opacity(0.82) : AuralisTheme.paper.opacity(0.28))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(!isOn ? Color(red: 0.20, green: 0.19, blue: 0.145) : Color(red: 0.10, green: 0.095, blue: 0.073))
                            .overlay(alignment: .bottom) { Rectangle().fill(Color.black.opacity(isOn ? 0.35 : 0.65)).frame(height: 2) }
                    }
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .frame(width: 26, height: 42)
                    .clipShape(RoundedRectangle(cornerRadius: 1))
                    .rotation3DEffect(.degrees(isOn ? -7 : 7), axis: (x: 1, y: 0, z: 0), perspective: 0.65)
                    .shadow(color: .black.opacity(0.82), radius: 1, y: isOn ? -2 : 2)
                }
                .frame(width: 38, height: 52)
                Circle()
                    .fill(isOn ? AuralisTheme.amber : Color.black.opacity(0.45))
                    .frame(width: 7, height: 7)
                    .shadow(color: isOn ? AuralisTheme.amber : .clear, radius: 5)
            }
            .animation(.spring(response: 0.16, dampingFraction: 0.74), value: isOn)
        }
        .buttonStyle(.plain)
    }
}

struct RotaryKnob: View {
    let title: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...1
    var tint = AuralisTheme.amber

    private var normalized: Double {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    var body: some View {
        VStack(spacing: 5) {
            InstrumentLabel(text: title)
            ZStack {
                ForEach(0..<11, id: \.self) { tick in
                    Rectangle()
                        .fill(AuralisTheme.ink.opacity(0.82))
                        .frame(width: 1.5, height: 5)
                        .offset(y: -29)
                        .rotationEffect(.degrees(-135 + Double(tick) * 27))
                }
                Circle()
                    .fill(RadialGradient(colors: [Color(red: 0.20, green: 0.19, blue: 0.15), Color(red: 0.055, green: 0.05, blue: 0.04)], center: UnitPoint(x: 0.42, y: 0.38), startRadius: 2, endRadius: 28))
                    .frame(width: 48, height: 48)
                    .overlay(Circle().stroke(Color.black.opacity(0.9), lineWidth: 2))
                    .overlay(Circle().inset(by: 6).stroke(AuralisTheme.paper.opacity(0.07), lineWidth: 1))
                    .shadow(color: .black.opacity(0.82), radius: 2, y: 3)
                Capsule()
                    .fill(tint.opacity(0.92))
                    .frame(width: 2.5, height: 14)
                    .offset(y: -12)
                    .rotationEffect(.degrees(-135 + normalized * 270))
                    .shadow(color: tint.opacity(0.65), radius: 2)
            }
            .frame(width: 64, height: 64)
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        updateValue(for: gesture.location, in: CGSize(width: 64, height: 64))
                    }
            )
            Text("\(Int(normalized * 100))")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(AuralisTheme.ink.opacity(0.75))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue("\(Int(normalized * 100)) percent")
    }

    private func updateValue(for location: CGPoint, in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let deltaX = location.x - center.x
        let deltaY = location.y - center.y
        guard abs(deltaX) + abs(deltaY) > 1 else { return }

        // Zero is straight up and positive angles run clockwise, matching the
        // physical pointer. The unused 90-degree section at the bottom clamps
        // to the nearest endpoint instead of wrapping the knob unexpectedly.
        let cursorAngle = atan2(Double(deltaX), Double(-deltaY)) * 180 / .pi
        let dialAngle: Double
        if cursorAngle > 135 {
            dialAngle = 135
        } else if cursorAngle < -135 {
            dialAngle = -135
        } else {
            dialAngle = cursorAngle
        }

        let cursorNormalized = (dialAngle + 135) / 270
        let span = range.upperBound - range.lowerBound
        value = range.lowerBound + cursorNormalized * span
    }
}

struct PassiveSignalMonitor: View {
    let signal: VisualizerState

    var body: some View {
        VStack(spacing: 11) {
            InstrumentLabel(text: "SIGNAL MONITOR")
            Text("TYPE LSJ-1")
                .font(.system(size: 7, weight: .bold, design: .monospaced))
                .tracking(1)
                .foregroundStyle(AuralisTheme.ink.opacity(0.55))

            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 0.78, green: 0.75, blue: 0.58))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black.opacity(0.72), lineWidth: 2))
                    .shadow(color: .black.opacity(0.45), radius: 1, y: 2)
                ForEach(0..<9, id: \.self) { tick in
                    Rectangle()
                        .fill(AuralisTheme.ink.opacity(0.8))
                        .frame(width: tick.isMultiple(of: 2) ? 2 : 1, height: tick.isMultiple(of: 2) ? 7 : 5)
                        .offset(y: -27)
                        .rotationEffect(.degrees(-60 + Double(tick) * 15))
                }
                VUNeedle(signal: signal)
                Circle().fill(Color.black.opacity(0.82)).frame(width: 9, height: 9).offset(y: 4)
                Text("VU")
                    .font(.system(size: 8, weight: .black, design: .monospaced))
                    .foregroundStyle(AuralisTheme.ink.opacity(0.8))
                    .offset(y: 23)
            }
            .frame(width: 101, height: 76)

            VStack(spacing: 8) {
                statusLine("AUTO LEVEL", lamp: AuralisTheme.phosphor)
                statusLine("LISSAJOUS", lamp: AuralisTheme.phosphor)
                statusLine("PHOSPHOR", lamp: AuralisTheme.amber)
            }

            VStack(spacing: 4) {
                ForEach(0..<7, id: \.self) { _ in
                    Capsule().fill(Color.black.opacity(0.32)).frame(height: 2)
                }
            }
            .padding(.horizontal, 7)

            Text("CALIBRATED · DO NOT ADJUST")
                .font(.system(size: 6, weight: .black, design: .monospaced))
                .tracking(0.35)
                .foregroundStyle(AuralisTheme.ink.opacity(0.62))
                .multilineTextAlignment(.center)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Passive Lissajous signal monitor")
    }

    private func statusLine(_ title: String, lamp: Color) -> some View {
        HStack(spacing: 7) {
            Circle()
                .fill(lamp.opacity(0.9))
                .frame(width: 6, height: 6)
                .shadow(color: lamp.opacity(0.65), radius: 3)
            Text(title)
                .font(.system(size: 7, weight: .black, design: .monospaced))
                .tracking(0.45)
            Spacer(minLength: 0)
        }
    }
}

private struct VUNeedle: View {
    @ObservedObject var signal: VisualizerState

    var body: some View {
        Capsule()
            .fill(AuralisTheme.amber.opacity(0.9))
            .frame(width: 2, height: 30)
            .offset(y: -11)
            .rotationEffect(.degrees(-55 + Double(signal.level) * 110))
            .shadow(color: AuralisTheme.amber.opacity(0.45), radius: 1)
    }
}

struct RisingFader: View {
    let title: String
    @Binding var value: Double

    private var normalized: Double { min(1, max(0, value)) }

    var body: some View {
        VStack(spacing: 5) {
            InstrumentLabel(text: title)
            GeometryReader { geometry in
                let travel = max(1, geometry.size.height - 20)
                let handleY = 10 + CGFloat(1 - normalized) * travel
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.095, green: 0.09, blue: 0.065))
                        .frame(width: 24)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(.black.opacity(0.85), lineWidth: 2))
                    VStack(spacing: 0) {
                        Spacer()
                        Rectangle()
                            .fill(LinearGradient(colors: [AuralisTheme.amber.opacity(0.72), AuralisTheme.phosphor.opacity(0.8)], startPoint: .bottom, endPoint: .top))
                            .frame(width: 8, height: CGFloat(normalized) * travel)
                    }
                    .frame(height: geometry.size.height - 10)
                    ForEach(0..<9, id: \.self) { tick in
                        HStack(spacing: 30) {
                            Rectangle().frame(width: tick.isMultiple(of: 2) ? 8 : 5, height: 1)
                            Rectangle().frame(width: tick.isMultiple(of: 2) ? 8 : 5, height: 1)
                        }
                        .foregroundStyle(AuralisTheme.ink.opacity(0.72))
                        .offset(y: 8 + CGFloat(tick) * travel / 8)
                    }
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(red: 0.24, green: 0.23, blue: 0.18))
                        .frame(width: 47, height: 14)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(.black.opacity(0.88), lineWidth: 2))
                        .overlay(Rectangle().fill(AuralisTheme.paper.opacity(0.5)).frame(width: 29, height: 1))
                        .shadow(color: .black.opacity(0.75), radius: 1, y: 2)
                        .position(x: geometry.size.width / 2, y: handleY)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            value = min(1, max(0, 1 - Double((gesture.location.y - 10) / travel)))
                        }
                )
            }
            .frame(width: 70, height: 115)
            Text("\(Int(normalized * 100))")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundStyle(AuralisTheme.ink.opacity(0.76))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue("\(Int(normalized * 100)) percent")
    }
}
