//
//  CompleteProfileView.swift
//  Bar
//
//  Created by David Chen on 1/3/21.
//

import Foundation
import SwiftUI
import CoreLocation
import FirebaseAuth
import Firebase

struct CompleteProfileView: View {
    @ObservedObject var locationManager = LocationManager()
    @State var isShowingCustomizeProfile = false
    @Binding var firstName: String
    @Binding var lastName: String
    @ObservedObject var profileViewModel = ProfileViewModel()
    @State var gender = "Non-binary"
    @State var genderPreference = "Both"
    @State var minAge = 0
    @State var maxAge = 62
    @State var minAgeTapped = false
    @State var maxAgeTapped = false
    @State var bio = ""
    let db = Firestore.firestore()
    
    var hasLocation: Bool {
        let manager = CLLocationManager()
        let status = manager.authorizationStatus
         
        if status == .restricted || status == .denied || status == .notDetermined {
            return false
        } else {
            return true
        }
    }
    var hasValidEntries: Bool {
        return self.profileViewModel.profPicURL != "" && self.profileViewModel.imageLinks.count >= 2 && self.gender != "" && self.genderPreference != ""
    }
    
    var body: some View {
        ZStack {
            BGColor()
            ScrollView (.vertical) {
                VStack (spacing: 30) {
                    VStack {
                        ProfilePictureView(profileVM: profileViewModel)
                        SystemText(text: "A Profile Picture is Required", fontstyle: .regular)
                        SystemText(text: "\(firstName) \(lastName)", fontstyle: .headerBold)
                    }
                    .padding(.top)
                    VStack (alignment: .leading) {
                        SystemTextTracking(text: "UPLOAD PHOTOS", fontstyle: .smallDemiBold)
                        ImagePickerGridView(profileViewModel: self.profileViewModel)
                        SystemText(text: "You must select at least two photos, and add a profile picture", fontstyle: .regular)
                    }
                    VStack (alignment: .leading) {
                        SystemTextTracking(text: "BASIC INFO", fontstyle: .smallDemiBold)
                            .padding(.vertical, 3).padding(.horizontal, 5)
                            .background(Color("Pink"))
                            .cornerRadius(3.0)
                        Spacer(minLength: 15)
                        SystemText(text: "About Me", fontstyle: .regular)
                        ZStack {
                            Color("Neutral")
                            MultilineTextField("A little bit about yourself", text: $bio, onCommit: {
                                        })
                            .padding(5)
                            .accentColor(.white)
                            .animationsDisabled()
                        }
                        .cornerRadius(5)
                    }
                    VStack (alignment: .leading) {
                        SystemText(text: "I identify as...", fontstyle: .regular)
                        SectionPickerView(choice: $gender, label: "Male")
                        SectionPickerView(choice: $gender, label: "Female")
                        SectionPickerView(choice: $gender, label: "Non-binary")
                    }
                    VStack (alignment: .leading) {
                        SystemTextTracking(text: "PREFERENCES", fontstyle: .smallDemiBold)
                            .padding(.vertical, 3).padding(.horizontal, 5)
                            .background(Color("Pink"))
                            .cornerRadius(3.0)
                        Spacer(minLength: 15)
                        SystemText(text: "I'm interested in...", fontstyle: .regular)
                        SectionPickerView(choice: $genderPreference, label: "Men")
                        SectionPickerView(choice: $genderPreference, label: "Women")
                        SectionPickerView(choice: $genderPreference, label: "Both")
                    }
                    VStack (alignment: .leading) {
                        SystemText(text: "Age Range", fontstyle: .regular)
                        AgeRangePicker(minAge: $minAge, maxAge: $maxAge, minAgeTapped: $minAgeTapped, maxAgeTapped: $maxAgeTapped)
                    }
                    ZStack {
                        if hasValidEntries {
                            NavigationLink(destination: CustomizeProfileView()) {
                                StandardButtonView(text: "Continue")
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                if let id = Auth.auth().currentUser?.uid {
                                    db.collection("users").document(id).setData([
                                        "gender" : self.gender,
                                        "bio" : self.bio,
                                        "genderPreference" : self.genderPreference,
                                        "minAge" : self.minAge,
                                        "maxAge" : self.maxAge
                                    ], merge: true)
                                }
                            })
                        } else {
                            StandardButtonView(text: "Continue")
                                .opacity(0.4)
                        }
                    }
                    RegistrationPaginationView(index: 3)
                }
            }
            .padding(.horizontal)
            .navigationBarTitle("Complete Your Profile", displayMode: .inline)
        }
        .animation(.easeInOut)
        .onAppear {
            UIScrollView.appearance().keyboardDismissMode = .onDrag
        }
    }
    
    func getAge(plus: Int) -> Int {
        return plus + 18
    }
}

