//
//  CustomizeProfileView.swift
//  Bar
//
//  Created by David Chen on 1/4/21.
//

import Foundation
import SwiftUI
import Firebase

struct CustomizeProfileView: View {
    @State var city = ""
    @State var state = ""
    @State var showsLocation = false
    @State var profession = ""
    @State var education = ""
    @State var company = ""
    @State var lookingFor = "Both"
    @State var lookingForDealbreaker = false
    @State var religions = [String]()
    @State var religiousPreferences = [String]()
    @State var religionDealbreaker = false
    @State var openToAll = false
    @State var order = ""
    @State var hobby = ""
    @State var quotes = ""
    @State var guiltyPleasure = ""
    @State var forFun = ""
    @State var customPrompts = ["", "", ""]
    @State var customResponses = ["", "", ""]
    @State var links = [String]()
    @State var gradYear = 0
    let db = Firestore.firestore()
    
    let lookingFors = ["Casual", "Serious", "Both"]
    
    init() {
        UITableView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: SystemTextTracking(text: "background", fontstyle: .regular)) {
                    UserBackgroundView(city: $city, state: $state, profession: $profession, company: $company, education: $education, gradYear: $gradYear)
                }
                Section(header: SystemTextTracking(text: "i'm looking for something", fontstyle: .regular)) {
                    HStack {
                        LookingForView(lookingFor: $lookingFor, lookingForDealBreaker: $lookingForDealbreaker)
                    }
                }
                Section(header: SystemTextTracking(text: "my religious affiliation is", fontstyle: .regular)) {
                    ReligionView(religions: $religions, openToAll: $openToAll, preferences: false)
                }
                Section(header: SystemTextTracking(text: "i'm open to", fontstyle: .regular)) {
                    VStack {
                        ReligionView(religions: $religiousPreferences, openToAll: $openToAll, preferences: true)
                        HStack {
                            SystemText(text: "Open to all", fontstyle: .medium)
                            Spacer()
                            SwitchView(on: $openToAll)
                                .simultaneousGesture(TapGesture().onEnded {
                                    self.religiousPreferences = [String]()
                                })
                        }
                        if !self.religiousPreferences.isEmpty {
                            Divider()
                            HStack {
                                SystemText(text: "Dealbreaker?", fontstyle: .medium)
                                Spacer()
                                SwitchView(on: $religionDealbreaker)
                            }
                        }
                        Spacer(minLength: 5)
                    }
                }
                Section(header: SystemTextTracking(text: "response prompts", fontstyle: .regular)) {
                    CustomizeFormView(feature: $order, text: "Bar Order", exampleText: "e.g. Gin and Tonic", iconName: "martiniIcon", isSystemIcon: false)
                    CustomizeFormView(feature: $hobby, text: "Favorite Hobby", exampleText: "e.g. Long Walks along the Pacific Coast", iconName: "hobbyIcon", isSystemIcon: false)
                    CustomizeFormView(feature: $quotes, text: "What Do You Quote Way Too Often?", exampleText: "e.g. The Office, Rick and Morty...", iconName: "quote.bubble.fill", isSystemIcon: true)
                    CustomizeFormView(feature: $guiltyPleasure, text: "Guilty Pleasure", exampleText: "e.g. Party sized Lays bag", iconName: "chipsIcon", isSystemIcon: false)
                    CustomizeFormView(feature: $forFun, text: "What Do You Do For Fun?", exampleText: "e.g. Re-paint my house different colors", iconName: "paintbrush.fill", isSystemIcon: true)
                }
                Section(header: SystemTextTracking(text: "custom prompts", fontstyle: .regular)) {
                    VStack {
                        HStack {
                            SystemText(text: "Add up to three custom prompts!", fontstyle: .regular)
                            Spacer()
                        }
                        Divider()
                        CustomPromptView(promptArray: $customPrompts, responseArray: $customResponses, index: 0)
                        Divider()
                        CustomPromptView(promptArray: $customPrompts, responseArray: $customResponses, index: 1)
                        Divider()
                        CustomPromptView(promptArray: $customPrompts, responseArray: $customResponses, index: 2)
                    }
                    .padding(.vertical)
                }
                Section {
                    NavigationLink(destination: BarView()) {
                        HStack {
                            Text("Take me to Bar")
                            Spacer()
                        }
                    }
                }
            }
        }
        .font(Font.custom("Avenir Next", size: 14))
        .navigationViewStyle(StackNavigationViewStyle())
        .accentColor(.white)
        .preferredColorScheme(.dark)
        .navigationBarTitle("Finishing Touches", displayMode: .automatic)
        .background(Color("Midnight").edgesIgnoringSafeArea(.all))
        .animation(.easeInOut)
        .onDisappear {
            UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
            if let id = Auth.auth().currentUser?.uid {
                db.collection("users").document(id).setData([
                    "city" : self.city,
                    "state" : self.state,
                    "showsLocation" : (self.city.isEmpty || self.state.isEmpty) ? false : true,
                    "profession" : self.profession,
                    "education" : self.education,
                    "company" : self.company,
                    "lookingFor" : self.lookingFor,
                    "lookingForDealbreaker" : self.lookingForDealbreaker,
                    "religions" : self.religions,
                    "religiousPreferences" : self.religiousPreferences,
                    "religionDealbreaker" : self.religionDealbreaker,
                    "openToAll" : self.openToAll,
                    "order" : self.order,
                    "hobby" : self.hobby,
                    "quotes" : self.quotes,
                    "guiltyPleasure" : self.guiltyPleasure,
                    "forFun" : self.forFun,
                    "customPrompts" : cleanPrompts(),
                    "customResponses" : cleanResponses(),
                    "gradYear" : self.education.isEmpty ? 0 : getGradClass(year: gradYear),
                    "currentBarID" : ""
                ], merge: true)
            }
        }
    }
    
    func getGradClass(year: Int) -> Int {
        return year + 1940
    }
    
    func cleanPrompts() -> [String] {
        var promptsToReturn = [String]()
        for i in 0..<3 {
            if !self.customPrompts[i].isEmpty && !self.customResponses[i].isEmpty {
                promptsToReturn.append(customPrompts[i])
            }
        }
        return promptsToReturn
    }
    
    func cleanResponses() -> [String] {
        var responsesToReturn = [String]()
        for i in 0..<3 {
            if !self.customPrompts[i].isEmpty && !self.customResponses[i].isEmpty {
                responsesToReturn.append(customResponses[i])
            }
        }
        return responsesToReturn
    }
}

