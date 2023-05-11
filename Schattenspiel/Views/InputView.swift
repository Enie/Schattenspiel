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

    private enum Field: Hashable {
      case width, height
    }
    @FocusState private var focusedField : Field?

    @State var textureWidth: Int = 256
    @State var textureHeight: Int = 256
    
    var body: some View {
        VStack(spacing: 0) {
            VSplitView {
                CodeEditor(source: $state.currentCode, language: .cpp, theme: .ocean)
                    .onChange(of: $state.currentCode.wrappedValue) { newValue in
                        setup.code = newValue
                    }
                CompileErrorView()
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
                WrapperView {
                    HStack {
                        Text("Width")
                        Spacer()
                        TextField("Width", value: $textureWidth, format: IntegerFormatStyle())
                            .onSubmit {
                                setup.width = textureWidth
                            }
                            .focused($focusedField, equals: .width)
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                        Text("px")
                    }
                    Divider()
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("Height", value: $textureHeight, format: IntegerFormatStyle())
                            .onSubmit {
                                setup.height = textureHeight
                            }
                            .focused($focusedField, equals: .height)
                            .textFieldStyle(PlainTextFieldStyle())
                            .multilineTextAlignment(.trailing)
                        Text("px")
                    }
                }
                    .padding(8)
                ImageSelectionView()
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                ImageListView()
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
            }
            .onChange(of: focusedField) { newValue in
                if newValue == .height || newValue == .none {
                    setup.width = textureWidth
                }
                if newValue == .width || newValue == .none {
                    setup.height = textureHeight
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
            
            textureWidth = setup.width
            textureHeight = setup.height
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
            .environmentObject(AppState())
    }
}
