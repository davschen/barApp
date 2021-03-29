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
    @Published var currentUser = TempUserLib().emptyUser
    private var db = Firestore.firestore()
    private var myUID: String {
        return Auth.auth().currentUser?.uid ?? "NOT-AN-ID"
    }
    
    init() {
        getUser()
    }
    
    func getUser() {
        db.collection("users").document(self.myUID).addSnapshotListener { (doc, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let doc = doc else { return }
            if let currentUser = try? doc.data(as: User.self) {
                DispatchQueue.main.async {
                    self.currentUser = currentUser
                }
            }
        }
    }
    
    func updateDB() {
        let _ = try? db.collection("users").document(self.myUID).setData(from: self.currentUser)
    }
    
    func convertCustomArray(userPrompts: [String]) -> [String] {
        var toReturn = ["", "", ""]
        for i in 0 ..< userPrompts.count {
            toReturn[i] = userPrompts[i]
        }
        return toReturn
    }
    
    func changeUserValueDB(key: String, value: Any) {
        db.collection("users").document(self.myUID).setData([
            key : value
        ], merge: true)
    }
}
