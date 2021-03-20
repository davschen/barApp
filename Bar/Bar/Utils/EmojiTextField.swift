//
//  EmojiTextField.swift
//  Bar
//
//  Created by David Chen on 1/26/21.
//

import Foundation
import SwiftUI
import UIKit

struct EmojiTF: View {
    @State var emojiText = ""

    var body: some View {
        VStack(spacing: 10) {
            TextFieldWrapperView(text: self.$emojiText)
                .background(Color.gray)
                .frame(width: 200, height: 50)
        }
        .frame(height: 40)
    }
}

struct TextFieldWrapperView: UIViewRepresentable {
    @Binding var text: String
    func makeCoordinator() -> TFCoordinator {
        TFCoordinator(self)
    }
}

extension TextFieldWrapperView {
    func makeUIView(context: UIViewRepresentableContext<TextFieldWrapperView>) -> UITextField {
        let textField = EmojiTextField()
        textField.delegate = context.coordinator
        return textField
    }
    func updateUIView(_ uiView: UITextField, context: Context) {
    }
}

class TFCoordinator: NSObject, UITextFieldDelegate {
    var parent: TextFieldWrapperView

    init(_ textField: TextFieldWrapperView) {
        self.parent = textField
    }
}


class EmojiTextField: UITextField {
    // required for iOS 13
    override var textInputContextIdentifier: String? { "" }

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" {
                return mode
            }
        }
        return nil
    }
}

