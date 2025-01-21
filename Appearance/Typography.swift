import SwiftUI

public let FA1 = Font.custom("FA-1-Regular", size: 11)

struct F56 {
    static let fontName = "F5.6-Regular"
    
    static func large() -> Font {
        return Font.custom(fontName, size: 24)
    }
    
    static func small() -> Font {
        return Font.custom(fontName, size: 12)
    }
}
