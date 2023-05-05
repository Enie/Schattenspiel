//
//  Project.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 01.02.23.
//

import Foundation
import SwiftUI

let defaultKernel = """
#include <metal_stdlib>
using namespace metal;

kernel void interpolate(texture2d<float, access::write> t [[texture(0)]],
uint2 gridPosition [[thread_position_in_grid]])
{
    float width = t.get_width();
    float height = float(t.get_height());
    t.write(float4(float(gridPosition.x)/width,0,float(gridPosition.y)/height,1), gridPosition);
}
"""

class Project: ObservableObject, CustomStringConvertible {
    let id = UUID()
    @Published var name: String
    @Published var sourceFiles: [URL]
    @Published var textures: [URL]
    
    static let projectsFolder: URL =
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appending(path: "Schattenspiel/projects")
    
    var description: String {
        return name
    }
    
    init(name: String) {
        self.name = name
        self.sourceFiles = []
        self.textures = []

        let projectDirectory = Project.projectsFolder.appendingPathComponent(self.name)
        //print("––––––––––",Project.projectsFolder)
        
        // check if project already exists
        if let projectContent = try? FileManager.default.contentsOfDirectory(at: projectDirectory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        {
            self.sourceFiles = projectContent
                .filter {$0.pathExtension == "mtl" }
            self.textures = projectContent
                .filter {$0.pathExtension != "mtl" }
        } else {
            try! FileManager.default.createDirectory(at: projectDirectory, withIntermediateDirectories: true, attributes: nil)
            try? defaultKernel.write(to: projectDirectory.appending(path: "main.mtl"), atomically: true, encoding: .utf8)
        }
    }
    
    func rename(newName: String) {
        let oldProjectDirectory = Project.projectsFolder.appendingPathComponent(self.name)
        let newProjectDirectory = Project.projectsFolder.appendingPathComponent(newName)
        
        try! FileManager.default.moveItem(at: oldProjectDirectory, to: newProjectDirectory)
        
        self.name = newName
    }
    
    func addSource(name: String, code: String) {
        let destination = Project.projectsFolder.appendingPathComponent(self.name).appendingPathComponent(name)
        
        try! code.write(to: destination, atomically: true, encoding: .utf8)
        
        self.sourceFiles.append(destination)
    }
    
    func addSourceFile(url: URL) {
        let destination = Project.projectsFolder.appendingPathComponent(self.name).appendingPathComponent(url.lastPathComponent)
        
        try! FileManager.default.copyItem(at: url, to: destination)
        
        self.sourceFiles.append(destination)
    }
    
    func removeSourceFile(at index: Int) {
        let file = self.sourceFiles[index]
        
        try! FileManager.default.removeItem(at: file)
        
        self.sourceFiles.remove(at: index)
    }
    
    func renameSourceFile(at index: Int, to newName: String) {
        let oldURL = self.sourceFiles[index]
        let newURL = oldURL.deletingLastPathComponent().appendingPathComponent(newName)
        
        try! FileManager.default.moveItem(at: oldURL, to: newURL)
        
        self.sourceFiles[index] = newURL
    }
    
    func addTexture(url: URL) {
        let destination = Project.projectsFolder.appendingPathComponent(self.name).appendingPathComponent(url.lastPathComponent)
        
        try! FileManager.default.copyItem(at: url, to: destination)
        
        self.textures.append(destination)
    }
    
    func removeTexture(at index: Int) {
        let file = self.textures[index]
        
        try! FileManager.default.removeItem(at: file)
        
        self.textures.remove(at: index)
    }
    
    func renameTexture(at index: Int, to newName: String) {
        let oldURL = self.textures[index]
        let newURL = oldURL.deletingLastPathComponent().appendingPathComponent(newName)
        
        try! FileManager.default.moveItem(at: oldURL, to: newURL)
        
        self.textures[index] = newURL
    }
    
    func remove() {
        let projectDirectory = Project.projectsFolder.appendingPathComponent(self.name)
        
        try! FileManager.default.removeItem(at: projectDirectory)
    }
}

extension Project {
    static func getAllProjectNames() -> [String] {
        if let projectDirectories = try? FileManager.default.contentsOfDirectory(at: Project.projectsFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        {
            return projectDirectories.map { $0.lastPathComponent }
        }
        return []
    }
    
    static func getAllProjects() -> [Project] {
        if let projectDirectories = try? FileManager.default.contentsOfDirectory(at: Project.projectsFolder, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
        {
            return projectDirectories.map { Project(name:$0.lastPathComponent) }
        }
        return []
    }
}
