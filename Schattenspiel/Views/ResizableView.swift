//
//  ResizableView.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 30.01.23.
//

import SwiftUI

struct ResizableView<Content: View>: View {
    @Binding var size: CGSize
    let content: Content
    @State var lastSize: CGSize?
    
    init(size: Binding<CGSize>, @ViewBuilder content: () -> Content) {
        self.content = content()
        _size = size
    }
    
    var body: some View {
        let drag = DragGesture()
            .onChanged { value in
                if lastSize == nil {
                    lastSize = size
                }
                size = CGSize(width: lastSize!.width - value.translation.width, height: value.translation.height + lastSize!.height)
                print(size)
            }
            .onEnded { value in
                size = lastSize!
                lastSize = nil
            }
        
        return content
//            .background(.red)
            .padding(8)
//            .fill(Color.gray)
            .frame(width: size.width, height: size.height)
            .gesture(drag)
//            .overlay(content())
    }
}

struct ResizableView_Previews: PreviewProvider {
    static var previews: some View {
        ResizableView(size: Binding(get: {
            CGSize(width: 128, height: 128)
        }, set: { value in
            print(value)
        })) {
            Text("Preview")
        }
    }
}
