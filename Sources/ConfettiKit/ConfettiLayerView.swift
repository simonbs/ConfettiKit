import UIKit

final class ConfettiLayerView: UIView {
    private let emitterLayer: CAEmitterLayer = {
        var behaviors: [NSObject] = []
        if let behavior = EmitterBehavior.makeHorizontalWaveBehavior() {
            behaviors.append(behavior)
        }
        if let behavior = EmitterBehavior.makeVerticalWaveBehavior() {
            behaviors.append(behavior)
        }
        let this = CAEmitterLayer()
        this.emitterShape = .sphere
        this.birthRate = 0
        if !behaviors.isEmpty {
            this.setValue(behaviors, forKey: "emitterBehaviors")
        }
        return this
    }()
    private var haveSetupEmitterCells = false
    private let confetti: [Confetto]
    private let scale: CGFloat
    private let speed: Float

    init(confetti: [Confetto], scale: CGFloat = 1, speed: Float = 1) {
        self.confetti = confetti
        self.scale = scale
        self.speed = speed
        super.init(frame: .zero)
        layer.addSublayer(emitterLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer.emitterSize = CGSize(width: 100, height: 100)
        emitterLayer.emitterPosition = CGPoint(x: bounds.midX, y: bounds.minY - 100)
        emitterLayer.frame = bounds
        updateAttractorBehavior()
    }

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview != nil && !haveSetupEmitterCells {
            haveSetupEmitterCells = true
            setupEmitterCells()
        }
    }

    func addAnimations() {
        emitterLayer.beginTime = CACurrentMediaTime()
        addAttractorAnimation()
        addBirthrateAnimation()
        addDragAnimation()
        addGravityAnimation()
    }
}

private extension ConfettiLayerView {
    private func setupEmitterCells() {
        emitterLayer.emitterCells = confetti.map { confetto in
            return emitterCell(showing: confetto.image)
        }
    }

    private func emitterCell(showing image: UIImage) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.name = UUID().uuidString
        cell.beginTime = 0
        cell.birthRate = 150
        cell.contents = image.cgImage
        cell.emissionRange = .pi
        cell.lifetime = 10
        cell.spin = 4
        cell.spinRange = 8
        cell.velocityRange = 0
        cell.yAcceleration = 0
        cell.scale = scale
        cell.speed = speed
        cell.setValue("plane", forKey: "particleType")
        cell.setValue(Double.pi, forKey: "orientationRange")
        cell.setValue(Double.pi / 2, forKey: "orientationLongitude")
        cell.setValue(Double.pi / 2, forKey: "orientationLatitude")
        return cell
    }

    private func updateAttractorBehavior() {
        guard let behaviors = emitterLayer.value(forKey: "emitterBehaviors") as? [NSObject], !behaviors.isEmpty else {
            return
        }
        var newBehaviors = behaviors
        newBehaviors.removeAll { behavior in
            if let name = behavior.value(forKey: "name") as? String, name == "attractor" {
                return true
            } else {
                return false
            }
        }
        if let attractorBehavior = EmitterBehavior.attractorBehavior(position: emitterLayer.emitterPosition) {
            newBehaviors.append(attractorBehavior)
        }
        emitterLayer.setValue(newBehaviors, forKey: "emitterBehaviors")
    }

    private func addAttractorAnimation() {
        let animation = CAKeyframeAnimation()
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = 3
        animation.keyTimes = [0, 0.4]
        animation.values = [80, 5]
        emitterLayer.add(animation, forKey: "emitterBehaviors.attractor.stiffness")
    }

    private func addBirthrateAnimation() {
        let animation = CABasicAnimation()
        animation.duration = 1
        animation.fromValue = 1
        animation.toValue = 0
        emitterLayer.add(animation, forKey: "birthRate")
    }

    private func addDragAnimation() {
        let animation = CABasicAnimation()
        animation.duration = 0.35
        animation.fromValue = 0
        animation.toValue = 2
        emitterLayer.add(animation, forKey:  "emitterBehaviors.drag.drag")
    }

    private func addGravityAnimation() {
        let animation = CAKeyframeAnimation()
        animation.duration = 6
        animation.keyTimes = [0.05, 0.1, 0.5, 1]
        animation.values = [0, 100, 2000, 4000]
        let cells = emitterLayer.emitterCells ?? []
        for cell in cells {
            if let name = cell.name {
                emitterLayer.add(animation, forKey: "emitterCells.\(name).yAcceleration")
            }
        }
    }
}
