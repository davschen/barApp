//
//  ProfileView.swift
//  Bar
//
//  Created by David Chen on 12/9/20.
//

import Foundation
import SwiftUI
import Firebase

struct ProfileView: View {
    @State var selected = 0
    @EnvironmentObject var cuvm: CurrentUserViewModel
    @Binding var isShowingProfile: Bool
    @ObservedObject var profileViewModel = ProfileViewModel()
    
    var body: some View {
        ZStack {
            Color("Midnight")
                .edgesIgnoringSafeArea(.all)
            ScrollView (.vertical) {
                VStack {
                    ProfilePictureView(viewModel: self.profileViewModel)
                    SystemText(text: "\(cuvm.currentUser.firstName) \(cuvm.currentUser.lastName)", fontstyle: .headerDemiBold)
                    CloutView()
                    MenuSelectionView(selected: $selected, cuvm: cuvm)
                        .padding(.vertical, 20)
                    if self.selected == 0 {
                        PreferencesView()
                    } else if self.selected == 1 {
                        AboutView(pvm: profileViewModel)
                    } else if self.selected == 2 {
                        SettingsView()
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .navigationBarTitle("\(cuvm.currentUser.firstName)'s Profile", displayMode: .inline)
        .animation(.easeInOut)
        .onAppear {
            self.profileViewModel.setProfPicURL(urlString: cuvm.currentUser.profURL)
        }
        .onDisappear {
            DispatchQueue.main.async {
                self.cuvm.updateDB()
            }
        }
    }
}

struct CloutView: View {
    @EnvironmentObject var cuvm: CurrentUserViewModel
    
    var body: some View {
        HStack {
            IconLabelView(number: cuvm.currentUser.likes, iconName: "smallHeart", subheading: "Likes")
            Spacer()
            IconLabelView(number: cuvm.currentUser.matches, iconName: "smallFlame", subheading: "Matches")
            Spacer()
            IconLabelView(number: cuvm.currentUser.contacts, iconName: "smallContact", subheading: "Contacts")
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 40)
        .frame(maxWidth: .infinity)
        .background(Color("Neutral"))
        .cornerRadius(10)
    }
}

struct IconLabelView: View {
    let number: Int
    let iconName: String
    let subheading: String
    
    var body: some View {
        VStack (spacing: 0) {
            HStack {
                SystemText(text: "\(number)", fontstyle: .largeDemiBold)
                Image("\(iconName)")
                    .resizable()
                    .frame(width: 15, height: 15)
            }
            SystemText(text: subheading, fontstyle: .medium)
        }
    }
}

struct MenuSelectionView: View {
    @Binding var selected: Int
    @ObservedObject var cuvm: CurrentUserViewModel
    
    var body: some View {
        VStack {
            HStack {
                SystemText(text: "Preferences", fontstyle: .largeBold)
                    .opacity(selected == 0 ? 1 : 0.5)
                    .onTapGesture {
                        self.selected = 0
                    }
                Spacer()
                SystemText(text: "About Me", fontstyle: .largeBold)
                    .opacity(selected == 1 ? 1 : 0.5)
                    .onTapGesture {
                        self.selected = 1
                    }
                Spacer()
                SystemText(text: "Settings", fontstyle: .largeBold)
                    .opacity(selected == 2 ? 1 : 0.5)
                    .onTapGesture {
                        self.selected = 2
                    }
            }
        }
    }
}

struct PreferencesView: View {
    @EnvironmentObject var cuvm: CurrentUserViewModel
    @State var minAgeTapped = false
    @State var maxAgeTapped = false
    
    var body: some View {
        VStack (spacing: 20) {
            VStack (alignment: .leading) {
                SystemTextTracking(text: "PREFERENCES", fontstyle: .smallDemiBold)
                    .padding(.vertical, 3).padding(.horizontal, 5)
                    .background(Color("Pink"))
                    .cornerRadius(3.0)
                Spacer(minLength: 15)
                SystemText(text: "I'm interested in...", fontstyle: .regular)
                SectionPickerView(choice: $cuvm.currentUser.genderPreference, label: "Men")
                SectionPickerView(choice: $cuvm.currentUser.genderPreference, label: "Women")
                SectionPickerView(choice: $cuvm.currentUser.genderPreference, label: "Both")
            }
            VStack (alignment: .leading) {
                SystemText(text: "Age Range", fontstyle: .regular)
                AgeRangePicker(minAge: $cuvm.currentUser.minAge, maxAge: $cuvm.currentUser.maxAge, minAgeTapped: $minAgeTapped, maxAgeTapped: $maxAgeTapped)
            }
            // Open to religious preferences
            VStack (alignment: .leading) {
                SystemText(text: "I'm Open To", fontstyle: .regular)
                VStack {
                    ReligionView(religions: $cuvm.currentUser.religiousPreferences, openToAll: $cuvm.currentUser.openToAll, preferences: true)
                    Spacer(minLength: 20)
                    HStack {
                        SystemText(text: "Open to all", fontstyle: .medium)
                        Spacer()
                        SwitchView(on: $cuvm.currentUser.openToAll)
                            .simultaneousGesture(TapGesture().onEnded {
                                cuvm.currentUser.religiousPreferences = [String]()
                            })
                    }
                    if !cuvm.currentUser.religiousPreferences.isEmpty {
                        Divider()
                        HStack {
                            SystemText(text: "Dealbreaker?", fontstyle: .medium)
                            Spacer()
                            SwitchView(on: $cuvm.currentUser.religionDealbreaker)
                        }
                    }
                    Spacer(minLength: 5)
                }
                .padding()
                .background(Color("Neutral"))
                .cornerRadius(5)
            }
        }
    }
}

struct AboutView: View {
    @ObservedObject var pvm: ProfileViewModel
    @EnvironmentObject var cuvm: CurrentUserViewModel
    @State var gradTapped = false
    @State var openToAll = false
    @State var customPromptsToSave = ["", "", ""]
    @State var customResponsesToSave = ["", "", ""]
    
    var body: some View {
        VStack (alignment: .leading) {
            VStack (alignment: .leading) {
                SystemTextTracking(text: "MY PHOTOS", fontstyle: .smallDemiBold)
                    .padding(.vertical, 3).padding(.horizontal, 5)
                    .background(Color("Pink"))
                    .cornerRadius(3.0)
                NavigationLink(
                    destination: EditPhotosView().environmentObject(self.pvm),
                    label: {
                        ImageGridView().environmentObject(self.pvm)
                    })
                SystemText(text: "Tap To Edit", fontstyle: .regular)
            }
            Spacer(minLength: 50)
            Group {
                SystemTextTracking(text: "PERSONAL INFO", fontstyle: .smallDemiBold)
                    .padding(.vertical, 3).padding(.horizontal, 5)
                    .background(Color("Pink"))
                    .cornerRadius(3.0)
                Spacer(minLength: 15)
                FirstNameLastNameView(firstName: $cuvm.currentUser.firstName, lastName: $cuvm.currentUser.lastName)
                Spacer(minLength: 15)
                // bio view
                SystemText(text: "Bio", fontstyle: .regular)
                InProfileBioView(bio: $cuvm.currentUser.bio)
                Spacer(minLength: 15)
                VStack (alignment: .leading) {
                    SystemText(text: "I identify as...", fontstyle: .regular)
                    SectionPickerView(choice: $cuvm.currentUser.gender, label: "Male")
                    SectionPickerView(choice: $cuvm.currentUser.gender, label: "Female")
                    SectionPickerView(choice: $cuvm.currentUser.gender, label: "Non-binary")
                }
                Spacer(minLength: 15)
                VStack (alignment: .leading) {
                    SystemText(text: "My religious affiliation is", fontstyle: .regular)
                    ReligionView(religions: $cuvm.currentUser.religions, openToAll: $openToAll, preferences: false)
                        .padding()
                        .background(Color("Neutral"))
                        .cornerRadius(5)
                }
            }
            Spacer(minLength: 50)
            Group {
                SystemTextTracking(text: "BACKGROUND", fontstyle: .smallDemiBold)
                    .padding(.vertical, 3).padding(.horizontal, 5)
                    .background(Color("Pink"))
                    .cornerRadius(3.0)
                UserBackgroundView(city: $cuvm.currentUser.city, state: $cuvm.currentUser.state, profession: $cuvm.currentUser.profession, company: $cuvm.currentUser.company, education: $cuvm.currentUser.education, gradYear: $cuvm.currentUser.gradYear)
                    .font(Font.custom("Avenir Next Regular", size: 14))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color("Neutral"))
                    .cornerRadius(5)
            }
            Spacer(minLength: 50)
            Group {
                Section(header:
                            SystemTextTracking(text: "RESPONSE PROMPTS", fontstyle: .smallDemiBold)
                                .padding(.vertical, 3).padding(.horizontal, 5)
                                .background(Color("Pink"))
                                .cornerRadius(3.0)) {
                    VStack {
                        CustomizeFormView(feature: $cuvm.currentUser.order, text: "Bar Order", exampleText: "e.g. Gin and Tonic", iconName: "martiniIcon", isSystemIcon: false)
                        Divider()
                        CustomizeFormView(feature: $cuvm.currentUser.hobby, text: "Favorite Hobby", exampleText: "e.g. Long Walks along the Pacific Coast", iconName: "hobbyIcon", isSystemIcon: false)
                        Divider()
                        CustomizeFormView(feature: $cuvm.currentUser.quotes, text: "What Do You Quote Way Too Often?", exampleText: "e.g. The Office, Rick and Morty...", iconName: "quote.bubble.fill", isSystemIcon: true)
                        Divider()
                        CustomizeFormView(feature: $cuvm.currentUser.guiltyPleasure, text: "Guilty Pleasure", exampleText: "e.g. Party sized Lays bag", iconName: "chipsIcon", isSystemIcon: false)
                        Divider()
                        CustomizeFormView(feature: $cuvm.currentUser.forFun, text: "What Do You Do For Fun?", exampleText: "e.g. Re-paint my house different colors", iconName: "paintbrush.fill", isSystemIcon: true)
                    }
                    .padding()
                    .background(Color("Neutral"))
                    .cornerRadius(5)
                    VStack {
                        HStack {
                            SystemTextTracking(text: "CUSTOM RESPONSES", fontstyle: .smallDemiBold)
                            Spacer()
                        }
                        CustomPromptView(promptArray: $customPromptsToSave, responseArray: $customResponsesToSave, index: 0)
                        Divider()
                        CustomPromptView(promptArray: $customPromptsToSave, responseArray: $customResponsesToSave, index: 1)
                        Divider()
                        CustomPromptView(promptArray: $customPromptsToSave, responseArray: $customResponsesToSave, index: 2)
                    }
                    .padding()
                    .background(Color("Neutral"))
                    .cornerRadius(5)
                }
            }
            .font(Font.custom("Avenir Next", size: 14))
        }
        .preferredColorScheme(.dark)
        .onAppear {
            self.pvm.setImageLinks(imageLinks: cuvm.currentUser.imageLinks)
            self.customPromptsToSave = self.cuvm.convertCustomArray(userPrompts: cuvm.currentUser.customPrompts)
            self.customResponsesToSave = self.cuvm.convertCustomArray(userPrompts: cuvm.currentUser.customResponses)
        }
        .onDisappear {
            self.cuvm.currentUser.customPrompts = []
            self.cuvm.currentUser.customResponses = []
            for i in 0 ..< self.customPromptsToSave.count {
                if !self.customPromptsToSave[i].isEmpty && !self.customResponsesToSave[i].isEmpty {
                    self.cuvm.currentUser.customPrompts.append(self.customPromptsToSave[i])
                    self.cuvm.currentUser.customResponses.append(self.customResponsesToSave[i])
                }
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var cuvm: CurrentUserViewModel
    @State var showPreview = false
    @State var presentAlert = false
    
    var body: some View {
        ZStack {
            BGColor()
            VStack {
                NavigationLink(
                    destination: UserView(user: self.cuvm.currentUser, invitable: false, isPreview: true, show: $showPreview),
                    label: {
                        HStack {
                            SystemText(text: "Preview Your Profile", fontstyle: .medium)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color("Neutral"))
                        .cornerRadius(5)
                    })
                Spacer(minLength: 20)
                Button(action: {
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    NotificationCenter.default.post(name: NSNotification.Name("LogInStatusChange"), object: nil)
                    try! Auth.auth().signOut()
                }, label: {
                    StandardButtonView(text: "Log Out")
                })
                Button(action: {
                    presentAlert.toggle()
                }, label: {
                    StandardButtonView(text: "Delete My Account")
                })
            }
        }
        .alert(isPresented: $presentAlert) {
            Alert(title: Text("Are You Sure?"), message: Text("Deleting your account will permanently remove all of your data"),
                  primaryButton: .cancel(),
                  secondaryButton: .default(Text("Yes, delete my account"), action: {
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    NotificationCenter.default.post(name: NSNotification.Name("LogInStatusChange"), object: nil)
                    if let id = Auth.auth().currentUser?.uid {
                        let db = Firestore.firestore()
                        db.collection("users").document(id).delete { (error) in
                            if error != nil { return }
                        }
                    }
                    try! Auth.auth().signOut()
                  }))
        }
    }
}

// Might use these two later - don't touch!
struct MilesKmSwitchView: View {
    @Binding var imperial: Bool
    let width: CGFloat = 80
    let height: CGFloat = 20
    var body: some View {
        ZStack {
            let offX: CGFloat = -width / 2 + width / 4
            let onX: CGFloat = width / 2 - width / 4
            RoundedRectangle(cornerRadius: 100)
                .frame(width: self.width, height: self.height)
                .foregroundColor(imperial ? Color("Pink") : Color("Navy"))
                .background(RoundedRectangle(cornerRadius: 100).stroke(Color.white, lineWidth: 3))
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: self.width / 2, height: self.height)
                    .foregroundColor(.white)
                Text(imperial ? "Mi" : "Km")
                    .font(Font.custom("Avenir Next Bold", size: 12))
                    .foregroundColor(Color("Navy"))
            }
            .offset(x: imperial ? offX : onX)
        }
        .frame(width: self.width, height: self.height)
        .onTapGesture {
            withAnimation {
                self.imperial.toggle()
            }
        }
    }
}

struct ImageGridView: View {
    @EnvironmentObject var pvm: ProfileViewModel
    var body: some View {
        GridStack(rows: 2, columns: 3) { row, col in
            let groupIndex = row * 3 + col
            ZStack {
                if !isBlank(groupIndex: groupIndex, imagesCount: self.pvm.imageLinks.count) {
                    SystemWebImage(url: self.pvm.imageLinks[groupIndex], radius: 0)
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                }
            }
            .frame(height: 150)
            .frame(maxWidth: .infinity)
            .cornerRadius(5)
            .background(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
            .background(Color("Neutral"))
            .shadow(color: .black, radius: 10, y: 10)
            .padding(2)
        }
    }
    
    func isBlank(groupIndex: Int, imagesCount: Int) -> Bool {
        return groupIndex >= imagesCount
    }
}

struct SliderView: View {
    @Binding var distance: Double
    var body: some View {
        Slider(value: $distance, in: 0...100)
            .accentColor(Color("Pink"))
    }
}

struct ProfileView_Previews: PreviewProvider {
    @State static var isShowingProfile = true
    static var previews: some View {
        ProfileView(isShowingProfile: $isShowingProfile)
    }
}

struct FirstNameLastNameView: View {
    @Binding var firstName: String
    @Binding var lastName: String
    
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                SystemText(text: "First Name", fontstyle: .regular)
                ZStack {
                    ZStack (alignment: .leading) {
                        if firstName.isEmpty {
                            Text("e.g. Sam")
                                .foregroundColor(.gray)
                                .animationsDisabled()
                        }
                        TextField("e.g. Sam", text: $firstName)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .font(Font.custom("Avenir Next Medium", size: 14))
                    .background(RoundedRectangle(
                        cornerRadius: 5, style: .continuous
                    ).stroke(Color.white, lineWidth: 0.5))
                    .accentColor(.white)
                }
            }
            VStack (alignment: .leading) {
                SystemText(text: "Last Name", fontstyle: .regular)
                ZStack {
                    ZStack (alignment: .leading) {
                        if lastName.isEmpty {
                            Text("e.g. Lee")
                                .foregroundColor(.gray)
                                .animationsDisabled()
                        }
                        TextField("e.g. Lee", text: $lastName)
                            .fixedSize(horizontal: false, vertical: true)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 15)
                    .font(Font.custom("Avenir Next Medium", size: 14))
                    .background(RoundedRectangle(
                        cornerRadius: 5, style: .continuous
                    ).stroke(Color.white, lineWidth: 0.5))
                    .accentColor(.white)
                }
            }
        }
    }
}

struct InProfileBioView: View {
    @Binding var bio: String
    @State var editTapped = false
    
    var body: some View {
        ZStack {
            Color("Neutral")
            MultilineTextField("A little bit about yourself", text: $bio, onCommit: {
                
            })
            .padding(.vertical, 5).padding(.horizontal, 10)
            .accentColor(.white)
            .animationsDisabled()
        }
        .cornerRadius(5)
    }
}
