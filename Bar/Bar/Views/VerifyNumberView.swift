//
//  VerifyNumberView.swift
//  Bar
//
//  Created by David Chen on 1/2/21.
//

import Foundation
import SwiftUI
import Firebase

struct VerifyNumberView: View {
    @Binding var ID: String
    @Binding var isShowingVerify: Bool
    @State var phoneNumber: String
    @State var isShowingBuildProfile = false
    @State var vCode = ""
    @State var alertMessage = ""
    @State var alert = false
    @State var showsBarView = false
    var db = Firestore.firestore()
    
    var body: some View {
        ZStack {
            BGColor()
            VStack {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding()
                        .onTapGesture {
                            self.isShowingVerify.toggle()
                        }
                    Spacer()
                }
                Spacer()
            }
            VStack (spacing: 30) {
                VStack {
                    Image("VerifyImage")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .padding()
                    SystemText(text: "Verification", fontstyle: .headerBold)
                    SystemText(text: "Enter the 6-digit verification code that was sent to your device", fontstyle: .medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                VStack (spacing: 20) {
                    ZStack {
                        ZStack (alignment: .leading) {
                            if vCode.isEmpty {
                                Text("e.g. 123456")
                                    .foregroundColor(.gray)
                                    .animationsDisabled()
                            }
                            TextField("e.g. 123456", text: $vCode)
                                .keyboardType(.numberPad)
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
                                .background(hasValidVCode() ? Color.green : Color("Neutral"))
                                .clipShape(Circle())
                                .padding(.horizontal, 7)
                                .background(Circle().stroke(Color.white, lineWidth: 0.5))
                        }
                    }
                    NavigationLink(
                        destination: BuildProfileView(phoneNumber: phoneNumber), isActive: $isShowingBuildProfile,
                        label: {
                            Button(action: {
                                if hasValidVCode() {
                                    let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.ID, verificationCode: self.vCode)
                                    Auth.auth().signIn(with: credential) { (result, error) in
                                        if error != nil {
                                            if error != nil {
                                                self.alertMessage = (error?.localizedDescription)!
                                                self.alert.toggle()
                                                return
                                            }
                                        }
                                        let docref = self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
                                        docref.getDocument { (doc, error) in
                                            if let doc = doc {
                                                NotificationCenter.default.post(name: NSNotification.Name("LogInStatusChange"), object: nil)
                                                if doc.exists {
                                                    UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                                                    showsBarView.toggle()
                                                } else {
                                                    self.isShowingBuildProfile.toggle()
                                                }
                                            }
                                        }
                                    }
                                }
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                            }, label: {
                                SystemText(text: "Continue", fontstyle: .regularDemiBold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Pink"))
                                    .clipShape(Capsule())
                                if showsBarView {
                                    NavigationLink(destination: BarView().environmentObject(CurrentUserViewModel()), isActive: $showsBarView) {
                                    }.hidden()
                                }
                            })
                            .opacity(hasValidVCode() ? 1 : 0.2)
                        })
                }
                .padding()
                .background(Color("Neutral"))
                .cornerRadius(5)
                .shadow(color: .black, radius: 20, y: 10)
                Spacer()
                RegistrationPaginationView(index: 1)
            }
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.alertMessage), dismissButton: .default(Text("Got It")))
            }
            .padding()
        }
        .animation(.easeInOut)
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
    }
    
    func hasValidVCode() -> Bool {
        return self.vCode.count == 6 && self.vCode.isInt
    }
}

struct VerifyView_Previews: PreviewProvider {
    @State static var isShowingVerify = true
    @State static var ID = ""
    static var previews: some View {
        VerifyNumberView(ID: $ID, isShowingVerify: $isShowingVerify, phoneNumber: "")
    }
}
