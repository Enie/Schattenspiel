//
//  ContentView.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 23.01.23.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var state: AppState
    @State private var hoveredProjectName: UUID?
    
    @State private var isPresentingRenameSheet = false
    @State private var newProjectName: String?

    private func toggleSidebar() {
#if os(iOS)
#else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }

    var body: some View {
        NavigationView {
            List(state.projects, id: \.id) { project in
                NavigationLink(destination: EditorView(projectName: project.name)
                    .environmentObject(state),
                               tag: project.name,
                               selection: $state.currentProjectName) {
                    ProjectRowView(project: project, hoveredProjectName: hoveredProjectName)
                }
                   .onHover { isHovered in
                       hoveredProjectName = isHovered ? project.id : nil
                   }
                   
            }
            .listStyle(.sidebar)

            EditorView(projectName: "New Project")
        }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        toggleSidebar()
                    }, label: {
                        Image(systemName: "sidebar.left")
                    })
                    .help("Toggle Sidebar")
                }
            }
            
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
