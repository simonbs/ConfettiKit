import UIKit

public final class ConfettiView: UIView {
    public var birthRate1: Float = 48
    public var birthRate2: Float = 20

    private let mode: ConfettiMode
    private let images: [UIImage]
    private var shootings: [Shooting] = []

    public init(mode: ConfettiMode = .topToBottom, images: [UIImage]) {
        self.mode = mode
        self.images = images
        super.init(frame: .zero)
        clipsToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        for shooting in shootings {
            shooting.view?.frame = bounds
        }
    }

    public func shoot() {
        let view = ConfettiShotView(mode: mode, images: images, birthRate1: birthRate1, birthRate2: birthRate2)
        view.frame = bounds
        addSubview(view)
        let shooting = Shooting(view: view)
        shooting.delegate = self
        view.addAnimations()
        shooting.scheduleFinish()
    }
}

extension ConfettiView: ShootingDelegate {
    func shootingDidFinish(_ shooting: Shooting) {
        guard let view = shooting.view else { return }
        
        UIView.animate(withDuration: 0.5, animations: {
            view.alpha = 0.0
        }, completion: { _ in
            view.removeFromSuperview()
            self.shootings.removeAll { $0 === shooting }
        })
    }
}
