import Foundation
import QuartzCore

final class ConfettiEmitterLayer: CAEmitterLayer {
    private let mode: ConfettiMode
    private let images: [CGImage]
    private let particleBirthRate: Float
    private let particleScale: CGFloat
    private let scaleRange: CGFloat
    private let particleSpeed: Float
    private var defaultEmissionLongitude: Double {
        switch mode {
        case .centerToBottom:
            90
        case .centerToRight, .centerToEdges:
            0
        case .centerToTop:
            270
        case .topToBottom, .centerToLeft:
            180
        }
    }
    private var defaultEmissionRange: Double {
        switch mode {
        case .topToBottom, .centerToLeft, .centerToTop, .centerToRight, .centerToBottom:
            90
        case .centerToEdges:
            360
        }
    }

    init(
        mode: ConfettiMode,
        images: [CGImage],
        birthRate: Float = 100,
        scale: CGFloat = 1,
        scaleRange: CGFloat = 0,
        speed: Float = 1
    ) {
        self.mode = mode
        self.images = images
        self.particleBirthRate = birthRate
        self.particleScale = scale
        self.scaleRange = scaleRange
        self.particleSpeed = speed
        super.init()
        emitterShape = mode.emitterShape
        self.birthRate = 0
        lifetime = 0
        var behaviors: [NSObject] = []
        if let behavior = EmitterBehavior.makeHorizontalWaveBehavior() { behaviors.append(behavior) }
        if let behavior = EmitterBehavior.makeVerticalWaveBehavior() { behaviors.append(behavior) }
        if !behaviors.isEmpty { setValue(behaviors, forKey: "emitterBehaviors") }
        setupEmitterCells()
    }

    override init(layer: Any) {
        guard let source = layer as? ConfettiEmitterLayer else {
            fatalError("Expected a ConfettiEmitterLayer")
        }
        mode = source.mode
        images = source.images
        particleBirthRate = source.particleBirthRate
        particleScale = source.particleScale
        scaleRange = source.scaleRange
        particleSpeed = source.particleSpeed
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateGeometry(in bounds: CGRect) {
        frame = bounds
        emitterSize = CGSize(width: bounds.width, height: 0)
        emitterPosition = mode.emitterPosition(in: bounds)
        updateAttractorBehavior()
    }

    func addAnimations() {
        addAttractorAnimation()
        addBirthrateAnimation()
        addDragAnimation()
        addGravityAnimation()
    }
}

private extension ConfettiEmitterLayer {
    private func setupEmitterCells() {
        emitterCells = images.map(emitterCell)
        lifetime = 1
    }

    private func emitterCell(showing image: CGImage) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.name = UUID().uuidString
        cell.beginTime = CACurrentMediaTime()
        cell.birthRate = particleBirthRate
        cell.lifetime = 5
        cell.lifetimeRange = 0
        cell.velocity = 180
        cell.velocityRange = 40
        cell.spin = 1.75
        cell.spinRange = 2
        cell.scale = particleScale
        cell.scaleRange = scaleRange
        cell.alphaSpeed = -0.2
        cell.speed = particleSpeed
        cell.emissionLongitude = degreesToRadians(defaultEmissionLongitude)
        cell.emissionRange = degreesToRadians(defaultEmissionRange)
        cell.contents = image
        cell.setValue("plane", forKey: "particleType")
        cell.setValue(Double.pi, forKey: "orientationRange")
        cell.setValue(Double.pi, forKey: "orientationLongitude")
        cell.setValue(Double.pi, forKey: "orientationLatitude")
        return cell
    }

    private func updateAttractorBehavior() {
        guard let behaviors = value(forKey: "emitterBehaviors") as? [NSObject], !behaviors.isEmpty else {
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
        if let attractorBehavior = EmitterBehavior.attractorBehavior(position: emitterPosition) {
            newBehaviors.append(attractorBehavior)
        }
        setValue(newBehaviors, forKey: "emitterBehaviors")
    }

    private func addAttractorAnimation() {
        let animation = CAKeyframeAnimation()
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.duration = 3
        animation.keyTimes = [0, 0.4]
        animation.values = [80, 5]
        add(animation, forKey: "emitterBehaviors.attractor.stiffness")
    }

    private func addBirthrateAnimation() {
        let animation = CABasicAnimation()
        animation.duration = 2
        animation.fromValue = 1
        animation.toValue = 0
        add(animation, forKey: "birthRate")
    }

    private func addDragAnimation() {
        let animation = CABasicAnimation()
        animation.duration = 0.35
        animation.fromValue = 0
        animation.toValue = 2
        add(animation, forKey: "emitterBehaviors.drag.drag")
    }

    private func addGravityAnimation() {
        let animation = CAKeyframeAnimation()
        animation.duration = 6
        switch mode {
        case .topToBottom:
            animation.keyTimes = [0.05, 0.1, 0.5, 1]
            animation.values = [0, 300, 750, 1_000]
        case .centerToLeft, .centerToTop:
            animation.keyTimes = [0, 0.1, 0.5, 1]
            animation.values = [-1_000, -750, -100, 0]
        case .centerToRight, .centerToBottom:
            animation.keyTimes = [0, 0.1, 0.5, 1]
            animation.values = [1_000, 750, 100, 0]
        case .centerToEdges:
            animation.keyTimes = [0, 0.1, 0.5, 1]
            animation.values = [0, 0, 0, 0]
        }
        let cells = emitterCells ?? []
        for cell in cells {
            if let name = cell.name {
                switch mode {
                case .topToBottom, .centerToTop, .centerToBottom:
                    add(animation, forKey: "emitterCells.\(name).yAcceleration")
                case .centerToLeft, .centerToRight, .centerToEdges:
                    add(animation, forKey: "emitterCells.\(name).xAcceleration")
                }
            }
        }
    }

    private func degreesToRadians(_ degrees: Double) -> Double {
        let degrees = Measurement(value: degrees, unit: UnitAngle.degrees)
        let radians = degrees.converted(to: .radians)
        return radians.value
    }
}

private extension ConfettiMode {
    var emitterShape: CAEmitterLayerEmitterShape {
        switch self {
        case .topToBottom:
            .line
        case .centerToLeft, .centerToTop, .centerToRight, .centerToBottom, .centerToEdges:
            .point
        }
    }

    func emitterPosition(in rect: CGRect) -> CGPoint {
        switch self {
        case .topToBottom:
            CGPoint(x: rect.midX, y: -10)
        case .centerToLeft, .centerToTop, .centerToRight, .centerToBottom, .centerToEdges:
            CGPoint(x: rect.midX, y: rect.midY)
        }
    }
}
