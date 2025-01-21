import SwiftUI

struct WaveformView: View {
    @Binding var selectedWaveform: Waveform
    @ObservedObject var transitionHandler: TransitionHandler
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Waveform.allCases, id: \.self) { waveform in
                Button(action: {
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    
                    self.selectedWaveform = waveform
                    transitionHandler.startTransition(to: selectedWaveform.controlParameter())
                }) {
                    Text(waveform.getReadableName())
                        .frame(width: padWidth / CGFloat(Waveform.allCases.count), height: 64)
                        .foregroundColor(selectedWaveform == waveform ? .black : .black)
                        .lineLimit(1)
                        .fixedSize(horizontal: true, vertical: false)
                        .background(selectedWaveform == waveform ? waveformSelectedColor : waveformColor)
                        .overlay(Rectangle().stroke(.black, lineWidth: 1))
                    
                }
                .zIndex(selectedWaveform == waveform ? 1 : 0)
            }
        }
        .offset(y: 1)
        .font(F56.small())
    }
}
