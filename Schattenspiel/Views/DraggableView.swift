//
//  DraggableView.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 09.05.23.
//

import SwiftUI

struct DraggableView: ViewModifier {
    @State private var dragOffset = CGSize.zero
    @State private var dragStart: CGSize? = nil
    
    func body(content: Content) -> some View {
        content
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { gestureValue in
                        if dragStart == nil {
                            dragStart = dragOffset
                        }
                        
                        dragOffset = gestureValue.translation
                        NSCursor.closedHand.set()
                        dragOffset.width = gestureValue.translation.width + dragStart!.width
                        dragOffset.height = gestureValue.translation.height + dragStart!.height
                    }
                    .onEnded { _ in
                        // Perform any actions you want when the drag ends
                        dragStart = nil
                    }
            )
            .onContinuousHover(perform: { phase in
                if phase == HoverPhase.ended {
                    NSCursor.arrow.set()
                }
                NSCursor.openHand.set()
            })
    }
}

extension View {
    func draggable() -> some View {
        self.modifier(DraggableView())
    }
}

struct DraggableView_Previews: PreviewProvider {
    static var previews: some View {
        Text("Drag me!")
            .font(.largeTitle)
            .draggable()
    }
}
