import SwiftUI

struct EnvelopeControlView: View {
    @Binding var position: CGPoint
    var color: Color
    var onDragChange: (CGPoint) -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: padWidth / 4, height: padWidth / 4)
                .overlay(
                    Circle()
                        .fill(color)
                        .frame(width: 44, height: 44)
                        .position(position)
                        .gesture(
                            DragGesture().onChanged { value in
                                onDragChange(value.location)
                            }
                        )
                )
        }
    }
}
