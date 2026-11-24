import SwiftUI

private enum EmotionalSignalForm {
    case ribbon, halo, bloom, fracture, tide, pulse, spiral, drift
    case rain, corridor, prism, heart, constellation, memoryLoop
    case orbitWeave, hourglass, skyline, waveGrid
}

private struct EmotionalVisualProfile {
    let form: EmotionalSignalForm
    let layers: Int
    let lobes: Int
    let speed: Double
    let amplitude: Double
    let spread: Double
    let glow: Double
    let feeling: String

    init(track: Track?, scene: SongVisualProgram.Scene) {
        if let title = track?.title.lowercased(), let tailored = Self.tailoredProfile(for: title) {
            self = tailored
            return
        }
        switch scene {
        case .letterHome:       self = .init(.ribbon, 4, 2, 0.18, 0.28, 0.52, 0.30, "WISTFUL")
        case .les:              self = .init(.drift, 3, 3, 0.34, 0.36, 0.70, 0.34, "RESTLESS")
        case .stressRelief:     self = .init(.memoryLoop, 5, 2, 0.18, 0.30, 0.74, 0.32, "NOSTALGIC")
        case .harvey:           self = .init(.halo, 4, 4, 0.16, 0.24, 0.58, 0.28, "TENDER")
        case .hotelRoom:        self = .init(.corridor, 7, 2, 0.12, 0.26, 0.62, 0.22, "LONELY")
        case .petal:            self = .init(.bloom, 5, 7, 0.13, 0.24, 0.62, 0.32, "REGRET")
        case .doubt:            self = .init(.fracture, 5, 5, 0.38, 0.40, 0.74, 0.36, "ANXIOUS")
        case .sweaterWeather:   self = .init(.ribbon, 6, 3, 0.16, 0.30, 0.68, 0.26, "COLD INTIMACY")
        case .diamonds:         self = .init(.prism, 6, 6, 0.21, 0.34, 0.74, 0.42, "LUMINOUS")
        case .hipsDontLie:      self = .init(.spiral, 4, 5, 0.52, 0.42, 0.86, 0.38, "EXUBERANT")
        case .chantaje:         self = .init(.drift, 5, 4, 0.30, 0.38, 0.76, 0.34, "MAGNETIC")
        case .forgottenMemory:  self = .init(.fracture, 7, 6, 0.44, 0.46, 0.82, 0.40, "VOLATILE")
        case .leanOn:           self = .init(.bloom, 4, 5, 0.25, 0.34, 0.70, 0.30, "WARM")
        case .swimmingPools:    self = .init(.tide, 12, 3, 0.11, 0.32, 0.92, 0.24, "SUBMERGED")
        case .janice:           self = .init(.fracture, 6, 8, 0.58, 0.48, 0.86, 0.44, "AGITATED")
        case .legendaryLovers:  self = .init(.bloom, 7, 8, 0.17, 0.28, 0.78, 0.38, "MYTHIC")
        case .kissMeMore:       self = .init(.heart, 5, 6, 0.31, 0.38, 0.78, 0.36, "PLAYFUL")
        case .ivy:              self = .init(.ribbon, 7, 4, 0.12, 0.25, 0.76, 0.28, "BITTERSWEET")
        case .flatline:         self = .init(.pulse, 3, 2, 0.09, 0.18, 0.72, 0.18, "NUMB")
        case .confident:        self = .init(.prism, 5, 5, 0.33, 0.44, 0.82, 0.46, "BOLD")
        case .americanWedding:  self = .init(.drift, 6, 2, 0.10, 0.27, 0.72, 0.24, "MELANCHOLIC")
        case .heartbeat:        self = .init(.pulse, 7, 3, 0.48, 0.48, 0.86, 0.44, "URGENT")
        case .teenSpirit:       self = .init(.fracture, 8, 7, 0.64, 0.56, 0.94, 0.48, "DEFIANT")
        case .soHigh:           self = .init(.constellation, 7, 3, 0.09, 0.26, 0.88, 0.30, "FLOATING")
        case .heartShapedBox:   self = .init(.heart, 7, 9, 0.15, 0.38, 0.80, 0.36, "HAUNTED")
        case .cassette:         self = .init(.ribbon, 5, 3, 0.20, 0.32, 0.66, 0.28, "PRIVATE")
        }
    }

    private static func tailoredProfile(for title: String) -> EmotionalVisualProfile? {
        switch title {
        case "bye bye bye": return .init(.prism, 4, 3, 0.44, 0.38, 0.76, 0.36, "KINETIC")
        case "nights like this": return .init(.constellation, 6, 4, 0.10, 0.29, 0.86, 0.30, "MIDNIGHT YEARNING")
        case "someone like you": return .init(.ribbon, 5, 2, 0.09, 0.24, 0.66, 0.25, "ACCEPTANCE")
        case "skyfall": return .init(.hourglass, 7, 5, 0.13, 0.42, 0.84, 0.43, "CINEMATIC")
        case "something about you": return .init(.memoryLoop, 4, 3, 0.21, 0.31, 0.71, 0.31, "GOLDEN HAZE")
        case "she": return .init(.orbitWeave, 7, 5, 0.28, 0.41, 0.80, 0.37, "DANGEROUS")
        case "maneater": return .init(.skyline, 11, 4, 0.32, 0.46, 0.82, 0.38, "NOCTURNAL")
        case "out of touch": return .init(.waveGrid, 8, 4, 0.38, 0.40, 0.86, 0.35, "NEON DISTANCE")
        case "dark red": return .init(.heart, 6, 5, 0.12, 0.34, 0.73, 0.34, "FOREBODING")
        case "bad habit": return .init(.drift, 5, 4, 0.23, 0.36, 0.78, 0.33, "MISSED CHANCE")
        case "you are the right one": return .init(.halo, 5, 6, 0.14, 0.27, 0.68, 0.28, "DEVOTED")
        case "car's outside": return .init(.corridor, 8, 3, 0.11, 0.31, 0.72, 0.26, "DEPARTURE")
        case "self aware": return .init(.fracture, 6, 4, 0.31, 0.38, 0.79, 0.34, "AWAKENING")
        case "earrings": return .init(.memoryLoop, 6, 4, 0.16, 0.27, 0.69, 0.29, "UNSAID")
        case "out of my league": return .init(.bloom, 6, 9, 0.29, 0.39, 0.82, 0.38, "EUPHORIC")
        case "luxury": return .init(.spiral, 5, 7, 0.46, 0.45, 0.88, 0.42, "OPULENT")
        case "look after you": return .init(.pulse, 5, 3, 0.12, 0.26, 0.71, 0.27, "PROTECTIVE")
        case "what it is (block boy) [feat. kodak black]": return .init(.skyline, 9, 5, 0.45, 0.49, 0.88, 0.42, "PLAYFUL SWAGGER")
        case "mirrors": return .init(.prism, 9, 8, 0.14, 0.35, 0.86, 0.40, "REFLECTIVE")
        case "back to the old house (2011 remaster)": return .init(.corridor, 9, 2, 0.07, 0.22, 0.62, 0.22, "MEMORY")
        case "slipping through my fingers": return .init(.ribbon, 7, 2, 0.08, 0.25, 0.74, 0.27, "PASSING TIME")
        case "smooth operator (2011 remastered)": return .init(.orbitWeave, 6, 8, 0.24, 0.33, 0.82, 0.34, "VELVET")
        case "baby come back": return .init(.pulse, 7, 4, 0.19, 0.35, 0.78, 0.33, "PLEADING")
        case "baby i'm back": return .init(.fracture, 5, 7, 0.42, 0.46, 0.87, 0.41, "RETURN")
        case "baby by me": return .init(.skyline, 8, 6, 0.51, 0.48, 0.91, 0.43, "BRASH")
        case "sailor song": return .init(.tide, 10, 4, 0.10, 0.30, 0.90, 0.27, "OCEANIC")
        case "invisible": return .init(.waveGrid, 9, 6, 0.33, 0.43, 0.89, 0.40, "PHANTOM")
        case "chicago": return .init(.drift, 7, 5, 0.17, 0.34, 0.82, 0.32, "SECRETIVE")
        case "mind over matter (reprise)": return .init(.hourglass, 6, 3, 0.10, 0.29, 0.72, 0.29, "RESOLVE")
        case "end of beginning": return .init(.memoryLoop, 7, 2, 0.13, 0.30, 0.76, 0.33, "HOMECOMING")
        case "wham bam shang-a-lang": return .init(.bloom, 8, 6, 0.35, 0.42, 0.86, 0.40, "SUNLIT")
        case "outside": return .init(.orbitWeave, 8, 6, 0.40, 0.47, 0.91, 0.43, "ESCAPE")
        case "love me (feat. drake & future)": return .init(.fracture, 7, 9, 0.47, 0.50, 0.92, 0.45, "HEDONIC")
        case "beauty and a beat (feat. nicki minaj)": return .init(.spiral, 6, 8, 0.55, 0.52, 0.94, 0.47, "CELEBRATION")
        case "boyfriend": return .init(.halo, 7, 7, 0.30, 0.38, 0.81, 0.37, "FLIRTATIOUS")
        case "shut up my mom's calling": return .init(.constellation, 8, 5, 0.12, 0.31, 0.91, 0.33, "LONELY STATIC")
        case "i wanna be yours": return .init(.heart, 8, 6, 0.09, 0.30, 0.74, 0.32, "OBSESSIVE")
        case "no. 1 party anthem": return .init(.tide, 9, 5, 0.15, 0.33, 0.86, 0.31, "SLOW DANCE")
        case "do i wanna know?": return .init(.pulse, 8, 5, 0.16, 0.43, 0.88, 0.39, "SUSPICION")
        case "v. 3005": return .init(.prism, 7, 5, 0.27, 0.42, 0.84, 0.39, "FOREVER")
        case "feel it": return .init(.bloom, 7, 10, 0.36, 0.44, 0.88, 0.43, "WEIGHTLESS")
        case "chamber of reflection": return .init(.halo, 9, 4, 0.07, 0.25, 0.83, 0.30, "ISOLATION")
        case "softcore": return .init(.waveGrid, 7, 3, 0.19, 0.35, 0.82, 0.34, "INTIMATE STATIC")
        case "reflections": return .init(.hourglass, 8, 7, 0.11, 0.34, 0.83, 0.37, "MIRRORED")
        case "the color violet": return .init(.prism, 8, 7, 0.15, 0.37, 0.86, 0.41, "VIOLET NIGHT")
        case "my all": return .init(.ribbon, 7, 3, 0.08, 0.27, 0.74, 0.29, "DEVOTION")
        case "wildflower": return .init(.bloom, 9, 11, 0.10, 0.30, 0.82, 0.36, "TENDER GUILT")
        case "blue": return .init(.tide, 12, 5, 0.07, 0.34, 0.92, 0.30, "DEEP BLUE")
        case "sienna": return .init(.memoryLoop, 6, 4, 0.11, 0.28, 0.72, 0.30, "IMAGINED LIFE")
        case "from the start": return .init(.orbitWeave, 7, 8, 0.28, 0.35, 0.79, 0.37, "BOSSA CRUSH")
        case "viva la vida": return .init(.hourglass, 10, 6, 0.20, 0.43, 0.90, 0.44, "FALLEN KING")
        case "hymn for the weekend": return .init(.constellation, 9, 6, 0.24, 0.43, 0.93, 0.43, "ECSTATIC")
        case "something just like this": return .init(.skyline, 11, 7, 0.34, 0.46, 0.91, 0.42, "HEROIC")
        case "duvet": return .init(.drift, 8, 5, 0.13, 0.34, 0.84, 0.34, "DREAM STATIC")
        case "chasing pavements": return .init(.corridor, 9, 3, 0.10, 0.31, 0.76, 0.31, "UNCERTAIN")
        case "k.": return .init(.halo, 9, 5, 0.06, 0.25, 0.78, 0.28, "INTIMATE")
        case "ku lo sa (with camila cabello)": return .init(.spiral, 6, 9, 0.42, 0.46, 0.90, 0.43, "MAGNETIC HEAT")
        case "cool for the summer": return .init(.bloom, 8, 10, 0.48, 0.51, 0.92, 0.47, "FEVER")
        case "die for you (with ariana grande) - remix": return .init(.heart, 9, 7, 0.13, 0.36, 0.82, 0.38, "BOUND")
        case "is there someone else?": return .init(.fracture, 7, 5, 0.14, 0.37, 0.86, 0.37, "SUSPICION")
        case "timeless (feat. playboi carti)": return .init(.skyline, 10, 8, 0.46, 0.51, 0.94, 0.47, "IMMORTAL")
        case "no role modelz": return .init(.pulse, 8, 6, 0.37, 0.48, 0.89, 0.42, "DISILLUSIONED")
        case "the party & the after party (slowed cut)": return .init(.orbitWeave, 9, 6, 0.08, 0.38, 0.88, 0.39, "AFTER HOURS")
        case "breakin' my heart (pretty brown eyes) [sped up + reverb]": return .init(.waveGrid, 10, 5, 0.43, 0.42, 0.90, 0.39, "RESTLESS LOVE")
        case "high enough (slowed edit)": return .init(.constellation, 8, 4, 0.07, 0.34, 0.91, 0.36, "CHEMICAL HAZE")
        case "play date": return .init(.memoryLoop, 7, 6, 0.24, 0.37, 0.79, 0.36, "DOLLHOUSE PULL")
        case "sucker": return .init(.orbitWeave, 8, 9, 0.42, 0.46, 0.91, 0.43, "HEADLONG")
        case "placing the blame": return .init(.corridor, 10, 3, 0.08, 0.30, 0.76, 0.29, "RECKONING")
        case "everything in its right place": return .init(.waveGrid, 11, 5, 0.09, 0.39, 0.94, 0.38, "DISLOCATION")
        case "let down": return .init(.tide, 13, 5, 0.07, 0.34, 0.92, 0.33, "WEIGHTLESS ACHE")
        case "blue light": return .init(.prism, 8, 6, 0.14, 0.31, 0.85, 0.35, "BLUE HOUR")
        case "all i need": return .init(.heart, 8, 5, 0.10, 0.35, 0.80, 0.36, "NEED")
        case "here": return .init(.fracture, 7, 5, 0.22, 0.40, 0.84, 0.38, "OUTSIDER")
        case "lisztomania": return .init(.spiral, 8, 11, 0.41, 0.45, 0.91, 0.43, "GILDED RUSH")
        case "4 raws": return .init(.fracture, 9, 7, 0.52, 0.52, 0.93, 0.47, "RAW PRESSURE")
        case "the color violet (live)": return .init(.prism, 10, 9, 0.18, 0.42, 0.91, 0.46, "VIOLET STAGE")
        case "big罪罪罪罪罪罪罪": return .init(.orbitWeave, 11, 7, 0.29, 0.53, 0.95, 0.48, "SEVENFOLD JUDGMENT")
        case "meant to be (slowed)": return .init(.memoryLoop, 7, 5, 0.07, 0.32, 0.80, 0.34, "SOFT CERTAINTY")
        case "or what": return .init(.pulse, 10, 8, 0.55, 0.55, 0.94, 0.48, "NO QUESTION")
        case "mantra": return .init(.hourglass, 12, 8, 0.18, 0.57, 0.96, 0.50, "EPIC ASCENT")
        case "redbone": return .init(.orbitWeave, 9, 7, 0.10, 0.42, 0.88, 0.42, "STAY WOKE")
        case "come and get your love (single version)": return .init(.bloom, 8, 9, 0.36, 0.44, 0.89, 0.42, "OPEN-ARMED")
        case "i say a little prayer": return .init(.halo, 9, 6, 0.12, 0.34, 0.82, 0.37, "DEVOTIONAL")
        case "love your voice": return .init(.ribbon, 8, 5, 0.20, 0.38, 0.85, 0.38, "VOICEPRINT")
        case "main chick (feat. chris brown)": return .init(.skyline, 10, 7, 0.48, 0.51, 0.93, 0.46, "NIGHT STATUS")
        case "一緒なら": return .init(.memoryLoop, 7, 3, 0.08, 0.29, 0.77, 0.30, "TOGETHER")
        case "青のすみか": return .init(.prism, 9, 7, 0.25, 0.43, 0.91, 0.43, "AZURE YOUTH")
        case "inferno (tv size)": return .init(.fracture, 9, 8, 0.63, 0.56, 0.95, 0.50, "IGNITION")
        case "ashes on the fire": return .init(.waveGrid, 12, 7, 0.28, 0.51, 0.95, 0.46, "WAR MARCH")
        case "you say run": return .init(.pulse, 9, 5, 0.52, 0.54, 0.93, 0.47, "PLUS ULTRA")
        case "livingroom": return .init(.halo, 7, 5, 0.09, 0.25, 0.72, 0.27, "DOMESTIC STATIC")
        case "in the pool": return .init(.tide, 13, 4, 0.07, 0.32, 0.94, 0.30, "SUBMERGED SUMMER")
        case "cóunter・attàck-mˈænkάɪnd": return .init(.fracture, 11, 9, 0.49, 0.58, 0.96, 0.50, "COUNTERSTRIKE")
        case "call your name": return .init(.corridor, 10, 3, 0.09, 0.35, 0.82, 0.34, "LOST CALL")
        case "licht und schatten": return .init(.hourglass, 10, 6, 0.08, 0.38, 0.88, 0.39, "LIGHT / SHADOW")
        case "glassy sky": return .init(.constellation, 11, 5, 0.07, 0.34, 0.94, 0.39, "SHATTERED SKY")
        case "call of silence": return .init(.ribbon, 9, 3, 0.07, 0.31, 0.84, 0.33, "SILENT VOW")
        case "oh yeah?": return .init(.orbitWeave, 7, 7, 0.29, 0.41, 0.86, 0.40, "COY RELEASE")
        case "you love me": return .init(.ribbon, 6, 3, 0.10, 0.28, 0.72, 0.29, "TENDER BELONGING")
        case "eyes without a face": return .init(.prism, 8, 5, 0.12, 0.36, 0.84, 0.39, "MASKED LONGING")
        case "when i close my eyes": return .init(.memoryLoop, 7, 4, 0.08, 0.30, 0.78, 0.32, "AFTERIMAGE")
        case "secret door": return .init(.constellation, 8, 6, 0.11, 0.33, 0.89, 0.35, "HIDDEN ROMANCE")
        default: return nil
        }
    }