struct UserBackgroundView: View {
    @Binding var city: String
    @Binding var state: String
    @Binding var profession: String
    @Binding var company: String
    @Binding var education: String
    @Binding var gradYear: Int
    @State var gradTapped = false
    var currentYear = Calendar.current.dateComponents([.year], from: Date())
    
    var body: some View {
        HStack {
            Image(systemName: "house.fill")
            TextField("City", text: $city)
            Image(systemName: "mappin.circle.fill")
            TextField("State", text: $state)
        }
        HStack {
            Image(systemName: "briefcase.fill")
            TextField("Profession", text: $profession)
        }
        if !profession.isEmpty {
            TextField("Company", text: $company)
        }
        HStack {
            SystemImage(name: "capIcon", radius: 0)
                .frame(width: 15, height: 15)
            TextField("School", text: $education)
        }
        // if they've put anything for education
        if !education.isEmpty {
            HStack {
                Text("Class of \(getGradClass(year: gradYear))")
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(self.gradTapped ? 180 : 0))
            }
            .onTapGesture {
                self.gradTapped.toggle()
            }
        }
        // if tapped on grdaute class, show picker
        if gradTapped {
            Picker(selection: $gradYear, label: Text("Graduating Class")) {
                ForEach(1940 ..< (currentYear.year! + 4)) { i in
                    Text("Class of \(String(i))")
                }
            }
            .pickerStyle(WheelPickerStyle())
        }
    }
    
    func getGradClass(year: Int) -> String {
        return String(year + 1940)
    }
}

struct CustomizeFormView: View {
    @Binding var feature: String
    @State var text: String
    @State var exampleText: String
    @State var iconName: String
    @State var isSystemIcon: Bool
    
