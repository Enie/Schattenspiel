//
//  FileTabs.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 01.02.23.
//

import SwiftUI

struct FileTabs: View {
    @State private var selectedFile: URL?
    var files: [URL]
    var callback: (_ name: URL) -> Void
    
    init(files: [URL], callback: @escaping (_: URL) -> Void) {
        self.files = files
        self.callback = callback
        self.selectedFile = files.first
    }

    var body: some View {
        HStack {
            ForEach(files, id: \.self) { file in
                HStack {
                    Image(systemName: "doc")
                    Text(file.lastPathComponent)
                }
                    .padding(8)
                    .background (
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                            .padding(1)
                            .opacity(selectedFile == file ? 1 : 0)
                    )
                    .onTapGesture {
                        selectedFile = file
                        callback(file)
                    }
                if files.firstIndex(of: file) != files.count-1 {
                    Divider()
                        .frame(height: 8)
                }
            }
        }
    }
}

struct FileTabs_Previews: PreviewProvider {
    static var previews: some View {
        FileTabs(files: [URL(filePath: "one"),URL(filePath: "two"),URL(filePath: "three")]) { name in
            print(name)
        }
    }
}
