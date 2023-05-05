//
//  MetalImageView.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 23.01.23.
//

import SwiftUI

struct MetalTextureView: View {
    var texture: MTLTexture
    var body: some View {
        Image(nsImage: NSImage(mtlTexture: texture))
    }
}
