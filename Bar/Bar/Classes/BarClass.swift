//
//  BarClass.swift
//  Bar
//
//  Created by David Chen on 12/9/20.
//

import Foundation
import SwiftUI
import FirebaseFirestoreSwift

struct Bar: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var imageLinkName: String
    var tags: [String]
    var cap: Double
    var occup: Double
    var city: String
    var state: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, imageLinkName, tags, cap, occup, city, state
    }
}

struct EmptyBar {
    public var bar = Bar(id: "", name: "", description: "", imageLinkName: "", tags: [], cap: 0, occup: 0, city: "", state: "")
}
