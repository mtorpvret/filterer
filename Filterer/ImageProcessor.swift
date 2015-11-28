import UIKit

public class ImageProcessor {
    var pixels: UnsafeMutableBufferPointer<Pixel>
    var rgbaImage: RGBAImage
    
    public init(image: UIImage) {
        rgbaImage=RGBAImage(image: image)!
        pixels = rgbaImage.pixels
    }
    
    public func getImage() -> UIImage {
        return rgbaImage.toUIImage()!
    }
    
    public func applyFilter(filter: Filter) {
        filter.apply(pixels)
    }
    
    public func applyFilters(filters: [Filter]) {
        _ = filters.map() { (filter: Filter) in
            filter.apply(pixels)
        }
    }
    
}