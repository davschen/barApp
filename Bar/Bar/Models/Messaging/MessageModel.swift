//
//  Message.swift
//  Bar
//
//  Created by David Chen on 12/27/20.
//

import SwiftUI
import FirebaseFirestoreSwift

struct MessageModel: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var text: String
    var senderID: String
    var timestamp: Date
    var response: String
    var respondToID: String
    var lastMessageSenderID: String
    var reaction: String
    var respondMessageID: String
    
    enum CodingKeys: String, CodingKey {
        case id, text, senderID, response, respondToID, timestamp, lastMessageSenderID, reaction, respondMessageID
    }
}