    private init(_ form: EmotionalSignalForm, _ layers: Int, _ lobes: Int, _ speed: Double, _ amplitude: Double, _ spread: Double, _ glow: Double, _ feeling: String) {
        self.form = form; self.layers = layers; self.lobes = lobes; self.speed = speed
        self.amplitude = amplitude; self.spread = spread; self.glow = glow; self.feeling = feeling
    }
}

/// One low-overhead visualizer engine whose geometry is art-directed per song.
/// It reuses the audio analyzer and playback clock instead of creating another timer.
private struct EmotionalSignalCanvas: View {
    @ObservedObject var signal: VisualizerState
    let profile: EmotionalVisualProfile
    let active: Bool
    // Forty-eight control points are enough for the phosphor curves and keep the
    // full family of song-specific shapes inside a predictable frame budget.
    private var samplingStep: Int { max(1, signal.left.count / 48) }

    var body: some View {
        Canvas { context, size in
            guard size.width > 1, size.height > 1, signal.left.count > 8 else { return }
            draw(context: &context, size: size, time: ProcessInfo.processInfo.systemUptime)
        }
        .padding(20)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .opacity(active ? 1 : 0.74)
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func draw(context: inout GraphicsContext, size: CGSize, time: Double) {
        let pulse = Double(signal.bassPulse)
        let level = Double(signal.level)
        let response = 0.68 + level * 0.72 + pulse * 0.28
        let phase = time * profile.speed

        if case .memoryLoop = profile.form {
            // This preset has its own quieter framing so its tape silhouette stays distinct.
        } else {
            for ring in 0..<3 {
                let diameter = min(size.width, size.height) * CGFloat(0.34 + Double(ring) * 0.20 + pulse * 0.025)
                let rect = CGRect(x: size.width / 2 - diameter / 2, y: size.height / 2 - diameter / 2, width: diameter, height: diameter)
                context.stroke(Path(ellipseIn: rect), with: .color(AuralisTheme.phosphorDim.opacity(0.035 + Double(ring) * 0.012)), lineWidth: 0.7)
            }
        }

        switch profile.form {
        case .ribbon: ribbon(&context, size, phase, response)
        case .halo: halo(&context, size, phase, response)
        case .bloom: bloom(&context, size, phase, response)
        case .fracture: fracture(&context, size, phase, response)
        case .tide: tide(&context, size, phase, response)
        case .pulse: pulseTrace(&context, size, phase, response)
        case .spiral: spiral(&context, size, phase, response)
        case .drift: drift(&context, size, phase, response)
        case .rain: rain(&context, size, phase, response)
        case .corridor: corridor(&context, size, phase, response)
        case .prism: prism(&context, size, phase, response)
        case .heart: heart(&context, size, phase, response)
        case .constellation: constellation(&context, size, phase, response)
        case .memoryLoop: memoryLoop(&context, size, phase, response)
        case .orbitWeave: orbitWeave(&context, size, phase, response)
        case .hourglass: hourglass(&context, size, phase, response)
        case .skyline: skyline(&context, size, phase, response)
        case .waveGrid: waveGrid(&context, size, phase, response)
        }
    }

    private func ribbon(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        for layer in 0..<profile.layers {
            let offset = (Double(layer) - Double(profile.layers - 1) / 2) * Double(size.height) * 0.052
            var points: [CGPoint] = []
            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let f = Double(index) / Double(signal.left.count - 1)
                let audio = Double(signal.left[index]) * 0.62 + Double(signal.right[index]) * 0.38
                let calm = sin(f * .pi * Double(profile.lobes) + phase + Double(layer) * 0.44) * 0.026
                let y = Double(size.height) * 0.5 + offset + (audio * profile.amplitude * response + calm) * Double(size.height) * 0.34
                points.append(CGPoint(x: CGFloat(f) * size.width, y: CGFloat(y)))
            }
            trace(smooth(points), &context, 0.76 - Double(layer) * 0.065, layer == profile.layers / 2 ? 1.25 : 0.78)
        }
    }

