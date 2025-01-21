/*
 Copyright © 2024 Mihailo Marković. All rights reserved.
 See LICENSE folder for this app's licensing information.
 
 Abstract:
 Provides a user interface for musical synthesis
 */

import SwiftUI
import Combine

struct ContentView: View {
    // MARK: - State Objects
    @StateObject private var orientationObserver = OrientationObserver()
    
    @StateObject var conductor = SynthConductor()
    @StateObject var chordIdentifier = ChordIdentifier()
    @StateObject var transitionHandler = TransitionHandler()
    @State private var selectedWaveform: Waveform = .sine
    @State private var firstOctave = 3
    
    // MARK: - Body
    var body: some View {
        Group {
            if orientationObserver.isLandscape {
                Text("Rotate device to portrait.")
                    .font(F56.large())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .multilineTextAlignment(.center)
            } else {
                mainContentView
            }
        }
    }
    
    // MARK: - Private Views
    private var mainContentView: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                padView
                waveformView
                keyboardScrollView
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: conductor.start)
        .onDisappear(perform: conductor.stop)
        
    }
    
    private var padView: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .overlay(Rectangle().fill(padBackroundColor).stroke(.black, lineWidth: 1))
                .frame(width: padWidth, height: padWidth)
            
            ZStack(alignment: .center) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.conductor.toggleLFO()
                    }
                }) {
                    if conductor.isLFO {
                        Image(systemName: "waveform.path")
                            .font(.system(size: 22, weight: .thin))
                            .frame(width: LFOToggleSize, height: LFOToggleSize)
                            .background(LFOToggleOnColor)
                            .foregroundColor(appBackgroundColor)
                            .cornerRadius(12)
                    } else {
                        Text("LFO")
                            .font(F56.small())
                            .frame(width: LFOToggleSize, height: LFOToggleSize)
                            .background(LFOToggleOnColor)
                            .foregroundColor(appBackgroundColor)
                            .cornerRadius(12)
                    }
                }
            }
            .frame(width: padWidth / 4, height: padWidth / 4)
            
            ZStack(alignment: .topTrailing) {
                VStack{
                    Text("Tinkertone")
                        .padding(.top, 10)
                    
                    HStack(alignment: .top, spacing: 6) {
                        VStack(alignment: .trailing, spacing: 5) {
                            Text("C4")
                            Text("Ratio")
                            Text("Pitch")
                            Text("Scale")
                            Text("Range")
                            Text("Color")
                        }
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("1.31 m")
                            Text("1 : 12")
                            Text("A440")
                            Text("C Major")
                            Text("C3 to C6")
                            Text("Newtonian")
                        }
                    }
                    .padding(10)
                    .foregroundColor(.black.opacity(1 / 3))
                }
                .font(FA1)
                .padding(10)
                .zIndex(3)
                
                VStack(spacing: 0) {
                    ChordView(chordIdentifier: chordIdentifier)
                    lfoAndWavesView
                    EnvelopeView(conductor: conductor)
                }
                .background(gridlineBackground)
            }
        }
        .zIndex(5)
    }
    
    private var waveformView: some View {
        WaveformView(selectedWaveform: $selectedWaveform, transitionHandler: transitionHandler)
            .onChange(of: selectedWaveform, initial: true) { oldWaveform, newWaveform in
                if newWaveform != oldWaveform {
                    self.conductor.setWaveform(newWaveform)
                }
            }
            .offset(y: -1)
    }
    
    private var keyboardScrollView: some View {
        ScrollView(.horizontal) {
            SynthKeyboardView(firstOctave: firstOctave, octaveCount: 1, noteOn: { pitch, point in
                self.conductor.noteOn(pitch: pitch, point: point)
                self.chordIdentifier.noteOn(pitch: pitch)
            }, noteOff: { pitch in
                self.conductor.noteOff(pitch: pitch)
                self.chordIdentifier.noteOff(pitch: pitch)
            })
        }
        .background(.black.opacity(0.25))
        .outline()
        .frame(width: padWidth)
        .scrollIndicators(.hidden)
        .scrollDisabled(true)
    }
    
    private var lfoAndWavesView: some View {
        ZStack(alignment: .leading) {
            if conductor.LFOconductor.isLFO {
                LFOPadView(conductor: conductor.LFOconductor).zIndex(2)
            } else {
                WavesView(firstOctave: $firstOctave, conductor: conductor, LFOcond: conductor.LFOconductor, waveModel: $selectedWaveform, transitionHandler: transitionHandler)
                    .zIndex(2)
            }
        }
    }
    
    public var gridlineBackground: some View {
        Gridline(every: 16)
            .stroke(Color.black, lineWidth: 0.5)
            .background(
                Gridline(every: 4)
                    .stroke(Color.black, lineWidth: 1)
            )
            .opacity(0.1)
    }
}

/// An `ObservableObject` that observes and publishes changes in device orientation.
class OrientationObserver: ObservableObject {
    // MARK: - Published Properties
    @Published var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    init() {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.isLandscape = UIDevice.current.orientation.isLandscape
                }
            }
            .store(in: &cancellables)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
    }
    
    // MARK: - Deinitializer
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
}
