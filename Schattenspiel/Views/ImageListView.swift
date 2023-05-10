//
//  ImageListView.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 10.05.23.
//

import SwiftUI

struct ImageListView: View {
    @EnvironmentObject var setup: GPUSetup
    @EnvironmentObject var state: AppState

    var body: some View {
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
                            state.currentProject?.removeTexture(at: state.currentProject!.textures.firstIndex(of: url)!)
                            setup.textureUrls.remove(at: setup.textureUrls.firstIndex(of: url)!)
                        } label: {
                            Image(systemName: "minus.circle")
                        }
                        .buttonStyle(.borderless)
                        .offset(CGSize(width: -16, height: 4))
                    }
                }
            }
        }
    }
}

struct ImageListView_Previews: PreviewProvider {
    static var previews: some View {
        ImageListView()
            .environmentObject(AppState())
            .environmentObject(GPUSetup())
    }
}
