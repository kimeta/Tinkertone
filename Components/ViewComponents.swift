import SwiftUI

struct Gridline: Shape {
    let every: Int // Number of grid divisions
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let spacing = rect.size.width / CGFloat(every)
        
        // Adjusted loop to start from 1 and end at every - 1 to exclude first and last vertical lines
        for i in 1..<every {
            let position = CGFloat(i) * spacing
            path.move(to: CGPoint(x: position, y: 0))
            path.addLine(to: CGPoint(x: position, y: rect.size.height))
        }
        
        // Adjusted loop to start from 1 and end at every - 1 to exclude first and last horizontal lines
        for i in 1..<every {
            let position = CGFloat(i) * spacing
            path.move(to: CGPoint(x: 0, y: position))
            path.addLine(to: CGPoint(x: rect.size.width, y: position))
        }
        
        return path.strokedPath(StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
    }
}

struct Hatching: View {
    var spacing: CGFloat
    var lineWidth: CGFloat
    var angleDegrees: CGFloat
    let backgroundColor: Color
    let lineColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let radians = angleDegrees * .pi / 180 // Convert angle to radians
                
                // Calculate extended coverage
                let maxDimension = max(geometry.size.width, geometry.size.height) * 2 // Ensure full coverage
                let diagonal = sqrt(pow(maxDimension, 2) + pow(maxDimension, 2))
                let extendedDiagonal = diagonal * 1.1 // Extend by 10%
                let numberOfLines = Int(ceil(extendedDiagonal / spacing))
                
                for index in -numberOfLines...numberOfLines {
                    let xAdjustment = CGFloat(index) * spacing
                    
                    let startX = cos(radians) * xAdjustment - sin(radians) * extendedDiagonal
                    let startY = sin(radians) * xAdjustment + cos(radians) * extendedDiagonal
                    let endX = cos(radians) * xAdjustment + sin(radians) * extendedDiagonal
                    let endY = sin(radians) * xAdjustment - cos(radians) * extendedDiagonal
                    
                    path.move(to: CGPoint(x: startX, y: startY))
                    path.addLine(to: CGPoint(x: endX, y: endY))
                }
            }
            .stroke(lineColor, lineWidth: lineWidth)
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(backgroundColor)
    }
}
