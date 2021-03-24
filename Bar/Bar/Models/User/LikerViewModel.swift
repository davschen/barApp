//
//  LikerViewModel.swift
//  Bar
//
//  Created by David Chen on 12/30/20.
//

import Foundation
import Firebase
import FirebaseFirestore

class LikerViewModel: ObservableObject {
    @Published var likers = [User]()
    @Published var matcher = [User]()
    @Published var likeCards = [LikeCard]()
    @Published var likedUser = TempUserLib().emptyUser
    @Published var matchedUser = TempUserLib().emptyUser
    private var currentUser = Auth.auth().currentUser
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    //NEEDS UPDATING LATER
    func fetchData() {
        guard let userID = currentUser?.uid else { return }
        let docRef = db.collection("users").document(userID)
        
        docRef.collection("likers").addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            data.forEach { (doc) in
                self.db.collection("users").document(doc.documentID).addSnapshotListener { (snap, error) in
                    if error != nil { return }
                    if let user = try? snap?.data(as: User.self) {
                        DispatchQueue.main.async {
                            var userVar = user
                            userVar.setID(id: doc.documentID)
                            if !self.likers.contains(userVar) {
                                self.likers.append(userVar)
                            }
                        }
                    }
                }
            }
        }
        
        docRef.collection("matcher").addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            
            data.forEach { (doc) in
                self.db.collection("users").document(doc.documentID).addSnapshotListener { (snap, error) in
                    if error != nil { return }
                    if let user = try? snap?.data(as: User.self) {
                        DispatchQueue.main.async {
                            var userVar = user
                            userVar.setID(id: doc.documentID)

                            if !self.matcher.contains(userVar) {
                                self.matcher.append(userVar)
                                self.matchedUser = userVar
                            }
                        }
                    }
                }
            }
        }
    }
    
    func pop(idToRemove: String) {
        guard let myUID = currentUser?.uid else { return }
        let docRef = db.collection("users").document(myUID)
        docRef.collection("likers").document(idToRemove).delete()
        self.likers.remove(at: 0)
    }
    
    func removeMatcher(idToRemove: String) {
        guard let myUID = currentUser?.uid else { return }
        let docRef = db.collection("users").document(myUID)
        self.matcher.removeAll()
        docRef.collection("matcher").document(idToRemove).delete()
        docRef.setData(["matcherID" : ""], merge: true)
    }
    
    // likeToID refers to the ID of the person the like is being sent to
    func addLiker(likeToID: String, heading: String, subheading: String, comment: String) {
        
        // myUID = current user in-app's ID
        guard let myUID = currentUser?.uid else { return }
        
        // docRef = Firebase reference for likeTo document
        let docRef = db.collection("users").document(likeToID)
        
        // add like to numLikes
        docRef.getDocument { (snap, error) in
            let numLikes = snap?.get("likes") as! Int
            docRef.setData([
                "likes" : numLikes + 1
            ], merge: true)
        }
        
        // in likeTo document, add a document w/ ID myUID, w/ field (pending) id
        docRef.collection("likers").document(myUID).setData([
            "id" : myUID,
            "heading" : heading,
            "subheading" : subheading,
            "comment" : comment
        ])
    }
    
    func removeAllLikers() {
        guard let myUID = currentUser?.uid else { return }
        let docRef = db.collection("users").document(myUID)
        docRef.collection("liker").getDocuments { (snap, error) in
            guard let data = snap else { return }
            data.documents.forEach { (doc) in
                self.db.collection("users").document(myUID).collection("likers").document(doc.documentID).delete()
            }
        }
    }
    
    func requestMatch() {
        guard let userID = currentUser?.uid else { return }
        guard let id = self.likedUser.id else { return }
        let matcherDocRef = db.collection("users").document(id)
        let myDocRef = db.collection("users").document(userID)
        
        // set my matcherID to matchTo ID
        myDocRef.getDocument { (snap, error) in
            myDocRef.setData([
                "matcherID" : id
            ], merge: true)
        }
        
        // set collection data
        matcherDocRef.collection("matcher").document(userID).setData([
            "id" : userID
        ])
    }
    
    func declineMatcher(id: String) {
        guard let userID = currentUser?.uid else { return }
        let matcherDocRef = db.collection("users").document(id)
        let myDocRef = db.collection("users").document(userID)
        
        // set matchTo matcherID value to my UID
        matcherDocRef.getDocument { (snap, error) in
            matcherDocRef.setData([
                "matcherID" : ""
            ], merge: true)
        }
        
        // set my matcherID to matchTo ID
        myDocRef.getDocument { (snap, error) in
            myDocRef.setData([
                "matcherID" : ""
            ], merge: true)
        }
        
        // delete document in matcher
        self.matcher.removeAll()
        matcherDocRef.collection("matcher").document(userID).delete()
        myDocRef.collection("matcher").document(id).delete()
    }
    
    func checkHasMatcher() -> Bool {
        var hasMatcher = false
        guard let userID = currentUser?.uid else { return false }
        let docRef = db.collection("users").document(userID)
        docRef.addSnapshotListener { (snap, error) in
            guard let data = snap else { return }
            let matcherID = data.get("matcherID") as! String
            if matcherID != "" {
                hasMatcher = true
            }
        }
        return hasMatcher
    }
    
    func match(matchToID: String) {
        // myUID = current user in-app's ID
        guard let myUID = currentUser?.uid else { return }
        
        // docRef = Firebase reference for likeTo document
        let matcherDocRef = db.collection("users").document(matchToID)
        let myDocRef = db.collection("users").document(myUID)
        
        // add match to matcher
        matcherDocRef.getDocument { (snap, error) in
            let numMatches = snap?.get("matches") as! Int
            matcherDocRef.setData([
                "matches" : numMatches + 1
            ], merge: true)
        }
        
        // add match to me
        myDocRef.getDocument { (snap, error) in
            let numMatches = snap?.get("matches") as! Int
            myDocRef.setData([
                "matches" : numMatches + 1
            ], merge: true)
        }
        
        matcherDocRef.collection("matcher").document(myUID).setData([
            "id" : myUID
        ])
    }
    
    func refreshLikeCards() {
        self.likeCards = likersToCards(users: self.likers)
        if self.likeCards.count > 0 {
            self.likedUser = likeCards[0].user
        }
    }
    
    func updateLikedUser() {
        self.likedUser = likeCards[0].user
    }
    
    func dismissUser(counter: Int) {
        guard let id = likedUser.id else { return }
        self.pop(idToRemove: id)
        self.likedUser = likeCards[counter < likeCards.count ? counter : 0].user
    }
    
    func generatePronouns(user: User) -> [String] {
        if user.gender == "Male" {
            return ["he", "him", "his"]
        } else if user.gender == "Female" {
            return ["she", "her", "hers"]
        } else {
            return ["they", "them", "their"]
        }
    }
}
