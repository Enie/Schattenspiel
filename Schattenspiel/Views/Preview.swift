//
//  Preview.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 23.01.23.
//

import SwiftUI
import MetalKit

struct Preview: View {
    @EnvironmentObject var setup: GPUSetup
    @EnvironmentObject var state: AppState
    
    @State var exportPresented: Bool = false
    
    private enum Field: String {
        case width, height
        var title: String { rawValue.capitalized }
    }
    @FocusState private var focusedField : Field?
    @State private var exportTextureWidth  = 256
    @State private var exportTextureHeight = 256

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
    
    func savePNG(image: NSImage, url:URL) throws {
        let imageRep = NSBitmapImageRep(data: image.tiffRepresentation!)
        let pngData = imageRep?.representation(using: .png, properties: [:])
        try pngData?.write(to: url)
    }
    
    var body: some View {
        if let output = setup.output {
            Image(nsImage: output)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .contextMenu {
                    Button {
                        exportPresented = true
                    } label: {
                        Label("Export Image", systemImage: "square.and.arrow.down")
                    }
                }
                .sheet(isPresented: $exportPresented) {
                    VStack {
                        Text("Export Size")
                        WrapperView {
                            pixelField(field: .width, value: $setup.width,
                                       editingState: $exportTextureWidth)
                            Divider()
                                .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            pixelField(field: .height, value: $setup.height,
                                       editingState: $exportTextureHeight)
                        }
                        Button {
                            let panel = NSSavePanel()
                            panel.allowedContentTypes = [.png]
                            panel.nameFieldStringValue = "Export"
                            let exportSetup: GPUSetup = GPUSetup()
                            exportSetup.textureUrls = setup.textureUrls
                            exportSetup.width = exportTextureWidth
                            exportSetup.height = exportTextureHeight
                            exportSetup.code = setup.code
                            
                            if panel.runModal() == .OK,
                               let image = exportSetup.output,
                               let url = panel.url {
                                do {
                                    try savePNG(image: image, url: url)
                                    exportPresented = false
                                } catch {
                                    _ = Alert(title: Text("Error while Saving"), message: Text(error.localizedDescription))
                                }
                            }
                        } label: {
                            Text("Save")
                        }
                    }
                    .padding(12)
                }
        } else {
            Text("No Output")
        }
    }
}

struct Preview_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
            .environmentObject(GPUSetup())
    }
}
