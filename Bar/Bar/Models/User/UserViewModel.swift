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
    private var user = Auth.auth().currentUser
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        guard let id = user?.uid else { return }
        db.collection("users").document(id).addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            let barIDFromData = snap?.get("currentBarID") as? String ?? ""
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
