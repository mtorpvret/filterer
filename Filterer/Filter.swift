import UIKit

// This is the protocol that all filters must conform to
public protocol Filter {
    var minValue: Double { get }
    var maxValue: Double { get }
    var defaultValue: Double { get }
    var thumbnail: UIImage? { get }
    var value: Double { get }
    func apply(pixels: UnsafeMutableBufferPointer<Pixel>)
    func set(value: Double)
}

public extension Filter {
    public static func getFilterByName(filterName: String) -> Filter? {
        switch filterName {
            // Ugly code, refactor!
            case "Contrast": return Contrast()
            case "Gamma": return Gamma()
            case "Solarise": return Solarise()
            case "Brightness": return Brightness()
            case "Grayscale": return Grayscale()
            default: return nil
        }
    }
}


// All filter definitions below use algorithms from this web page:
// http://www.dfstudios.co.uk/articles/programming/image-programming-algorithms/

public class Contrast: Filter {
    var factor: Double
    public var minValue: Double = -255
    public var maxValue: Double = 255
    public var defaultValue: Double = 100
    public var value: Double
    public var thumbnail: UIImage? = UIImage(named: "Contrast (100x100).jpg")
    // TODO: DRY
    public init() {
        factor = 259*Double(Int(defaultValue)+255)/Double(255*(259-Int(defaultValue)))
        value = defaultValue
    }
    public init(level: Double) {
        factor = 259*Double(Int(level)+255)/Double(255*(259-Int(level)))
        value = level
    }
    public func set(level: Double) {
        factor = 259*Double(Int(level)+255)/Double(255*(259-Int(level)))
        value = level
    }
    public func apply(pixels: UnsafeMutableBufferPointer<Pixel>) {
        for i in 0..<pixels.count {
            var pixel = pixels[i]
            pixel.red = truncate(factor*Double(Int(pixel.red) - 128) + 128)
            pixel.green = truncate(factor*Double(Int(pixel.green) - 128) + 128)
            pixel.blue = truncate(factor*Double(Int(pixel.blue) - 128) + 128)
            pixels[i] = pixel
        }
    }
    
    func truncate(value: Double) -> UInt8 {
        let intVal = Int(value)
        return UInt8(min(255, max(0, intVal)))
    }
}

public class Gamma: Filter {
    var gCorr: Double
    public var minValue: Double = 0
    public var maxValue: Double = 8
    public var defaultValue: Double = 1.25
    public var value: Double
    public var thumbnail: UIImage? = UIImage(named: "Gamma (100x100).jpg")
    public init() {
        gCorr = 1/defaultValue
        value = defaultValue
    }
    public init(value: Double) {
        gCorr = 1/value
        self.value = value
    }
    public func set(value: Double) {
        gCorr = 1/value
        self.value = value
    }
    public func apply(pixels: UnsafeMutableBufferPointer<Pixel>) {
        for i in 0..<pixels.count {
            var pixel = pixels[i]
            pixel.red = UInt8(255*(pow(Double(pixel.red)/255,gCorr)))
            pixel.green = UInt8(255*(pow(Double(pixel.green)/255,gCorr)))
            pixel.blue = UInt8(255*(pow(Double(pixel.blue)/255,gCorr)))
            pixels[i] = pixel
        }
    }
}

public class Solarise: Filter {
    var threshold: UInt8
    public var minValue: Double = 0
    public var maxValue: Double = 255
    public var defaultValue: Double = 128
    public var value: Double
    public var thumbnail: UIImage? = UIImage(named: "Solarise (100x100).jpg")
    public init() {
        self.threshold = UInt8(defaultValue)
        value = defaultValue
    }
    public init(threshold: Double) {
        self.threshold = UInt8(threshold)
        value = threshold
    }
    public func set(threshold: Double) {
        self.threshold = UInt8(threshold)
        value = threshold
    }
    public func apply(pixels: UnsafeMutableBufferPointer<Pixel>) {
        for i in 0..<pixels.count {
            var pixel = pixels[i]
            if pixel.red < threshold {
                pixel.red = 255-pixel.red
            }
            if pixel.green < threshold {
                pixel.green = 255-pixel.green
            }
            if pixel.blue < threshold {
                pixel.blue = 255-pixel.blue
            }
            pixels[i] = pixel
        }
    }
}

public class Grayscale: Filter {
    var weighted: Bool
    public var minValue: Double = 0
    public var maxValue: Double = 1
    public var defaultValue: Double = 1
    public var value: Double
    public var thumbnail: UIImage? = UIImage(named: "Grayscale (100x100).jpg")
    public init() {
        self.weighted = true
        value = 1
    }
    public init(weighted: Double) {
        if (weighted < 0.5) {
            self.weighted = false
        }
        else {
            self.weighted = true
        }
        value = weighted
    }
    public func set(weighted: Double) {
        if (weighted < 0.5) {
            self.weighted = false
        }
        else {
            self.weighted = true
        }
        value = weighted
    }
    public func apply(pixels: UnsafeMutableBufferPointer<Pixel>) {
        for i in 0..<pixels.count {
            var pixel = pixels[i]
            let intensity: UInt8
            if weighted {
                intensity = UInt8(Double(pixel.red)*0.299 + Double(pixel.green)*0.587 + Double(pixel.blue)*0.114)
            }
            else {
                intensity = UInt8((Double(pixel.red) + Double(pixel.green) + Double(pixel.blue))/3)
            }
            pixel.red=intensity
            pixel.green=intensity
            pixel.blue=intensity
            pixels[i] = pixel
        }
    }
    
}

public class Brightness: Filter {
    var increase: Int8
    public var minValue: Double = -127
    public var maxValue: Double = 128
    public var defaultValue: Double = 50
    public var value: Double
    public var thumbnail: UIImage? = UIImage(named: "Brightness (100x100).jpg")
    public init() {
        self.increase = Int8(defaultValue)
        value = defaultValue
    }
    public init(increase: Double) {
        self.increase = Int8(increase)
        value = increase
    }
    public func set(increase: Double) {
        self.increase = Int8(increase)
        value = increase
    }
    public func apply(pixels: UnsafeMutableBufferPointer<Pixel>) {
        for i in 0..<pixels.count {
            var pixel = pixels[i]
            pixel.red = truncate(Int(pixel.red) + Int(increase))
            pixel.green = truncate(Int(pixel.green) + Int(increase))
            pixel.blue = truncate(Int(pixel.blue) + Int(increase))
            pixels[i] = pixel
        }
    }
    
    func truncate(value: Int) -> UInt8 {
        return UInt8(min(255, max(0, value)))
    }
}
