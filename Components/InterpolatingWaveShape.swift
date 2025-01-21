import SwiftUI

struct InterpolatingWaveShape: Shape {
    var frequency: Double = 440
    var phase: Double = 0 // For LFO must be zero
    var amplitude: Double
    var waveformIndexFrom: Int
    var waveformIndexTo: Int
    var transitionProgress: Double
    var scaleFreq: Double = 1 / 1000
    @ObservedObject var LFOconductor: LFOConductor
    
    var animatableData: AnimatablePair<Double, AnimatablePair<Double, Double>> {
        get {
            AnimatablePair(frequency, AnimatablePair(transitionProgress, Double(waveformIndexTo)))
        }
        set {
            frequency = newValue.first
            transitionProgress = newValue.second.first
            waveformIndexTo = Int(newValue.second.second)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = Double(rect.width)
        let scaleFreq: Double = 0.005
        let wavelength = width / (frequency * scaleFreq)
        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / wavelength * 2 * .pi + phase
            let y = getYValue(x: relativeX, rect: rect)
            if x == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
    
    private func getYValue(x: Double, rect: CGRect) -> Double {
        let midHeight = Double(rect.height) / 2.0
        let currentWaveValue = calculateWaveValue(x: x, typeIndex: waveformIndexFrom, rect: rect)
        let nextWaveValue = calculateWaveValue(x: x, typeIndex: waveformIndexTo, rect: rect)
        
        let interpolatedValue = interpolate(from: currentWaveValue, to: nextWaveValue, with: transitionProgress)
        return interpolatedValue * amplitude + midHeight
    }
    
    private func calculateWaveValue(x: Double, typeIndex: Int, rect: CGRect) -> Double {
        switch typeIndex {
        case 0: // Sine
            return sin(x)
        case 1: // Square
            return sin(x) >= 0 ? 1 : -1
        case 2: // Triangle
            let relativeX = x.truncatingRemainder(dividingBy: 2 * .pi)
            return 2 * abs(2 * (relativeX / (2 * .pi)) - 1) - 1
        case 3: // Sawtooth
            let relativeX = x.truncatingRemainder(dividingBy: 2 * .pi)
            return 2 * (relativeX / (2 * .pi)) - 1
        default:
            return sin(x)
        }
    }
    
    private func interpolate(from startValue: Double, to endValue: Double, with factor: Double) -> Double {
        return startValue + (endValue - startValue) * factor
    }
}
