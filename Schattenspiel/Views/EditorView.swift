//
//  EditorView.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 26.01.23.
//

import SwiftUI

struct EditorView: View {
    @State private var setup = GPUSetup()
    
    @State private var dragStart:CGSize?
    @State private var offset = CGSize.zero
    
    @ObservedObject private var currentProject: Project
    
    var projectName: String
    
    init(projectName: String) {
        self.projectName = projectName
        self.currentProject = Project(name: projectName)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                InputView()
                    Preview()
                    .frame(width: 256, height: 256*(CGFloat(setup.height)/CGFloat(setup.width)))
                        .background(.gray.opacity(0.2))
                        .cornerRadius(8)
                        .offset(offset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    if dragStart == nil{
                                        dragStart = offset
                                    }
                                    offset = CGSize(width:min(24, max(-geometry.size.width + 256 - 24, gesture.translation.width + dragStart!.width)),
                                                    height:max(-24, min(geometry.size.height - 256 + 24, gesture.translation.height + dragStart!.height)))
                                }
                                .onEnded { _ in
                                    dragStart = nil
                                }
                        )
            }
            .environmentObject(setup)
            .navigationTitle(projectName)
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView(projectName: "Preview")
    }
}
