//
//  MatchView.swift
//  Bar
//
//  Created by David Chen on 1/15/21.
//

import Foundation
import SwiftUI

struct MatchView: View {
    @State var showChat = false
    @Binding var showMatchView: Bool
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    
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
                        SystemText(text: likerVM.matchedUser.firstName, fontstyle: .headerBold)
                        Spacer()
                    }
                    .padding(.vertical)
                    .frame(maxWidth: .infinity)
                    VStack {
                        HStack {
                            SystemWebImage(url: currentUserVM.currentUser.profURL, radius: 0)
                                .frame(maxHeight: UIScreen.main.bounds.height / 6)
                                .clipShape(Circle())
                                .background(Circle().stroke(Color("Pink"), lineWidth: 10))
                                .padding(.horizontal)
                            SystemWebImage(url: likerVM.matchedUser.profURL, radius: 0)
                                .frame(maxHeight: UIScreen.main.bounds.height / 6)
                                .clipShape(Circle())
                                .background(Circle().stroke(Color.white, lineWidth: 10))
                                .padding(.horizontal)
                        }
                        SystemText(text: "It's a Match!", fontstyle: .headerBold)
                        Spacer().frame(height: 15)
                        SystemText(text: "After you confirm, you will have 20 minutes to share your contact information with \(likerVM.matchedUser.firstName)", fontstyle: .regular)
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
                        self.likerVM.match(matchToID: likerVM.matchedUser.id ?? "")
                        self.showChat.toggle()
                    } label: {
                        StandardButtonView(text: "Start Your Conversation")
                            .padding(.horizontal, 20)
                    }
                    
                    // Change Your Mind Button
                    Button {
                        self.likerVM.declineMatcher(id: likerVM.matchedUser.id!)
                        self.showMatchView.toggle()
                    } label: {
                        SystemText(text: "I've Changed My Mind", fontstyle: .regularBold)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal, 40).padding(.top)
                NavigationLink(
                    destination: ChatView(chatTo: self.likerVM.matchedUser, showChat: $showChat, chatVM: ChatViewModel(recipient: self.likerVM.matchedUser)).environmentObject(self.likerVM), isActive: $showChat,
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

struct MatchView_Previews: PreviewProvider {
    @State static var matcher = TempUserLib().user1
    @State static var currentUser = TempUserLib().user1
    @State static var showMatchView = false
    static var previews: some View {
        MatchView(showMatchView: $showMatchView)
    }
}