struct ShakeEffect: GeometryEffect {
    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX: -30 * sin(position * 4 * .pi), y: 0))
    }
    init(shakes: Int) {
            position = CGFloat(shakes)
        }
        var position: CGFloat
        var animatableData: CGFloat {
            get { position }
            set { position = newValue }
        }
}

struct SectionPickerView: View {
    @Binding var choice: String
    let label: String
    
    var body: some View {
        HStack {
            SystemText(text: label, fontstyle: .medium)
            Spacer()
            Image(systemName: "checkmark")
                .foregroundColor(self.choice == label ? .white : Color("Neutral"))
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: (self.choice == label) ? 1 : 0))
        .background(Color("Neutral"))
        .cornerRadius(5)
        .onTapGesture {
            self.choice = (self.choice != label) ? label : self.choice
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }
}

struct AgeRangePicker: View {
    @Binding var minAge: Int
    @Binding var maxAge: Int
    @Binding var minAgeTapped: Bool
    @Binding var maxAgeTapped: Bool
    
    var body: some View {
        VStack {
            HStack {
                SystemText(text: "Between", fontstyle: .medium)
                HStack (spacing: 3) {
                    SystemText(text: String(minAge + 18), fontstyle: .mediumDemiBold)
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .frame(width: 5, height: 5)
                        .foregroundColor(.white)
                }
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
                .background(minAgeTapped ? Color("Light Muted") : Color("Neutral"))
                .onTapGesture {
                    self.minAgeTapped.toggle()
                    if maxAgeTapped {
                        self.maxAgeTapped.toggle()
                    }
                    if minAge > maxAge {
                        let tempMax = maxAge
                        maxAge = minAge
                        minAge = tempMax
                    }
                }
                SystemText(text: "and", fontstyle: .medium)
                HStack (spacing: 3) {
                    SystemText(text: String(maxAge + 18), fontstyle: .mediumDemiBold)
                    Image(systemName: "arrowtriangle.down.fill")
                        .resizable()
                        .frame(width: 5, height: 5)
                        .foregroundColor(.white)
                }
                .padding(5)
                .background(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
                .background(maxAgeTapped && !minAgeTapped ? Color("Light Muted") : Color("Neutral"))
                .onTapGesture {
                    self.maxAgeTapped.toggle()
                    if minAgeTapped {
                        self.minAgeTapped.toggle()
                    }
                    if minAge > maxAge {
                        let tempMax = maxAge
                        maxAge = minAge
                        minAge = tempMax
                    }
                }
                Spacer()
            }
            if minAgeTapped || maxAgeTapped {
                Picker(selection: minAgeTapped ? $minAge : $maxAge, label: Text(""), content: {
                    ForEach(18..<70 + 1) { i in
                        Text(String(i))
                    }
                })
                .colorScheme(.dark)
            }
        }
        .padding(10)
        .background(Color("Neutral"))
        .cornerRadius(5)
    }
}

struct CompleteProfileView_Previews: PreviewProvider {
    @State static var isShowingCompleteProfile = true
    @State static var firstName = "David"
    @State static var lastName = "Chen"
    static var previews: some View {
        CompleteProfileView(firstName: $firstName, lastName: $lastName)
    }
}
