//
//  MatchView.swift
//  Bar
//
//  Created by David Chen on 1/15/21.
//

import Foundation
import SwiftUI

struct MatchView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    @State var showChat = false
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .dark))
                .edgesIgnoringSafeArea(.all)
            Color.black
                .edgesIgnoringSafeArea(.all)
                .opacity(0.2)
            VStack {
                VStack (alignment: .leading, spacing: 0) {
                    HStack {
                        SystemText(text: currentUserVM.currentUser.firstName, fontstyle: .headerBold)
                        Image(systemName: "xmark")
                        SystemText(text: likerVM.matcher.firstName, fontstyle: .headerBold)
                        Spacer()
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    VStack {
                        HStack {
                            BarWebImage(url: currentUserVM.currentUser.profURL, radius: 0)
                                .frame(maxHeight: UIScreen.main.bounds.height / 6)
                                .clipShape(Circle())
                                .background(Circle().stroke(Color("Pink"), lineWidth: 10))
                                .padding(.horizontal)
                            BarWebImage(url: likerVM.matcher.profURL, radius: 0)
                                .frame(maxHeight: UIScreen.main.bounds.height / 6)
                                .clipShape(Circle())
                                .background(Circle().stroke(Color.white, lineWidth: 10))
                                .padding(.horizontal)
                        }
                        SystemText(text: "It's a Match!", fontstyle: .headerBold)
                        Spacer().frame(height: 15)
                        SystemText(text: "After you confirm, you will have 20 minutes to share your contact information with \(likerVM.matcher.firstName)", fontstyle: .regular)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("Neutral"))
                    .cornerRadius(10)
                    .shadow(color: .black, radius: 10, x: 0, y: 10)
                }
                .padding(.horizontal, 40)
                VStack {
                    // Start Your Conversation Button
                    Button {
                        self.likerVM.acceptMatch(matchToID: likerVM.matcher.id ?? "")
                        self.showChat.toggle()
                    } label: {
                        StandardButtonView(text: "Start Your Conversation")
                            .padding(.horizontal, 20)
                    }
                    
                    // Change Your Mind Button
                    Button {
                        self.likerVM.declineMatcher()
                    } label: {
                        SystemText(text: "I've Changed My Mind", fontstyle: .regularBold)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal, 40).padding(.top)
                NavigationLink(
                    destination: ChatView(showChat: $showChat)
                        .environmentObject(self.chatVM)
                        .environmentObject(self.likerVM)
                    , isActive: $showChat,
                    label: {
                        // no label, because that is the point
                    }).hidden()
            }
            .frame(maxHeight: .infinity)
            .navigationBarHidden(true)
            .navigationBarTitle("")
        }
        .edgesIgnoringSafeArea(.all)
    }
}
