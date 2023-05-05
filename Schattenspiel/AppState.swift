//
//  AppState.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 01.02.23.
//

import Foundation

class AppState: ObservableObject {
    @Published var projects: [Project] = Project.getAllProjects()

    @Published var currentProject: Project? {
        didSet {
            if let project = self.currentProject {
                UserDefaults.standard.set(project.name, forKey: "lastOpenedProject")
                self.currentFile = project.sourceFiles.first!
                if project.name != currentProjectName {
                    self.currentProjectName = project.name
                }
            }
        }
    }
    @Published var currentProjectName: String? {
        didSet {
            if let name = currentProjectName,
               name != currentProject?.name {
                currentProject = Project(name: name)
            }
        }
    }
    @Published var currentFile: URL? { didSet {
        if let file = currentFile {
            self.currentCode = (try? String(contentsOf: file)) ?? ""
        }
    }}
    @Published var currentCode: String = ""
}
