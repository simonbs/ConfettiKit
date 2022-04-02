import UIKit

final class ConfettiShotView: UIView {
    private let backgroundLayerView: ConfettiLayerView
    private let foregroundLayerView: ConfettiLayerView

    init(confetti: [Confetto]) {
        backgroundLayerView = ConfettiLayerView(confetti: confetti, scale: 0.5, speed: 0.95)
        foregroundLayerView = ConfettiLayerView(confetti: confetti)
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
