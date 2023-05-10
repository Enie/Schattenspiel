//
//  EditorView.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 26.01.23.
//

import SwiftUI

struct EditorView: View {
    @StateObject private var setup = GPUSetup()
    @ObservedObject private var currentProject: Project
    
    var projectName: String
    
    init(projectName: String) {
        self.projectName = projectName
        self.currentProject = Project(name: projectName)
    }
    
    var body: some View {
        return GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                InputView()
                    Preview()
                        .frame(width: CGFloat(setup.width), height: CGFloat(setup.height))
                        .background(.gray.opacity(0.2))
                        .cornerRadius(4)
                        .draggable()
            }
            .environmentObject(setup)
            .navigationTitle(projectName)
        }
    }
}

struct EditorView_Previews: PreviewProvider {
    static var previews: some View {
        EditorView(projectName: "Preview")
            .environmentObject(AppState())
    }
}
