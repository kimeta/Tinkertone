import Foundation
import AVFoundation
import CoreAudio

public class Oscillator: Node {
    private static let twoPi = 2 * Float.pi
    
    private var currentPhase: Float = 0
    private var _frequency: Float = 440
    private lazy var sourceNode = createSourceNode()
    
    public var frequency: Float {
        get { _frequency }
        set { _frequency = max(10, min(newValue, 20_000)) }
    }
    
    public var amplitude: AUValue = 1
    public var connections: [Node] { [] }
    public var avAudioNode: AVAudioNode { sourceNode }
    
    fileprivate var waveform: Table?
    var LFOconductor: LFOConductor
    
    public init(LFOconductor: LFOConductor, waveform: Table = Table(.sine), frequency: AUValue = 440, amplitude: AUValue = 0) {
        self.LFOconductor = LFOconductor
        self.waveform = waveform
        self.frequency = frequency
        self.amplitude = amplitude
    }
    
    public func setWaveform(_ waveform: Table) {
        self.waveform = waveform
    }
    
    private func createSourceNode() -> AVAudioSourceNode {
        AVAudioSourceNode { [weak self] _, _, frameCount, audioBufferList in
            guard let self = self else { return noErr }
            
            let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let addition = self.LFOconductor.isLFO ? self.LFOconductor.lfoValue : 1
            let phaseIncrement = (Oscillator.twoPi / Float(Settings.sampleRate)) * (self.frequency * Float(addition))
            
            for frame in 0 ..< Int(frameCount) {
                self.processFrame(frame, phaseIncrement, ablPointer)
            }
            
            return noErr
        }
    }
    
    private func processFrame(_ frame: Int, _ phaseIncrement: Float, _ ablPointer: UnsafeMutableAudioBufferListPointer) {
        let index = Int(currentPhase / Oscillator.twoPi * Float(waveform!.count))
        let value = waveform![index] * amplitude
        
        currentPhase += phaseIncrement
        if currentPhase >= Oscillator.twoPi { currentPhase -= Oscillator.twoPi }
        if currentPhase < 0.0 { currentPhase += Oscillator.twoPi }
        
        for buffer in ablPointer {
            let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
            buf[frame] = value
        }
    }
}
