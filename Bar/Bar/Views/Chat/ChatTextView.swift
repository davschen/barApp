//
//  ChatTextView.swift
//  Bar
//
//  Created by David Chen on 12/28/20.
//

import Foundation
import SwiftUI
import Firebase
import MobileCoreServices

struct ChatTextView: View {
    @EnvironmentObject var userVM: UserViewModel
    
    @Binding var replyText: String
    @Binding var respondMessageID: String
    @Binding var respondToID: String
    @Binding var lastMessageSenderID: String
    @Binding var responderName: String
    @Binding var selectedMessageID: String
    @Binding var lastMessageID: String
    
    @State var proxy: ScrollViewProxy
    @State var didReply = false
    @State var showChatTo = false
    @State var hOffset: CGFloat = .zero
    @State var messageData: Message
    
    @ObservedObject var chatViewModel: ChatViewModel
    let chatTo: User
    
    var isFirstMessageFromUser: Bool {
        return messageData.lastMessageSenderID != chatTo.id
    }
    
    var body: some View {
        ZStack {
            HStack {
                if isCurrentUser() { Spacer() }
                VStack {
                    Spacer()
                    replyButton(isCurrentUser: isCurrentUser())
                        .animation(.easeInOut)
                        .opacity(abs(self.hOffset) >= 20 ? (Double(abs(self.hOffset) - 20)) / 10 : 0)
                }
                if !isCurrentUser() { Spacer() }
            }
            HStack {
                VStack (spacing: 0) {
                    Spacer(minLength: switchedUser() ? 10 : 0)
                    if selected() {
                        Text(messageData.timestamp, style: .time)
                            .font(Font.custom("Avenir Next", size: 12))
                            .foregroundColor(.white)
                            .padding(.vertical, 5)
                    }
                    ZStack {
                        HStack (alignment: .top) {
                            if isCurrentUser() {
                                Spacer(minLength: UIScreen.main.bounds.width * 0.2)
                            }
                            // for the person the user is messaging, show the image icon if the last message was not sent by them
                            if !isCurrentUser() {
                                if shouldDisplayImage() {
                                    NavigationLink(destination: UserView(invitable: false, isPreview: true, show: $showChatTo)) {
                                        VStack {
                                            BarWebImage(url: chatTo.profURL, radius: 0)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                                .padding(.top, 3)
                                        }
                                    }
                                    .simultaneousGesture(TapGesture().onEnded{
                                        userVM.setInspectedUser(user: chatTo)
                                    })
                                } else {
                                    // this is just the number of pixels that ends up matching perfectly with the gap made from the picture
                                    Spacer().frame(width: 38)
                                }
                            }
                            VStack(alignment: isCurrentUser() ? .trailing : .leading, spacing: 0) {
                                // Darker bubble with "responding to..."
                                if messageData.response != "" {
                                    VStack (alignment: .leading) {
                                        SystemTextTracking(text: "RESPONDING TO " + respondingTo(senderID: messageData.respondToID), fontstyle: .smallDemiBold)
                                            .padding(.bottom, 2)
                                        SystemText(text: messageData.response, fontstyle: .mediumItalics)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 7)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(5)
                                    .onTapGesture {
                                        withAnimation {
                                            proxy.scrollTo(messageData.respondMessageID, anchor: .center)
                                        }
                                    }
                                }
                                HStack {
                                    Text(messageData.text)
                                        .font(Font.custom("Avenir Next", size: 16))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(isCurrentUser() ? .leading : .trailing, 3)
                                        .padding(.vertical, 9)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .background(isCurrentUser() ?
                                                (selected() ? Color("Dark Accent") : Color("My Texts")) :
                                                (selected() ? Color("Neutral") : Color("Light Muted")))
                                .clipShape(isCurrentUser() ?
                                            RoundedCorners(tl: 20, tr: isFirstMessageFromUser ? 4 : 20, bl: 20, br: 4) :
                                            RoundedCorners(tl: isFirstMessageFromUser ? 20 : 4, tr: 20, bl: 4, br: 20))
                                .onTapGesture {
                                    if selected() {
                                        self.selectedMessageID = ""
                                    } else {
                                        self.selectedMessageID = self.messageData.id ?? ""
                                    }
                                }
                                .contextMenu {
                                    Button {
                                        UIPasteboard.general.setValue(messageData.text, forPasteboardType: kUTTypePlainText as String)
                                    } label: {
                                        Text("Copy")
                                        Image(systemName: "doc.on.doc")
                                    }
                                }
                                Spacer().frame(height: messageData.id == self.lastMessageID ? 10 : 0)
                            }
                            if !isCurrentUser() {
                                Spacer(minLength: UIScreen.main.bounds.width * 0.2)
                            }
                        }
                    }
                }
                .animation(.easeInOut)
            }
            .offset(x: self.hOffset)
            .gesture(DragGesture()
                        .onChanged({ (gesture) in
                            if gesture.translation.width < 0 && isCurrentUser() {
                                if selected() {
                                    self.selectedMessageID = ""
                                }
                                self.hOffset = gesture.translation.width / 4
                            } else if gesture.translation.width > 0 && !isCurrentUser() {
                                if selected() {
                                    self.selectedMessageID = ""
                                }
                                self.hOffset = gesture.translation.width / 4
                            }
                        })
                        .onEnded({ (gesture) in
                            if abs(self.hOffset) > 20 {
                                self.replyText = messageData.text
                                self.respondMessageID = messageData.id ?? ""
                                self.responderName = isCurrentUser() ? "yourself" : chatTo.firstName
                                self.respondToID = (isCurrentUser() ? Auth.auth().currentUser?.uid : chatTo.id) ?? ""
                                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                            }
                            self.hOffset = .zero
                        })
            )
        }
    }
    
    func isCurrentUser() -> Bool {
        return messageData.senderID == Auth.auth().currentUser?.uid ?? ""
    }
    
    func shouldDisplayImage() -> Bool {
        return messageData.senderID == chatTo.id && messageData.lastMessageSenderID != chatTo.id
    }
    
    func switchedUser() -> Bool {
        return messageData.senderID != messageData.lastMessageSenderID
    }
    
    func selected() -> Bool {
        return selectedMessageID == messageData.id
    }
    
    func respondingTo(senderID: String) -> String {
        return senderID == chatTo.id ? chatTo.firstName.uppercased() : "ME"
    }
}

struct replyButton: View {
    @State var isCurrentUser: Bool
    
    var body: some View {
        Image(systemName: "arrowshape.turn.up.\(isCurrentUser ? "right" : "left").circle.fill")
            .resizable()
            .foregroundColor(.white)
            .frame(width: 20, height: 20)
            .background(Color(isCurrentUser ? "Pink" : "Light Muted"))
            .clipShape(Circle())
    }
}

struct UserProfPicPreview: View {
    
    var body: some View {
        Circle()
            .frame(width: 70, height: 70)
    }
}
