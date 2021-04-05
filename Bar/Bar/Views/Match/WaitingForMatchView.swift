//
//  WaitingForMatchView.swift
//  Bar
//
//  Created by David Chen on 1/27/21.
//

import Foundation
import SwiftUI

struct WaitingForMatchView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    
    @Binding var showWaitView: Bool
    
    @State var showChat = false
    @State var mainText = "Waiting For A Confirmation..."
    @State var timeRemaining = 10
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var allowsBack: Bool {
        return timeRemaining <= 0
    }
    
    var body: some View {
        ZStack {
            let matcher = likerVM.requestedMatcher
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
                .edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    BarWebImage(url: matcher.profURL, radius: 0)
                        .frame(width: 150, height: 165)
                        .clipShape(Circle())
                    SystemText(text: self.mainText, fontstyle: .headerBold)
                    Spacer().frame(height: 15)
                    SystemText(text: "Waiting for \(matcher.firstName) to confirm your match. After \(likerVM.generatePronouns(user: matcher)[0]) confirms, you will have 20 minutes to share your contact information with \(likerVM.generatePronouns(user: matcher)[1])", fontstyle: .regular)
                }
                .padding(20)
                .background(Color("Neutral"))
                .cornerRadius(10)
                Spacer().frame(height: 40)
                
                Button {
                    if allowsBack {
                        self.showWaitView.toggle()
                        self.likerVM.declineMatcher(id: matcher.id ?? "NOT-AN-ID")
                    }
                } label: {
                    // e.g. Back (10) if timeRemaining <= 0, else Back
                    Text("Back\(!allowsBack ? "\( " (\(timeRemaining))")" : "")")
                        .font(Font.custom("Avenir Next Demi Bold", size: 14))
                        .foregroundColor(Color("Midnight"))
                        .padding(.vertical, 15).padding(.horizontal, 80)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .opacity(allowsBack ? 1 : 0.4)
                }
            }
            .padding(.horizontal, 40)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .onReceive(timer) { time in
            self.timeRemaining -= 1
        }
        NavigationLink(destination: ChatView(showChat: $currentUserVM.currentUser.hasMatch), isActive: $currentUserVM.currentUser.hasMatch) {
            
        }.hidden()
    }
}
