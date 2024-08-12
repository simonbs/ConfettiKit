import UIKit

final class ConfettiLayerView: UIView {
    private let mode: ConfettiMode
    private let emitterLayer: CAEmitterLayer = {
        var behaviors: [NSObject] = []
        if let behavior = EmitterBehavior.makeHorizontalWaveBehavior() {
            behaviors.append(behavior)
        }
        if let behavior = EmitterBehavior.makeVerticalWaveBehavior() {
            behaviors.append(behavior)
        }
        let this = CAEmitterLayer()
        this.birthRate = 0
        this.lifetime = 0
        if !behaviors.isEmpty {
            this.setValue(behaviors, forKey: "emitterBehaviors")
        }
        return this
    }()
    private var haveSetupEmitterCells = false
    private let images: [UIImage]
    private let birthRate: Float
    private let scale: CGFloat
    private let scaleRange: CGFloat
    private let speed: Float

    init(mode: ConfettiMode, images: [UIImage], birthRate: Float = 100, scale: CGFloat = 1, scaleRange: CGFloat = 0, speed: Float = 1) {
        self.mode = mode
        self.images = images
        self.birthRate = birthRate
        self.scale = scale
        self.scaleRange = scaleRange
        self.speed = speed
        super.init(frame: .zero)
        emitterLayer.emitterShape = mode.emitterShape
        layer.addSublayer(emitterLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        emitterLayer.emitterSize = CGSize(width: bounds.width, height: 0)
        emitterLayer.emitterPosition = mode.emitterPosition(in: bounds)
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
        addAttractorAnimation()
        addBirthrateAnimation()
        addDragAnimation()
        addGravityAnimation()
    }
}

private extension ConfettiLayerView {
    private func setupEmitterCells() {
        emitterLayer.emitterCells = images.map(emitterCell)
        emitterLayer.lifetime = 1
    }

    private func emitterCell(showing image: UIImage) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.name = UUID().uuidString
        cell.beginTime = CACurrentMediaTime()
        cell.birthRate = birthRate
        cell.lifetime = 5
        cell.lifetimeRange = 0
        cell.velocity = 180
        cell.velocityRange = 40
        cell.spin = 1.75
        cell.spinRange = 2
        cell.scale = scale
        cell.scaleRange = scaleRange
        cell.speed = speed
        cell.emissionLongitude = degreesToRadians(180)
        cell.emissionRange = degreesToRadians(90)
        cell.contents = image.cgImage
        cell.setValue("plane", forKey: "particleType")
        cell.setValue(Double.pi, forKey: "orientationRange")
        cell.setValue(Double.pi, forKey: "orientationLongitude")
        cell.setValue(Double.pi, forKey: "orientationLatitude")
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
        animation.duration = 2
        animation.fromValue = 1
        animation.toValue = 0
        emitterLayer.add(animation, forKey: "birthRate")
    }

    private func addDragAnimation() {
        let animation = CABasicAnimation()
        animation.duration = 0.35
        animation.fromValue = 0
        animation.toValue = 2
        emitterLayer.add(animation, forKey: "emitterBehaviors.drag.drag")
    }

    private func addGravityAnimation() {
        let animation = CAKeyframeAnimation()
        animation.duration = 6
        switch mode {
        case .topToBottom:
            animation.keyTimes = [0.05, 0.1, 0.5, 1]
            animation.values = [0, 300, 750, 1_000]
        case .centerToLeft:
            animation.keyTimes = [0, 0.1, 0.5, 1]
            animation.values = [-1_000, -750, -100, 0]
        }
        let cells = emitterLayer.emitterCells ?? []
        for cell in cells {
            if let name = cell.name {
                switch mode {
                case .topToBottom:
                    emitterLayer.add(animation, forKey: "emitterCells.\(name).yAcceleration")
                case .centerToLeft:
                    emitterLayer.add(animation, forKey: "emitterCells.\(name).xAcceleration")
                }
            }
        }
    }

    private func degreesToRadians(_ degrees: Double) -> Double {
        let degrees = Measurement(value: 180, unit: UnitAngle.degrees)
        let radians = degrees.converted(to: .radians)
        return radians.value
    }
}

private extension ConfettiMode {
    var emitterShape: CAEmitterLayerEmitterShape {
        switch self {
        case .topToBottom:
            return .line
        case .centerToLeft:
            return .point
        }
    }

    func emitterPosition(in rect: CGRect) -> CGPoint {
        switch self {
        case .topToBottom:
            return CGPoint(x: rect.midX, y: -10)
        case .centerToLeft:
            return CGPoint(x: rect.midX, y: rect.midY)
        }
    }
}
