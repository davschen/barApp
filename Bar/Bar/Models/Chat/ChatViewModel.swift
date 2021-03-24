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
    
    let ref = Firestore.firestore()
    
    init() {
        readAllMessages()
    }
    
    func readAllMessages() {
        ref.collection("users").document(Auth.auth().currentUser!.uid).collection("messages").order(by: "timestamp").addSnapshotListener { (snap, err) in
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
        let message = Message(text: self.text, senderID: Auth.auth().currentUser!.uid, timestamp: Date(), response: self.response, respondToID: self.respondToID, lastMessageSenderID: self.lastMessageSenderID, reaction: "", respondMessageID: self.respondMessageID)
        let _ = try? ref.collection("users").document(Auth.auth().currentUser!.uid).collection("messages").addDocument(from: message) { (err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
        }
        
        let _ = try? ref.collection("users").document(self.chatToUser.id!).collection("messages").addDocument(from: message) { (err) in
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
        ref.collection("users").document(userID).collection("messages").getDocuments { (snap, err) in
            guard let data = snap else { return }
            data.documents.forEach { (doc) in
                self.ref.collection("users").document(userID).collection("messages").document(doc.documentID).delete()
                self.ref.collection("users").document(self.chatToUser.id!).collection("messages").document(doc.documentID).delete()
            }
        }
    }
    
    func shareContact() {
        let message = Message(text: Auth.auth().currentUser!.phoneNumber ?? "Couldn't send contact", senderID: Auth.auth().currentUser!.uid, timestamp: Date(), response: self.response, respondToID: "", lastMessageSenderID: self.lastMessageSenderID, reaction: "", respondMessageID: "")

        let _ = try? ref.collection("users").document(Auth.auth().currentUser!.uid).collection("messages").addDocument(from: message) { (err) in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
        }

        let _ = try? ref.collection("users").document(self.chatToUser.id!).collection("messages").addDocument(from: message) { (err) in
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
        ref.collection("users").document(Auth.auth().currentUser!.uid).collection("messages").document(messageID).setData([
            "reaction" : emoji
        ], merge: true)
    }
}
