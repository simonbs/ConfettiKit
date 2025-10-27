import ConfettiKit
import UIKit

final class ViewController: UIViewController {
    private let emojiLabel: UILabel = {
        let this = UILabel()
        this.font = .systemFont(ofSize: 64)
        this.text = "🎉"
        return this
    }()
    private var confettiView: ConfettiView?
    private let modeButton: ConfettiModeButton = {
        let this = ConfettiModeButton()
        this.translatesAutoresizingMaskIntoConstraints = false
        return this
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(emojiLabel)
        view.addSubview(modeButton)
        setupConfettiView(with: modeButton.selectedMode)
        modeButton.onSelectionChange = { [weak self] mode in
            self?.setupConfettiView(with: mode)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let emojiLabelSize = emojiLabel.intrinsicContentSize
        let emojiLabelOrigin = CGPoint(x: (view.frame.width - emojiLabelSize.width) / 2, y: (view.frame.height - emojiLabelSize.height) / 2)
        emojiLabel.frame = CGRect(origin: emojiLabelOrigin, size: emojiLabelSize)
        confettiView?.frame = view.bounds
        let segmentedControlSize = modeButton.intrinsicContentSize
        let segmentedControlOriginX = (view.frame.width - segmentedControlSize.width) / 2
        let segmentedControlOriginY = view.frame.height - view.safeAreaInsets.bottom - segmentedControlSize.height - 30
        let segmentedControlOrigin = CGPoint(x: segmentedControlOriginX, y: segmentedControlOriginY)
        modeButton.frame = CGRect(origin: segmentedControlOrigin, size: segmentedControlSize)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        confettiView?.shoot()
    }
}

private extension ViewController {
    private func setupConfettiView(with mode: ConfettiMode) {
        confettiView?.removeFromSuperview()
        let images = (1 ... 7).compactMap { UIImage(named: "confetti\($0)") }
        let confettiView = ConfettiView(mode: mode, images: images)
        confettiView.isUserInteractionEnabled = false
        view.addSubview(confettiView)
        self.confettiView = confettiView
        view.setNeedsLayout()
    }
}
