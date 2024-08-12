import UIKit

final class ConfettiShotView: UIView {
    private let backgroundLayerView: ConfettiLayerView
    private let foregroundLayerView: ConfettiLayerView

    init(mode: ConfettiMode, images: [UIImage], birthRate1: Float, birthRate2: Float) {
        backgroundLayerView = ConfettiLayerView(mode: mode, images: images, birthRate: birthRate1, scale: 0.6, speed: 0.95)
        foregroundLayerView = ConfettiLayerView(mode: mode, images: images, birthRate: birthRate2, scale: 0.8, scaleRange: 0.1)
        backgroundLayerView.alpha = 0.5
        super.init(frame: .zero)
        addSubview(backgroundLayerView)
        addSubview(foregroundLayerView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundLayerView.frame = bounds
        foregroundLayerView.frame = bounds
    }

    func addAnimations() {
        backgroundLayerView.addAnimations()
        foregroundLayerView.addAnimations()
    }
}
