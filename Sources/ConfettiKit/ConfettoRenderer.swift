import UIKit

enum ConfettoRenderer {
    static func image(from confetto: Confetto) -> UIImage {
        let size = confetto.shape.imageSize
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            let cgContext = context.cgContext
            cgContext.setFillColor(confetto.color.cgColor)
            switch confetto.shape {
            case .rectangle:
                cgContext.fill(rect)
            case .circle:
                cgContext.fillEllipse(in: rect)
            }
        }
    }
}

private extension Confetto.Shape {
    var imageSize: CGSize {
        switch self {
        case .rectangle:
            return CGSize(width: 12, height: 6)
        case .circle:
            return CGSize(width: 6, height: 6)
        }
    }
}
