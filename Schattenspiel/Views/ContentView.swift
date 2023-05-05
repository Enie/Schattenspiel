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

    private func toggleSidebar() {
#if os(iOS)
#else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }
    
    func projectContextMenu(project: Project) -> some View {
        Group {
            Button {
                NSWorkspace.shared.activateFileViewerSelecting([Project.projectsFolder.appending(component: project.name)])
            } label: {
                Text("Reveal in Finder")
            }.padding([.top,.bottom], 4)
            Divider()
            Button {
                project.remove()
            } label: {
                Text("Delete Project")
            }.buttonStyle(.plain)
        }
    }
        
    var body: some View {
        NavigationView {
            List(state.projects, id: \.id) { project in
                NavigationLink(destination: EditorView(projectName: project.name)
                    .environmentObject(state),
                               tag: project.name,
                               selection: $state.currentProjectName) {
                    HStack {
                        Text(project.name)
                        Spacer()
                        MenuButton(label: Image(systemName: "ellipsis.circle.fill")) {
                            projectContextMenu(project: project)
                        }
                            .menuButtonStyle(BorderlessButtonMenuButtonStyle())
                            .opacity(hoveredProjectName == project.id ? 1 : 0)
                            .frame(width: 18)
                    }
                }
                   .onHover { isHovered in
                       hoveredProjectName = isHovered ? project.id : nil
                   }
                   .background(Rectangle().fill(.clear).contextMenu {
                       projectContextMenu(project: project)
                   })
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
    }
}
