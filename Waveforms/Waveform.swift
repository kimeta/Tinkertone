import Foundation

enum Waveform: Int, CaseIterable {
    case sine
    case triangle
    case square
    case saw
    
    private func pulseWave(pulseSize: Float = 0.25) -> [Table.Element] {
        var table = [Table.Element](zeros: 4096)
        for i in 0..<4096 {
            table[i] = i < Int(4096.0 * (pulseSize)) ? Float(1): Float(-1)
        }
        return table
    }
    
    func getTable() -> Table {
        switch self {
        case .sine:
            return Table(.sine)
        case .square:
            return Table(.square)
        case .saw:
            return Table(.sawtooth)
        case .triangle:
            return Table(.triangle)
        }
    }
    func controlParameter() -> Int {
        switch self {
        case .sine:
            return 0
        case .square:
            return 1
        case .saw:
            return 3
        case .triangle:
            return 2
        }
    }
    
    func getReadableName() -> String {
        let names: [Waveform: String] = [
            .sine: "Sine",
            .square: "Square",
            .saw: "Sawtooth",
            .triangle: "Triangle"]
        return names[self]!
    }
}
