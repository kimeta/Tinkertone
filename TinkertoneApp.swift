/*
Copyright © 2024 Mihailo Marković. All rights reserved.
See LICENSE folder for this app's licensing information.
 
Abstract:
The entry point for the Tinkertone app for iPad.
*/

import SwiftUI

@main
struct TinkertoneApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .background(Hatching(spacing: 8, lineWidth: 0.5, angleDegrees: 45, backgroundColor: appBackgroundColor, lineColor: hatchingLinesColor))
                .preferredColorScheme(.light)
                .ignoresSafeArea()
        }
    }
    
    init() {
        FontManager.shared.loadFonts()
    }
}
