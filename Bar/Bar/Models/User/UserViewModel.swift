//
//  InBarUserModel.swift
//  Bar
//
//  Created by David Chen on 12/28/20.


import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class UserViewModel: ObservableObject {
    @Published var users = [User]()
    private var db = Firestore.firestore()
    private var currentUser = Auth.auth().currentUser
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        guard let id = currentUser?.uid else { return }
        db.collection("users").document(id).addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            let barIDFromData = snap?.get("currentBarID") as? String ?? "notAnID"
            let genderPreferences = self.getGenderPreferences(genderPreference: snap?.get("genderPreference") as? String ?? "")
            let seenBefore = snap?.get("seenBefore") as? [String] ?? []
            self.db.collection("users")
                .whereField("currentBarID", isEqualTo: barIDFromData)
                .whereField("gender", in: genderPreferences)
                .addSnapshotListener { (snap, error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        return
                    }
                    guard let data = snap?.documents else { return }
                    guard let userID = Auth.auth().currentUser?.uid else { return }
                    data.forEach { (doc) in
                        if let user = try? doc.data(as: User.self) {
                            DispatchQueue.main.async {
                                var userVar = user
                                userVar.setID(id: doc.documentID)
                                if doc.documentID != userID && !self.users.contains(userVar) && !seenBefore.contains(doc.documentID) {
                                    self.users.append(userVar)
                                }
                            }
                        }
                    }
            }
        }
    }
    
    func removeFromBar(id: String) {
        
    }
    
    func clearUsers() {
        self.users.removeAll()
    }
    
    func cardsFormatter(user: User) -> (headings: [String], subheadings: [String], count: Int) {
        var headings = [""]
        var subheadings = [""]
        var count = 0
        if user.order != "" {
            headings.append("my usual order")
            subheadings.append("\(user.order)")
            count += 1
        }
        if user.hobby != "" {
            headings.append("a hobby of mine")
            subheadings.append("\(user.hobby)")
            count += 1
        }
        if user.quotes != "" {
            headings.append("something i quote way too often")
            subheadings.append("\(user.quotes)")
            count += 1
        }
        if user.guiltyPleasure != "" {
            headings.append("guilty pleasure")
            subheadings.append("\(user.guiltyPleasure)")
            count += 1
        }
        if user.forFun != "" {
            headings.append("my idea of fun")
            subheadings.append("\(user.forFun)")
            count += 1
        }
        if user.customPrompts.count != 0, user.customResponses.count != 0 {
            headings.append(contentsOf: user.customPrompts)
            subheadings.append(contentsOf: user.customResponses)
            count += user.customResponses.count
        }
        return (headings, subheadings, count)
    }
    
    private func getGenderPreferences(genderPreference: String) -> [String] {
        if genderPreference == "Men" {
            return ["Male"]
        } else if genderPreference == "Women" {
            return ["Female"]
        } else {
            return ["Male", "Female"]
        }
    }
}
