import Foundation
import QuartzCore

extension ConfettiView {
    /// Emits one two-layer burst using the same particle configuration on both platforms.
    public func shoot() {
        guard let container = confettiContainerLayer, !bounds.isEmpty else {
            return
        }
        let shot = ConfettiShotLayer(mode: mode, images: images, birthRate1: birthRate1, birthRate2: birthRate2)
        shot.frame = bounds
        container.addSublayer(shot)
        shot.start()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak shot] in shot?.removeFromSuperlayer() }
    }

    func layoutConfettiShots() {
        for shot in confettiContainerLayer?.sublayers ?? [] where shot is ConfettiShotLayer {
            shot.frame = bounds
            shot.setNeedsLayout()
        }
    }
}
