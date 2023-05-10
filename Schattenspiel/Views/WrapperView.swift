//
//  TextFieldCombo.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 10.05.23.
//

import SwiftUI

struct WrapperView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .padding(8)
        .background(.white.opacity(0.03))
        .background {
            RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
                .stroke(.white.opacity(0.1), lineWidth: 2)
            
        }
        .cornerRadius(8)
    }
}

struct TextFieldComboView_Previews: PreviewProvider {
    static var previews: some View {
        WrapperView {
            Text("Hello World!")
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            Divider()
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
            Text("Looking good")
                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        }
            .padding(8)
    }
}
