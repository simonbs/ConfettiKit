@testable import ConfettiKit
import QuartzCore
import XCTest
#if canImport(UIKit)
import UIKit
#else
import AppKit
#endif

@MainActor
final class ConfettiViewTests: XCTestCase {
    func testBurstUsesSharedForegroundAndBackgroundEmitters() throws {
        let view = try makeView()
        view.shoot()
        let container = try XCTUnwrap(view.confettiContainerLayer)
        XCTAssertTrue(container.masksToBounds)
        let shot = try XCTUnwrap(container.sublayers?.first as? ConfettiShotLayer)
        let emitters = try XCTUnwrap(shot.sublayers?.compactMap { $0 as? CAEmitterLayer })
        XCTAssertEqual(emitters.count, 2)
        XCTAssertEqual(emitters[0].opacity, 0.5)
        XCTAssertEqual(emitters[1].opacity, 1)
        for emitter in emitters {
            XCTAssertEqual(emitter.frame, view.bounds)
            XCTAssertEqual(emitter.emitterShape, .line)
            XCTAssertEqual(emitter.emitterPosition, CGPoint(x: view.bounds.midX, y: -10))
            let cell = try XCTUnwrap(emitter.emitterCells?.first)
            XCTAssertEqual(cell.emissionLongitude, .pi, accuracy: 0.001)
            XCTAssertGreaterThan(cell.beginTime, CACurrentMediaTime() - 1)
            XCTAssertEqual(cell.lifetime, 5)
            XCTAssertNotNil(emitter.animation(forKey: "birthRate"))
        }
        XCTAssertEqual(emitters[0].emitterCells?.first?.birthRate, 48)
        XCTAssertEqual(emitters[1].emitterCells?.first?.birthRate, 20)
    }

    func testResizeUpdatesBothEmittersAndRepeatedShotsStayIndependent() throws {
        let view = try makeView()
        view.shoot()
        view.shoot()
        view.frame.size = CGSize(width: 700, height: 900)
        #if canImport(UIKit)
        view.setNeedsLayout()
        view.layoutIfNeeded()
        #else
        view.needsLayout = true
        view.layoutSubtreeIfNeeded()
        #endif
        let shots = try XCTUnwrap(view.confettiContainerLayer?.sublayers)
        XCTAssertEqual(shots.count, 2)
        for shot in shots {
            shot.layoutIfNeeded()
            XCTAssertEqual(shot.frame, view.bounds)
            for emitter in shot.sublayers ?? [] {
                XCTAssertEqual(emitter.frame, view.bounds)
            }
        }
    }

    func testEveryEmissionModeRetainsItsOriginAndGravityAxis() throws {
        let images = try makeView().images
        let bounds = CGRect(x: 0, y: 0, width: 540, height: 840)
        for mode in ConfettiMode.allCases {
            let emitter = ConfettiEmitterLayer(mode: mode, images: images)
            emitter.updateGeometry(in: bounds)
            emitter.addAnimations()
            let cell = try XCTUnwrap(emitter.emitterCells?.first)
            let name = try XCTUnwrap(cell.name)
            switch mode {
            case .topToBottom:
                XCTAssertEqual(emitter.emitterShape, .line)
                XCTAssertEqual(emitter.emitterPosition, CGPoint(x: bounds.midX, y: -10))
            default:
                XCTAssertEqual(emitter.emitterShape, .point)
                XCTAssertEqual(emitter.emitterPosition, CGPoint(x: bounds.midX, y: bounds.midY))
            }
            let axis: String
            switch mode {
            case .topToBottom, .centerToTop, .centerToBottom:
                axis = "yAcceleration"
            case .centerToLeft, .centerToRight, .centerToEdges:
                axis = "xAcceleration"
            }
            XCTAssertNotNil(emitter.animation(forKey: "emitterCells.\(name).\(axis)"))
        }
    }

    func testCompletedShotsAreRemovedWithoutRetainingTheView() async throws {
        let view = try makeView()
        view.shoot()
        let shots = NSHashTable<CALayer>.weakObjects()
        shots.add(try XCTUnwrap(view.confettiContainerLayer?.sublayers?.first))
        XCTAssertEqual(shots.allObjects.count, 1)
        try await Task.sleep(nanoseconds: 5_200_000_000)
        XCTAssertTrue(view.confettiContainerLayer?.sublayers?.isEmpty ?? true)
        XCTAssertTrue(shots.allObjects.isEmpty)
    }

    private func makeView() throws -> ConfettiView {
        let context = try XCTUnwrap(CGContext(data: nil, width: 13, height: 13, bitsPerComponent: 8,
                                              bytesPerRow: 52, space: CGColorSpaceCreateDeviceRGB(),
                                              bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        let image = try XCTUnwrap(context.makeImage())
        #if canImport(UIKit)
        let view = ConfettiView(images: [UIImage(cgImage: image)])
        #else
        let view = ConfettiView(images: [NSImage(cgImage: image, size: CGSize(width: 13, height: 13))])
        XCTAssertTrue(view.isFlipped)
        XCTAssertTrue(view.layer?.isGeometryFlipped == true)
        #endif
        view.frame = CGRect(x: 0, y: 0, width: 540, height: 840)
        return view
    }
}
