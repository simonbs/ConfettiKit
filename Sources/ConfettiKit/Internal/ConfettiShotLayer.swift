import QuartzCore

/// Identical foreground/background density, geometry and timing on UIKit and AppKit.
final class ConfettiShotLayer: CALayer {
    init(mode: ConfettiMode, images: [CGImage], birthRate1: Float, birthRate2: Float) {
        super.init()
        let background = ConfettiEmitterLayer(mode: mode, images: images, birthRate: birthRate1, scale: 0.6, speed: 0.95)
        let foreground = ConfettiEmitterLayer(mode: mode, images: images, birthRate: birthRate2, scale: 0.8, scaleRange: 0.1)
        background.opacity = 0.5
        addSublayer(background)
        addSublayer(foreground)
    }

    override init(layer: Any) { super.init(layer: layer) }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSublayers() {
        super.layoutSublayers()
        for case let emitter as ConfettiEmitterLayer in sublayers ?? [] {
            emitter.updateGeometry(in: bounds)
        }
    }

    func start() {
        setNeedsLayout()
        layoutIfNeeded()
        for case let emitter as ConfettiEmitterLayer in sublayers ?? [] {
            emitter.addAnimations()
        }
    }
}
