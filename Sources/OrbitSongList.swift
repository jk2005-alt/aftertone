import AppKit
import SwiftUI

/// Native momentum scrolling with a bounded pool of rows.
struct OrbitSongList: NSViewRepresentable {
    let tracks: [Track]
    let radius: CGFloat
    let center: CGPoint
    let rowWidth: CGFloat
    let library: LibraryStore
    let select: (Track) -> Void

    func makeNSView(context: Context) -> NSScrollView {
        let scroll = NSScrollView()
        scroll.drawsBackground = false
        scroll.wantsLayer = true
        scroll.contentView.wantsLayer = true
        // The orbit changes horizontal positions on every vertical scroll.
        // Retaining copied clip-view pixels produces stale positions between updates.
        scroll.contentView.copiesOnScroll = false
        scroll.hasVerticalScroller = false
        scroll.hasHorizontalScroller = false
        scroll.verticalScrollElasticity = .allowed
        scroll.horizontalScrollElasticity = .none
        let document = OrbitDocument()
        document.wantsLayer = true
        scroll.documentView = document
        scroll.contentView.postsBoundsChangedNotifications = true
        return scroll
    }

    func updateNSView(_ scroll: NSScrollView, context: Context) {
        guard let document = scroll.documentView as? OrbitDocument else { return }
        document.configure(tracks: tracks, radius: radius, center: center,
                           rowWidth: rowWidth, library: library, select: select)
    }
}

private final class OrbitDocument: NSView {
    override var isFlipped: Bool { true }
    private var tracks: [Track] = []
    private var radius: CGFloat = 1
    private var center = CGPoint.zero
    private var rowWidth: CGFloat = 1
    private let rowHeight: CGFloat = 38
    private var rows: [OrbitButton] = []
    private weak var library: LibraryStore?
    private var select: ((Track) -> Void)?
    private var observer: NSObjectProtocol?

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        if let observer { NotificationCenter.default.removeObserver(observer) }
        guard let clip = superview as? NSClipView else { return }
        observer = NotificationCenter.default.addObserver(
            forName: NSView.boundsDidChangeNotification, object: clip, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.positionRows() }
        }
    }

    deinit {
        if let observer { NotificationCenter.default.removeObserver(observer) }
    }

    func configure(tracks: [Track], radius: CGFloat, center: CGPoint, rowWidth: CGFloat,
                   library: LibraryStore, select: @escaping (Track) -> Void) {
        let changed = self.tracks != tracks
        self.tracks = tracks
        self.radius = radius
        self.center = center
        self.rowWidth = rowWidth
        self.library = library
        self.select = select
        if changed {
            for row in rows { row.reset() }
        }
        resizeDocument()
        positionRows()
    }

    private var topPadding: CGFloat { max(0, radius * 1.55 - 19) }

    override func layout() {
        super.layout()
        resizeDocument()
        positionRows()
    }

    private func resizeDocument() {
        guard let scroll = enclosingScrollView else { return }
        let size = NSSize(width: scroll.contentSize.width,
                          height: max(scroll.contentSize.height, topPadding + CGFloat(tracks.count) * rowHeight + 12))
        if frame.size != size { setFrameSize(size) }
    }

    private func offset(at y: CGFloat) -> CGFloat {
        let distance = y - center.y
        let turn = -0.8 * radius
        if distance >= turn {
            let clamped = min(abs(distance), radius)
            return center.x + sqrt(max(0, radius * radius - clamped * clamped))
        }
        let start = center.x + 0.6 * radius
        let travel = start + rowWidth + 2
        let fraction = min(1, (turn - distance) / radius)
        let slope = min(3, (4.0 / 3.0) * radius / travel)
        let progress = fraction * (slope + fraction * ((3 - 2 * slope) + fraction * (slope - 2)))
        return start - travel * progress
    }

    private func positionRows() {
        guard let scroll = enclosingScrollView, let library else { return }
        let visible = scroll.contentView.bounds
        let first = max(0, min(tracks.count, Int(floor((visible.minY - topPadding) / rowHeight)) - 1))
        let last = max(first, min(tracks.count, Int(ceil((visible.maxY - topPadding) / rowHeight)) + 1))
        let count = last - first
        while rows.count < count {
            let row = OrbitButton()
            addSubview(row)
            rows.append(row)
        }
        // Frames follow the scroll position directly, without implicit layer animations.
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        let visibleSlots = Set((first..<last).map { $0 % rows.count })
        for (slot, row) in rows.enumerated() where !visibleSlots.contains(slot) {
            row.isHidden = true
            row.reset()
        }
        for index in first..<last {
            let row = rows[index % rows.count]
            let y = topPadding + CGFloat(index) * rowHeight
            let size = NSSize(width: rowWidth, height: rowHeight)
            if row.frame.size != size {
                row.setFrameSize(size)
                row.needsDisplay = true
            }
            row.setFrameOrigin(NSPoint(x: offset(at: y + rowHeight / 2 - visible.minY), y: y))
            row.isHidden = false
            row.configure(tracks[index], library: library)
            row.onSelect = select
        }
        CATransaction.commit()
    }
}

