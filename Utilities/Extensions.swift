import SwiftUI

extension View {
    func outline(color: Color = .black, width: CGFloat = 1) -> some View {
        self.modifier(Outline(color: color, width: width))
    }
    
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(BorderEdge(width: width, edges: edges).foregroundColor(color))
    }
}

extension Pitch {
    var frequency: Double {
        let referencePitch = Int8(69)
        let referenceFrequency = 440.0
        let semitonesFromA4 = Double(self.midiNoteNumber - referencePitch)
        return referenceFrequency * pow(2.0, semitonesFromA4 / 12.0)
    }
}

extension Double {
    var formatted: (value: String, unit: String) {
        self >= 1000 ? (String(format: "%.2f", self / 1000), "kHz") : (String(format: "%.1f", self), "Hz")
    }
}

extension Chord {
    var inversionText: String {
        ["Root Position", "1st Inversion", "2nd Inversion", "3rd Inversion", "4th Inversion", "5th Inversion"][inversion]
    }
    
    var descriptionWithInversion: String {
        "\(description) \(inversionText)"
    }
}
