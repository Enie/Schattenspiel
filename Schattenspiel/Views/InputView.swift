//
//  InputView.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 23.01.23.
//

import SwiftUI
import MetalKit
import CodeEditor

struct InputView: View {
    @EnvironmentObject var setup: GPUSetup
    @EnvironmentObject var state: AppState
    
    var body: some View {
        VStack(spacing: 0) {
            CodeEditor(source: $state.currentCode, language: .cpp, theme: .ocean)
                .onChange(of: $state.currentCode.wrappedValue) { newValue in
                    setup.code = newValue
                }
            Divider()
                .padding(0)
                .foregroundColor(.black)
            VStack(spacing: 0) {
                HStack {
                    Text("Output Texture")
                        .fontWeight(.bold)
                    Spacer()
                }
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 0))
                VStack(spacing: 0) {
                    HStack {
                        Text("Width")
                        Spacer()
                        TextField("Width", value: $setup.width, format: IntegerFormatStyle())
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                        Text("px")
                    }
                    Divider()
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("Height", value: $setup.height, format: IntegerFormatStyle())
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                        Text("px")
                    }
                }
                    .padding(8)
                    .background(.white.opacity(0.03))
                    .background {
                        RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
                            .stroke(.white.opacity(0.1), lineWidth: 2)
                            
                    }
                    .cornerRadius(8)
                    .padding(8)
                    
                HStack {
                    Text("Input Textures")
                        .fontWeight(.bold)
                    Spacer()
                    Text(setup.textureUrls.count == 0 ? "No textures selected yet" : "count: \(setup.textureUrls.count)")
                    Button {
                        let openPanel = NSOpenPanel()
                        openPanel.allowedContentTypes = [.image]
                        openPanel.allowsMultipleSelection = true
                        
                        if openPanel.runModal() == .OK {
                            openPanel.urls.forEach { url in
                                setup.textureUrls.append(url)
                                state.currentProject?.addTexture(url: url)
                            }
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                    .buttonStyle(.borderless)
                    .padding(2)
                    .help("Select input texture")
                }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
            
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(setup.textureUrls, id: \.self) { url in
                            ZStack(alignment: .topTrailing) {
                                Image(nsImage: NSImage(byReferencing: url))
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 160)
                                    .shadow(radius: 2)
                                    .padding(16)
                                Button {
                                    setup.textureUrls.remove(at: setup.textureUrls.firstIndex(of: url)!)
                                    state.currentProject?.removeTexture(at: state.currentProject!.textures.firstIndex(of: url)!)
                                } label: {
                                    Image(systemName: "minus.circle")
                                }
                                .buttonStyle(.borderless)
                                .offset(CGSize(width: -16, height: 4))
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                if let project = state.currentProject {
                    FileTabs(files: project.sourceFiles) { file in
                        state.currentFile = file
                    }
                }
            }
            ToolbarItem {
                Spacer()
            }
            ToolbarItem {
                ProgressView()
                    .scaleEffect(CGSize(width: 0.5, height: 0.5))
                    .opacity(setup.isComputing ? 1 : 0)
            }
            ToolbarItem {
                Button {
                    setup.isActive.toggle()
                    try? setup.onChange()
                } label: {
                    setup.isActive
                    ? Image(systemName: "stop.fill")
                    : Image(systemName: "play.fill")
                }
            }
        }
        .onAppear {
            setup.code = state.currentCode
            setup.textureUrls = state.currentProject?.textures ?? []
        }
        .onChange(of: state.currentProject?.name) { projectName in
            setup.code = state.currentCode
            setup.textureUrls = state.currentProject?.textures ?? []
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
            .environmentObject(GPUSetup())
    }
}
