import SwiftUI

class FontManager {
    static let shared = FontManager()
    
    private init() {}
    
    func loadFonts() {
        loadCustomFont(named: "FA-1-Regular", fileType: "otf")
        loadCustomFont(named: "F5.6-Regular", fileType: "otf")
    }
    
    private func loadCustomFont(named fontName: String, fileType: String) {
        guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: fileType),
              let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
              let font = CGFont(fontDataProvider),
              CTFontManagerRegisterGraphicsFont(font, nil) else {
            print("Error registering font: \(fontName)")
            return
        }
    }
}
