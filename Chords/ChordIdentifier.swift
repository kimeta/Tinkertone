import Foundation
import Combine

class ChordIdentifier: ObservableObject {
    private var chordDetectionQueue = DispatchQueue(label: "chordDetectionQueue", attributes: .concurrent)
    private var updateQueue = DispatchQueue.main
    
    func noteOn(pitch: Pitch, position: CGPoint = .zero) {
        pitchSet.add(pitch)
        notes.append(Note(pitch: pitch))
    }
    
    func noteOff(pitch: Pitch) {
        pitchSet.remove(pitch)
        notes.removeAll(where: {$0.pitch == pitch})
    }
    
    @Published var notes: [Note] = [] {
        didSet {
            chordDetectionQueue.async { [weak self] in
                guard let self = self else { return }
                let potentialChords = self.getPotentialChords()
                self.updateQueue.async {
                    self.potentialChords = potentialChords
                }
            }
        }
    }
    
    @Published var pitchSet: PitchSet = .init() {
        didSet {
            chordDetectionQueue.async { [weak self] in
                guard let self = self else { return }
                let potentialChords = self.getPotentialChords()
                self.updateQueue.async {
                    self.potentialChords = potentialChords
                }
            }
        }
    }
    
    var noteSet: NoteSet {
        return NoteSet(notes: pitchSet.array.map { Note(pitch: $0) })
    }
    
    @Published var chord: Chord?
    
    @Published var potentialChords = [Chord]() {
        didSet {
            if potentialChords != oldValue {
                chord = getDefaultChord()
            }
        }
    }
    
    func text(pitch: Pitch) -> String {
        if let chord = chord {
            if pitchSet.array.map({ $0.midiNoteNumber }).contains(pitch.midiNoteNumber) {
                var note = pitch.note(in: detectedKey).noteClass.canonicalNote
                let root = chord.root.canonicalNote
                if root.noteNumber > note.noteNumber {
                    note = Note(note.letter, accidental: note.accidental, octave: note.octave + 1)
                }
                
                let interval = Interval.betweenNotes(root, note)
                return interval?.description ?? "R"
            }
        }
        return ""
    }
    
    var genericPitchSetDescription: String {
        guard potentialChords.count == 0 else { return " " }
        
        if pitchSet.count == 0 {
            return " "
        }
        if pitchSet.count == 1 {
            return pitchSet.first!.note(in: .C).description
        }
        
        if pitchSet.count == 2 {
            let note1 = pitchSet.array[0].note(in: .C)
            let note2 = pitchSet.array[1].note(in: .C)
            var intervalString = ""
            if let interval = Interval.betweenNotes(note1, note2) {
                intervalString = interval.description
            }
            return intervalString + " " + note1.description + " + " + note2.description
        }
        
        return pitchSet.array.map { $0.note(in: .C).description }.joined(separator: " + ")
    }
    
    var detectedKey: Key {
        let keys: [Key] = [.C, .G, .F, .D, .Bb, .A, .Eb, .E, .Ab, .B, .Db]
        for key in keys {
            if pitchSet.chord(in: key) != nil {
                return key
            }
        }
        return .C
    }
    
    private func getPotentialChords() -> [Chord] {
        return Chord.getRankedChords(from: pitchSet)
    }
    
    private func getDefaultChord() -> Chord? {
        if potentialChords.count > 0 {
            return potentialChords[0]
        } else {
            return nil
        }
    }
    
    // creates a chord and then removes it (hack to prevent UI hang)
    private func addThenRemovePitchSetForTriad() {
        pitchSet.add(Pitch.init(48))
        pitchSet.add(Pitch.init(52))
        pitchSet.add(Pitch.init(56))
        _ = text(pitch: .init(48))
        pitchSet.remove(Pitch.init(48))
        pitchSet.remove(Pitch.init(52))
        pitchSet.remove(Pitch.init(56))
    }
}
