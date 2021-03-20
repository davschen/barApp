//
//  CurrentUserViewModel.swift
//  Bar
//
//  Created by David Chen on 1/8/21.
//

import Foundation
import SwiftUI
import Firebase

class CurrentUserViewModel: ObservableObject {
    @Published var currentUser: User
    private var db = Firestore.firestore()
    
    init(currentUser: User = User(id: "", firstName: "", lastName: "", phoneNumber: "", gender: "", genderPreference: "", education: "", profession: "", company: "", city: "", state: "", lookingFor: "", bio: "", order: "", hobby: "", quotes: "", guiltyPleasure: "", forFun: "", currentBarID: "", profURL: "", matcherID: "", minAge: 0, maxAge: 0, likes: 0, matches: 0, contacts: 0, gradYear: 0, imageLinks: [], customPrompts: [], customResponses: [], religions: [], religiousPreferences: [], seenBefore: [], showsLocation: false, lookingForDealbreaker: false, religionDealbreaker: false, openToAll: false, dob: Date())) {
        self.currentUser = currentUser
        getUser()
    }
    
    func getUser() {
        db.collection("users").document(Auth.auth().currentUser?.uid ?? "").addSnapshotListener { (doc, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            if let doc = doc {
                if let currentUser = try? doc.data(as: User.self) {
                    DispatchQueue.main.async {
                        self.currentUser = currentUser
                    }
                }
            }
        }
    }
    
    func updateDB() {
        if let id = Auth.auth().currentUser?.uid {
            let _ = try? db.collection("users").document(id).setData(from: self.currentUser)
        }
    }
    
    func convertCustomArray(userPrompts: [String]) -> [String] {
        var toReturn = ["", "", ""]
        for i in 0 ..< userPrompts.count {
            toReturn[i] = userPrompts[i]
        }
        return toReturn
    }
    
    func changeUserValueDB(key: String, value: Any) {
        if let id = Auth.auth().currentUser?.uid {
            db.collection("users").document(id).setData([
                key : value
            ], merge: true)
        }
    }
}
