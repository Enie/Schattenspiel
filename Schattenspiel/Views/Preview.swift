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

    var body: some View {
        if let output = setup.output {
            Image(nsImage: output)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .aspectRatio(contentMode: .fit)
                .padding(8)
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
