//
//  Extensions.swift
//  Bar
//
//  Created by David Chen on 12/10/20.
//

import Foundation
import SwiftUI

extension Array {
    func wrap(around index: Int) -> Array<Element> {

        var oldArray = [Element]()
        var priorElements = [Element]()
        var newArray = [Element]()

        for i in 0..<self.count {
            let element = self[i]
            if i == index || oldArray.count > 0 {
                oldArray.append(element)
            } else {
                priorElements.append(element)
            }
            newArray = oldArray + priorElements
        }
        return newArray
    }
}

extension View {
    func animationsDisabled() -> some View {
        return self.transaction { (tx: inout Transaction) in
            tx.disablesAnimations = true
            tx.animation = nil
        }.animation(nil)
    }
}

struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
