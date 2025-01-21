import SwiftUI

public class TransitionHandler: ObservableObject{
    @Published public var waveformIndexFrom: Int = 0
    @Published public var waveformIndexTo: Int = 0
    @Published public var transitionProgress: Double = 1.0
    
    func startTransition(to newIndex: Int) {
        waveformIndexFrom = waveformIndexTo
        waveformIndexTo = newIndex 
        transitionProgress = 0.0 
        
        withAnimation(.easeInOut(duration: 1)) {
            transitionProgress = 1.0
        }
    }
}
