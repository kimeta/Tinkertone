import SwiftUI

struct EnvelopeView: View {
    @ObservedObject var conductor: SynthConductor
    @State private var attackDecayPosition = CGPoint(x: 90, y: 90)
    @State private var sustainReleasePosition = CGPoint(x: 90, y: 90)
    
    var body: some View {
        ZStack{
            Group{
                HStack{
                    Text("Attack")
                        .rotationEffect(.degrees(-90), anchor: .center)
                        .offset(x: -10)
                    
                    Spacer()
                    
                    Text("Release")
                        .rotationEffect(.degrees(90), anchor: .center)
                        .offset(x: 10)
                }
                
                HStack{
                    Text("Decay")
                        .offset(x:64, y: -74)
                    
                    Spacer()
                    
                    Text("Sustain")
                        .offset(x:-60, y: -74)
                }
            }
            .font(FA1)
            .foregroundColor(.black.opacity(0.5))
            
            HStack(spacing: 0) {
                EnvelopeControlView(position: $attackDecayPosition, color: attackDecaySelectorColor) { position in
                    updateEnvelopePoint(from: position, isAttackDecay: true)
                }
                
                GeometryReader { geometry in
                    let width = geometry.size.width / 4
                    let height = geometry.size.height
                    let startPoint = CGPoint(x: geometry.size.width / 2, y: height)
                    let decayPoint = CGPoint(x: startPoint.x - width * CGFloat(conductor.decayDur / 2) * 0.75, y: height - width)
                    let attackPoint = CGPoint(x: decayPoint.x - width * CGFloat(conductor.attack / 2) * 0.75, y: height)
                    let sustainPoint = CGPoint(x: startPoint.x + width * 0.75, y: height - width * CGFloat(conductor.sustain))
                    let releasePoint = CGPoint(x: sustainPoint.x + width * CGFloat(conductor.releaseDur / 2) * 0.75, y:height)
                    
                    Group{
                        // Attack segment
                        Path { path in
                            path.move(to: attackPoint)
                            path.addLine(to: decayPoint)
                            path.addLine(to: CGPoint(x: decayPoint.x, y: height))
                            path.closeSubpath()
                        }
                        .fill(.clear)
                        
                        // Decay segment
                        Path { path in
                            path.move(to: startPoint)
                            path.addLine(to: CGPoint(x:startPoint.x, y:sustainPoint.y))
                            path.addLine(to: decayPoint)
                            path.addLine(to: CGPoint(x: decayPoint.x, y: height))
                            path.closeSubpath()
                        }
                        .fill(.clear)
                        
                        // Sustain segment
                        Path { path in
                            path.move(to: startPoint)
                            path.addLine(to: CGPoint(x:startPoint.x, y: sustainPoint.y))
                            path.addLine(to: sustainPoint)
                            path.addLine(to: CGPoint(x: sustainPoint.x, y: height))
                            path.closeSubpath()
                        }
                        .fill(.clear)
                        
                        // Release segment
                        Path { path in
                            path.move(to: sustainPoint)
                            path.addLine(to: releasePoint)
                            path.addLine(to: CGPoint(x: sustainPoint.x, y: height))
                            path.closeSubpath()
                        }
                        .fill(.clear)
                        
                        //Outline path
                        Path{ path in
                            let control = CGPoint(x: attackPoint.x, y: decayPoint.y)
                            let control2 = CGPoint(x: decayPoint.x, y: sustainPoint.y)
                            let control3 = CGPoint(x: sustainPoint.x, y: releasePoint.y)
                            path.move(to:attackPoint)
                            path.addQuadCurve(to: decayPoint, control: control)
                            path.addQuadCurve(to: CGPoint(x: startPoint.x, y: sustainPoint.y), control: control2)
                            path.addLine(to: sustainPoint)
                            path.addQuadCurve(to: releasePoint, control: control3)
                        }.stroke(ADSRConnectionLinesColor, lineWidth: 2)
                        
                        //Dashed lines
                        Path{ path in
                            path.move(to:CGPoint(x: decayPoint.x, y: height))
                            path.addLine(to: decayPoint)
                        }.stroke(ADSRConnectionLinesColor, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        
                        Path{ path in
                            path.move(to: startPoint)
                            path.addLine(to: CGPoint(x: startPoint.x, y: sustainPoint.y))
                        }.stroke(ADSRConnectionLinesColor, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        
                        Path{ path in
                            path.move(to: CGPoint(x:sustainPoint.x, y: height))
                            path.addLine(to: sustainPoint)
                        }.stroke(ADSRConnectionLinesColor, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        
                        Path{ path in
                            path.move(to: CGPoint(x:attackPoint.x, y: height))
                            path.addLine(to: releasePoint)
                        }.stroke(ADSRConnectionLinesColor, style: StrokeStyle(lineWidth: 1.5, dash: [4]))
                        
                        // Circles
                        Path{ path in
                            path.addArc(center: attackPoint, radius:7, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                            path.addArc(center: decayPoint, radius: 7, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                            path.addArc(center: CGPoint(x: startPoint.x, y: sustainPoint.y), radius: 7, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                            path.addArc(center: CGPoint(x: sustainPoint.x, y: sustainPoint.y), radius: 7, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                            path.addArc(center: releasePoint, radius: 7, startAngle: .zero, endAngle: .degrees(360), clockwise: false)                            
                            
                        }.fill(.orange)
                    }
                    .offset(CGSize(width: 0, height: -height / 4))
                }
                
                EnvelopeControlView(position: $sustainReleasePosition, color: sustainReleaseSelectorColor) { position in
                    updateEnvelopePoint(from: position, isAttackDecay: false)
                }
            }
        }
        .frame(width: padWidth, height: padWidth / 4)
        .onAppear(){
            updateEnvelopePoint(from: sustainReleasePosition, isAttackDecay: false)                      
            updateEnvelopePoint(from: attackDecayPosition, isAttackDecay: true)
        }
    }
    
    private func updateEnvelopePoint(from position: CGPoint, isAttackDecay: Bool) {
        let clampedX = min(max(position.x, 0), 180)
        let clampedY = min(max(position.y, 0), 180)
        let xPercent = clampedX / 180
        let yPercent = clampedY / 180
        let releaseX =  180 - clampedX
        let releasePercent = releaseX / 180.0
        if isAttackDecay {
            attackDecayPosition = CGPoint(x: clampedX, y: clampedY)
            conductor.attack = Float(0.01 + (2.0 - 0.01) * (1 - xPercent))
            conductor.decayDur = Float(0.01 + (2.0 - 0.01) * (1 - yPercent))
        } else {
            sustainReleasePosition = CGPoint(x: clampedX, y: clampedY)
            conductor.sustain = Float(1 - yPercent)
            conductor.releaseDur = Float(0.01 + (2.0 - 0.01) * (1 - releasePercent))
        }
        
        conductor.envelope.attackDuration = conductor.attack
        conductor.envelope.decayDuration = conductor.decayDur
        conductor.envelope.sustainLevel = conductor.sustain
        conductor.envelope.releaseDuration = conductor.releaseDur
    }
}
