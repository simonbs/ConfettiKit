import UIKit

protocol ShootingDelegate: AnyObject {
    func shootingDidFinish(_ shooting: Shooting)
}

final class Shooting {
    weak var delegate: ShootingDelegate?
    private(set) weak var view: UIView?
    private var timer: Timer?

    init(view: UIView) {
        self.view = view
    }

    deinit {
        timer?.invalidate()
        timer = nil
    }

    func scheduleFinish() {
        if timer == nil {
            timer = .scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerDidTrigger), userInfo: nil, repeats: false)
        }
    }
}

private extension Shooting {
    @objc private func timerDidTrigger() {
        timer?.invalidate()
        timer = nil
        delegate?.shootingDidFinish(self)
    }
}
