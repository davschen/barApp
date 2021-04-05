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
    @Published var invitedUserIsBusy = false
    
    private var currentUser = Auth.auth().currentUser
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    // NEEDS UPDATING LATER
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
                        let heading = doc.get("heading") as? String ?? ""
                        let subheading = doc.get("subheading") as? String ?? ""
                        let comment = doc.get("comment") as? String ?? ""
                        DispatchQueue.main.async {
                            var userVar = user
                            userVar.setID(id: doc.documentID)
                            if !self.likers.contains(userVar) {
                                self.likers.append(userVar)
                                self.likeCards.append(LikeCard(user: userVar, heading: heading, subHeading: subheading, comment: comment, id: self.likeCards.count))
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
                            var userVar = matcher
                            userVar.setID(id: doc.documentID)
                            self.matcher = userVar
                        }
                    }
                }
            }
        }
    }
    
    func setInvitedUser(user: User) {
        self.sendInviteToUser = user
    }
    
    func pop() {
        let idToRemove = self.requestedMatcher.id ?? "NOT-AN-ID"
        guard let myUID = currentUser?.uid else { return }
        let docRef = db.collection("users").document(myUID)
        print(idToRemove)
        docRef.collection("likers").document(idToRemove).delete()
        if self.likers.count > 0 {
            self.likers.removeFirst()
            self.likeCards.removeFirst()
        }
    }
    
    // swipe left
    func dismissUser() {
        self.pop()
        self.updateRequestedMatcher()
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
    
    /* NOTE: All code below deals with matching. If I were more responsible, I would have created
     a new VM called matchVM, but I'm not, so I'm fitting it into likerVM
     */
    
    func requestMatch() {
        self.updateRequestedMatcher()
        
        guard let id = currentUser?.uid else { return }
        let matcherDocRef = db.collection("users").document(requestedMatcher.id ?? "NOT-AN-ID")
        matcherDocRef.addSnapshotListener { (doc, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            let invitedUserHasMatch = doc?.get("hasMatch") as? Bool ?? true
            let invitedMatcherID = doc?.get("matcherID") as? String ?? ""
            if !invitedUserHasMatch || invitedMatcherID == (self.currentUser?.uid ?? "NOT-AN-ID") {
                // set my matcherID to matchTo ID
                matcherDocRef.setData([
                    "matcherID" : id,
                    "hasMatch" : true
                ], merge: true)
            } else {
                self.invitedUserIsBusy = true
            }
        }
    }
    
    // called whenever the current user "changes their mind," so to speak, on their match before starting convo.
    func declineMatcher(id: String) {
        guard let userID = currentUser?.uid else { return }
        let matcherDocRef = db.collection("users").document(id)
        let myDocRef = db.collection("users").document(userID)
        
        // set matchTo matcherID value to my UID
        matcherDocRef.getDocument { (snap, error) in
            matcherDocRef.setData([
                "hasMatch" : false,
                "conversationID" : "",
                "matcherID" : ""
            ], merge: true)
        }
        
        // set my matcherID to matchTo ID
        myDocRef.getDocument { (snap, error) in
            myDocRef.setData([
                "hasMatch" : false,
                "conversationID" : "",
                "matcherID" : ""
            ], merge: true)
        }
        self.pop()
    }
    
    func acceptMatch(matchToID: String) {
        // myUID = current user in-app's ID
        guard let myUID = currentUser?.uid else { return }
        
        // docRef = Firebase reference for likeTo document
        let matcherDocRef = db.collection("users").document(matchToID)
        let myDocRef = db.collection("users").document(myUID)
        
        // add match to matcher
        matcherDocRef.getDocument { (snap, error) in
            let numMatches = snap?.get("matches") as? Int ?? 0
            matcherDocRef.setData([
                "hasMatch" : true,
                "matcherID" : myUID,
                "matches" : numMatches + 1
            ], merge: true)
        }
        
        // add match to me
        myDocRef.getDocument { (snap, error) in
            let numMatches = snap?.get("matches") as? Int ?? 0
            myDocRef.setData([
                "matches" : numMatches + 1
            ], merge: true)
        }
    }
    
    func updateRequestedMatcher() {
        if likeCards.count > 0 {
            self.requestedMatcher = likeCards[0].user
        }
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
