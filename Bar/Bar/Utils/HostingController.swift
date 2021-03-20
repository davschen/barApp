//
//  HostingController.swift
//  Bar
//
//  Created by David Chen on 12/30/20.
//

import Foundation
import SwiftUI

class HostingController<ContentView>: UIHostingController<ContentView> where ContentView : View {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
