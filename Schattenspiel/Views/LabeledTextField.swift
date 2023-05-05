//
//  LabeledTextField.swift
//  Schattenspiel
//
//  Created by Enie Weiß on 29.01.23.
//

import SwiftUI

struct LabeledTextField<F: ParseableFormatStyle>: View where F.FormatOutput == String {
    var placeholder: String
    private var text: Binding<String>?
    private var value: Binding<F.FormatInput>?
    private var format: F?
    
    init(placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self.text = text
    }
    
    init(placeholder: String, value: Binding<F.FormatInput>, format: F) {
        self.placeholder = placeholder
        self.value = value
        self.format = format
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            if let text = self.text {
                Text(self.placeholder)
                    .foregroundColor(text.wrappedValue.isEmpty ? Color.gray : Color.gray.opacity(0.5))
                    .offset(x: 0,
                            y: text.wrappedValue.isEmpty ? 0 : -16)
                    .scaleEffect(text.wrappedValue.isEmpty ? 1 : 0.8, anchor: .topLeading)
                    .animation(.easeIn(duration: 0.15))
                Spacer()
                TextField(text.wrappedValue, text: self.text!)
                    .textFieldStyle(PlainTextFieldStyle())
            }
            if let value = self.value,
               let valueOutput = format?.format(value.wrappedValue) {
                Text(self.placeholder)
                    .foregroundColor(valueOutput.isEmpty ? Color.gray : Color.gray.opacity(0.5))
                    .offset(x: 0,
                            y: valueOutput.isEmpty ? 0 : -16)
                    .scaleEffect(valueOutput.isEmpty ? 1 : 0.8, anchor: .topLeading)
                    .animation(.easeIn(duration: 0.15))
                Spacer()
                TextField(value: self.value!    , format: format!) {
                    Label("", image: "")
                }
                    .textFieldStyle(PlainTextFieldStyle())
            }
        }
    }
}
