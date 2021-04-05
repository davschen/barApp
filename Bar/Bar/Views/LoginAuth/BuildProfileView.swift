//
//  BuildProfileView.swift
//  Bar
//
//  Created by David Chen on 1/3/21.
//

import Foundation
import SwiftUI
import Firebase

struct BuildProfileView: View {
    @State var phoneNumber: String
    @State var isShowingCompleteProfile = false
    @State var alert = false
    @State var alertMessage = "Going back will erase your current progress"
    @State var firstName = ""
    @State var lastName = ""
    @State var selectedDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
    let db = Firestore.firestore()

    var body: some View {
        ZStack {
            BGColor()
            ScrollView (.vertical) {
                VStack (spacing: 30) {
                    VStack {
                        Image("About Me")
                            .resizable()
                            .frame(width: 150, height: 150)
                            .padding()
                        SystemText(text: "About Me", fontstyle: .headerBold)
                        SystemText(text: "Help us get to know you!", fontstyle: .medium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    // First Name, Last Name
                    VStack (alignment: .leading) {
                        SystemTextTracking(text: "FIRST NAME", fontstyle: .smallDemiBold)
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
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(firstName != "" ? Color.green : Color("Neutral"))
                                    .clipShape(Circle())
                                    .padding(.horizontal, 7)
                                    .background(Circle().stroke(Color.white, lineWidth: 0.5))
                            }
                        }
                        Spacer(minLength: 20)
                        SystemTextTracking(text: "LAST NAME", fontstyle: .smallDemiBold)
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
                            HStack {
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(lastName != "" ? Color.green : Color("Neutral"))
                                    .clipShape(Circle())
                                    .padding(.horizontal, 7)
                                    .background(Circle().stroke(Color.white, lineWidth: 0.5))
                            }
                        }
                        SystemText(text: "Your last name will never be shown", fontstyle: .regular)
                    }
                    .padding()
                    .background(Color("Neutral"))
                    .cornerRadius(5)
                    .shadow(color: .black, radius: 20, y: 10)
                    // Date Picker
                    VStack (alignment: .leading) {
                        HStack {
                            SystemTextTracking(text: "BIRTHDAY", fontstyle: .smallDemiBold)
                            Spacer()
                            Text(selectedDate, style: .date)
                                .font(Font.custom("Avenir Next Bold", size: 16))
                                .foregroundColor(.white)
                        }
                        DatePicker("", selection: $selectedDate, in: yearRange, displayedComponents: .date)
                            .accentColor(.white)
                            .colorScheme(.dark)
                            .datePickerStyle(GraphicalDatePickerStyle())
                        SystemText(text: "You cannot change this in the future", fontstyle: .regular)
                    }
                    .padding()
                    .background(Color("Neutral"))
                    .cornerRadius(5)
                    .shadow(color: .black, radius: 20, y: 10)
                    Spacer()
                    NavigationLink(
                        destination: CompleteProfileView(firstName: $firstName, lastName: $lastName), isActive: $isShowingCompleteProfile,
                        label: {
                            Button(action: {
                                if hasCompletedFields() {
                                    self.isShowingCompleteProfile.toggle()
                                    if let id = Auth.auth().currentUser?.uid {
                                        db.collection("users").document(id).setData([
                                            "firstName" : self.firstName,
                                            "lastName" : self.lastName,
                                            "phoneNumber" : self.phoneNumber,
                                            "dob" : self.selectedDate,
                                            "likes" : 0,
                                            "matches" : 0,
                                            "contacts" : 0,
                                            "seenBefore" : [],
                                            "matcherID" : ""
                                        ])
                                    }
                                }
                            }, label: {
                                SystemText(text: "Continue", fontstyle: .regularDemiBold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Pink"))
                                    .clipShape(Capsule())
                            })
                            .opacity(hasCompletedFields() ? 1 : 0.2)
                        })
                    RegistrationPaginationView(numSteps: 5, index: 2)
                }
            }
            .alert(isPresented: $alert) {
                Alert(title: Text("Are You Sure?"), message: Text(self.alertMessage), dismissButton: .default(Text("Yes, Go Back")))
            }
            .colorScheme(.dark)
            .padding()
        }
        .animation(.easeInOut)
        .navigationBarTitle("Build Your Profile")
        .navigationBarBackButtonHidden(true)
        .onAppear {
            UIScrollView.appearance().keyboardDismissMode = .onDrag
        }
    }
    func hasCompletedFields() -> Bool {
        return self.firstName != "" && self.lastName != ""
    }
    var yearRange: ClosedRange<Date> {
        let minYear = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let maxYear = Calendar.current.date(byAdding: .year, value: -18, to: Date())!
        return minYear...maxYear
    }
}

struct BuildProfileView_Previews: PreviewProvider {
    @State static var isShowingBuildProfile = true
    static var previews: some View {
        BuildProfileView(phoneNumber: "")
    }
}
