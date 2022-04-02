import UIKit

public final class Confetto {
    public enum Shape {
        case rectangle
        case circle
    }

    public let color: UIColor
    public let shape: Shape

    private var cachedImage: UIImage?
    var image: UIImage {
        if let cachedImage = cachedImage {
            return cachedImage
        } else {
            let image = ConfettoRenderer.image(from: self)
            cachedImage = image
            return image
        }
    }

    public init(color: UIColor, shape: Shape) {
        self.color = color
        self.shape = shape
    }
}
