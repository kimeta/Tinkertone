import SwiftUI

struct SynthKeyboardView: View {
    var firstOctave: Int
    var octaveCount: Int
    
    var body: some View {
        let totalKeys = octaveCount * 7 + 1
        let keyboardWidth = CGFloat(totalKeys) * whiteKeyWidth
        
        HStack {
            Keyboard(layout: .piano(pitchRange: Pitch(intValue: firstOctave * 12 + 24) ... Pitch(intValue: firstOctave * 12 + octaveCount * 12 + 24),
                                    initialSpacerRatio: initialSpacerRatio,
                                    spacerRatio: spacerRatio,
                                    relativeBlackKeyWidth: relativeBlackKeyWidth,
                                    relativeBlackKeyHeight: relativeBlackKeyHeight),
                     noteOn: noteOn,
                     noteOff: noteOff)
            { pitch, isActivated in
                let note = pitch.note(in: .C)
                let isWhite = note.accidental == .natural
                
                ZStack {
                    Rectangle()
                        .foregroundColor(isWhite ? whiteKeyColor : blackKeyColor)
                        .outline()
                    if isActivated {
                        Rectangle().foregroundColor(Color(PitchColor.newtonian[Int(pitch.pitchClass)]))
                    }
                    
                    VStack {
                        if note.letter == .C && note.accidental == .natural {
                            Text(note.description)
                                .foregroundColor(isActivated ? .white : (isWhite ? .black : .white))
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                .padding(6)
                        }
                        
                        Spacer()
                        
                        Rectangle()
                            .fill(.clear)
                            .overlay(
                                HStack(spacing: 0) {
                                    Text(pitch.frequency.formatted.value)
                                        .monospacedDigit()
                                    Text(pitch.frequency.formatted.unit).opacity(0.4)
                                }
                                    .rotationEffect(.degrees(-90), anchor: .topLeading)
                                    .offset(x: 6, y: 8)
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                                    .foregroundColor(isActivated ? .white : (isWhite ? .black : .white)),
                                alignment: .bottomLeading)
                    }
                }
            }
            .font(FA1)
            .frame(width: keyboardWidth, height: 216)
            .border(.black)
        }
    }
    
    var noteOn: (Pitch, CGPoint) -> Void
    var noteOff: (Pitch) -> Void
    
    var initialSpacerRatio: [Letter: CGFloat] = [
        .C: CGFloat(2) / 3
    ]
    
    var spacerRatio: [Letter: CGFloat] = [
        .C: CGFloat(0),
        .D: CGFloat(1) / 3,
        .E: CGFloat(1) / 3,
        .F: CGFloat(1),
        .G: CGFloat(1) / 3,
        .A: CGFloat(1) / 3,
        .B: CGFloat(4) / 3
    ]
    
    var relativeBlackKeyWidth: CGFloat = 2 / 3
    var relativeBlackKeyHeight: CGFloat = 1 / 2
}
