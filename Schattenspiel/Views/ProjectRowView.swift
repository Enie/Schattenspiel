//
//  ProjectRowView.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 07.05.23.
//

import SwiftUI

struct ProjectRowView: View {
    @EnvironmentObject var state: AppState
    
    @StateObject var project: Project
    var hoveredProjectName: UUID?
    @FocusState private var isFocused: Bool
    @State private var name: String = "project"
    
    func projectContextMenu(project: Project) -> some View {
        Group {
            Button {
                NSWorkspace.shared.activateFileViewerSelecting([Project.projectsFolder.appending(component: project.name)])
            } label: {
                Text("Reveal in Finder")
            }.padding([.top,.bottom], 4)
            Divider()
            RenameButton()
                .buttonStyle(.plain)
                .renameAction({
                    isFocused.toggle()
                })
            Button {
                project.remove()
                state.projects.removeAll { $0.name == project.name }
            } label: {
                Text("Delete Project")
            }.buttonStyle(.plain)
        }
    }
    
    var body: some View {
        HStack {
            TextField(text: $name) {
                Text("Prompt")
            }.onSubmit {
                project.rename(newName: name)
            }
            Spacer()
            MenuButton(label: Image(systemName: "ellipsis.circle.fill")) {
                projectContextMenu(project: project)
            }
                .menuButtonStyle(BorderlessButtonMenuButtonStyle())
                .opacity(hoveredProjectName == project.id ? 1 : 0)
                .frame(width: 18)
        }
        .focused($isFocused)
        .background(Rectangle().fill(.clear).contextMenu {
            projectContextMenu(project: project)
        })
        .onAppear {
            name = project.name
        }
    }
}

//struct ProjectRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectRowView()
//    }
//}
