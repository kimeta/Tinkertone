import SwiftUI

public class LFOConductor: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentSignalType: Waveform = .sine
    @Published var frequency: Float = 440
    @Published var lfoAmount: Float = 1.0
    @Published var lfoRate: Float = 0.15
    @Published var lfoValue: Double = 0.0 {
        didSet {
            instrument.tuning = AUValue(lfoValue)
        }
    }
    @Published public var isLFO: Bool = false
    @Published public var tickCount = 0.0
    @Published var isTimerActive: Bool = false
    
    // MARK: - Private Properties
    let engine: AudioEngine = AudioEngine()
    var instrument = AppleSampler()
    var timer: Timer?
    let sampleRate: Double = 44100
    let scale: Double = 0.4
    
    // MARK: - Initialization
    init() {
        instrument.volume = 0
        engine.output = instrument
    }
    
    // MARK: - Timer Control
    func toggleTimer() {
        isTimerActive ? stopTimer() : startTimer()
        isTimerActive.toggle()
    }
    
    private func startTimer() {
        instrument.volume = 20
        setupTimer()
    }
    
    private func stopTimer() {
        instrument.stop()
        timer?.invalidate()
        timer = nil
        instrument.volume = 0
    }
    
    private func setupTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { [weak self] _ in
            self?.updateLFOValue()
        }
    }
    
    // MARK: - LFO Value Update
    private func updateLFOValue() {
        tickCount += Double(lfoRate) * scale
        lfoValue = abs(sin(tickCount)) * Double(lfoAmount)
    }
    
    // MARK: - Engine Control
    func startEngine() {
        do {
            try engine.start()
        } catch {
            print("AudioEngine did not start")
        }
    }
    
    func stopEngine() {
        engine.stop()
        timer?.invalidate()
    }
}
