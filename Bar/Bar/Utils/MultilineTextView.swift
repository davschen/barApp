//
//  MultilineTextView.swift
//  Bar
//
//  Created by David Chen on 1/5/21.
//

import SwiftUI
import Combine

final class UserTextData: ObservableObject  {
    let didChange = PassthroughSubject<UserTextData, Never>()

    var text = "" {
        didSet {
            didChange.send(self)
        }
    }

    init(text: String) {
        self.text = text
    }
}

struct MultilineTextView: UIViewRepresentable {
    @Binding var text: String
    let bgColor: Color
    let textColor: Color

    func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.isScrollEnabled = true
        view.isEditable = true
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor(bgColor)
        view.textColor = UIColor(textColor)
        return view
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
}
