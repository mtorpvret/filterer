import UIKit

public class ImageProcessor {
    let originalImage: UIImage
    var pixels: UnsafeMutableBufferPointer<Pixel>
    var rgbaImage: RGBAImage
    
    public init(image: UIImage) {
        originalImage = image
        rgbaImage=RGBAImage(image: image)!
        pixels = rgbaImage.pixels
    }
    
    public func getOriginalImage() -> UIImage {
        return originalImage
    }
    
    public func reset() {
        rgbaImage=RGBAImage(image: originalImage)!
        pixels = rgbaImage.pixels
    }
        
    public func getFilteredImage() -> UIImage {
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