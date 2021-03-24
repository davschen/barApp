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
    var id: Int
    var offset: CGFloat
    
    init(user: User, id: Int) {
        self.user = user
        self.id = id
        self.offset = 0
    }
}

func likersToCards(users: [User]) -> [LikeCard] {
    var likeCards: [LikeCard] = []
    for i in 0..<users.count {
        likeCards.append(LikeCard(user: users[i], id: i))
    }
    return likeCards
}

struct LikersToCards {
    let users: [User]
    
}
