import SwiftUI

struct WavesView: View {
    @Binding var firstOctave: Int
    private let octaveCount = 1
    @Binding public var waveModel: Waveform
    @AppStorage("amp") private var amp: Double = 70
    @AppStorage("previousAmp") private var previousAmp: Double = 70
    @State private var previousFrequency: Double = 0
    @State private var selectedFrequency:Double = 440
    @State private var offsetFreq: Double = 0
    @State private var octaveFrequency:Double = 0
    @ObservedObject private var conductor: SynthConductor
    @ObservedObject private var LFOcond: LFOConductor
    @ObservedObject private var transitionHandler:TransitionHandler
    
    init(firstOctave: Binding<Int>, conductor:SynthConductor, LFOcond: LFOConductor, waveModel: Binding<Waveform>, transitionHandler: TransitionHandler){
        self._firstOctave = firstOctave
        self._waveModel = waveModel
        self.conductor = conductor
        self.LFOcond = LFOcond
        self.transitionHandler = transitionHandler
    }
    
    var frequenciesArray: [Double] {
        let startPitchValue = firstOctave * 12 + 24
        let endPitchValue = firstOctave * 12 + octaveCount * 12 + 24 + 1
        return (startPitchValue..<endPitchValue).map { midiNoteNumber in
            let frequency = pow(2.0, Double(midiNoteNumber - 69) / 12.0) * 440.0
            return frequency
        }
    }
    
    func wavelength(fromFrequency frequency: Double) -> Measurement<UnitLength> {
        let speedOfLight = Measurement(value: 343, unit: UnitSpeed.metersPerSecond)
        let frequencyMeasurement = Measurement(value: frequency, unit: UnitFrequency.hertz)
        
        let wavelengthInMeters = speedOfLight.converted(to: .metersPerSecond).value / frequencyMeasurement.value
        return Measurement(value: wavelengthInMeters, unit: UnitLength.meters)
    }
    
    var body: some View {
        HStack{
            
            ZStack{
                ForEach(frequenciesArray.indices, id: \.self) { index in
                    let frequency:Double = frequenciesArray[index]
                    let isPlayed = self.conductor.activeNotes.contains( Int(round(frequenciesArray[index])) )
                    InterpolatingWaveShape(frequency: frequency + offsetFreq, amplitude: amp, waveformIndexFrom: transitionHandler.waveformIndexFrom, waveformIndexTo: transitionHandler.waveformIndexTo, transitionProgress: transitionHandler.transitionProgress, LFOconductor: LFOcond)
                        .stroke(isPlayed ? (Color(PitchColor.newtonian[index % 12])): Color.black, lineWidth: isPlayed ? 4 : 0.5)
                        .frame(height: 360)
                        .drawingGroup()
                }.contentShape(Rectangle())
                    .simultaneousGesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                        .onChanged { gesture in
                            let newAmp = previousAmp + gesture.translation.height * 0.7
                            amp = min(max(newAmp, -137), 137)
                            conductor.amplitude = abs(amp) / 137
                            let minOffset = 130 - frequenciesArray[6]
                            let maxOffset = 2090 - frequenciesArray[6]
                            let newFrequency = gesture.translation.width * CGFloat(-firstOctave) * 0.75
                            offsetFreq = min(max(newFrequency, Double(minOffset)), Double(maxOffset))
                            
                        }
                        .onEnded { _ in
                            let frequencyRef: Double = 440.0  // Reference frequency (A4)
                            let octaveRef: Double = 4.0
                            let octaveFreq: Double = Double(frequenciesArray[6]) + offsetFreq
                            let octaveNew = log2(octaveFreq / frequencyRef) + octaveRef
                            firstOctave = min(Int(floor(octaveNew)), 5)
                            
                            withAnimation(Animation.spring(response: 0.15, dampingFraction: 0.15, blendDuration: 0)){
                                previousAmp = amp
                                offsetFreq = 0
                            }
                        }
                    )
                    .simultaneousGesture(
                        MagnifyGesture()
                            .onChanged { value in
                                let minOffset = 261 - frequenciesArray[6]
                                let maxOffset = 2080 - frequenciesArray[6]
                                let newFrequency = (100 * Double((value.magnification - 1)) * Double(firstOctave))
                                offsetFreq = min(max(newFrequency, Double(minOffset)), Double(maxOffset))
                                
                            }
                            .onEnded { value in
                                withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.2, blendDuration: 0)){
                                    previousAmp = amp
                                    let frequencyRef: Double = 440.0  // Reference frequency (A4)
                                    let octaveRef: Double = 4.0
                                    let octaveFreq: Double = Double(frequenciesArray[6]) + offsetFreq
                                    let octaveNew = log2(octaveFreq / frequencyRef) + octaveRef
                                    firstOctave = min(Int(floor(octaveNew)), 5)
                                    offsetFreq = 0
                                }
                            }
                    )
            }        .frame(width: padWidth, height: padWidth / 2)
                .offset(y: 1)
        }
    }
}
