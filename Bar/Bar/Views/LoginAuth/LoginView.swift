//
//  LoginView.swift
//  Bar
//
//  Created by David Chen on 1/2/21.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @State var isShowingSignUp = false
    @State var numSteps = 0
    
    var body: some View {
        ZStack {
            BGColor()
            VStack {
                VStack {
                    Image("App Icon")
                        .resizable()
                        .frame(width: 100, height: 90)
                }
                .frame(height: UIScreen.main.bounds.height / 2)
                NavigationLink(destination: SignUpView(isShowingSignUp: $isShowingSignUp, numSteps: $numSteps), isActive: self.$isShowingSignUp) {
                    Text("Create Account")
                        .font(Font.custom("Avenir Next Demi Bold", size: 12))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(Color.white)
                        .clipShape(Capsule())
                }
                .simultaneousGesture(TapGesture().onEnded{
                    self.numSteps = 5
                })
                NavigationLink(destination: SignUpView(isShowingSignUp: $isShowingSignUp, numSteps: $numSteps), isActive: self.$isShowingSignUp) {
                    Text("Login")
                        .font(Font.custom("Avenir Next Demi Bold", size: 12))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                        .background(Color("Pink"))
                        .clipShape(Capsule())
                }
                .simultaneousGesture(TapGesture().onEnded{
                    self.numSteps = 2
                })
                Text("By singing up for bar, you agree to our terms and conditions. Learn how we process your data in our Privacy and Cookies Policy")
                    .foregroundColor(.white)
                    .font(Font.custom("Avenir Next Demi Bold", size: 10))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 50)
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .navigationBarBackButtonHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
