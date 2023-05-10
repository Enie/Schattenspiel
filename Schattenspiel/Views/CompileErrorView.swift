//
//  CompileErrorView.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 10.05.23.
//

import SwiftUI

struct CompileErrorView: View {
    @EnvironmentObject var setup: GPUSetup
    @EnvironmentObject var state: AppState

    var body: some View {
        if let error = setup.error {
            ScrollView() {
                HStack {
                    Text(error)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(16)
                    Spacer()
                }
            }
                .frame(maxWidth: .infinity, idealHeight: 100)
                .background{
                    Color.red
                }
        }
    }
}

struct CompileErrorView_Previews: PreviewProvider {
    static var previews: some View {
        CompileErrorView()
    }
}
