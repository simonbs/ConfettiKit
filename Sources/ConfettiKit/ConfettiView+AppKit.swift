#if canImport(AppKit) && !canImport(UIKit)
import AppKit

public final class ConfettiView: NSView {
    public var birthRate1: Float = 48
    public var birthRate2: Float = 20
    let mode: ConfettiMode
    let images: [CGImage]
    var confettiContainerLayer: CALayer? { layer }
    override public var isFlipped: Bool { true }

    public init(mode: ConfettiMode = .topToBottom, images: [NSImage]) {
        self.mode = mode
        self.images = images.compactMap { $0.cgImage(forProposedRect: nil, context: nil, hints: nil) }
        super.init(frame: .zero)
        wantsLayer = true
        layer?.masksToBounds = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override public func layout() {
        super.layout()
        layoutConfettiShots()
    }
}
#endif
