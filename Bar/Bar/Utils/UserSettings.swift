//
//  UserSettings.swift
//  Bar
//
//  Created by David Chen on 12/27/20.
//

import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var firstName: String {
        didSet {
            UserDefaults.standard.set(firstName, forKey: "firstName")
        }
    }
    @Published var lastName: String {
        didSet {
            UserDefaults.standard.set(lastName, forKey: "lastName")
        }
    }
    @Published var maxDistance: Double {
        didSet {
            UserDefaults.standard.set(maxDistance, forKey: "maxDistance")
        }
    }
    @Published var imperial: Bool {
        didSet {
            UserDefaults.standard.set(imperial, forKey: "imperial")
        }
    }
    @Published var likesMen: Bool {
        didSet {
            UserDefaults.standard.set(likesMen, forKey: "likesMen")
        }
    }
    @Published var likesWomen: Bool {
        didSet {
            UserDefaults.standard.set(likesWomen, forKey: "likesWomen")
        }
    }
    @Published var likesGNB: Bool {
        didSet {
            UserDefaults.standard.set(likesGNB, forKey: "likesGNB")
        }
    }
    @Published var lowAge: Int {
        didSet {
            UserDefaults.standard.set(lowAge, forKey: "lowAge")
        }
    }
    @Published var highAge: Int {
        didSet {
            UserDefaults.standard.set(highAge, forKey: "highAge")
        }
    }
    @Published var hasBuiltProfile: Bool {
        didSet {
            UserDefaults.standard.set(highAge, forKey: "hasBuiltProfile")
        }
    }
    
    init() {
        self.firstName = UserDefaults.standard.object(forKey: "firstName") as? String ?? ""
        self.lastName = UserDefaults.standard.object(forKey: "lastName") as? String ?? ""
        self.maxDistance = UserDefaults.standard.object(forKey: "maxDistance") as? Double ?? 50
        self.imperial = UserDefaults.standard.object(forKey: "imperial") as? Bool ?? true
        self.likesMen = UserDefaults.standard.object(forKey: "likesMen") as? Bool ?? false
        self.likesWomen = UserDefaults.standard.object(forKey: "likesWomen") as? Bool ?? false
        self.likesGNB = UserDefaults.standard.object(forKey: "likesGNB") as? Bool ?? false
        self.lowAge = UserDefaults.standard.object(forKey: "lowAge") as? Int ?? 18
        self.highAge = UserDefaults.standard.object(forKey: "highAge") as? Int ?? 80
        self.hasBuiltProfile = UserDefaults.standard.object(forKey: "hasBuiltProfile") as? Bool ?? false
    }
}
