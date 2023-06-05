//
//  GPUSetup.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 23.01.23.
//

import Foundation
import MetalKit

class GPUSetup: ObservableObject {
    private var device: MTLDevice
    
    @Published var width = 256 { didSet { try? onChange() }}
    @Published var height = 256 { didSet { try? onChange() }}
    
    @Published var error: String?
    
    var code: String = "" { didSet { do {try onChange()} catch {print("meh")} }}
    var textureUrls: [URL] = [] { didSet {
        objectWillChange.send()
        do {try onChange()} catch {print("meh")}
    }}
    
    @Published var output: NSImage?
    @Published var isActive: Bool = true
    @Published var isComputing: Bool = false
    
    init() {
        guard let device = MTLCreateSystemDefaultDevice()
        else {
            // todo: show an alert before applications shuts down.
            fatalError("GPU not available")
        }
        self.device = device
    }
    
    func onChange() throws {
        Task.init {
            if isActive {
                DispatchQueue.main.async {
                    self.isComputing = true
                }
                try? safeShell()
            }
        }
    }
    
    func runShader() -> NSImage? {
        let result = code.groups(for: #"(?:\G(?!\A)\s*,\s*|\b(?:kernel void)\s+)(\w+)"#).flatMap { $0 }
        
        let outputTextureDescriptor = MTLTextureDescriptor()
        outputTextureDescriptor.usage = [.shaderRead, .shaderWrite]
        outputTextureDescriptor.width = width
        outputTextureDescriptor.height = height
        
        guard let device = MTLCreateSystemDefaultDevice(),
              let queue = device.makeCommandQueue(),
              let buffer = queue.makeCommandBuffer(),
              let library = try? device.makeLibrary(source: code, options: nil),
              let functionName = result.first,
              let function = library.makeFunction(name: functionName),
              let s = try? device.makeComputePipelineState(function: function),
              let encoder = buffer.makeComputeCommandEncoder(),
              let o = device.makeTexture(descriptor: outputTextureDescriptor)
        else {
            return nil
        }
        
        let loader = MTKTextureLoader(device:device)
        
        let w = s.threadExecutionWidth
        let h = s.maxTotalThreadsPerThreadgroup / w
        let gridSize = MTLSizeMake(width, height, 1)
        
        encoder.setComputePipelineState(s)
        o.label = "output tex"
        encoder.setTexture(o, index: 0)
        for (index, textureUrl) in textureUrls.enumerated() {
            if let texture = try? loader.newTexture(URL: textureUrl,
                                                    options: [.textureUsage : MTLTextureUsage.shaderRead.rawValue | MTLTextureUsage.shaderWrite.rawValue]) {
                texture.label = "tex \(index+1)"
                encoder.setTexture(texture, index: index+1)
            }
        }
        
        let threadGroupSize = MTLSizeMake(w, h, 1);
        let threadGroupCount = MTLSizeMake((gridSize.width + threadGroupSize.width - 1) / threadGroupSize.width,
                                               (gridSize.height + threadGroupSize.height - 1) / threadGroupSize.height,
                                               1);
        encoder.dispatchThreadgroups(threadGroupCount, threadsPerThreadgroup: threadGroupSize)
        encoder.endEncoding()
        
        buffer.commit()
        buffer.waitUntilCompleted()
        
        return NSImage(mtlTexture: o)
    }
    
    func safeShell() throws {
        let group = DispatchGroup()
        
        let scriptURL = Bundle.main.url(forResource: "runShader", withExtension: nil)
        var arguments = [code]
        if textureUrls.count>0 {
            arguments.append("--textureUrls=\(textureUrls.map {$0.path()}.joined(separator:","))")
        }
        
        arguments.append("--width=\(width)")
        arguments.append("--height=\(height)")
        
        group.enter()
        
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.standardInput = nil
        task.arguments = arguments
        task.launchPath = scriptURL?.deletingLastPathComponent().path()
        task.executableURL = scriptURL

        task.terminationHandler = { _ in
            task.terminationHandler = nil
            group.leave()
        }

        group.enter()
        DispatchQueue.global().async {
            if let data = try? pipe.fileHandleForReading.readToEnd() {
                pipe.fileHandleForReading.closeFile()
                DispatchQueue.main.async {
                    let string = String(data: data, encoding: .utf8)!
                    let shaderRanSuccessful = string.contains("success")
                    print("shader successful: shaderRanSuccessful: \(shaderRanSuccessful)")
                    print(string)
                    if shaderRanSuccessful {
                        self.output = self.runShader()
                        self.objectWillChange.send()
                        self.error = nil
                    } else {
                        self.error = string.components(separatedBy: "–––––\n").last
                    }
                    group.leave()
                }
            }
            DispatchQueue.main.async {
                self.isComputing = false
            }
        }

        try task.run()
        task.waitUntilExit()
    }
}