    var body: some View {
        VStack (alignment: .leading) {
            Text(text)
            HStack {
                if isSystemIcon {
                    Image(systemName: iconName)
                } else {
                    SystemImage(name: iconName, radius: 0)
                        .frame(width: 15, height: 15)
                }
                TextField(exampleText, text: $feature)
            }
        }.padding(.vertical, 5)
    }
}

struct CustomPromptView: View {
    @Binding var promptArray: [String]
    @Binding var responseArray: [String]
    @State var index: Int
    var body: some View {
        VStack {
            HStack {
                Text("Prompt: ")
                TextField("Type your prompt", text: $promptArray[self.index])
            }
            HStack {
                Text("Response: ")
                TextField("Response", text: $responseArray[self.index])
            }
        }
    }
}

struct LookingForView: View {
    @Binding var lookingFor: String
    @Binding var lookingForDealBreaker: Bool
    
    var body: some View {
        VStack {
            HStack {
                bubbleView(label: "Serious")
                Spacer()
                bubbleView(label: "Casual")
                Spacer()
                bubbleView(label: "Both")
            }
            if self.lookingFor != "Both" {
                Divider()
                HStack {
                    SystemText(text: "Dealbreaker?", fontstyle: .medium)
                    Spacer()
                    SwitchView(on: $lookingForDealBreaker)
                }
            }
        }
        .padding(.vertical, 5)
    }
    func bubbleView(label: String) -> some View {
        SystemText(text: label, fontstyle: .regular)
            .padding(.vertical, 5).padding(.horizontal, 15)
            .frame(width: 80)
            .background(Capsule().stroke(Color.white, lineWidth: 1))
            .background(self.lookingFor == label ? Color("Light Muted") : Color.white.opacity(0.2))
            .clipShape(Capsule())
            .onTapGesture {
                setLookingFor(label: label)
            }
    }
    func setLookingFor(label: String) {
        self.lookingFor = label
        if label == "Both" {
            self.lookingForDealBreaker = false
        }
    }
}

struct ReligionView: View {
    @Binding var religions: [String]
    @Binding var openToAll: Bool
    @State var preferences: Bool
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                bubbleView(label: "Atheist")
                Spacer()
                bubbleView(label: "Agnostic")
                Spacer()
                bubbleView(label: "Buddhist")
            }
            HStack {
                bubbleView(label: "Catholic")
                Spacer()
                bubbleView(label: "Christian")
                Spacer()
                bubbleView(label: "Hindu")
            }
            HStack {
                bubbleView(label: "Jewish")
                Spacer()
                bubbleView(label: "Muslim")
                Spacer()
                bubbleView(label: "Spiritual")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
    }
    
    func bubbleView(label: String) -> some View {
        return SystemText(text: label, fontstyle: .regular)
            .padding(.vertical, 5).padding(.horizontal, 15)
            .frame(width: 80)
            .background(Capsule().stroke(Color.white, lineWidth: 1))
            .background(self.religions.contains(label) ? Color("Light Muted") : Color.white.opacity(0.2))
            .clipShape(Capsule())
            .onTapGesture {
                if self.religions.contains(label) {
                    self.religions = self.religions.filter { $0 != label }
                } else {
                    self.religions.append(label)
                }
                if self.preferences && self.openToAll {
                    self.openToAll = false
                }
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            }
    }
}

struct SwitchView: View {
    @Binding var on: Bool
    
    let width: CGFloat = 40
    let height: CGFloat = 14
    var body: some View {
        ZStack {
            let offX: CGFloat = -width / 2 + 7
            let onX: CGFloat = width / 2 - 7
            RoundedRectangle(cornerRadius: 100)
                .foregroundColor(on ? Color("Pink") : Color("Navy"))
                .background(RoundedRectangle(cornerRadius: 100).stroke(Color.white, lineWidth: 3))
            Circle()
                .foregroundColor(.white)
                .offset(x: on ? onX : offX)
                .padding(1)
        }
        .onTapGesture {
            on.toggle()
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        .frame(width: self.width, height: self.height)
    }
}

struct CustomizeProfileView_Previews: PreviewProvider {
    @State static var numImages = 0
    static var previews: some View {
        CustomizeProfileView()
    }
}
