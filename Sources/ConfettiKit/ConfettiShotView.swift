import UIKit

final class ConfettiShotView: UIView {
    private let backgroundLayerView: ConfettiLayerView
    private let foregroundLayerView: ConfettiLayerView

    init(images: [UIImage]) {
        backgroundLayerView = ConfettiLayerView(images: images, birthRate: 20, scale: 0.6, speed: 0.95)
        foregroundLayerView = ConfettiLayerView(images: images, birthRate: 48, scale: 0.8, scaleRange: 0.1)
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
