import SwiftUI

struct LFOWaveView: Shape {
    var coefficient: Double
    var frequency: Double
    var scaleFrequency: Double = 0.005
    @ObservedObject var conductor: LFOConductor
    
    var animatableData: Double {
        get { frequency }
        set { frequency = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = Double(rect.width)
        let height = Double(rect.height)
        let midHeight = height / 2
        let wavelength = width / (frequency * scaleFrequency)
        
        for x in stride(from: 0, through: width, by: 0.1) {
            let newX = x
            let y = sineWave(x: newX, wavelength: wavelength, coefficient: coefficient, midHeight: midHeight)
            if x == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path.strokedPath(.init(lineWidth: 1, lineCap: .round, lineJoin: .round))
    }
    
    private func sineWave(x: Double, wavelength: Double, coefficient: Double, midHeight: Double) -> Double {
        let LFOmove = -(CGFloat(conductor.tickCount) + CGFloat(conductor.lfoRate))
        let relativeX = x / wavelength * 2 * .pi + Double(LFOmove)
        return coefficient * sin(relativeX) + midHeight
    }
}
