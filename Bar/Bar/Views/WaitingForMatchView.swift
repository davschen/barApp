//
//  WaitingForMatchView.swift
//  Bar
//
//  Created by David Chen on 1/27/21.
//

import Foundation
import SwiftUI

struct WaitingForMatchView: View {
    @Binding var showWaitView: Bool
    @State var showChat = false
    @State var mainText = "Waiting For A Confirmation..."
    @EnvironmentObject var likerVM: LikerViewModel
    
    var body: some View {
        ZStack {
            let matcher = likerVM.likedUser
            VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialLight))
                .edgesIgnoringSafeArea(.all)
            VStack {
                VStack {
                    SystemWebImage(url: matcher.profURL, radius: 0)
                        .frame(width: 150, height: 165)
                        .clipShape(Circle())
                    SystemText(text: self.mainText, fontstyle: .headerBold)
                    Spacer().frame(height: 15)
                    SystemText(text: "Waiting for \(matcher.firstName) to confirm your match. After they confirm, you will have 20 minutes to share your contact information with them", fontstyle: .regular)
                }
                .padding(20)
                .background(Color("Neutral"))
                .cornerRadius(10)
                Spacer().frame(height: 40)
                
                Button {
                    self.showWaitView.toggle()
                } label: {
                    Text("Back")
                        .font(Font.custom("Avenir Next Demi Bold", size: 14))
                        .foregroundColor(Color("Midnight"))
                        .padding(.vertical, 15).padding(.horizontal, 80)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .opacity(0.4)
                }
            }
            .padding(.horizontal, 40)
            // If you're waiting for match, you don't yet have a matcher.
            if self.likerVM.matcher.count == 1 {
                Text("").onAppear { self.showChat.toggle() }
            }
            NavigationLink(destination: ChatView(chatTo: matcher, showChat: $showChat, chatVM: ChatViewModel(recipient: matcher)).environmentObject(likerVM), isActive: $showChat) {
            }.hidden()
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .navigationBarTitle("")
    }
}
