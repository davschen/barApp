//
//  ChatRoom.swift
//  Bar
//
//  Created by David Chen on 12/28/20.
//

import Foundation
import SwiftUI
import Firebase

class ChatViewModel: ObservableObject {
    @Published var conversationID = ""
    @Published var messages = [Message]()
    @Published var chatToUser = TempUserLib().emptyUser
    @Published var text = ""
    @Published var response = ""
    @Published var respondToID = ""
    @Published var lastMessageSenderID = ""
    @Published var respondMessageID = ""
    @Published var lastMessageID = ""
    @Published var timeBegan = Date()
    
    private var db = Firestore.firestore()
    private var myUID: String {
        return Auth.auth().currentUser?.uid ?? "NOT-AN-ID"
    }
    
    init() {
        readAllMessages()
    }
    
    func readAllMessages() {
        if !self.conversationID.isEmpty {
            let docRef = db.collection("conversations").document(self.conversationID)
            docRef.collection("messages").order(by: "timestamp").addSnapshotListener { (snap, err) in
                if err != nil {
                    print(err!.localizedDescription)
                    return
                }
                guard let data = snap?.documents else { return }
                self.messages = data.compactMap { (query) -> Message? in
                    return try? query.data(as: Message.self)
                }
            }
        }
        let myDocRef = db.collection("users").document(myUID)
        myDocRef.addSnapshotListener { (doc, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let matcherID = doc?.get("matcherID") as? String else { return }
            if !matcherID.isEmpty {
                self.db.collection("users").document(matcherID).addSnapshotListener { (doc, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    guard let doc = doc else { return }
                    if let matcher = try? doc.data(as: User.self) {
                        DispatchQueue.main.async {
                            var userVar = matcher
                            userVar.setID(id: doc.documentID)
                            self.chatToUser = userVar
                        }
                    }
                }
            }
        }
    }
    
    func createConversationDocument(userID: String) {
        let docRef = db.collection("conversations").document()
        docRef.setData([
            "timeBegan" : Date()
        ])
        let myDocRef = db.collection("users").document(self.myUID)
        myDocRef.setData([
            "conversationID" : docRef.documentID
        ], merge: true)
        self.conversationID = docRef.documentID
    }
    
    func writeMessage() {
        let message = Message(text: self.text, senderID: myUID, timestamp: Date(), response: self.response, respondToID: self.respondToID, lastMessageSenderID: self.lastMessageSenderID, reaction: "", respondMessageID: self.respondMessageID)
        let _ = try? db.collection("conversations").document(self.conversationID).collection("messages").addDocument(from: message) { (err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
        }
        self.response = ""
        self.respondToID = ""
        self.respondMessageID = ""
        self.text = ""
    }
    
    func shareContact() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let message = Message(text: currentUser.phoneNumber ?? "Couldn't send contact", senderID: self.myUID, timestamp: Date(), response: self.response, respondToID: "", lastMessageSenderID: self.lastMessageSenderID, reaction: "", respondMessageID: "")

        let _ = try? db.collection("conversations").document(self.conversationID).collection("messages").addDocument(from: message) { (err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
        }
    }
    
    func setSenderID(id: String) {
        self.lastMessageSenderID = id
    }
    
    func setLastMessageID(id: String) {
        self.lastMessageID = id
    }
    
    func addReaction(messageID: String, emoji: String) {
        db.collection("conversations").document(self.conversationID).collection("messages").document(messageID).setData([
            "reaction" : emoji
        ], merge: true)
    }
}
