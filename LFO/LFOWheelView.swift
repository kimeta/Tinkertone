import SwiftUI

struct LFOWheelView: View {
    @ObservedObject var conductor: LFOConductor
    var amplitude: Double
    var isLFO: Bool
    private let phase: CGFloat = 0
    
    var body: some View {
        TimelineView(.animation) { context in
            Canvas { graphicsContext, size in
                drawWheel(in: graphicsContext, size: size)
            }
            .frame(width: 370, height: 370)
        }
    }
    
    private func drawWheel(in graphicsContext: GraphicsContext, size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let maxRadius = CGFloat(amplitude)
        let rotationAngle = -1 * (CGFloat(conductor.tickCount) + CGFloat(conductor.lfoRate)) + phase
        
        var circlePath = Path()
        circlePath.addArc(center: center, radius: maxRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        graphicsContext.stroke(circlePath, with: .color(LFOWheelColor), lineWidth: 2)
        
        let progressAngle = Double(conductor.lfoRate) * 360
        let progressRadians = progressAngle * .pi / 180
        
        var dashedCircle = Path()
        dashedCircle.addArc(center: center, radius: maxRadius / 2, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
        graphicsContext.stroke(dashedCircle, with: .color(LFORateColor), style: StrokeStyle(lineWidth: 1.5, dash: [4]))
        
        let smallCircleRadius: CGFloat = 5 
        let smallCircleX = center.x + cos(progressRadians) * (maxRadius / 2)
        let smallCircleY = center.y + sin(progressRadians) * (maxRadius / 2)
        
        var progressCircle = Path()
        progressCircle.addArc(center: center, radius: maxRadius / 2, startAngle: .zero, endAngle: .degrees(progressAngle), clockwise: false)
        graphicsContext.stroke(progressCircle, with: .color(LFORateColor), lineWidth: 2)
        
        var smallCirclePath = Path()
        smallCirclePath.addArc(center: CGPoint(x: smallCircleX, y: smallCircleY), radius: smallCircleRadius, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        graphicsContext.fill(smallCirclePath, with: .color(LFORateColor))
        
        if isLFO {
            drawLever(in: graphicsContext, from: center, with: maxRadius, rotationAngle: rotationAngle, size: size)
        }
    }
    
    private func drawLever(in graphicsContext: GraphicsContext, from center: CGPoint, with maxRadius: CGFloat, rotationAngle: CGFloat, size: CGSize) {
        let leverEnd = CGPoint(x: center.x + maxRadius * cos(rotationAngle), y: center.y + maxRadius * sin(rotationAngle))
        var leverPath = Path()
        leverPath.move(to: center)
        leverPath.addLine(to: leverEnd)
        graphicsContext.stroke(leverPath, with: .color(LFOWheelColor), lineWidth: 2)
        
        var normalPath = Path()
        normalPath.move(to: leverEnd)
        normalPath.addLine(to: CGPoint(x: size.width - 5, y: leverEnd.y))
        graphicsContext.stroke(normalPath, with: .color(LFOWriterColor), lineWidth: 2)
        
        var endMarker = Path()
        endMarker.addArc(center: CGPoint(x: size.width - 5, y: leverEnd.y), radius: 5, startAngle: .zero, endAngle: .degrees(360), clockwise: true)
        graphicsContext.fill(endMarker, with: .color(LFOWriterColor))
    }
}
