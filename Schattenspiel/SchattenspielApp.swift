//
//  SchattenspielApp.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 23.01.23.
//

import SwiftUI

@main
struct SchattenspielApp: App {
    @StateObject var state = AppState()
    
    func newProject() {
        let names = Project.getAllProjectNames()
        var newName = "New Project"
        if names.contains("New Project") {
            var index = 1
            while names.contains("New Project \(index)") { index+=1 }
            newName = "New Project \(index)"
        }
        state.projects.append(Project(name: newName))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(state)
                .onAppear {
                    if let lastProject = UserDefaults.standard.string(forKey: "lastOpenedProject") {
                        state.currentProject = Project(name: lastProject)
                    } else {
                        if let firstProject = Project.getAllProjects().first {
                            state.currentProject = firstProject
                        } else {
                            newProject()
                        }
                    }
                    
                }
        }
            .commands {
                SidebarCommands()
                CommandGroup(replacing: .newItem, addition: {
                    Button("New Project") {
                        newProject()
                    }.keyboardShortcut("N")
                })
                CommandGroup(after: .newItem) {
                    Button("Save File") {
                        if let file = state.currentFile {
                            // TODO: inform user if file could not be saved
                            try? state.currentCode.write(to: file, atomically: true, encoding: .utf8)
                        }
                    }.keyboardShortcut("S")
                }
            }
    }
}
