import SwiftUI

struct LFOPadView: View {
    @ObservedObject private var conductor: LFOConductor
    @State private var amplitude: Double = 90
    @State private var previousAmount: Float
    @State private var previousRate: Float
    init(conductor: LFOConductor) {
        self.conductor = conductor
        previousAmount = conductor.lfoAmount
        previousRate = conductor.lfoRate
    }
    
    var body: some View {
        ZStack {
            VStack {
                waveStack
            }
            .frame(maxHeight: .infinity)
        }
        .frame(width: padWidth, height: padWidth / 2)
        .onAppear(perform: conductor.startEngine)
        .onDisappear(perform: conductor.stopEngine)
    }
    
    private var waveStack: some View {
        ZStack{
            HStack {
                LFOWheelView(conductor: conductor, amplitude: amplitude * Double(conductor.lfoAmount), isLFO: true)
                    .zIndex(2)
                    .frame(width:355, height: 360)
                    .offset(CGSize(width: 4, height: -2))
                
                LFOWaveView(coefficient: amplitude * Double(conductor.lfoAmount), frequency: Double(conductor.frequency), conductor: conductor)
                    .zIndex(1)
                    .frame(width:360, height: 200)
                    .offset(CGSize(width: 0, height: 0))
                    .clipped()
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
            .onChanged { gesture in
                let newAmount = CGFloat(previousAmount) + gesture.translation.height * 0.01
                conductor.lfoAmount = Float(min(max(newAmount, 0), 1))
                
                let newRate = gesture.translation.width * 0.005 + CGFloat(previousRate)
                conductor.lfoRate = Float(min(max(newRate, 0), 1))
                
            }
            .onEnded { _ in
                withAnimation(Animation.spring(response: 0.15, dampingFraction: 0.15, blendDuration: 0)){
                    previousAmount = conductor.lfoAmount
                    previousRate = conductor.lfoRate
                }
            })
    }
}