    private func halo(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        for layer in 0..<profile.layers {
            let base = min(size.width, size.height) * CGFloat(0.15 + Double(layer) * 0.032 * profile.spread)
            var points: [CGPoint] = []
            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let f = Double(index) / Double(signal.left.count)
                let angle = f * .pi * 2 + phase * (layer.isMultiple(of: 2) ? 1 : -0.72)
                let stereo = (Double(signal.left[index]) + Double(signal.right[index])) * 0.5
                let petals = sin(angle * Double(profile.lobes)) * 0.030
                let radius = base * CGFloat(1 + abs(stereo) * profile.amplitude * response + petals)
                points.append(CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius))
            }
            trace(smooth(points, closed: true), &context, 0.82 - Double(layer) * 0.075, layer == 0 ? 1.25 : 0.82)
        }
    }

    private func bloom(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        for layer in 0..<profile.layers {
            let base = min(size.width, size.height) * CGFloat(0.10 + Double(layer) * 0.044 * profile.spread)
            var points: [CGPoint] = []
            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let f = Double(index) / Double(signal.left.count)
                let angle = f * .pi * 2 + phase * (layer.isMultiple(of: 2) ? 0.55 : -0.42)
                let audio = abs(Double(signal.left[index]) * 0.55 + Double(signal.right[index]) * 0.45)
                let petal = pow(abs(sin(angle * Double(profile.lobes) / 2)), 1.7) * profile.amplitude
                let radius = base * CGFloat(1 + petal * 0.68 + audio * response * 0.42)
                points.append(CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius))
            }
            trace(smooth(points, closed: true), &context, 0.84 - Double(layer) * 0.08, layer == 0 ? 1.2 : 0.8)
        }
    }

    private func fracture(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        for layer in 0..<profile.layers {
            var points: [CGPoint] = []
            let polarity = layer.isMultiple(of: 2) ? 1.0 : -1.0
            for step in 0..<64 {
                let f = Double(step) / 63
                let index = min(signal.left.count - 1, step * signal.left.count / 64)
                let audio = Double(signal.left[index]) * 0.7 - Double(signal.right[(index + profile.lobes) % signal.right.count]) * 0.3
                let split = sin(f * .pi * Double(profile.lobes) + phase + Double(layer)) * 0.042
                let y = 0.5 + polarity * (audio * profile.amplitude * response * 0.32 + split) + (Double(layer) - Double(profile.layers - 1) / 2) * 0.028
                points.append(CGPoint(x: CGFloat(f) * size.width, y: CGFloat(y) * size.height))
            }
            trace(smooth(points), &context, 0.78 - Double(layer) * 0.06, layer == 0 ? 1.35 : 0.78)
        }
    }

    private func tide(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        for row in 0..<profile.layers {
            let depth = Double(row) / Double(max(1, profile.layers - 1))
            var points: [CGPoint] = []
            for step in 0..<96 {
                let f = Double(step) / 95
                let index = min(signal.left.count - 1, step * signal.left.count / 96)
                let audio = Double(signal.left[index]) * 0.55 + Double(signal.right[index]) * 0.45
                let wave = sin(f * .pi * Double(profile.lobes) + phase + depth * 4.2) * profile.amplitude * 0.14
                let y = 0.10 + depth * 0.80 + wave + audio * response * 0.055
                points.append(CGPoint(x: CGFloat(f) * size.width, y: CGFloat(y) * size.height))
            }
            trace(smooth(points), &context, 0.38 + depth * 0.40, row == profile.layers / 2 ? 1.15 : 0.72)
        }
    }

    private func pulseTrace(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        for echo in 0..<profile.layers {
            var points: [CGPoint] = []
            let offset = (Double(echo) - Double(profile.layers - 1) / 2) * 0.027
            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let f = Double(index) / Double(signal.left.count - 1)
                let audio = Double(signal.left[index]) * 0.68 + Double(signal.right[index]) * 0.32
                let carrier = sin(f * .pi * Double(profile.lobes) * 2 + phase) * 0.012
                let y = 0.5 + offset + audio * profile.amplitude * response * (0.38 - Double(echo) * 0.018) + carrier
                points.append(CGPoint(x: CGFloat(f) * size.width, y: CGFloat(y) * size.height))
            }
            trace(smooth(points), &context, echo == profile.layers / 2 ? 0.90 : 0.34, echo == profile.layers / 2 ? 1.35 : 0.72)
        }
    }

    private func spiral(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        for layer in 0..<profile.layers {
            var points: [CGPoint] = []
            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let f = Double(index) / Double(signal.left.count - 1)
                let angle = f * .pi * Double(3 + profile.lobes) + phase * (layer.isMultiple(of: 2) ? 1 : -0.7)
                let audio = abs(Double(signal.left[index]) * 0.6 + Double(signal.right[index]) * 0.4)
                let radius = min(size.width, size.height) * CGFloat(0.055 + f * 0.29 * profile.spread + audio * profile.amplitude * response * 0.075 + Double(layer) * 0.008)
                points.append(CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius))
            }
            trace(smooth(points), &context, 0.82 - Double(layer) * 0.09, layer == 0 ? 1.2 : 0.76)
        }
    }

    private func drift(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        for layer in 0..<profile.layers {
            var points: [CGPoint] = []
            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let f = Double(index) / Double(signal.left.count)
                let audioX = Double(signal.left[index]) * profile.amplitude * response
                let audioY = Double(signal.right[(index + 11) % signal.right.count]) * profile.amplitude * response
                let x = sin(f * .pi * 2 * Double(profile.lobes) + phase + Double(layer) * 0.28) * profile.spread * 0.30 + audioX * 0.10
                let y = sin(f * .pi * 2 * Double(max(1, profile.lobes - 1)) - phase * 0.72) * profile.spread * 0.34 + audioY * 0.10
                points.append(CGPoint(x: center.x + CGFloat(x) * size.width, y: center.y + CGFloat(y) * size.height))
            }
            trace(smooth(points, closed: true), &context, 0.78 - Double(layer) * 0.10, layer == 0 ? 1.15 : 0.75)
        }
    }

    private func rain(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let columns = profile.layers * 3
        for column in 0..<columns {
            let index = column * signal.left.count / columns
            let audio = abs(Double(signal.left[index]) * 0.62 + Double(signal.right[index]) * 0.38)
            let x = size.width * CGFloat(Double(column) / Double(max(1, columns - 1)))
            let cycle = (sin(phase * 1.7 + Double(column) * 1.91) + 1) * 0.5
            let y = size.height * CGFloat(0.08 + cycle * 0.67)
            let length = size.height * CGFloat(0.045 + audio * profile.amplitude * response * 0.42)
            var drop = Path()
            drop.move(to: CGPoint(x: x, y: y))
            drop.addQuadCurve(
                to: CGPoint(x: x + CGFloat(sin(phase + Double(column))) * 4, y: y + length),
                control: CGPoint(x: x - 3, y: y + length * 0.52)
            )
            trace(drop, &context, 0.34 + audio * 0.54, column.isMultiple(of: 5) ? 1.2 : 0.72)
        }

        for ripple in 0..<3 {
            let audio = abs(Double(signal.left[(ripple * 31) % signal.left.count]))
            let width = size.width * CGFloat(0.20 + Double(ripple) * 0.12 + audio * 0.12)
            let height = width * 0.16
            let rect = CGRect(x: size.width / 2 - width / 2, y: size.height * CGFloat(0.72 + Double(ripple) * 0.055), width: width, height: height)
            trace(Path(ellipseIn: rect), &context, 0.48 - Double(ripple) * 0.10, 0.75)
        }
    }

    private func corridor(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        for layer in 0..<profile.layers {
            let depth = Double(layer + 1) / Double(profile.layers + 1)
            let index = layer * 17 % signal.left.count
            let audio = abs(Double(signal.left[index]) * 0.55 + Double(signal.right[index]) * 0.45)
            let breathing = 1 + audio * profile.amplitude * response * 0.32
            let width = size.width * CGFloat((0.16 + depth * 0.62) * breathing)
            let height = size.height * CGFloat((0.12 + depth * 0.68) * breathing)
            let drift = CGFloat(sin(phase + Double(layer) * 0.8) * 5.0 * (1 - depth))
            let rect = CGRect(x: center.x - width / 2 + drift, y: center.y - height / 2, width: width, height: height)
            trace(Path(roundedRect: rect, cornerRadius: 4 + CGFloat(layer) * 2), &context, 0.72 - depth * 0.045, layer == 0 ? 1.25 : 0.75)
        }

        var rays = Path()
        let outer = CGRect(x: size.width * 0.10, y: size.height * 0.08, width: size.width * 0.80, height: size.height * 0.84)
        let inner = CGRect(x: size.width * 0.42, y: size.height * 0.44, width: size.width * 0.16, height: size.height * 0.12)
        for pair in [(outer.minX, outer.minY, inner.minX, inner.minY), (outer.maxX, outer.minY, inner.maxX, inner.minY), (outer.minX, outer.maxY, inner.minX, inner.maxY), (outer.maxX, outer.maxY, inner.maxX, inner.maxY)] {
            rays.move(to: CGPoint(x: pair.0, y: pair.1)); rays.addLine(to: CGPoint(x: pair.2, y: pair.3))
        }
        trace(rays, &context, 0.28, 0.7)
    }

    private func prism(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        for layer in 0..<profile.layers {
            let base = min(size.width, size.height) * CGFloat(0.105 + Double(layer) * 0.047 * profile.spread)
            var points: [CGPoint] = []
            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let f = Double(index) / Double(signal.left.count)
                let angle = f * .pi * 2 + phase * 0.22
                let denominator = max(0.72, abs(cos(angle)) + abs(sin(angle)))
                let audio = abs(Double(signal.left[index]) * 0.5 + Double(signal.right[index]) * 0.5)
                let radius = base / CGFloat(denominator) * CGFloat(1 + audio * profile.amplitude * response * 0.52)
                points.append(CGPoint(x: center.x + CGFloat(cos(angle)) * radius, y: center.y + CGFloat(sin(angle)) * radius))
            }
            trace(smooth(points, closed: true), &context, 0.84 - Double(layer) * 0.09, layer == 0 ? 1.25 : 0.78)
        }
    }

    private func heart(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height * 0.53)
        for layer in 0..<profile.layers {
            let scale = min(size.width, size.height) * CGFloat(0.013 + Double(layer) * 0.0014 * profile.spread)
            var points: [CGPoint] = []
            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let t = Double(index) / Double(signal.left.count) * .pi * 2
                let audio = Double(signal.left[index]) * 0.55 + Double(signal.right[index]) * 0.45
                let beat = 1 + audio * profile.amplitude * response * 0.42 + sin(phase + Double(layer)) * 0.015
                let x = 16 * pow(sin(t), 3) * beat
                let y = (13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t)) * beat
                points.append(CGPoint(x: center.x + CGFloat(x) * scale, y: center.y - CGFloat(y) * scale))
            }
            trace(smooth(points, closed: true), &context, 0.84 - Double(layer) * 0.085, layer == 0 ? 1.3 : 0.76)
        }
    }

    private func constellation(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let count = 24
        var points: [CGPoint] = []
        var strengths: [Double] = []
        for point in 0..<count {
            let index = point * signal.left.count / count
            let f = Double(point) / Double(count)
            let audio = abs(Double(signal.left[index]) * 0.55 + Double(signal.right[index]) * 0.45)
            let angle = f * .pi * 2 * Double(profile.lobes) + phase
            let orbit = min(size.width, size.height) * CGFloat(0.13 + f * 0.24 * profile.spread + audio * profile.amplitude * response * 0.08)
            points.append(CGPoint(x: center.x + CGFloat(cos(angle)) * orbit, y: center.y + CGFloat(sin(angle * 0.73)) * orbit))
            strengths.append(audio)
        }
        trace(smooth(points), &context, 0.42, 0.72)
        for index in points.indices {
            let radius = CGFloat(1.5 + strengths[index] * response * 4.5)
            context.fill(Path(ellipseIn: CGRect(x: points[index].x - radius, y: points[index].y - radius, width: radius * 2, height: radius * 2)), with: .color(AuralisTheme.phosphor.opacity(0.46 + strengths[index] * 0.46)))
        }
    }

    /// Stress Relief: a slowly breathing cassette-tape loop with restrained stereo afterimages.
    /// The shape remains legible during quiet passages and expands gently with the recording.
    private func memoryLoop(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let bass = Double(signal.bassPulse)
        let baseWidth = Double(size.width) * (0.265 + bass * 0.010)
        let baseHeight = Double(size.height) * (0.185 + bass * 0.008)

        // A few offset recordings of the same loop create a soft analogue afterimage.
        for echo in 0..<profile.layers {
            let depth = Double(echo) / Double(max(1, profile.layers - 1))
            let echoPhase = phase * (0.18 + depth * 0.04) - depth * 0.22
            let width = baseWidth * (1 - depth * 0.075)
            let height = baseHeight * (1 - depth * 0.055)
            var points: [CGPoint] = []

            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let progress = Double(index) / Double(signal.left.count)
                let angle = progress * .pi * 2
                let left = Double(signal.left[index])
                let right = Double(signal.right[index])
                let stereo = left * 0.58 + right * 0.42
                let difference = left - right
                let envelope = 1 + abs(stereo) * profile.amplitude * response * 0.20
                let x = sin(angle + echoPhase) * width * envelope
                let y = sin(angle * 2) * height * (1 + difference * 0.075 * response)
                    + sin(angle * 3 - phase * 0.22) * Double(size.height) * 0.010
                points.append(CGPoint(
                    x: center.x + CGFloat(x),
                    y: center.y + CGFloat(y + (depth - 0.5) * Double(size.height) * 0.012)
                ))
            }

            let opacity = echo == 0 ? 0.92 : 0.34 - depth * 0.15
            trace(smooth(points, closed: true), &context, opacity, echo == 0 ? 1.35 : 0.70)
        }

        // A quiet waveform through the centre ties the symbol directly to the current sound.
        var spine: [CGPoint] = []
        for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
            let progress = Double(index) / Double(signal.left.count - 1)
            let stereo = Double(signal.left[index]) * 0.5 + Double(signal.right[index]) * 0.5
            let fade = pow(sin(progress * .pi), 0.72)
            let x = Double(size.width) * (0.18 + progress * 0.64)
            let y = Double(center.y) + stereo * fade * profile.amplitude * response * Double(size.height) * 0.22
            spine.append(CGPoint(x: x, y: y))
        }
        trace(smooth(spine), &context, 0.68, 0.82)

        // Four tape-guide points brighten with bass without flashing or jumping.
        for marker in 0..<4 {
            let angle = phase * 0.16 + Double(marker) * .pi / 2
            let x = center.x + CGFloat(cos(angle)) * size.width * 0.305
            let y = center.y + CGFloat(sin(angle)) * size.height * 0.225
            let radius = CGFloat(1.5 + bass * 2.2)
            context.fill(
                Path(ellipseIn: CGRect(x: x - radius, y: y - radius, width: radius * 2, height: radius * 2)),
                with: .color(AuralisTheme.phosphor.opacity(0.42 + bass * 0.38))
            )
        }
    }

    private func orbitWeave(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        for orbit in 0..<profile.layers {
            let depth = Double(orbit) / Double(max(1, profile.layers - 1))
            let radiusX = size.width * CGFloat(0.18 + depth * 0.15 * profile.spread)
            let radiusY = size.height * CGFloat(0.08 + depth * 0.13 * profile.spread)
            let tilt = phase * (orbit.isMultiple(of: 2) ? 0.16 : -0.12) + Double(orbit) * .pi / Double(max(2, profile.layers))
            var points: [CGPoint] = []
            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let f = Double(index) / Double(signal.left.count)
                let angle = f * .pi * 2
                let audio = Double(signal.left[index]) * 0.55 + Double(signal.right[index]) * 0.45
                let x0 = cos(angle) * Double(radiusX) * (1 + abs(audio) * profile.amplitude * response * 0.22)
                let y0 = sin(angle) * Double(radiusY) * (1 + audio * profile.amplitude * response * 0.20)
                let x = x0 * cos(tilt) - y0 * sin(tilt)
                let y = x0 * sin(tilt) + y0 * cos(tilt)
                points.append(CGPoint(x: center.x + CGFloat(x), y: center.y + CGFloat(y)))
            }
            trace(smooth(points, closed: true), &context, 0.78 - depth * 0.42, orbit == 0 ? 1.2 : 0.72)
        }
    }

    private func hourglass(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        for layer in 0..<profile.layers {
            let depth = Double(layer) / Double(max(1, profile.layers - 1))
            var upper: [CGPoint] = []
            var lower: [CGPoint] = []
            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let f = Double(index) / Double(signal.left.count - 1)
                let audio = Double(signal.left[index]) * 0.55 + Double(signal.right[index]) * 0.45
                let waist = 0.10 + abs(f - 0.5) * (0.54 + depth * 0.13)
                let shimmer = sin(f * .pi * Double(profile.lobes) + phase + depth) * 0.014
                let displacement = waist + shimmer + abs(audio) * profile.amplitude * response * 0.11
                let x = CGFloat(f) * size.width
                upper.append(CGPoint(x: x, y: size.height * CGFloat(0.5 - displacement)))
                lower.append(CGPoint(x: x, y: size.height * CGFloat(0.5 + displacement)))
            }
            trace(smooth(upper), &context, 0.74 - depth * 0.38, layer == 0 ? 1.15 : 0.68)
            trace(smooth(lower), &context, 0.74 - depth * 0.38, layer == 0 ? 1.15 : 0.68)
        }
    }

    private func skyline(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        let columns = max(14, profile.layers * 3)
        let baseline = size.height * 0.58
        let columnWidth = size.width / CGFloat(columns) * 0.56
        for column in 0..<columns {
            let index = min(signal.left.count - 1, column * signal.left.count / columns)
            let audio = abs(Double(signal.left[index]) * 0.58 + Double(signal.right[index]) * 0.42)
            let rhythm = (sin(phase + Double(column) * 1.37) + 1) * 0.5
            let height = size.height * CGFloat(0.05 + audio * profile.amplitude * response * 0.46 + rhythm * 0.025)
            let x = CGFloat(column) * size.width / CGFloat(columns) + columnWidth * 0.4
            let bar = CGRect(x: x, y: baseline - height, width: columnWidth, height: height)
            context.fill(Path(roundedRect: bar, cornerRadius: columnWidth * 0.45), with: .color(AuralisTheme.phosphor.opacity(0.32 + audio * 0.62)))
            let reflection = CGRect(x: x, y: baseline + 3, width: columnWidth, height: height * 0.34)
            context.fill(Path(roundedRect: reflection, cornerRadius: columnWidth * 0.45), with: .color(AuralisTheme.phosphorDim.opacity(0.08 + audio * 0.12)))
        }
        var horizon = Path(); horizon.move(to: CGPoint(x: 0, y: baseline)); horizon.addLine(to: CGPoint(x: size.width, y: baseline))
        trace(horizon, &context, 0.46, 0.75)
    }

    private func waveGrid(_ context: inout GraphicsContext, _ size: CGSize, _ phase: Double, _ response: Double) {
        for row in 0..<profile.layers {
            let depth = Double(row) / Double(max(1, profile.layers - 1))
            var points: [CGPoint] = []
            for index in stride(from: 0, to: signal.left.count, by: samplingStep) {
                let f = Double(index) / Double(signal.left.count - 1)
                let audio = Double(signal.left[index]) * (1 - depth) + Double(signal.right[index]) * depth
                let carrier = sin(f * .pi * Double(profile.lobes) + phase + depth * 3.4) * 0.025
                let y = 0.18 + depth * 0.64 + carrier + audio * profile.amplitude * response * 0.09
                points.append(CGPoint(x: CGFloat(f) * size.width, y: CGFloat(y) * size.height))
            }
            trace(smooth(points), &context, 0.62 - depth * 0.23, row == profile.layers / 2 ? 1.0 : 0.62)
        }
        for column in 1..<profile.lobes {
            let x = size.width * CGFloat(Double(column) / Double(profile.lobes))
            var line = Path(); line.move(to: CGPoint(x: x, y: size.height * 0.16)); line.addLine(to: CGPoint(x: x, y: size.height * 0.84))
            context.stroke(line, with: .color(AuralisTheme.phosphorDim.opacity(0.10)), lineWidth: 0.55)
        }
    }

    private func trace(_ path: Path, _ context: inout GraphicsContext, _ opacity: Double, _ width: CGFloat) {
        context.stroke(path, with: .color(AuralisTheme.phosphor.opacity(opacity * profile.glow * 0.38)), style: StrokeStyle(lineWidth: width + CGFloat(profile.glow * 4), lineCap: .round, lineJoin: .round))
        context.stroke(path, with: .color(AuralisTheme.phosphor.opacity(opacity)), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

    private func smooth(_ points: [CGPoint], closed: Bool = false) -> Path {
        guard points.count > 2 else { return Path() }
        func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint { CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2) }
        var path = Path()
        if closed {
            path.move(to: midpoint(points[points.count - 1], points[0]))
            for index in points.indices {
                let next = points[(index + 1) % points.count]
                path.addQuadCurve(to: midpoint(points[index], next), control: points[index])
            }
            path.closeSubpath()
        } else {
            path.move(to: points[0])
            for index in 1..<points.count {
                path.addQuadCurve(to: midpoint(points[index - 1], points[index]), control: points[index - 1])
            }
            path.addLine(to: points[points.count - 1])
        }
        return path
    }
}

