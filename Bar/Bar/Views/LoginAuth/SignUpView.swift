//
//  SignUpView.swift
//  Bar
//
//  Created by David Chen on 1/2/21.
//

import Foundation
import SwiftUI
import Firebase

struct SignUpView: View {
    @Binding var isShowingSignUp: Bool
    @Binding var numSteps: Int
    @State var isShowingVerify = false
    @State var countryCode = "1"
    @State var number = ""
    @State var alertMessage = ""
    @State var ID = ""
    @State var alert = false
    
    var body: some View {
        ZStack {
            BGColor()
            VStack {
                HStack {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .padding()
                        .onTapGesture {
                            self.isShowingSignUp.toggle()
                        }
                    Spacer()
                }
                Spacer()
            }
            VStack (spacing: 30) {
                VStack {
                    Image("RegistrationImage")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .padding()
                    SystemText(text: "Registration", fontstyle: .headerBold)
                    SystemText(text: "Enter your phone number, and we will send a code for you to verify with.", fontstyle: .medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                VStack (spacing: 20) {
                    HStack {
                        HStack (spacing: 2) {
                            SystemText(text: "+", fontstyle: .medium)
                            TextField("e.g. 1", text: $countryCode)
                                .frame(width: 30)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundColor(.white)
                                .keyboardType(.numberPad)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 15)
                        .font(Font.custom("Avenir Next Medium", size: 14))
                        .background(RoundedRectangle(
                            cornerRadius: 5, style: .continuous
                        ).stroke(Color.white, lineWidth: 0.5))
                        .accentColor(.white)
                        ZStack {
                            ZStack (alignment: .leading) {
                                if number.isEmpty {
                                    Text("Enter Your Number")
                                        .foregroundColor(.gray)
                                        .animationsDisabled()
                                }
                                TextField("Enter Your Number", text: $number)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundColor(.white)
                                    .keyboardType(.numberPad)
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
                                    .background(hasValidEntry() ? Color.green : Color("Neutral"))
                                    .clipShape(Circle())
                                    .padding(.horizontal, 7)
                                    .background(Circle().stroke(Color.white, lineWidth: 0.5))
                            }
                        }
                    }
                    NavigationLink(
                        destination: VerifyNumberView(ID: $ID, isShowingVerify: $isShowingVerify, numSteps: numSteps, phoneNumber: distillNumber()), isActive: $isShowingVerify,
                        label: {
                            Button(action: {
                                if hasValidEntry() {
                                    self.isShowingVerify.toggle()
                                    PhoneAuthProvider.provider().verifyPhoneNumber("+" + self.countryCode + self.number, uiDelegate: nil) { (ID, err) in
                                        if err != nil {
                                            self.alertMessage = (err?.localizedDescription)!
                                            self.alert.toggle()
                                            return
                                        }
                                        self.ID = ID!
                                    }
                                }
                            }, label: {
                                SystemText(text: "Continue", fontstyle: .regularDemiBold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color("Pink"))
                                    .clipShape(Capsule())
                            })
                            .opacity(hasValidEntry() ? 1 : 0.2)
                        })
                }
                .padding()
                .background(Color("Neutral"))
                .cornerRadius(5)
                .shadow(color: .black, radius: 20, y: 10)
                Spacer()
                RegistrationPaginationView(numSteps: numSteps, index: 0)
            }
            .padding()
            .alert(isPresented: $alert) {
                Alert(title: Text("Error"), message: Text(self.alertMessage), dismissButton: .default(Text("Got It")))
            }
        }
        .animation(.easeInOut)
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
    }
    
    func hasValidEntry() -> Bool {
        return self.countryCode.count >= 1 && self.number.count >= 10
    }
    
    func distillNumber() -> String {
        var distilledNumber = "+" + self.countryCode
        for char in self.number {
            if String(char).isInt {
                distilledNumber += String(char)
            }
        }
        return distilledNumber
    }
}

struct RegistrationPaginationView: View {
    let numSteps: Int
    let index: Int
    var body: some View {
        HStack {
            ForEach(0..<numSteps, id: \.self) { i in
                Image(systemName: index == i ? "circle.fill" : "circle").resizable().frame(width: 10, height: 10)
            }
        }
        .foregroundColor(Color("Pink"))
    }
}
