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
    @Published var messages = [Message]()
    @Published var chatToUser = TempUserLib().emptyUser
    @Published var text = ""
    @Published var response = ""
    @Published var respondToID = ""
    @Published var lastMessageSenderID = ""
    @Published var respondMessageID = ""
    @Published var lastMessageID = ""
    
    private var db = Firestore.firestore()
    private var myUID: String {
        return Auth.auth().currentUser?.uid ?? "NOT-AN-ID"
    }
    
    init() {
        readAllMessages()
    }
    
    func readAllMessages() {
        db.collection("users").document(self.myUID).collection("messages").order(by: "timestamp").addSnapshotListener { (snap, err) in
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
    
    func writeMessage() {
        let message = Message(text: self.text, senderID: myUID, timestamp: Date(), response: self.response, respondToID: self.respondToID, lastMessageSenderID: self.lastMessageSenderID, reaction: "", respondMessageID: self.respondMessageID)
        let _ = try? db.collection("users").document(self.myUID).collection("messages").addDocument(from: message) { (err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
        }
        guard let chatToUserID = self.chatToUser.id else { return }
        let _ = try? db.collection("users").document(chatToUserID).collection("messages").addDocument(from: message) { (err) in
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
    
    func deleteMessages() {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        db.collection("users").document(userID).collection("messages").getDocuments { (snap, err) in
            guard let data = snap else { return }
            guard let chatToUserID = self.chatToUser.id else { return }
            data.documents.forEach { (doc) in
                self.db.collection("users").document(userID).collection("messages").document(doc.documentID).delete()
                self.db.collection("users").document(chatToUserID).collection("messages").document(doc.documentID).delete()
            }
        }
    }
    
    func shareContact() {
        guard let currentUser = Auth.auth().currentUser else { return }
        let message = Message(text: currentUser.phoneNumber ?? "Couldn't send contact", senderID: self.myUID, timestamp: Date(), response: self.response, respondToID: "", lastMessageSenderID: self.lastMessageSenderID, reaction: "", respondMessageID: "")

        let _ = try? db.collection("users").document(self.myUID).collection("messages").addDocument(from: message) { (err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
        }
        guard let chatToUserID = self.chatToUser.id else { return }
        let _ = try? db.collection("users").document(chatToUserID).collection("messages").addDocument(from: message) { (err) in
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
        db.collection("users").document(self.myUID).collection("messages").document(messageID).setData([
            "reaction" : emoji
        ], merge: true)
    }
}