private struct VisualizerTimeReadout: View {
    @ObservedObject var clock: PlaybackClock
    let album: String

    var body: some View {
        HStack {
            Text(clock.currentTime.preciseClockString)
            Spacer()
            Text(album.uppercased())
            Spacer()
            Text("−\(max(0, clock.duration - clock.currentTime).preciseClockString)")
        }
        .font(.system(size: 8, weight: .bold, design: .monospaced))
        .opacity(0.58)
    }
}

/// Hand-authored looping scenes for the bundled library. Motion is driven by the
/// playback clock, so every scene pauses and seeks with its song without running
/// a separate display timer.
@MainActor
struct TrackAnimationView: View {
    let signal: VisualizerState
    let clock: PlaybackClock
    let track: Track?
    let active: Bool

    private var program: SongVisualProgram { SongVisualProgram(track: track) }

    var body: some View {
        let scene = program
        let emotion = EmotionalVisualProfile(track: track, scene: scene.scene)
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(RadialGradient(
                    colors: [Color(red: 0.034, green: 0.060, blue: 0.031), Color(red: 0.010, green: 0.017, blue: 0.009)],
                    center: .center, startRadius: 10, endRadius: 520
                ))
            GeometryReader { proxy in
                let side = min(proxy.size.width * 0.54, proxy.size.height * 0.60)
                EmotionalSignalCanvas(signal: signal, profile: emotion, active: active)
                    .frame(width: side, height: side)
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2 + 4)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
            crtOverlay
            VStack(spacing: 2) {
                Text(track?.artist.uppercased() ?? "AFTERTONE").font(.system(size: 13, weight: .black, design: .monospaced)).tracking(1.5)
                Text(track.map { "\($0.title.uppercased())  ·  \(emotion.feeling)" } ?? "NO TAPE LOADED")
                    .font(.system(size: 8, weight: .bold, design: .monospaced)).tracking(1).opacity(0.62)
                Spacer()
                VisualizerTimeReadout(clock: clock, album: track?.album ?? "NO ALBUM")
            }
            .foregroundStyle(scene.palette.ink).padding(.horizontal, 29).padding(.vertical, 23).allowsHitTesting(false)
            if track == nil {
                VStack(spacing: 8) {
                    Text("NO SIGNAL").font(.system(size: 15, weight: .black, design: .monospaced)).tracking(2)
                    Text("SELECT A TRACK TO LOAD ITS EMOTIVE PROFILE").font(.system(size: 8, weight: .bold, design: .monospaced)).tracking(1).opacity(0.5)
                }.foregroundStyle(AuralisTheme.phosphor)
            }
            RoundedRectangle(cornerRadius: 22).fill(LinearGradient(colors: [.white.opacity(0.035), .clear, .black.opacity(0.22)], startPoint: .topLeading, endPoint: .bottomTrailing)).blendMode(.screen).allowsHitTesting(false)
            RoundedRectangle(cornerRadius: 22).fill(RadialGradient(colors: [.clear, .black.opacity(0.46)], center: .center, startRadius: 150, endRadius: 560)).allowsHitTesting(false)
            RoundedRectangle(cornerRadius: 22).stroke(.black.opacity(0.92), lineWidth: 13).shadow(color: .black.opacity(0.95), radius: 10).allowsHitTesting(false)
        }
        .aspectRatio(1.34, contentMode: .fit)
        .accessibilityLabel("Emotion-responsive music visualizer for \(track?.title ?? "the selected track")")
    }

    private var crtOverlay: some View {
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
        }.clipShape(RoundedRectangle(cornerRadius: 22)).allowsHitTesting(false)
    }

    private func draw(scene: SongVisualProgram, context: inout GraphicsContext, size: CGSize, time: Double) {
        guard track != nil else { return }
        let pulse = Double(signal.bassPulse), level = Double(signal.level)
        switch scene.scene {
        case .letterHome: letterHome(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .les: les(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .stressRelief: stressRelief(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .harvey: harvey(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .hotelRoom: hotelRoom(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .petal: petal(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .doubt: doubt(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .sweaterWeather: sweaterWeather(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .diamonds: diamonds(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .hipsDontLie: hipsDontLie(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .chantaje: chantaje(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .forgottenMemory: forgottenMemory(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .leanOn: leanOn(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .swimmingPools: swimmingPools(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .janice: janice(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .legendaryLovers: legendaryLovers(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .kissMeMore: kissMeMore(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .ivy: ivy(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .flatline: flatline(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .confident: confident(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .americanWedding: americanWedding(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .heartbeat: heartbeat(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .teenSpirit: teenSpirit(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .soHigh: soHigh(context: &context, size: size, time: time, p: scene.palette, level: level)
        case .heartShapedBox: heartShapedBox(context: &context, size: size, time: time, p: scene.palette, pulse: pulse)
        case .cassette: cassette(context: &context, size: size, time: time, p: scene.palette, level: level)
        }
    }

    // MARK: - Twenty-five art-directed song loops

    private func letterHome(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        dust(&context, size, time, p.ink, 28, 7)
        let bob = CGFloat(sin(time * 0.55) * 8)
        let paper = CGRect(x: size.width * 0.34, y: size.height * 0.22 + bob, width: size.width * 0.32, height: size.height * 0.54)
        context.fill(Path(roundedRect: paper, cornerRadius: 3), with: .color(p.paper.opacity(0.84)))
        context.stroke(Path(roundedRect: paper, cornerRadius: 3), with: .color(p.ink.opacity(0.5)), lineWidth: 1)
        for row in 0..<8 { let y = paper.minY + 54 + CGFloat(row) * 18; line(&context, CGPoint(x: paper.minX + 24, y: y), CGPoint(x: paper.maxX - CGFloat(row % 3) * 13 - 24, y: y), p.back.opacity(0.55), 1) }
        circle(&context, CGPoint(x: paper.midX, y: paper.maxY - 31), CGFloat(14 + pulse * 3), p.accent.opacity(0.72))
    }

    private func les(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        city(&context, size, time * 0.22, p, 0.70)
        let window = CGRect(x: size.width * 0.18, y: size.height * 0.18, width: size.width * 0.64, height: size.height * 0.57)
        context.stroke(Path(roundedRect: window, cornerRadius: 14), with: .color(p.ink.opacity(0.62)), lineWidth: 5)
        line(&context, CGPoint(x: window.midX, y: window.minY), CGPoint(x: window.midX, y: window.maxY), p.ink.opacity(0.35), 3)
        silhouette(&context, CGPoint(x: size.width * 0.42, y: size.height * 0.62), 1 + level * 0.04, p.back.opacity(0.88))
        silhouette(&context, CGPoint(x: size.width * 0.58, y: size.height * 0.62), 0.94 + level * 0.04, p.back.opacity(0.88))
    }

    private func stressRelief(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        // Keep the entire illustration within the footprint of the old full-size
        // visualizer, leaving the surrounding CRT field deliberately still.
        let stageWidth = min(size.width * 0.50, size.height * 0.82)
        let stageHeight = stageWidth * 0.60
        let stage = CGRect(
            x: (size.width - stageWidth) / 2,
            y: (size.height - stageHeight) / 2 + 8,
            width: stageWidth,
            height: stageHeight
        )
        let ground = stage.maxY - stage.height * 0.22
        var scene = context
        scene.clip(to: Path(stage.insetBy(dx: -8, dy: -8)))

        // Two quiet skyline layers move at different rates for depth, but the
        // camera and car remain fixed.
        for layer in 0..<2 {
            var skyline = Path()
            let segment = stage.width / CGFloat(layer == 0 ? 11 : 8)
            let speed = layer == 0 ? 3.8 : 7.0
            let baseline = ground - CGFloat(layer) * 7
            skyline.move(to: CGPoint(x: stage.minX, y: baseline))
            for index in 0...14 {
                let rawX = stage.minX + CGFloat(index) * segment - CGFloat(time * speed).truncatingRemainder(dividingBy: segment)
                let height = stage.height * CGFloat(0.10 + noise(index + layer * 20, 41) * (layer == 0 ? 0.16 : 0.23))
                skyline.addLine(to: CGPoint(x: rawX, y: baseline - height))
                skyline.addLine(to: CGPoint(x: rawX + segment * 0.72, y: baseline - height))
                skyline.addLine(to: CGPoint(x: rawX + segment * 0.72, y: baseline))
            }
            scene.stroke(skyline, with: .color(p.ink.opacity(layer == 0 ? 0.075 : 0.12)), lineWidth: layer == 0 ? 0.75 : 1)
        }

        // Proper slow rain: long-lived drops, almost vertical, with three depth
        // bands. Each drop takes roughly 8–18 seconds to cross the scene.
        for index in 0..<38 {
            let depth = 0.35 + noise(index, 72) * 0.65
            let fall = (noise(index, 23) + time * (0.055 + depth * 0.060)).truncatingRemainder(dividingBy: 1)
            let sway = sin(time * 0.14 + Double(index) * 0.63) * (1.2 + depth * 1.8)
            let x = stage.minX + stage.width * CGFloat(noise(index, 11)) + CGFloat(sway)
            let y = stage.minY + stage.height * CGFloat(fall)
            let length = CGFloat(4.5 + depth * 8.5)
            var drop = Path()
            drop.move(to: CGPoint(x: x, y: y - length))
            drop.addQuadCurve(
                to: CGPoint(x: x + CGFloat(0.7 + depth), y: y),
                control: CGPoint(x: x + CGFloat(sway * 0.12), y: y - length * 0.48)
            )
            scene.stroke(drop, with: .color(p.ink.opacity(0.07 + depth * 0.16)), style: StrokeStyle(lineWidth: CGFloat(0.45 + depth * 0.55), lineCap: .round))
        }

        // Passing lamps are sparse and slow; their reflections stretch briefly
        // across the wet road instead of appearing as floating dots.
        for lamp in 0..<3 {
            let spacing = stage.width / 2
            var x = stage.minX + CGFloat(lamp) * spacing - CGFloat(time * 13).truncatingRemainder(dividingBy: spacing)
            if x < stage.minX - 24 { x += stage.width + spacing }
            let top = ground - stage.height * 0.42
            line(&scene, CGPoint(x: x, y: top), CGPoint(x: x, y: ground), p.ink.opacity(0.14), 0.9)
            var arm = Path(); arm.move(to: CGPoint(x: x, y: top)); arm.addQuadCurve(to: CGPoint(x: x + 18, y: top + 10), control: CGPoint(x: x + 16, y: top))
            scene.stroke(arm, with: .color(p.ink.opacity(0.18)), lineWidth: 0.9)
            circle(&scene, CGPoint(x: x + 18, y: top + 12), CGFloat(1.7 + pulse * 0.9), p.ink.opacity(0.28 + pulse * 0.12))
            let reflection = CGRect(x: x + 14, y: ground + 9, width: 8, height: stage.height * 0.15)
            scene.fill(Path(ellipseIn: reflection), with: .color(p.ink.opacity(0.025 + pulse * 0.025)))
        }

        line(&scene, CGPoint(x: stage.minX, y: ground), CGPoint(x: stage.maxX, y: ground), p.ink.opacity(0.24), 1)
        for dash in 0..<6 {
            let spacing = stage.width / 4
            var x = stage.minX + CGFloat(dash) * spacing - CGFloat(time * 24).truncatingRemainder(dividingBy: spacing)
            if x < stage.minX - 30 { x += stage.width + spacing }
            line(&scene, CGPoint(x: x, y: ground + stage.height * 0.13), CGPoint(x: x + stage.width * 0.075, y: ground + stage.height * 0.13), p.ink.opacity(0.21), 1.2)
        }

        let scale = stage.width / 620
        let bob = CGFloat(sin(time * 1.25) * 0.55)
        let carCenter = CGPoint(x: stage.midX, y: ground - 14 * scale + bob)
        var car = Path()
        car.move(to: CGPoint(x: carCenter.x - 114 * scale, y: carCenter.y + 3 * scale))
        car.addQuadCurve(to: CGPoint(x: carCenter.x - 82 * scale, y: carCenter.y - 18 * scale), control: CGPoint(x: carCenter.x - 105 * scale, y: carCenter.y - 10 * scale))
        car.addLine(to: CGPoint(x: carCenter.x - 35 * scale, y: carCenter.y - 47 * scale))
        car.addQuadCurve(to: CGPoint(x: carCenter.x + 37 * scale, y: carCenter.y - 47 * scale), control: CGPoint(x: carCenter.x, y: carCenter.y - 55 * scale))
        car.addLine(to: CGPoint(x: carCenter.x + 75 * scale, y: carCenter.y - 18 * scale))
        car.addQuadCurve(to: CGPoint(x: carCenter.x + 116 * scale, y: carCenter.y + 6 * scale), control: CGPoint(x: carCenter.x + 108 * scale, y: carCenter.y - 7 * scale))
        car.addLine(to: CGPoint(x: carCenter.x + 108 * scale, y: carCenter.y + 21 * scale))
        car.addLine(to: CGPoint(x: carCenter.x - 107 * scale, y: carCenter.y + 21 * scale))
        car.addQuadCurve(to: CGPoint(x: carCenter.x - 114 * scale, y: carCenter.y + 3 * scale), control: CGPoint(x: carCenter.x - 120 * scale, y: carCenter.y + 15 * scale))
        scene.fill(car, with: .color(p.back.opacity(0.98)))
        scene.stroke(car, with: .color(p.ink.opacity(0.72)), style: StrokeStyle(lineWidth: 1.55, lineCap: .round, lineJoin: .round))

        let window = Path { path in
            path.move(to: CGPoint(x: carCenter.x - 31 * scale, y: carCenter.y - 41 * scale))
            path.addLine(to: CGPoint(x: carCenter.x - 65 * scale, y: carCenter.y - 21 * scale))
            path.addLine(to: CGPoint(x: carCenter.x + 61 * scale, y: carCenter.y - 21 * scale))
            path.addLine(to: CGPoint(x: carCenter.x + 33 * scale, y: carCenter.y - 41 * scale))
            path.closeSubpath()
        }
        scene.fill(window, with: .color(p.ink.opacity(0.035)))
        scene.stroke(window, with: .color(p.ink.opacity(0.40)), lineWidth: 1)
        line(&scene, CGPoint(x: carCenter.x + 2 * scale, y: carCenter.y - 43 * scale), CGPoint(x: carCenter.x + 2 * scale, y: carCenter.y - 21 * scale), p.ink.opacity(0.31), 0.9)

        // A restrained driver silhouette, door seam, mirror, and handles make the
        // drawing feel authored without cluttering the tiny composition.
        circle(&scene, CGPoint(x: carCenter.x + 25 * scale, y: carCenter.y - 33 * scale), 5.2 * scale, p.ink.opacity(0.20))
        var shoulder = Path(); shoulder.move(to: CGPoint(x: carCenter.x + 13 * scale, y: carCenter.y - 22 * scale)); shoulder.addQuadCurve(to: CGPoint(x: carCenter.x + 44 * scale, y: carCenter.y - 22 * scale), control: CGPoint(x: carCenter.x + 27 * scale, y: carCenter.y - 36 * scale)); scene.stroke(shoulder, with: .color(p.ink.opacity(0.17)), lineWidth: 1)
        line(&scene, CGPoint(x: carCenter.x + 2 * scale, y: carCenter.y - 17 * scale), CGPoint(x: carCenter.x + 2 * scale, y: carCenter.y + 17 * scale), p.ink.opacity(0.22), 0.8)
        line(&scene, CGPoint(x: carCenter.x + 19 * scale, y: carCenter.y - 8 * scale), CGPoint(x: carCenter.x + 35 * scale, y: carCenter.y - 8 * scale), p.ink.opacity(0.28), 0.9)
        let mirror = Path(ellipseIn: CGRect(x: carCenter.x + 66 * scale, y: carCenter.y - 23 * scale, width: 13 * scale, height: 6 * scale)); scene.stroke(mirror, with: .color(p.ink.opacity(0.36)), lineWidth: 0.9)

        for wheelX in [carCenter.x - 70 * scale, carCenter.x + 73 * scale] {
            circle(&scene, CGPoint(x: wheelX, y: carCenter.y + 21 * scale), 17 * scale, p.back)
            scene.stroke(Path(ellipseIn: CGRect(x: wheelX - 17 * scale, y: carCenter.y + 4 * scale, width: 34 * scale, height: 34 * scale)), with: .color(p.ink.opacity(0.64)), lineWidth: 1.35)
            scene.stroke(Path(ellipseIn: CGRect(x: wheelX - 5.5 * scale, y: carCenter.y + 15.5 * scale, width: 11 * scale, height: 11 * scale)), with: .color(p.ink.opacity(0.30)), lineWidth: 0.9)
        }
        line(&scene, CGPoint(x: carCenter.x + 112 * scale, y: carCenter.y - 3 * scale), CGPoint(x: carCenter.x + (128 + CGFloat(pulse * 5)) * scale, y: carCenter.y - 5 * scale), p.ink.opacity(0.14 + pulse * 0.13), 2.2)

        // Small wet-road echoes under the car, never a full-screen effect.
        for reflection in 0..<4 {
            let phase = (time * 0.08 + Double(reflection) * 0.23).truncatingRemainder(dividingBy: 1)
            let width = stage.width * CGFloat(0.06 + phase * 0.10)
            let y = ground + stage.height * CGFloat(0.055 + Double(reflection) * 0.026)
            line(&scene, CGPoint(x: stage.midX - width, y: y), CGPoint(x: stage.midX + width, y: y), p.ink.opacity(0.09 * (1 - phase)), 0.8)
        }
    }

    private func harvey(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        circle(&context, CGPoint(x: size.width * 0.5, y: size.height * 0.42), CGFloat(72 + level * 10), p.accent.opacity(0.48))
        waves(&context, size, time, p.ink, 0.60, 7, 7 + level * 7)
        for side in [-1.0, 1.0] { let x = size.width * CGFloat(side < 0 ? 0.22 : 0.78); let crown = CGPoint(x: x + CGFloat(side * 22), y: size.height * 0.36); line(&context, CGPoint(x: x, y: size.height * 0.78), crown, p.back.opacity(0.8), 7); for leaf in 0..<6 { let a = Double(leaf) / 6 * .pi * 2 + time * 0.08; line(&context, crown, CGPoint(x: crown.x + CGFloat(cos(a) * 42), y: crown.y + CGFloat(sin(a) * 16)), p.back.opacity(0.78), 3) } }
    }

    private func hotelRoom(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        let building = CGRect(x: size.width * 0.23, y: size.height * 0.20, width: size.width * 0.54, height: size.height * 0.66)
        context.fill(Path(building), with: .color(p.paper.opacity(0.10))); context.stroke(Path(building), with: .color(p.ink.opacity(0.34)), lineWidth: 2)
        for floor in 0..<3 { for room in 0..<5 { let rect = CGRect(x: building.minX + 22 + CGFloat(room) * (building.width - 44) / 5, y: building.minY + 55 + CGFloat(floor) * 70, width: 27, height: 34); let lit = (room + floor * 2) % 4 == 0; context.fill(Path(rect), with: .color((lit ? p.accent : p.back).opacity(lit ? 0.42 + pulse * 0.18 : 0.60))) } }
        let flicker = sin(time * 5.3) > -0.84 ? 0.82 : 0.28, sign = CGRect(x: building.maxX - 35, y: building.minY + 22, width: 92, height: 30)
        context.stroke(Path(roundedRect: sign, cornerRadius: 3), with: .color(p.accent.opacity(flicker)), lineWidth: 3)
        context.draw(Text("MOTEL").font(.system(size: 11, weight: .black, design: .monospaced)).foregroundColor(p.accent.opacity(flicker)), at: CGPoint(x: sign.midX, y: sign.midY))
        rain(&context, size, time * 0.72, p.ink, 48, -8)
    }

    private func petal(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        line(&context, CGPoint(x: size.width * 0.5, y: size.height * 0.76), CGPoint(x: size.width * 0.5 - 10, y: size.height * 0.39), p.ink.opacity(0.46), 3)
        for i in 0..<18 { let q = (Double(i) / 18 + time * (0.025 + Double(i % 3) * 0.006)).truncatingRemainder(dividingBy: 1); let c = CGPoint(x: size.width * CGFloat(0.30 + noise(i, 31) * 0.40) + CGFloat(sin(time + Double(i)) * 18), y: size.height * CGFloat(0.28 + q * 0.58)); petalShape(&context, c, CGFloat(0.7 + noise(i, 8) * 0.8 + level * 0.2), time * 0.18 + Double(i), p.accent.opacity(0.38 + noise(i, 2) * 0.45)) }
    }

    private func doubt(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        let inset = size.width * 0.22
        for ring in 0..<7 { let rect = CGRect(x: inset + CGFloat(ring) * 18, y: size.height * 0.19 + CGFloat(ring) * 14, width: size.width - inset * 2 - CGFloat(ring) * 36, height: size.height * 0.62 - CGFloat(ring) * 28); context.stroke(Path(roundedRect: rect, cornerRadius: CGFloat(ring * 2)), with: .color(p.ink.opacity(0.12 + Double(ring) * 0.055)), lineWidth: 2); if ring == 3 { context.fill(Path(CGRect(x: rect.midX - 8, y: rect.minY - 3, width: 16, height: 7)), with: .color(p.back)) } }
        let a = time * 0.32; circle(&context, CGPoint(x: size.width / 2 + CGFloat(cos(a)) * size.width * 0.16, y: size.height / 2 + CGFloat(sin(a * 1.7)) * size.height * 0.19), CGFloat(5 + pulse * 7), p.accent.opacity(0.8))
    }

    private func sweaterWeather(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        let y = size.height * 0.35; var cord = Path(); cord.move(to: CGPoint(x: 0, y: y)); cord.addQuadCurve(to: CGPoint(x: size.width, y: y), control: CGPoint(x: size.width / 2, y: y + 28 + CGFloat(level * 8))); context.stroke(cord, with: .color(p.ink.opacity(0.58)), lineWidth: 2)
        let sway = CGFloat(sin(time * 0.55) * 7), sweater = CGRect(x: size.width * 0.40 + sway, y: y + 20, width: size.width * 0.20, height: size.height * 0.29)
        context.fill(Path(roundedRect: sweater, cornerRadius: 12), with: .color(p.paper.opacity(0.36))); context.stroke(Path(roundedRect: sweater, cornerRadius: 12), with: .color(p.ink.opacity(0.45)), lineWidth: 2)
        for i in 0..<36 { let q = (noise(i, 17) + time * 0.035).truncatingRemainder(dividingBy: 1); circle(&context, CGPoint(x: size.width * CGFloat(noise(i, 9)), y: size.height * CGFloat(q)), 1.2, p.ink.opacity(0.3)) }
    }

    private func diamonds(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        for i in 0..<27 { let a = noise(i, 3) * .pi * 2 + time * (0.06 + noise(i, 5) * 0.10), r = CGFloat(24 + noise(i, 7) * Double(min(size.width, size.height)) * 0.42), c = CGPoint(x: size.width / 2 + cos(a) * r, y: size.height / 2 + sin(a) * r * 0.68); diamond(&context, c, CGFloat(3 + noise(i, 11) * 10 + pulse * 3), p.ink.opacity(0.25 + noise(i, 13) * 0.65)) }
    }

    private func hipsDontLie(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        for ribbon in 0..<7 { var path = Path(); for point in 0...90 { let f = Double(point) / 90, q = CGPoint(x: size.width * CGFloat(0.15 + f * 0.70), y: size.height * CGFloat(0.50 + sin(f * .pi * 3 + time * 1.05 + Double(ribbon) * 0.65) * (0.06 + level * 0.08) + (Double(ribbon) - 3) * 0.035)); point == 0 ? path.move(to: q) : path.addLine(to: q) }; context.stroke(path, with: .color((ribbon.isMultiple(of: 2) ? p.accent : p.ink).opacity(0.30 + level * 0.45)), lineWidth: 2) }
        silhouette(&context, CGPoint(x: size.width * 0.50, y: size.height * 0.65), 1.2, p.back.opacity(0.65))
    }

    private func chantaje(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        let c = CGPoint(x: size.width / 2, y: size.height / 2); circle(&context, c, min(size.width, size.height) * 0.23, p.paper.opacity(0.10))
        for i in 0..<2 { let a = time * (i == 0 ? 0.42 : -0.31) + Double(i) * .pi, q = CGPoint(x: c.x + CGFloat(cos(a)) * size.width * 0.24, y: c.y + CGFloat(sin(a)) * size.height * 0.18); circle(&context, q, CGFloat(8 + pulse * 5), (i == 0 ? p.accent : p.ink).opacity(0.72)) }
        for ring in 0..<4 { let rect = CGRect(x: c.x - CGFloat(65 + ring * 28), y: c.y - CGFloat(42 + ring * 18), width: CGFloat(130 + ring * 56), height: CGFloat(84 + ring * 36)); context.stroke(Path(ellipseIn: rect), with: .color(p.ink.opacity(0.11)), lineWidth: 1) }
    }

    private func forgottenMemory(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        for i in 0..<9 { let q = (noise(i, 21) + time * (0.018 + noise(i, 4) * 0.02)).truncatingRemainder(dividingBy: 1), x = size.width * CGFloat(0.16 + noise(i, 12) * 0.68) + CGFloat(sin(time * 0.4 + Double(i)) * 12), y = size.height * CGFloat(0.82 - q * 0.64), rect = CGRect(x: x - 27, y: y - 32, width: 54, height: 64); context.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(p.paper.opacity(0.18 + level * 0.15))); context.stroke(Path(roundedRect: rect, cornerRadius: 2), with: .color(p.ink.opacity(0.32)), lineWidth: 1); context.fill(Path(CGRect(x: rect.minX + 6, y: rect.minY + 6, width: rect.width - 12, height: 37)), with: .color(p.back.opacity(0.72))) }
    }

    private func leanOn(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        for arch in 0..<5 { let rect = CGRect(x: size.width * 0.12 + CGFloat(arch) * size.width * 0.16, y: size.height * 0.33, width: size.width * 0.12, height: size.height * 0.48); context.stroke(Path(roundedRect: rect, cornerRadius: rect.width / 2), with: .color(p.ink.opacity(0.18 + Double(arch) * 0.07)), lineWidth: 3); let sway = CGFloat(sin(time * 0.7 + Double(arch)) * 8); line(&context, CGPoint(x: rect.midX, y: rect.minY), CGPoint(x: rect.midX + sway, y: rect.minY + 72), p.ink.opacity(0.4), 1); circle(&context, CGPoint(x: rect.midX + sway, y: rect.minY + 80), CGFloat(6 + pulse * 4), p.accent.opacity(0.48 + pulse * 0.3)) }
    }

    private func swimmingPools(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        for x in stride(from: CGFloat(0), through: size.width, by: 54) { line(&context, CGPoint(x: x, y: 0), CGPoint(x: x, y: size.height), p.ink.opacity(0.07), 1) }; for y in stride(from: CGFloat(0), through: size.height, by: 42) { line(&context, CGPoint(x: 0, y: y), CGPoint(x: size.width, y: y), p.ink.opacity(0.07), 1) }
        waves(&context, size, time * 0.42, p.ink, 0.30, 6, 10 + level * 10)
        for i in 0..<20 { let q = (noise(i, 6) + time * (0.018 + noise(i, 8) * 0.025)).truncatingRemainder(dividingBy: 1), c = CGPoint(x: size.width * CGFloat(noise(i, 4)), y: size.height * CGFloat(0.84 - q * 0.66)); context.stroke(Path(ellipseIn: CGRect(x: c.x - 3, y: c.y - 3, width: 6, height: 6)), with: .color(p.ink.opacity(0.25 + level * 0.3)), lineWidth: 1) }
    }

    private func janice(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        let phone = CGRect(x: size.width * 0.38, y: size.height * 0.17, width: size.width * 0.24, height: size.height * 0.66); context.fill(Path(roundedRect: phone, cornerRadius: 18), with: .color(.black.opacity(0.62))); context.stroke(Path(roundedRect: phone, cornerRadius: 18), with: .color(p.ink.opacity(0.45)), lineWidth: 3)
        for row in 0..<6 { let jitter = CGFloat(sin(time * 9 + Double(row)) * pulse * 9), bubble = CGRect(x: phone.minX + 16 + jitter, y: phone.minY + 48 + CGFloat(row) * 38, width: phone.width * CGFloat(row.isMultiple(of: 2) ? 0.64 : 0.48), height: 18); context.fill(Path(roundedRect: bubble, cornerRadius: 8), with: .color((row.isMultiple(of: 2) ? p.accent : p.ink).opacity(0.28 + pulse * 0.30))) }
        if pulse > 0.35 { for i in 0..<5 { let y = size.height * CGFloat(0.25 + noise(i, 3) * 0.5); line(&context, CGPoint(x: 0, y: y), CGPoint(x: size.width, y: y), p.accent.opacity(pulse * 0.3), CGFloat(1 + noise(i, 4) * 3)) } }
    }

    private func legendaryLovers(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        circle(&context, CGPoint(x: size.width * 0.5, y: size.height * 0.32), CGFloat(62 + level * 8), p.accent.opacity(0.30)); let floor = size.height * 0.77; line(&context, CGPoint(x: size.width * 0.16, y: floor), CGPoint(x: size.width * 0.84, y: floor), p.ink.opacity(0.55), 4)
        for column in 0..<6 { let x = size.width * CGFloat(0.22 + Double(column) * 0.112); line(&context, CGPoint(x: x, y: size.height * 0.36), CGPoint(x: x, y: floor), p.paper.opacity(0.28), 9); context.fill(Path(CGRect(x: x - 10, y: size.height * 0.34, width: 20, height: 8)), with: .color(p.ink.opacity(0.38))) }
        dust(&context, size, time * 0.5, p.ink, 20, 4)
    }

    private func kissMeMore(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        let planet = CGPoint(x: size.width * 0.5, y: size.height * 0.52); circle(&context, planet, CGFloat(70 + pulse * 8), p.paper.opacity(0.20)); context.stroke(Path(ellipseIn: CGRect(x: planet.x - 120, y: planet.y - 28, width: 240, height: 56)), with: .color(p.ink.opacity(0.42)), lineWidth: 3)
        for i in 0..<18 { let a = noise(i, 4) * .pi * 2 + time * (0.05 + noise(i, 9) * 0.08), r = CGFloat(100 + noise(i, 3) * 180), c = CGPoint(x: planet.x + cos(a) * r, y: planet.y + sin(a) * r * 0.48); petalShape(&context, c, CGFloat(0.45 + noise(i, 2) * 0.65), a, p.accent.opacity(0.35 + noise(i, 8) * 0.5)) }
    }

    private func ivy(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        let window = CGRect(x: size.width * 0.30, y: size.height * 0.18, width: size.width * 0.40, height: size.height * 0.62); context.fill(Path(window), with: .color(p.paper.opacity(0.10 + level * 0.06))); context.stroke(Path(window), with: .color(p.ink.opacity(0.42)), lineWidth: 5); line(&context, CGPoint(x: window.midX, y: window.minY), CGPoint(x: window.midX, y: window.maxY), p.ink.opacity(0.32), 3); line(&context, CGPoint(x: window.minX, y: window.midY), CGPoint(x: window.maxX, y: window.midY), p.ink.opacity(0.32), 3)
        for vine in 0..<7 { var path = Path(); for point in 0...40 { let f = Double(point) / 40, x = size.width * CGFloat((vine.isMultiple(of: 2) ? 0.21 : 0.79) + sin(f * 8 + time * 0.12 + Double(vine)) * 0.035), y = size.height * CGFloat(0.86 - f * (0.40 + noise(vine, 3) * 0.36)), c = CGPoint(x: x, y: y); point == 0 ? path.move(to: c) : path.addLine(to: c); if point % 8 == 0 { petalShape(&context, c, 0.45, f * 8, p.accent.opacity(0.30 + level * 0.22)) } }; context.stroke(path, with: .color(p.ink.opacity(0.35)), lineWidth: 2) }
    }

    private func flatline(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        let monitor = CGRect(x: size.width * 0.16, y: size.height * 0.25, width: size.width * 0.68, height: size.height * 0.47); context.fill(Path(roundedRect: monitor, cornerRadius: 8), with: .color(.black.opacity(0.52))); context.stroke(Path(roundedRect: monitor, cornerRadius: 8), with: .color(p.ink.opacity(0.34)), lineWidth: 3)
        var trace = Path(); let count = 150, sweep = (time * 0.22).truncatingRemainder(dividingBy: 1); for i in 0...count { let f = Double(i) / Double(count), local = (f - sweep + 1).truncatingRemainder(dividingBy: 1), spike = exp(-pow((local - 0.14) * 42, 2)) * sin((local - 0.14) * 100) * (0.16 + pulse * 0.18), q = CGPoint(x: monitor.minX + CGFloat(f) * monitor.width, y: monitor.midY - CGFloat(spike) * monitor.height); i == 0 ? trace.move(to: q) : trace.addLine(to: q) }; stroke(trace, &context, p.accent, 0.8, 1.5); circle(&context, CGPoint(x: monitor.maxX - 20, y: monitor.minY + 20), CGFloat(3 + pulse * 3), p.accent.opacity(0.8))
    }

    private func confident(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        let stageY = size.height * 0.76; context.fill(Path(CGRect(x: 0, y: stageY, width: size.width, height: size.height - stageY)), with: .color(.black.opacity(0.55)))
        for light in 0..<3 { let origin = CGPoint(x: size.width * CGFloat(0.25 + Double(light) * 0.25), y: size.height * 0.12), sway = CGFloat(sin(time * 0.45 + Double(light)) * 80); var beam = Path(); beam.move(to: origin); beam.addLine(to: CGPoint(x: origin.x + sway - 65, y: stageY)); beam.addLine(to: CGPoint(x: origin.x + sway + 65, y: stageY)); beam.closeSubpath(); context.fill(beam, with: .color((light == 1 ? p.accent : p.ink).opacity(0.05 + level * 0.08))) }
        silhouette(&context, CGPoint(x: size.width * 0.5, y: stageY), 1.45, p.back.opacity(0.86)); for x in [size.width * 0.16, size.width * 0.84] { context.fill(Path(CGRect(x: x - 30, y: stageY - 80, width: 60, height: 80)), with: .color(.black.opacity(0.62))); circle(&context, CGPoint(x: x, y: stageY - 53), CGFloat(13 + level * 6), p.ink.opacity(0.25)) }
    }

    private func americanWedding(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        let baseY = size.height * 0.79; var chapel = Path(); chapel.move(to: CGPoint(x: size.width * 0.31, y: baseY)); chapel.addLine(to: CGPoint(x: size.width * 0.31, y: size.height * 0.43)); chapel.addLine(to: CGPoint(x: size.width * 0.50, y: size.height * 0.25)); chapel.addLine(to: CGPoint(x: size.width * 0.69, y: size.height * 0.43)); chapel.addLine(to: CGPoint(x: size.width * 0.69, y: baseY)); chapel.closeSubpath(); context.fill(chapel, with: .color(p.paper.opacity(0.15))); context.stroke(chapel, with: .color(p.ink.opacity(0.44)), lineWidth: 2)
        let door = CGRect(x: size.width * 0.45, y: size.height * 0.57, width: size.width * 0.10, height: size.height * 0.22); context.fill(Path(roundedRect: door, cornerRadius: door.width / 2), with: .color(p.back.opacity(0.72)))
        for i in 0..<2 { let x = size.width * CGFloat(i == 0 ? 0.46 : 0.54); context.stroke(Path(ellipseIn: CGRect(x: x - 20, y: size.height * 0.34 - 20, width: 40, height: 40)), with: .color(p.accent.opacity(0.40 + pulse * 0.28)), lineWidth: 3) }
        for i in 0..<5 { let y = size.height * CGFloat((noise(i, 5) + time * 0.017).truncatingRemainder(dividingBy: 1)); line(&context, CGPoint(x: 0, y: y), CGPoint(x: size.width, y: y), p.ink.opacity(0.08), CGFloat(1 + noise(i, 2) * 2)) }
    }

    private func heartbeat(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        city(&context, size, 0, p, 0.78); let y = size.height * 0.51; var path = Path(); let count = 180, sweep = (time * 0.26).truncatingRemainder(dividingBy: 1)
        for i in 0...count { let f = Double(i) / Double(count), local = (f - sweep + 1).truncatingRemainder(dividingBy: 1), beat = exp(-pow((local - 0.18) * 50, 2)) * sin((local - 0.18) * 150) * (0.18 + level * 0.18), q = CGPoint(x: size.width * CGFloat(f), y: y - size.height * CGFloat(beat)); i == 0 ? path.move(to: q) : path.addLine(to: q) }; stroke(path, &context, p.accent, 0.9, 1.6)
    }

    private func teenSpirit(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        let floor = size.height * 0.78; context.fill(Path(CGRect(x: 0, y: floor, width: size.width, height: size.height - floor)), with: .color(.black.opacity(0.68))); let bulbX = size.width * 0.5 + CGFloat(sin(time * 0.45) * 35); line(&context, CGPoint(x: size.width * 0.5, y: 0), CGPoint(x: bulbX, y: size.height * 0.30), p.ink.opacity(0.35), 2); circle(&context, CGPoint(x: bulbX, y: size.height * 0.32), CGFloat(9 + pulse * 9), p.accent.opacity(0.35 + pulse * 0.34))
        for x in [size.width * 0.19, size.width * 0.81] { let speaker = CGRect(x: x - 54, y: floor - 126, width: 108, height: 126); context.fill(Path(speaker), with: .color(.black.opacity(0.7))); context.stroke(Path(speaker), with: .color(p.ink.opacity(0.28)), lineWidth: 2); circle(&context, CGPoint(x: x, y: floor - 82), CGFloat(25 + pulse * 7), p.ink.opacity(0.12 + pulse * 0.12)); circle(&context, CGPoint(x: x, y: floor - 30), CGFloat(12 + pulse * 4), p.ink.opacity(0.13 + pulse * 0.12)) }
        dust(&context, size, time * 1.4, p.ink, 42, 12)
    }

    private func soHigh(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        for i in 0..<12 { let q = (noise(i, 10) + time * (0.012 + noise(i, 3) * 0.012)).truncatingRemainder(dividingBy: 1), c = CGPoint(x: size.width * CGFloat(q), y: size.height * CGFloat(0.20 + noise(i, 8) * 0.55)); cloud(&context, c, CGFloat(0.55 + noise(i, 2) * 0.95), p.paper.opacity(0.12 + level * 0.10)) }
        let bob = CGFloat(sin(time * 0.38) * 12), bed = CGRect(x: size.width * 0.35, y: size.height * 0.52 + bob, width: size.width * 0.30, height: 52); context.fill(Path(roundedRect: bed, cornerRadius: 8), with: .color(p.ink.opacity(0.34))); context.fill(Path(roundedRect: CGRect(x: bed.minX + 10, y: bed.minY - 12, width: 64, height: 26), cornerRadius: 8), with: .color(p.paper.opacity(0.30)))
        for i in 0..<18 { circle(&context, CGPoint(x: size.width * CGFloat(noise(i, 4)), y: size.height * CGFloat(noise(i, 5))), CGFloat(1 + level * 2), p.accent.opacity(0.25 + noise(i, 7) * 0.35)) }
    }

    private func heartShapedBox(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, pulse: Double) {
        let c = CGPoint(x: size.width * 0.5, y: size.height * 0.52), heart = heartPath(c, CGFloat(1 + pulse * 0.035)); context.fill(heart, with: .color(p.paper.opacity(0.14))); context.stroke(heart, with: .color(p.ink.opacity(0.58)), lineWidth: 4)
        let lock = CGRect(x: c.x - 13, y: c.y + 20, width: 26, height: 30); context.fill(Path(roundedRect: lock, cornerRadius: 4), with: .color(p.accent.opacity(0.52))); circle(&context, CGPoint(x: c.x, y: c.y + 32), 3, p.back.opacity(0.85))
        for vine in 0..<5 { var path = Path(); for point in 0...45 { let f = Double(point) / 45, a = f * 5 + Double(vine) + time * 0.08, q = CGPoint(x: c.x + CGFloat((Double(vine) - 2) * 42 + sin(a) * 24), y: size.height * CGFloat(0.90 - f * 0.72)); point == 0 ? path.move(to: q) : path.addLine(to: q) }; context.stroke(path, with: .color(p.ink.opacity(0.22 + pulse * 0.12)), lineWidth: 2) }
        for i in 0..<10 { let a = noise(i, 4) * .pi * 2 + time * (0.08 + noise(i, 9) * 0.08), q = CGPoint(x: c.x + cos(a) * CGFloat(110 + noise(i, 3) * 100), y: c.y + sin(a * 1.3) * CGFloat(70 + noise(i, 8) * 50)); moth(&context, q, CGFloat(0.5 + noise(i, 2) * 0.7), p.ink.opacity(0.24 + pulse * 0.18)) }
    }

    private func cassette(context: inout GraphicsContext, size: CGSize, time: Double, p: ScenePalette, level: Double) {
        let tape = CGRect(x: size.width * 0.27, y: size.height * 0.30, width: size.width * 0.46, height: size.height * 0.40); context.fill(Path(roundedRect: tape, cornerRadius: 10), with: .color(p.paper.opacity(0.18))); context.stroke(Path(roundedRect: tape, cornerRadius: 10), with: .color(p.ink.opacity(0.45)), lineWidth: 3)
        for side in [-1.0, 1.0] { let c = CGPoint(x: tape.midX + CGFloat(side * Double(tape.width) * 0.19), y: tape.midY); context.stroke(Path(ellipseIn: CGRect(x: c.x - 26, y: c.y - 26, width: 52, height: 52)), with: .color(p.ink.opacity(0.42)), lineWidth: CGFloat(2 + level * 2)); let a = time * 1.1 * side; line(&context, c, CGPoint(x: c.x + cos(a) * 20, y: c.y + sin(a) * 20), p.accent.opacity(0.65), 2) }
    }

    // MARK: - Lightweight drawing primitives

    private func city(_ c: inout GraphicsContext, _ s: CGSize, _ time: Double, _ p: ScenePalette, _ baseline: Double) {
        for i in 0..<22 { let w = s.width / 18, x = CGFloat((Double(i) / 18 + time).truncatingRemainder(dividingBy: 1.22)) * s.width - w, h = s.height * CGFloat(0.10 + noise(i, 2) * 0.30), r = CGRect(x: x, y: s.height * baseline - h, width: w + 2, height: h); c.fill(Path(r), with: .color(p.paper.opacity(0.11 + noise(i, 7) * 0.12))); for floor in 0..<5 where noise(i * 7 + floor, 6) > 0.48 { circle(&c, CGPoint(x: r.midX, y: r.minY + 12 + CGFloat(floor) * 15), 1.5, p.accent.opacity(0.36)) } }
    }
    private func rain(_ c: inout GraphicsContext, _ s: CGSize, _ time: Double, _ color: Color, _ count: Int, _ slant: CGFloat) { for i in 0..<count { let q = (noise(i, 2) + time * (0.13 + noise(i, 7) * 0.12)).truncatingRemainder(dividingBy: 1), x = s.width * CGFloat(noise(i, 3)), y = s.height * CGFloat(q); line(&c, CGPoint(x: x, y: y), CGPoint(x: x + slant, y: y + CGFloat(12 + noise(i, 4) * 26)), color.opacity(0.12 + noise(i, 9) * 0.22), 1) } }
    private func dust(_ c: inout GraphicsContext, _ s: CGSize, _ time: Double, _ color: Color, _ count: Int, _ drift: Double) { for i in 0..<count { let x = s.width * CGFloat((noise(i, 3) + sin(time * 0.1 + Double(i)) * 0.015).truncatingRemainder(dividingBy: 1)), y = s.height * CGFloat((noise(i, 5) + time * 0.006 * drift).truncatingRemainder(dividingBy: 1)); circle(&c, CGPoint(x: x, y: y), CGFloat(0.7 + noise(i, 8) * 1.7), color.opacity(0.12 + noise(i, 2) * 0.20)) } }
    private func waves(_ c: inout GraphicsContext, _ s: CGSize, _ time: Double, _ color: Color, _ start: Double, _ rows: Int, _ amp: Double) { for row in 0..<rows { var path = Path(); for point in 0...90 { let f = Double(point) / 90, q = CGPoint(x: s.width * CGFloat(f), y: s.height * CGFloat(start + Double(row) * 0.045) + CGFloat(sin(f * .pi * 5 + time + Double(row) * 0.6) * amp)); point == 0 ? path.move(to: q) : path.addLine(to: q) }; c.stroke(path, with: .color(color.opacity(0.16 + Double(row) * 0.035)), lineWidth: 1) } }
    private func line(_ c: inout GraphicsContext, _ a: CGPoint, _ b: CGPoint, _ color: Color, _ width: CGFloat) { var p = Path(); p.move(to: a); p.addLine(to: b); c.stroke(p, with: .color(color), lineWidth: width) }
    private func circle(_ c: inout GraphicsContext, _ center: CGPoint, _ r: CGFloat, _ color: Color) { c.fill(Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)), with: .color(color)) }
    private func stroke(_ path: Path, _ c: inout GraphicsContext, _ color: Color, _ opacity: Double, _ width: CGFloat) { c.stroke(path, with: .color(color.opacity(opacity * 0.13)), lineWidth: width + 4); c.stroke(path, with: .color(color.opacity(opacity)), lineWidth: width) }
    private func diamond(_ c: inout GraphicsContext, _ center: CGPoint, _ r: CGFloat, _ color: Color) { var p = Path(); p.move(to: CGPoint(x: center.x, y: center.y - r)); p.addLine(to: CGPoint(x: center.x + r * 0.7, y: center.y)); p.addLine(to: CGPoint(x: center.x, y: center.y + r)); p.addLine(to: CGPoint(x: center.x - r * 0.7, y: center.y)); p.closeSubpath(); c.fill(p, with: .color(color)) }
    private func silhouette(_ c: inout GraphicsContext, _ center: CGPoint, _ scale: Double, _ color: Color) { circle(&c, CGPoint(x: center.x, y: center.y - CGFloat(68 * scale)), CGFloat(14 * scale), color); c.fill(Path(roundedRect: CGRect(x: center.x - CGFloat(19 * scale), y: center.y - CGFloat(52 * scale), width: CGFloat(38 * scale), height: CGFloat(70 * scale)), cornerRadius: CGFloat(16 * scale)), with: .color(color)) }
    private func petalShape(_ c: inout GraphicsContext, _ center: CGPoint, _ scale: CGFloat, _ angle: Double, _ color: Color) { var p = Path(ellipseIn: CGRect(x: center.x - 7 * scale, y: center.y - 13 * scale, width: 14 * scale, height: 26 * scale)); p = p.applying(CGAffineTransform(translationX: center.x, y: center.y).rotated(by: angle).translatedBy(x: -center.x, y: -center.y)); c.fill(p, with: .color(color)) }
    private func cloud(_ c: inout GraphicsContext, _ center: CGPoint, _ scale: CGFloat, _ color: Color) { circle(&c, CGPoint(x: center.x - 25 * scale, y: center.y), 22 * scale, color); circle(&c, CGPoint(x: center.x, y: center.y - 10 * scale), 30 * scale, color); circle(&c, CGPoint(x: center.x + 30 * scale, y: center.y), 20 * scale, color) }
    private func moth(_ c: inout GraphicsContext, _ center: CGPoint, _ scale: CGFloat, _ color: Color) { c.fill(Path(ellipseIn: CGRect(x: center.x - 12 * scale, y: center.y - 5 * scale, width: 12 * scale, height: 10 * scale)), with: .color(color)); c.fill(Path(ellipseIn: CGRect(x: center.x, y: center.y - 5 * scale, width: 12 * scale, height: 10 * scale)), with: .color(color)) }
    private func heartPath(_ c: CGPoint, _ scale: CGFloat) -> Path { var p = Path(); p.move(to: CGPoint(x: c.x, y: c.y + 76 * scale)); p.addCurve(to: CGPoint(x: c.x - 88 * scale, y: c.y - 16 * scale), control1: CGPoint(x: c.x - 26 * scale, y: c.y + 48 * scale), control2: CGPoint(x: c.x - 88 * scale, y: c.y + 26 * scale)); p.addCurve(to: CGPoint(x: c.x, y: c.y - 60 * scale), control1: CGPoint(x: c.x - 88 * scale, y: c.y - 66 * scale), control2: CGPoint(x: c.x - 28 * scale, y: c.y - 78 * scale)); p.addCurve(to: CGPoint(x: c.x + 88 * scale, y: c.y - 16 * scale), control1: CGPoint(x: c.x + 28 * scale, y: c.y - 78 * scale), control2: CGPoint(x: c.x + 88 * scale, y: c.y - 66 * scale)); p.addCurve(to: CGPoint(x: c.x, y: c.y + 76 * scale), control1: CGPoint(x: c.x + 88 * scale, y: c.y + 26 * scale), control2: CGPoint(x: c.x + 26 * scale, y: c.y + 48 * scale)); p.closeSubpath(); return p }
    private func noise(_ index: Int, _ salt: Int) -> Double { var x = UInt64(truncatingIfNeeded: index &* 374_761_393 &+ salt &* 668_265_263); x = (x ^ (x >> 13)) &* 1_274_126_177; x ^= x >> 16; return Double(x & 0xFFFF) / 65535 }
}

private struct ScenePalette { let back: Color; let ink: Color; let accent: Color; let paper: Color; let glow: Color }

private struct SongVisualProgram {
    enum Scene: String {
        case letterHome, les, stressRelief, harvey, hotelRoom, petal, doubt, sweaterWeather, diamonds, hipsDontLie, chantaje, forgottenMemory, leanOn, swimmingPools, janice, legendaryLovers, kissMeMore, ivy, flatline, confident, americanWedding, heartbeat, teenSpirit, soHigh, heartShapedBox, cassette
        var caption: String {
            switch self {
            case .letterHome: return "UNSENT LETTER"; case .les: return "LAST TRAIN · LOWER EAST"; case .stressRelief: return "RAIN DRIVE · 2:17 AM"; case .harvey: return "FADING BOARDWALK"; case .hotelRoom: return "VACANCY · ROOM 27"; case .petal: return "FALLING PETALS"; case .doubt: return "NO EXIT"; case .sweaterWeather: return "COLD FRONT"; case .diamonds: return "NIGHT CRYSTALS"; case .hipsDontLie: return "CARNIVAL RIBBONS"; case .chantaje: return "CIRCLES AT MIDNIGHT"; case .forgottenMemory: return "LOST POLAROIDS"; case .leanOn: return "LANTERN COURTYARD"; case .swimmingPools: return "UNDERWATER TILE"; case .janice: return "MESSAGE OVERLOAD"; case .legendaryLovers: return "MOON TEMPLE"; case .kissMeMore: return "PLANET OF PETALS"; case .ivy: return "OVERGROWN WINDOW"; case .flatline: return "EMPTY MONITOR"; case .confident: return "CENTER STAGE"; case .americanWedding: return "VHS CHAPEL"; case .heartbeat: return "CITY PULSE"; case .teenSpirit: return "BASEMENT SHOW"; case .soHigh: return "FLOATING ROOM"; case .heartShapedBox: return "LOCKED GARDEN"; case .cassette: return "PRIVATE MIX TAPE"
            }
        }
    }
    let scene: Scene; let palette: ScenePalette
    init(track: Track?) {
        let t = track?.title.lowercased() ?? ""
        if t == "letter home" { scene = .letterHome } else if t == "les" { scene = .les } else if t == "stress relief" { scene = .stressRelief } else if t == "harvey" { scene = .harvey } else if t == "hotel room" { scene = .hotelRoom } else if t.contains("hate that i made you") { scene = .petal } else if t == "doubt" { scene = .doubt } else if t == "sweater weather" { scene = .sweaterWeather } else if t == "diamonds" { scene = .diamonds } else if t == "hips don't lie" { scene = .hipsDontLie } else if t == "chantaje" { scene = .chantaje } else if t.contains("can't remember to forget") { scene = .forgottenMemory } else if t == "lean on" { scene = .leanOn } else if t.contains("swimming pools") { scene = .swimmingPools } else if t == "janice stfu" { scene = .janice } else if t == "legendary lovers" { scene = .legendaryLovers } else if t == "kiss me more" { scene = .kissMeMore } else if t == "ivy" { scene = .ivy } else if t == "flatline" { scene = .flatline } else if t.contains("confident") { scene = .confident } else if t == "american wedding" { scene = .americanWedding } else if t == "heartbeat" { scene = .heartbeat } else if t == "smells like teen spirit" { scene = .teenSpirit } else if t == "so high" { scene = .soHigh } else if t == "heart-shaped box" { scene = .heartShapedBox } else { scene = .cassette }
        palette = ScenePalette(
            back: Color(red: 0.010, green: 0.017, blue: 0.009),
            ink: AuralisTheme.phosphor,
            accent: AuralisTheme.phosphor,
            paper: AuralisTheme.phosphorDim,
            glow: AuralisTheme.phosphor
        )
    }
}
