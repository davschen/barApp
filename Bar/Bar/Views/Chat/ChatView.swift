//
//  ChatView.swift
//  Bar
//
//  Created by David Chen on 12/26/20.
//

import Foundation
import SwiftUI

struct ChatView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @Binding var showChat: Bool
    
    @State var responderName = ""
    @State var isShowingMore = false
    @State var showChatTo = false
    @State var selectedMessageID = ""
    @State var showsMenu = false
    @State private var timeRemaining: Double = 1200
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: .init(colors: [Color("Neutral"), Color("Midnight")]),
                startPoint: .init(x: 0, y: 0),
                endPoint: .init(x: 0, y: 0.5))
                .edgesIgnoringSafeArea(.all)
            ScrollViewReader { proxy in
                VStack (spacing: 0) {
                    VStack {
                        HStack {
                            NavigationLink(destination: UserView(invitable: false, isPreview: true, show: $showChatTo)) {
                                BarWebImage(url: self.chatVM.chatToUser.profURL, radius: 0)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            }
                            .simultaneousGesture(TapGesture().onEnded{
                                userVM.setInspectedUser(user: chatVM.chatToUser)
                            })
                            VStack (alignment: .leading, spacing: -3) {
                                SystemText(text: self.chatVM.chatToUser.firstName, fontstyle: .largeDemiBold)
                                Text(countdownStringHandler())
                                    .font(Font.custom("Avenir Next Medium", size: 12))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            EllipsisView()
                                .onTapGesture {
                                    dismissKeyboard()
                                    self.showsMenu.toggle()
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                        }
                        .padding(.horizontal)
                        GeometryReader { geometry in
                            Rectangle()
                                .foregroundColor(timeRemaining > 120 ? Color("Pink") : Color.white)
                                .frame(width: timeRemaining > 0 ? geometry.size.width * CGFloat(Double(timeRemaining) / 1200) : 0)
                        }
                        .frame(height: 4)
                    }
                    ScrollView(.vertical, showsIndicators: true, content: {
                        VStack (spacing: 3) {
                            ForEach(chatVM.messages) { message in
                                ChatTextView(replyText: $chatVM.response, respondMessageID: $chatVM.respondMessageID, respondToID: $chatVM.respondToID, lastMessageSenderID: $chatVM.lastMessageSenderID, responderName: $responderName, selectedMessageID: $selectedMessageID, lastMessageID: $chatVM.lastMessageID, proxy: proxy, messageData: message, chatViewModel: self.chatVM, chatTo: self.chatVM.chatToUser)
                                    .onAppear {
                                        chatVM.setSenderID(id: message.senderID)
                                        chatVM.setLastMessageID(id: message.id ?? "")
                                    }
                            }
                            .onAppear {
                                guard let lastMessage = chatVM.messages.last else { return }
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                        .padding([.top, .horizontal])
                    })
                    .frame(width: UIScreen.main.bounds.width)
                    .background(Color("Midnight"))
                    .frame(maxHeight: .infinity)
                    VStack (spacing: 0) {
                        if self.isShowingMore {
                            // show horizontal scrollview with some buttons if arrow pressed
                            ScrollView(.horizontal) {
                                HStack {
                                    Button(action: {
                                        reject()
                                    }, label: {
                                        SystemText(text: "Dip", fontstyle: .regular)
                                            .padding(.vertical, 7)
                                            .padding(.horizontal, 15)
                                            .background(Capsule().stroke(Color.white, lineWidth: 1))
                                            .background(Color("Neutral"))
                                            .clipShape(Capsule())
                                    })
                                    Button(action: {
                                        chatVM.shareContact()
                                    }, label: {
                                        SystemText(text: "Share Contact", fontstyle: .regular)
                                            .padding(.vertical, 7)
                                            .padding(.horizontal, 15)
                                            .background(Capsule().stroke(Color.white, lineWidth: 1))
                                            .background(Color("Pink"))
                                            .clipShape(Capsule())
                                    })
                                    Button(action: {
                                        self.isShowingMore.toggle()
                                        dismissKeyboard()
                                        self.showsMenu.toggle()
                                    }, label: {
                                        SystemText(text: "Show More", fontstyle: .regular)
                                            .padding(.vertical, 7)
                                            .padding(.horizontal, 15)
                                            .background(Capsule().stroke(Color.white, lineWidth: 1))
                                            .background(Color.white.opacity(0.5))
                                            .clipShape(Capsule())
                                    })
                                }
                                .padding()
                            }
                            .background(Color("Midnight"))
                        }
                        // Bottom bar with Show More Button, TextField, Send Message Button
                        HStack (alignment: .bottom) {
                            // Show More button (plus that turns into minus)
                            Button(action: {
                                self.isShowingMore.toggle()
                                guard let lastMessage = chatVM.messages.last else { return }
                                withAnimation {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }, label: {
                                ShowingMoreView(isShowingMore: $isShowingMore)
                            })
                            .padding(.vertical, 10)
                            // VStack containing TextField and respondTo message, if there is one
                            VStack (spacing: 0) {
                                HStack {
                                    VStack (alignment: .leading) {
                                        SystemTextTracking(text: "RESPONDING TO " + self.responderName.uppercased(), fontstyle: .smallDemiBold)
                                        SystemText(text: chatVM.response, fontstyle: .regular)
                                    }
                                    Spacer()
                                    Image("xIcon")
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                        .onTapGesture {
                                            chatVM.response = ""
                                            chatVM.respondMessageID = ""
                                        }
                                }
                                .padding(hasResponse() ? 15 : 0)
                                .background(Color("Light Muted"))
                                .opacity(hasResponse() ? 1 : 0)
                                .clipShape(RoundedCorners(tl: 20, tr: 20, bl: 4, br: 20))
                                .frame(height: hasResponse() ? 50 : 0)
                                // TextField
                                HStack (alignment: .bottom, spacing: 0) {
                                    DynamicTextFieldChatView(chatText: $chatVM.text)
                                        .simultaneousGesture(TapGesture().onEnded{
                                            guard let lastMessage = chatVM.messages.last else { return }
                                            withAnimation {
                                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                            }
                                        })
                                    Button {
                                        if !self.chatVM.text.isEmpty {
                                            self.chatVM.writeMessage()
                                        }
                                    } label: {
                                        Image(systemName: "paperplane.fill")
                                            .padding(8)
                                            .background(Color("Pink"))
                                            .clipShape(Circle())
                                            .font(.system(size: 15))
                                            .foregroundColor(.white)
                                            .opacity(self.chatVM.text.isEmpty ? 0.4 : 1)
                                    }
                                }
                                .padding(3)
                                .padding(.bottom, 1)
                                .background(Color("Neutral"))
                                .cornerRadius(20)
                            }
                        }
                        .gesture(DragGesture().onChanged({ (gesture) in
                            // dismiss keyboard on drag
                            if gesture.translation.height > 0 {
                                dismissKeyboard()
                            }
                        }))
                        .padding()
                    }
                    .animation(.easeInOut)
                }
            }
            ZStack {
                PullUpMenuView(chatTo: self.chatVM.chatToUser, showChatTo: $showChatTo, showsMenu: $showsMenu, timeRemaining: $timeRemaining, chatVM: self.chatVM, showChat: $showChat)
            }.transition(.opacity).animation(.easeInOut)
        }
        .onReceive(timer) { time in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                reject()
            }
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    func countdownStringHandler() -> String {
        var toReturn = ""
        if self.timeRemaining > 120 {
            toReturn = "\(Int(self.timeRemaining / 60)) minutes to go"
        } else {
            let seconds = Int(self.timeRemaining.truncatingRemainder(dividingBy: 60))
            toReturn = "\(Int(self.timeRemaining / 60)):\(seconds < 10 ? "0" + "\(seconds)" : "\(seconds)") to go"
        }
        return toReturn
    }
    
    func reject() {
        self.likerVM.declineMatcher(id: self.chatVM.chatToUser.id ?? "")
        self.showChat.toggle()
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
    
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func hasResponse() -> Bool {
        return self.chatVM.response != ""
    }
}

struct EllipsisView: View {
    var body: some View {
        VStack (spacing: 3) {
            Circle()
                .frame(width: 4, height: 4)
                .foregroundColor(.white)
            Circle()
                .frame(width: 4, height: 4)
                .foregroundColor(.white)
            Circle()
                .frame(width: 4, height: 4)
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.3))
        .clipShape(Circle())
    }
}

struct DynamicTextFieldChatView: View {
    @Binding var chatText: String
    
    var body: some View {
        MultilineTextField("Write a Message", text: $chatText, onCommit: {
                    })
        .accentColor(.white)
        .padding(.horizontal, 10)
        .background(Color("Neutral"))
        .animationsDisabled()
    }
}

struct PullUpMenuView: View {
    @State var chatTo: User
    @Binding var showChatTo: Bool
    @Binding var showsMenu: Bool
    @Binding var timeRemaining: Double
    @StateObject var chatVM: ChatViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    @Binding var showChat: Bool
    @State var vOffset: CGFloat = 0
    
    var body: some View {
        ZStack (alignment: .bottom) {
            Color.black
                .opacity(self.showsMenu ? 0.5 : 0)
                .onTapGesture {
                    self.showsMenu.toggle()
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                }
            ZStack {
                VisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
                    .edgesIgnoringSafeArea(.bottom)
                VStack {
                    Color.white
                        .opacity(0.5)
                        .frame(width: 50,height: 5)
                        .clipShape(Capsule())
                    Spacer()
                    HStack {
                        VStack {
                            Button {
                                self.likerVM.declineMatcher(id: self.chatVM.chatToUser.id ?? "")
                                self.showChat.toggle()
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color("Muted Blue"))
                                    .clipShape(Circle())
                            }
                            SystemText(text: "Leave", fontstyle: .regular)
                        }
                        Spacer()
                        VStack {
                            Button {
                                self.chatVM.shareContact()
                                self.showsMenu.toggle()
                            } label: {
                                Image("smallContact")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding()
                                    .background(Color("Pink"))
                                    .clipShape(Circle())
                            }
                            SystemText(text: "Share Contact", fontstyle: .regular)
                        }
                        Spacer()
                        VStack {
                            NavigationLink(destination: UserView(invitable: false, isPreview: true, show: $showChatTo)) {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.orange)
                                    .clipShape(Circle())
                            }
                            SystemText(text: "\(chatTo.firstName)'s Profile", fontstyle: .regular)
                        }
                    }
                    .padding(.horizontal, 15)
                    VStack {
                        HStack {
                            let seconds = Int(self.timeRemaining.truncatingRemainder(dividingBy: 60))
                            Text("\(Int(self.timeRemaining / 60)):\(seconds < 10 ? "0" + "\(seconds)" : "\(seconds)") left")
                                .foregroundColor(Color("Midnight"))
                                .font(Font.custom("Avenir Next Demi Bold", size: 12))
                                .padding(.vertical)
                            Spacer()
                            Image(systemName: "clock")
                                .foregroundColor(.black)
                        }
                        Divider()
                        HStack {
                            Text("Dismiss")
                                .foregroundColor(Color("Midnight"))
                                .font(Font.custom("Avenir Next Demi Bold", size: 12))
                                .padding(.vertical)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.horizontal)
                    .background(Color.white)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(5)
                    .padding([.horizontal, .bottom], 15).padding(.top, 10)
                    .onTapGesture {
                        self.showsMenu.toggle()
                    }
                    Spacer()
                }
                .padding()
            }
            .frame(height: UIScreen.main.bounds.height * 0.4)
            .clipShape(RoundedCorners(tl: 20, tr: 20, bl: 0, br: 0))
            .offset(y: self.showsMenu ? vOffset : 1000)
            .gesture(DragGesture()
                        .onChanged({ (gesture) in
                            if gesture.translation.height > 0 {
                                self.vOffset = abs(gesture.translation.height)
                            }})
                        .onEnded({ (gesture) in
                            if gesture.translation.height > 50 {
                                self.showsMenu.toggle()
                                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                            }
                            self.vOffset = 0
                        }))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct ShowingMoreView: View {
    @Binding var isShowingMore: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 10, height: 2)
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 2, height: 10)
                .rotationEffect(Angle(degrees: isShowingMore ? 90 : 0))
        }
        .padding(5)
        .background(Color("Pink"))
        .clipShape(Circle())
    }
}
