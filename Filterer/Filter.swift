import Foundation

// This is the protocol that all filters must conform to
public protocol Filter {
    static var minValue: Double { get }
    static var maxValue: Double { get }
    static var defaultValue: Double { get }
    func apply(pixels: UnsafeMutableBufferPointer<Pixel>)
}

public extension Filter {
    static public func getFilterByName(filterName: String) -> Filter? {
        switch filterName {
            // Ugly code, refactor!
            case "Contrast": return Contrast(level: Contrast.defaultValue)
            case "Gamma": return Gamma(value: Gamma.defaultValue)
            case "Solarise": return Solarise(threshold: Solarise.defaultValue)
            case "Brightness": return Brightness(increase: Brightness.defaultValue)
            case "Grayscale": return Grayscale(weighted: Grayscale.defaultValue)
            default: return nil
        }
    }
}


// All filter definitions below use algorithms from this web page:
// http://www.dfstudios.co.uk/articles/programming/image-programming-algorithms/

public class Contrast: Filter {
    var factor: Double
    static public var minValue: Double = -255
    static public var maxValue: Double = 255
    static public var defaultValue: Double = 100
    // TODO: DRY
    public init(level: Double) {
        factor = 259*Double(Int(level)+255)/Double(255*(259-Int(level)))        
    }
    public func set(level: Double) {
        factor = 259*Double(Int(level)+255)/Double(255*(259-Int(level)))
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
    static public var minValue: Double = 0
    static public var maxValue: Double = 8
    static public var defaultValue: Double = 4
    public init(value: Double) {
        gCorr = 1/value
    }
    public func set(value: Double) {
        gCorr = 1/value
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
    static public var minValue: Double = 0
    static public var maxValue: Double = 255
    static public var defaultValue: Double = 128
    public init(threshold: Double) {
        self.threshold = UInt8(threshold)
    }
    public func set(threshold: Double) {
        self.threshold = UInt8(threshold)
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
    static public var minValue: Double = 0
    static public var maxValue: Double = 1
    static public var defaultValue: Double = 1
    public init(weighted: Double) {
        if (weighted < 0.5) {
            self.weighted = false
        }
        else {
            self.weighted = true
        }
    }
    public func set(weighted: Double) {
        if (weighted < 0.5) {
            self.weighted = false
        }
        else {
            self.weighted = true
        }
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
    static public var minValue: Double = -255
    static public var maxValue: Double = 255
    static public var defaultValue: Double = 100
    public init(increase: Double) {
        self.increase = Int8(increase)
    }
    public func set(increase: Double) {
        self.increase = Int8(increase)
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
