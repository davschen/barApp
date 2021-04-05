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
    @Published var inspectedUser: User = TempUserLib().emptyUser
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
            let gender = snap?.get("gender") as? String ?? ""
            let seenBefore = snap?.get("seenBefore") as? [String] ?? []
            let minAge = snap?.get("minAge") as? Int ?? 18
            let maxAge = snap?.get("maxAge") as? Int ?? 80
            let minDOB = self.getDateFromInt(int: minAge + 18)
            let maxDOB = self.getDateFromInt(int: maxAge + 18)
            self.db.collection("users")
                .whereField("currentBarID", isEqualTo: barIDFromData)
                .whereField("currentBarID", isNotEqualTo: "")
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
                                if doc.documentID != userID
                                    && !self.users.contains(userVar)
                                    && !seenBefore.contains(doc.documentID)
                                    && user.dob <= minDOB
                                    && user.dob >= maxDOB
                                    && user.genderPreference == self.getGender(gender: gender)
                                    && self.users.count < 6 {
                                    self.users.append(userVar)
                                }
                                if self.users.count == 6 {
                                    return
                                }
                            }
                        }
                    }
            }
        }
    }
    
    func setInspectedUser(user: User) {
        self.inspectedUser = user
    }
    
    func removeFromBar(id: String) {
        self.users.remove(at: getIndexFromID(id: id))
    }
    
    func getIndexFromID(id: String) -> Int {
        for i in 0..<self.users.count {
            let user = self.users[i]
            guard let userID = user.id else { return 0 }
            if userID == id {
                return i
            }
        }
        return 0
    }
    
    func clearUsers() {
        self.users.removeAll()
    }
    
    func getYearsDiffFromDate(date: Date) -> Int {
        let difference = Calendar.current.dateComponents([.year], from: date, to: Date())
        return Int(difference.year!)
    }
    
    func getDateFromInt(int: Int) -> Date {
        let currentDate = Date()
        var dateComponent = DateComponents()
        dateComponent.year = -(int)
        
        let differenceFromCurrent = Calendar.current.date(byAdding: dateComponent, to: currentDate)
        return differenceFromCurrent ?? Date()
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
    
    private func getGender(gender: String) -> String {
        switch gender {
        case "Male": return "Men"
        case "Female": return "Women"
        default: return "Both"
        }
    }
}
