#if canImport(UIKit)
import UIKit

public final class ConfettiView: UIView {
    public var birthRate1: Float = 48
    public var birthRate2: Float = 20
    let mode: ConfettiMode
    let images: [CGImage]
    var confettiContainerLayer: CALayer? { layer }

    public init(mode: ConfettiMode = .topToBottom, images: [UIImage]) {
        self.mode = mode
        self.images = images.compactMap(\.cgImage)
        super.init(frame: .zero)
        clipsToBounds = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutConfettiShots()
    }
}
#endif