private final class OrbitButton: NSButton {
    private var track: Track?
    private var thumbnail: NSImage?
    private var imageTask: Task<Void, Never>?
    private var titleText = NSAttributedString()
    private var artistText = NSAttributedString()
    var onSelect: ((Track) -> Void)?

    override init(frame: NSRect) {
        super.init(frame: frame)
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        isBordered = false
        title = ""
        target = self
        action = #selector(choose)
        setAccessibilityRole(.button)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override var isFlipped: Bool { true }

    func reset() {
        imageTask?.cancel()
        imageTask = nil
        track = nil
        thumbnail = nil
    }

    func configure(_ track: Track, library: LibraryStore) {
        guard self.track != track else { return }
        reset()
        self.track = track
        let color = NSColor(srgbRed: 0.99, green: 0.955, blue: 0.85, alpha: 1)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byTruncatingTail
        titleText = NSAttributedString(string: track.displayTitle, attributes: [
            .font: NSFont.systemFont(ofSize: 12.5, weight: .bold),
            .foregroundColor: color, .paragraphStyle: paragraph
        ])
        artistText = NSAttributedString(string: track.artist, attributes: [
            .font: NSFont.systemFont(ofSize: 10),
            .foregroundColor: color.withAlphaComponent(0.74), .paragraphStyle: paragraph
        ])
        setAccessibilityLabel("\(track.displayTitle), \(track.artist)")
        needsDisplay = true
        imageTask = Task { [weak self] in
            let image = await library.coverImage(for: track, thumbnail: true)
            guard !Task.isCancelled, self?.track?.id == track.id else { return }
            self?.thumbnail = image
            self?.needsDisplay = true
        }
    }

    @objc private func choose() {
        if let track { onSelect?(track) }
    }

    override func draw(_ dirtyRect: NSRect) {
        NSGraphicsContext.saveGraphicsState()
        if isHighlighted { NSGraphicsContext.current?.cgContext.setAlpha(0.65) }
        let cover = NSRect(x: 0, y: 7, width: 24, height: 24)
        NSGraphicsContext.saveGraphicsState()
        NSBezierPath(roundedRect: cover, xRadius: 3, yRadius: 3).addClip()
        thumbnail?.draw(in: cover, from: .zero, operation: .sourceOver,
                        fraction: 1, respectFlipped: true, hints: [.interpolation: NSImageInterpolation.high])
        NSGraphicsContext.restoreGraphicsState()
        titleText.draw(in: NSRect(x: 31, y: 5, width: max(0, bounds.width - 31), height: 16))
        artistText.draw(in: NSRect(x: 31, y: 21, width: max(0, bounds.width - 31), height: 13))
        NSGraphicsContext.restoreGraphicsState()
    }
}
