import SwiftUI

struct ChordView: View {
    @ObservedObject var chordIdentifier: ChordIdentifier
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            ChordTextView(chord: $chordIdentifier.chord,
                          potentialChords: chordIdentifier.potentialChords,
                          genericPitchSetDescription: chordIdentifier.genericPitchSetDescription)
        }
    }
    
    struct ChordTextView: View {
        @Binding var chord: Chord?
        let potentialChords: [Chord]
        let genericPitchSetDescription: String
        
        var body: some View {
            HStack {
                Group {
                    if potentialChords.isEmpty {
                        singleChordText(genericPitchSetDescription)
                    } else if potentialChords.count == 1, let chord = chord {
                        singleChordText(chord.description + " " + chord.inversionText)
                    } else {
                        VStack {
                            ForEach(potentialChords, id: \.description) { chord in
                                singleChordText(chord.description + " " + chord.inversionText)
                            }.font(F56.large())
                        }
                    }
                }
                .frame(width: padWidth, height: padWidth / 4)
            }
        }
        
        @ViewBuilder
        private func singleChordText(_ text: String) -> some View {
            let parts = splitTextWithStyles(text: text)
            HStack(spacing: 0) {
                ForEach(parts, id: \.self) { part in
                    Text(part.text)
                        .font(part.isSymbol ? .system(size: 24, weight: .regular) : F56.large())
                }
            }
        }
        
        private func splitTextWithStyles(text: String) -> [TextPart] {
            let symbols: [Character: Bool] = [
                "♯": true,  // Sharp
                "♭": true,  // Flat
                "𝄫": true,  // Double flat
                "𝄪": true,  // Double sharp
                "°": true,  // Diminished chords
                "⌀": true,  // 
                "+": true
            ]
            var parts: [TextPart] = []
            var currentPart: String = ""
            var isCurrentPartSymbol: Bool? = nil
            
            for char in text {
                if let isSymbol = symbols[char] {
                    if let isCurrentSymbol = isCurrentPartSymbol, isSymbol == isCurrentSymbol {
                        currentPart.append(char)
                    } else {
                        if !currentPart.isEmpty {
                            parts.append(TextPart(text: currentPart, isSymbol: isCurrentPartSymbol ?? false))
                        }
                        currentPart = String(char)
                        isCurrentPartSymbol = isSymbol
                    }
                } else {
                    if isCurrentPartSymbol == true {
                        if !currentPart.isEmpty {
                            parts.append(TextPart(text: currentPart, isSymbol: true))
                        }
                        currentPart = String(char)
                        isCurrentPartSymbol = false
                    } else {
                        currentPart.append(char)
                    }
                }
            }
            
            if !currentPart.isEmpty {
                parts.append(TextPart(text: currentPart, isSymbol: isCurrentPartSymbol ?? false))
            }
            
            return parts
        }}
}

struct TextPart: Hashable {
    let text: String
    let isSymbol: Bool
}
