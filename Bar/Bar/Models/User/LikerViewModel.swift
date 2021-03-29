//
//  LikerViewModel.swift
//  Bar
//
//  Created by David Chen on 12/30/20.
//

import Foundation
import Firebase
import FirebaseFirestore

/*
 Responsibilities of the Liker View Model:
    - Contains array of "likers," (people who send current user an invitation)
    
    - Contains user instance "matcher," who accepts an invitation from current user
        • current user has two ways to match: push match from my side, or liker pushes match from their side
    - Requested Matcher is the current 
 */

class LikerViewModel: ObservableObject {
    @Published var likers = [User]()
    @Published var likeCards = [LikeCard]()
    @Published var sendInviteToUser: User = TempUserLib().emptyUser
    @Published var matcher: User = TempUserLib().emptyUser
    @Published var requestedMatcher: User = TempUserLib().emptyUser
    private var currentUser = Auth.auth().currentUser
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    // NEEDS UPDATING LATER - how about now hehehe
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
        
        docRef.addSnapshotListener { (doc, error) in
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
                            self.matcher = matcher
                        }
                    }
                }
            }
        }
    }
    
    func setInvitedUser(user: User) {
        self.sendInviteToUser = user
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
        self.matcher = TempUserLib().emptyUser
        docRef.collection("matcher").document(idToRemove).delete()
        docRef.setData(["matcherID" : ""], merge: true)
    }
    
    func removeAllLikers() {
        guard let myUID = currentUser?.uid else { return }
        let docRef = self.db.collection("users").document(myUID).collection("likers")
        docRef.addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            data.forEach { (doc) in
                docRef.document(doc.documentID).delete()
            }
        }
    }
    
    // likeToID refers to the ID of the person the like is being sent to
    func sendInvite(heading: String, subheading: String, comment: String) {
        // myUID = current user in-app's ID
        guard let myUID = currentUser?.uid else { return }
        
        // docRef = Firebase reference for likeTo document
        let docRef = db.collection("users").document(self.sendInviteToUser.id ?? "NOT-A-UID")
        
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
    
    func requestMatch() {
        guard let myUID = currentUser?.uid else { return }
        guard let id = self.requestedMatcher.id else { return }
        let matcherDocRef = db.collection("users").document(id)
        let myDocRef = db.collection("users").document(myUID)
        
        // set my matcherID to matchTo ID
        myDocRef.getDocument { (snap, error) in
            myDocRef.setData([
                "matcherID" : id
            ], merge: true)
        }
        
        // set collection data
        matcherDocRef.collection("matcher").document(myUID).setData([
            "id" : myUID
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
        self.matcher = TempUserLib().emptyUser
        matcherDocRef.collection("matcher").document(userID).delete()
        myDocRef.collection("matcher").document(id).delete()
    }
    
    func checkHasMatcher() -> Bool {
        return self.matcher != TempUserLib().emptyUser
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
        if self.likeCards.count > 0 {
            self.requestedMatcher = likeCards[0].user
        }
    }
    
    func updateRequestedMatcher() {
        self.requestedMatcher = likeCards[0].user
    }
    
    func dismissUser(counter: Int) {
        guard let id = requestedMatcher.id else { return }
        self.pop(idToRemove: id)
        self.requestedMatcher = likeCards[counter < likeCards.count ? counter : 0].user
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
