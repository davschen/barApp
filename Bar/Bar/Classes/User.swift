//
//  User.swift
//  Bar
//
//  Created by David Chen on 12/18/20.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var firstName, lastName, phoneNumber, gender, genderPreference, education, profession, company, city, state, lookingFor, bio, order, hobby, quotes, guiltyPleasure, forFun, currentBarID, profURL, matcherID, conversationID: String
    var minAge, maxAge, likes, matches, contacts, gradYear: Int
    var imageLinks, customPrompts, customResponses, religions, religiousPreferences, seenBefore: [String]
    var showsLocation, lookingForDealbreaker, religionDealbreaker, openToAll, hasMatch, isOnline: Bool
    var dob: Date

    enum CodingKeys: String, CodingKey {
        case firstName, lastName, phoneNumber, gender, genderPreference, education, gradYear, profession, company, city, state, lookingFor, bio, order, hobby, quotes, guiltyPleasure, forFun, currentBarID, profURL, matcherID, conversationID, minAge, maxAge, likes, matches, contacts, imageLinks, customPrompts, customResponses, religions, religiousPreferences, seenBefore, showsLocation, lookingForDealbreaker, religionDealbreaker, openToAll, hasMatch, isOnline, dob
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    mutating func setID(id: String) {
        self.id = id
    }
}

struct TempUserLib {
    let user1 = User(id: "jimmyB", firstName: "James", lastName: "Bond", phoneNumber: "1800-get-rich-quick", gender: "Male", genderPreference: "Female", education: "Cambridge", profession: "British Intelligence Officer", company: "MI6", city: "London", state: "United Kingdom", lookingFor: "Casual", bio: "Humbly, I’ve been the title character of over twenty feature-length films. You may recognize me from 2021’s No Time to Die.", order: "Vodka martini, shaken, not stirred", hobby: "Making love to beautiful Bond girls", quotes: "Any James Bond Movie", guiltyPleasure: "Jason Bourne Movies", forFun: "Signing up for dating apps", currentBarID: "jimmysBarID", profURL: "https://i.pinimg.com/originals/5d/82/5f/5d825f84b3d1afae294af8eb41b21ca6.jpg", matcherID: "", conversationID: "", minAge: 0, maxAge: 40, likes: 0, matches: 0, contacts: 0, gradYear: 50, imageLinks: ["https://i.pinimg.com/originals/5d/82/5f/5d825f84b3d1afae294af8eb41b21ca6.jpg", "https://www.filmink.com.au/wp-content/uploads/2020/11/no-time-to-die-poster.jpg"], customPrompts: ["Best thing I do"], customResponses: ["Honestly unsure"], religions: ["Atheist"], religiousPreferences: ["Christian", "Catholic"], seenBefore: [], showsLocation: true, lookingForDealbreaker: true, religionDealbreaker: false, openToAll: false, hasMatch: false, isOnline: false, dob: Date(timeInterval: -40, since: Date()))
    let emptyUser = User(id: "NOT-A-UID", firstName: "", lastName: "", phoneNumber: "", gender: "", genderPreference: "", education: "", profession: "", company: "", city: "", state: "", lookingFor: "", bio: "", order: "", hobby: "", quotes: "", guiltyPleasure: "", forFun: "", currentBarID: "", profURL: "", matcherID: "", conversationID: "", minAge: 0, maxAge: 0, likes: 0, matches: 0, contacts: 0, gradYear: 0, imageLinks: [], customPrompts: [], customResponses: [], religions: [], religiousPreferences: [], seenBefore: [], showsLocation: false, lookingForDealbreaker: false, religionDealbreaker: false, openToAll: false, hasMatch: false, isOnline: false, dob: Date())
}
 
