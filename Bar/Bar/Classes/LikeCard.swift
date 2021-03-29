//
//  LikeCard.swift
//  Bar
//
//  Created by David Chen on 12/22/20.
//

import Foundation
import SwiftUI

struct LikeCard: Identifiable, Hashable {
    var user: User
    var heading: String
    var subHeading: String
    var comment: String
    var id: Int
    var offset: CGFloat
    
    init(user: User, heading: String, subHeading: String, comment: String, id: Int) {
        self.user = user
        self.heading = heading
        self.subHeading = subHeading
        self.comment = comment
        self.id = id
        self.offset = 0
    }
}

struct LikersToCards {
    let users: [User]
    
}
