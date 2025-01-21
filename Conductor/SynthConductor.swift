import Foundation
import SwiftUI

class SynthConductor: ObservableObject, HasAudioEngine {
    @Published var engine = AudioEngine()
    @Published var LFOconductor: LFOConductor
    var oscillator: Oscillator
    let envelope: AmplitudeEnvelope
    
    @Published var attack: Float = 0.2
    @Published var decayDur: Float = 0.2
    @Published var releaseDur: Float = 0.2
    @Published var sustain: Float = 0.2
    @Published public var isLFO: Bool = false 
    @Published var activeNotes: Set<Int> = []
    @Published var amplitude: Double = 1.0
    func toggleLFO() {
        isLFO.toggle()
        LFOconductor.isLFO = isLFO
    }
    
    func noteOn(pitch: Pitch, point _: CGPoint) {
        if(LFOconductor.isLFO){
            oscillator.frequency = Float(pitch.frequency)
            oscillator.amplitude = 1.0
            LFOconductor.toggleTimer()
            envelope.openGate()
            withAnimation(Animation.linear(duration: 0.15)){
                LFOconductor.frequency = Float(pitch.frequency)
            }
        }else{
            oscillator.frequency = Float(pitch.frequency)
            oscillator.amplitude = Float(amplitude)
            envelope.openGate()
            DispatchQueue.main.async {
                self.activeNotes.insert(Int(round(pitch.frequency)))
            }
        }
    }
    
    func noteOff(pitch: Pitch) {
        if(isLFO){
            LFOconductor.toggleTimer()
            LFOconductor.instrument.stop(noteNumber: MIDINoteNumber(pitch.midiNoteNumber), channel: 0)
            envelope.closeGate()
        }else{
            envelope.closeGate()
            DispatchQueue.main.async {
                self.activeNotes.remove(Int(round(pitch.frequency)))
            }
        }
    }
    
    func setWaveform(_ waveform: Waveform) {
        oscillator.setWaveform(waveform.getTable())
        LFOconductor.currentSignalType = waveform
    }
    
    func stop() {
        engine.stop()
    }
    var outputNode: Mixer = Mixer()
    
    init() {
        let localLFOConductor = LFOConductor()
        self.LFOconductor = localLFOConductor
        self.oscillator = Oscillator(LFOconductor: localLFOConductor)
        envelope = AmplitudeEnvelope(oscillator)
        envelope.attackDuration = 0.2
        envelope.decayDuration = 1.0
        envelope.sustainLevel = 1.0
        envelope.releaseDuration = 0.2
        envelope.start()
        oscillator.start()
        outputNode.addInput(envelope)
        outputNode.addInput(LFOconductor.instrument)
        engine.output = PeakLimiter(outputNode)
    }
}
