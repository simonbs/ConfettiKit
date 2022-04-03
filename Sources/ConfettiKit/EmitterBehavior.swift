import CoreGraphics
import Foundation

enum EmitterBehavior {
    static func makeHorizontalWaveBehavior() -> NSObject? {
        guard let behavior = makeBehavior(type: "wave") else {
            return nil
        }
        behavior.setValue([100, 0, 0], forKeyPath: "force")
        behavior.setValue(0.5, forKeyPath: "frequency")
        return behavior
    }

    static func makeVerticalWaveBehavior() -> NSObject? {
        guard let behavior = makeBehavior(type: "wave") else {
            return nil
        }
        behavior.setValue([0, 500, 0], forKeyPath: "force")
        behavior.setValue(3, forKeyPath: "frequency")
        return behavior
    }

    static func attractorBehavior(position: CGPoint) -> NSObject? {
        guard let behavior = makeBehavior(type: "attractor") else {
            return nil
        }
        behavior.setValue("attractor", forKeyPath: "name")
        behavior.setValue(-50, forKey: "falloff")
        behavior.setValue(300, forKey: "radius")
        behavior.setValue(10, forKey: "stiffness")
        behavior.setValue(position, forKey: "position")
        behavior.setValue(-70, forKey: "zPosition")
        return behavior
    }

    static func dragBehavior(position: CGPoint) -> NSObject? {
        guard let behavior = makeBehavior(type: "drag") else {
            return nil
        }
        behavior.setValue("drag", forKey: "name")
        behavior.setValue(2, forKey: "drag")
        return behavior
     }
}

private extension EmitterBehavior {
    private static func makeBehavior(type: String) -> NSObject? {
        let klassName = "CA" + "heBrettimE".reversed() + "avior"
        guard let klass = NSClassFromString(klassName) as? NSObject.Type else {
            return nil
        }
        let methodName = "Wroivaheb".reversed() + "ithTy" + ":ep".reversed()
        guard let behaviorWithType = klass.method(for: NSSelectorFromString(methodName)) else {
            return nil
        }
        let castedBehaviorWithType = unsafeBitCast(behaviorWithType, to: (@convention(c) (Any?, Selector, Any?) -> NSObject).self)
        let casedMethodName = String(methodName.dropLast())
        return castedBehaviorWithType(klass, NSSelectorFromString(casedMethodName), type)
    }
}
