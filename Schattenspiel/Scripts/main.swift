#!/usr/bin/env swift
// compile: swiftc -O main.swift String+regex.swift 

import Foundation
import MetalKit
import Accelerate

func runShader(code: String, width: Int, height: Int, textureUrls: [URL]) -> MTLTexture? {
    let result = code.groups(for: #"(?:\G(?!\A)\s*,\s*|\b(?:kernel void)\s+)(\w+)"#).flatMap { $0 }

    let outputTextureDescriptor = MTLTextureDescriptor()
    outputTextureDescriptor.usage = [.shaderRead, .shaderWrite]
    outputTextureDescriptor.width = width
    outputTextureDescriptor.height = height

    guard let device = MTLCreateSystemDefaultDevice()
    else {
        print("–––––")
        print("Metal device not available")
        return nil
    }
    
    var library: MTLLibrary?
    do {
        library = try device.makeLibrary(source: code, options: nil)
    } catch let error {
        print("–––––")
        print("\(error.localizedDescription)")
        return nil
    }

    guard let lib = library,
          let queue = device.makeCommandQueue(),
          let buffer = queue.makeCommandBuffer(),
          let functionName = result.first,
          let function = lib.makeFunction(name: functionName),
          let s = try? device.makeComputePipelineState(function: function),
          let encoder = buffer.makeComputeCommandEncoder(),
          let o = device.makeTexture(descriptor: outputTextureDescriptor)
    else {
        print("Schattenspiel Shader Compiler ran into an unknown error.")
        return nil
    }
    
    let loader = MTKTextureLoader(device:device)

    let w = s.threadExecutionWidth
    let h = s.maxTotalThreadsPerThreadgroup / w
    let gridSize = MTLSizeMake(width, height, 1)
    let threadsPerThreadgroup = MTLSizeMake(w, h, 1)

    encoder.setComputePipelineState(s)
    o.label = "output tex"
    encoder.setTexture(o, index: 0)
    for (index, textureUrl) in textureUrls.enumerated() {
        if let texture = try? loader.newTexture(URL: textureUrl) {
            texture.label = "tex \(index+1)"
            encoder.setTexture(texture, index: index+1)
        }
    }
    

    encoder.dispatchThreads(gridSize, threadsPerThreadgroup: threadsPerThreadgroup)
    encoder.endEncoding()

    buffer.commit()
    buffer.waitUntilCompleted()
    
    return o
}

// Arguments
// shader code: always first argument since this is the only non optional argument
// width: "w=<value>"
// height: "h=<value>"
// list of input texture paths: comma separated list beginning with "textureUrls=<path,path,path>"

let code = CommandLine.arguments[1]
let width = Int(CommandLine.arguments.first { $0.contains("--width=") }?.replacingOccurrences(of: "--width=", with: "") ?? "256")!
let height = Int(CommandLine.arguments.first { $0.contains("--height=") }?.replacingOccurrences(of: "--height=", with: "") ?? "256")!
let textureUrls = CommandLine.arguments.first { $0.contains("--textureUrls=") }?
    .replacingOccurrences(of: "--textureUrls=", with: "")
    .components(separatedBy: ",")
    .map { URL(filePath: $0) } ?? []

if let _ = runShader(code: code, width: width, height: height, textureUrls: textureUrls) {
    print("success")
}
