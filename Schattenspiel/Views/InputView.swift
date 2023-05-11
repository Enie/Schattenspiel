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
    @EnvironmentObject private var setup: GPUSetup
    @EnvironmentObject private var state: AppState

    private enum Field: String {
        case width, height
        var title: String { rawValue.capitalized }
    }
    @FocusState private var focusedField : Field?

    @State private var textureWidth  = 256
    @State private var textureHeight = 256
    
    var body: some View {
        VStack(spacing: 0) {
            VSplitView {
                CodeEditor(source: $state.currentCode, language: .cpp, theme: .ocean)
                    .onChange(of: $state.currentCode.wrappedValue) { newValue in
                        // hh: This should probably have a debounced assignment
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
                    pixelField(field: .width, value: $setup.width,
                               editingState: $textureWidth)
                    Divider()
                        .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                    pixelField(field: .height, value: $setup.height,
                               editingState: $textureHeight)
                }
                .padding(8)
                .textFieldStyle(PlainTextFieldStyle())
                
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
            inputToolbar
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
    
    @ViewBuilder private func pixelField(
        field: Field,
        value: Binding<Int>,
        editingState: Binding<Int>
    ) -> some View {
        HStack {
            Text(field.title)
            Spacer()
            TextField(field.title, value: editingState, format: IntegerFormatStyle())
                .onSubmit {
                    value.wrappedValue = editingState.wrappedValue
                }
                .focused($focusedField, equals: field)
                .multilineTextAlignment(.trailing)
            Text("px")
        }
    }
    
    @ToolbarContentBuilder private var inputToolbar: some ToolbarContent {
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
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView()
            .environmentObject(GPUSetup())
            .environmentObject(AppState())
    }
}
