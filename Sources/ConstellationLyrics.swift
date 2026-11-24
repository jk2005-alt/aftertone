import SwiftUI

struct ConstellationLyrics: View {
    let lines: [LyricLine]
    let time: Double
    var showsBorder = true
    var body: some View {
        Canvas { context, size in
            let ink = AuralisTheme.phosphor
            if showsBorder {
              let edge = Path(roundedRect: CGRect(origin: .zero, size: size).insetBy(dx: 20, dy: 20), cornerRadius: 18)
            var glow = context
            glow.addFilter(.blur(radius: 9))
            glow.stroke(edge, with: .color(ink.opacity(0.4)), lineWidth: 5)
            context.stroke(edge, with: .color(ink.opacity(0.3)), lineWidth: 1)
            }
            guard let line = lines.last(where: { ($0.timestamp ?? .infinity) <= time }) else { return }
            if line.words.isEmpty {
                let text = context.resolve(Text(line.text).font(.system(size: 24, weight: .medium)).foregroundColor(ink))
                context.draw(text, in: CGRect(x: size.width * 0.15, y: size.height * 0.43, width: size.width * 0.7, height: size.height * 0.2))
                return
            }
            guard let active = line.words.lastIndex(where: { $0.timestamp <= time }) else { return }
            let group = active / 6
            let words = Array(line.words.dropFirst(group * 6).prefix(6))
            let slots = [0, 4, 2, 3, 1, 5]
            let cell = max(1, (size.width - 110) / 3)
            var points: [CGPoint] = []
            var labels: [(GraphicsContext.ResolvedText, CGRect)] = []
            for (index, word) in words.enumerated() {
                let slot = slots[(index + (line.id + group) % 6) % 6]
                let jitter = sin(Double(line.id * 17 + group * 7 + index * 11))
                let point = CGPoint(x: 55 + cell * (Double(slot % 3) + 0.5), y: size.height * (slot < 3 ? 0.34 : 0.65) + jitter * 13)
                points.append(point)
                let fontSize = min(word.id == active ? 29.0 : 17.0, cell / max(4, Double(word.text.count) * 0.61))
                let label = context.resolve(Text(word.text).font(.system(size: fontSize, weight: word.id == active ? .bold : .medium)).foregroundColor(ink))
                let measured = label.measure(in: CGSize(width: cell - 12, height: 90))
                labels.append((label, CGRect(x: point.x - measured.width / 2, y: point.y + 19, width: measured.width, height: measured.height)))
            }
            // Exclude padded text bounds from every connecting line.
            var connections = context
            var mask = Path(CGRect(origin: .zero, size: size))
            for (_, rect) in labels { mask.addRect(rect.insetBy(dx: -9, dy: -7)) }
            connections.clip(to: mask, style: FillStyle(eoFill: true))
            for index in words.indices where index > 0 && words[index].timestamp <= time {
                let progress = min(1, max(0, (time - words[index].timestamp) / 0.22))
                let from = points[index - 1], to = points[index]
                var path = Path()
                path.move(to: from)
                path.addLine(to: CGPoint(x: from.x + (to.x - from.x) * progress, y: from.y + (to.y - from.y) * progress))
                connections.stroke(path, with: .color(ink.opacity(0.38)), lineWidth: 0.8)
            }
            for index in words.indices where words[index].timestamp <= time {
                let selected = words[index].id == active
                let reveal = min(1, max(0, (time - words[index].timestamp) / 0.16))
                let radius = (selected ? 10.0 : 4.5) * reveal
                let p = points[index]
                var star = Path()
                for vertex in 0..<8 {
                    let angle = Double(vertex) * .pi / 4
                    let r = vertex.isMultiple(of: 2) ? radius : radius * 0.25
                    let q = CGPoint(x: p.x + sin(angle) * r, y: p.y + cos(angle) * r)
                    if vertex == 0 { star.move(to: q) } else { star.addLine(to: q) }
                }
                star.closeSubpath()
                var layer = context
                layer.opacity = reveal * (selected ? 1 : 0.6)
                layer.fill(star, with: .color(ink))
                layer.draw(labels[index].0, in: labels[index].1)
            }
        }
        .accessibilityLabel("Animated lyrics")
    }
}
