//
//  ImageSelectionView.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 10.05.23.
//

import SwiftUI

struct ImageSelectionView: View {
    @EnvironmentObject var setup: GPUSetup
    @EnvironmentObject var state: AppState

    var body: some View {
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
    }
}

struct ImageSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ImageSelectionView()
            .environmentObject(AppState())
            .environmentObject(GPUSetup())
    }
}
