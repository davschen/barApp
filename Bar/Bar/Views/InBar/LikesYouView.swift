//
//  LikesYouView.swift
//  Bar
//
//  Created by David Chen on 12/20/20.
//

import Foundation
import SwiftUI

struct LikesYouView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @State var offset = CGSize.zero
    @State var noLikeOpacity = 0.0
    @State var showUser = false
    @State var hOffset = CGSize.zero
    @State var pressDislike = false
    @State var showWaitView = false
    
    var body: some View {
        ZStack {
            BGColor()
            VStack {
                // Card Views
                ZStack {
                    if self.likerVM.likers.count == 0 {
                        NoLikerView()
                    }
                    ForEach(self.likerVM.likeCards.reversed()) { likeCard in
                        let liker: User = likeCard.user
                        VStack {
                            HStack {
                                ZStack {
                                    LikesYouPreView(user: liker, showUser: $showUser)
                                        .cornerRadius(10)
                                        .rotationEffect(Angle(degrees: Double(likeCard.offset) * 0.05))
                                }
                            }
                            LikerCommentCardView(user: liker, headingLabel: likeCard.heading, quoteLabel: likeCard.subHeading, comment: likeCard.comment)
                                .rotationEffect(Angle(degrees: Double(likeCard.offset) * -0.05))
                            Spacer()
                        }
                        .padding()
                        .offset(x: likeCard.offset)
                        .gesture(DragGesture()
                                    .onChanged { gesture in
                                        withAnimation {
                                            likerVM.likeCards[0].offset = gesture.translation.width
                                        }
                                        self.hOffset.width = gesture.translation.width
                                    }
                                    .onEnded { gesture in
                                        withAnimation(.spring()) {
                                            if self.hOffset.width > 70 {
                                                likerVM.likeCards[0].offset = 1000
                                                requestMatch()
                                            } else if self.hOffset.width <= -70 {
                                                likerVM.likeCards[0].offset = -1000
                                                dislike()
                                            } else {
                                                likerVM.likeCards[0].offset = .zero
                                            }
                                        }
                                        self.hOffset = .zero
                                    }
                        )
                    }
                }
            }
            // Dynamically sizing buttons based on offset
            VStack {
                if showWaitView {
                    WaitingForMatchView(showWaitView: $showWaitView)
                        .environmentObject(self.chatVM)
                        .environmentObject(self.likerVM)
                }
            }
            .transition(.opacity).animation(.easeInOut)
        }
        .navigationBarTitle(showWaitView ? "" : "Who's Lovin' You", displayMode: .inline)
        .navigationBarHidden(showWaitView)
        .onAppear {
            self.likerVM.updateRequestedMatcher()
        }
    }
    func requestMatch() {
        //self.chatVM.createConversationDocument(userID: self.likerVM.requestedMatcher.id ?? "NOT-AN-ID")
        self.likerVM.requestMatch()
        self.userVM.setInspectedUser(user: self.likerVM.requestedMatcher)
        self.showWaitView.toggle()
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
    func dislike() {
        self.likerVM.dismissUser()
    }
}

struct LikesYouPreView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    
    let user: User
    
    @State var photoIndex = 0
    @Binding var showUser: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<user.imageLinks.count) { i in
                let link = self.user.imageLinks[i]
                BarWebImage(url: link, radius: 0)
                    .opacity(self.photoIndex == i ? 1 : 0)
                    .clipped()
            }
            Rectangle()
                .fill(LinearGradient(
                        gradient: .init(colors: [Color.black.opacity(0), Color.black.opacity(0.7)]),
                        startPoint: .init(x: 0, y: 0.7),
                        endPoint: .init(x: 0, y: 1)))
            // user name, age, profession if there is one
            VStack {
                ImageTickerView(n: user.imageLinks.count, photoIndex: photoIndex)
                Spacer()
                // rectangles for tapping
                HStack {
                    VStack {
                        Color.clear
                            .frame(maxHeight: .infinity)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if photoIndex > 0 {
                            self.photoIndex -= 1
                        }
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                    VStack {
                        Color.clear
                            .frame(maxHeight: .infinity)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if photoIndex < user.imageLinks.count - 1 {
                            self.photoIndex += 1
                        }
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                }
            }
            .padding()
            HStack {
                VStack (alignment: .leading) {
                    Spacer()
                    Text("\(user.firstName), \(userVM.getYearsDiffFromDate(date: user.dob))")
                        .font(Font.custom("Avenir Next Demi Bold", size: 20))
                        .foregroundColor(.white)
                    if user.profession != "" {
                        ProfessionView
                    }
                    NavigationLink(
                        destination: UserView(invitable: false, isPreview: false, show: $showUser).environmentObject(self.likerVM),
                        isActive: $showUser) {
                            Text("Show More")
                                .font(Font.custom("Avenir Next Demi Bold", size: 12))
                                .foregroundColor(.white)
                                .padding(.vertical, 2).padding(.horizontal, 10)
                                .background(Color("Pink"))
                                .clipShape(Capsule())
                        }
                    .simultaneousGesture(TapGesture().onEnded {
                        self.userVM.setInspectedUser(user: user)
                    })
                }
                .padding()
                Spacer()
            }
        }
        .frame(minWidth: 0)
    }
    
    private var ProfessionView: some View {
        let profession = self.user.profession
        let company = self.user.company
        return Text("\(profession)\(company != "" ? (", " + "\(company)") : "")")
            .font(Font.custom("Avenir Next", size: 14))
            .foregroundColor(.white)
    }
}

struct LikerCommentCardView: View {
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    let user: User
    let headingLabel: String
    let quoteLabel: String
    let comment: String
    
    var body: some View {
        VStack (alignment: .leading, spacing: 3) {
            if !headingLabel.isEmpty {
                // like or comment
                HStack {
                    Image(comment.isEmpty ? "lightheart" : "lightcomment")
                        .resizable()
                        .frame(width: 20, height: 20)
                    Text(comment.isEmpty ? "\(user.firstName) liked your prompt!" : "\(comment)")
                        .font(Font.custom("Avenir Next Italic", size: 16))
                    Spacer()
                }
                .padding(20)
                .background(Color.white.opacity(0.1))
                .clipShape(ChatBubbleShape())
                .opacity(user == likerVM.requestedMatcher ? 1 : 0)
            }
            VStack (alignment: .leading) {
                // most basic version of invite
                if comment.isEmpty && headingLabel.isEmpty {
                    Text("\(user.firstName) likes you! Swipe right to chat")
                        .font(Font.custom("Avenir Next Italic", size: 12))
                        .foregroundColor(.white)
                } else if headingLabel.isEmpty && !comment.isEmpty {
                    // simple invite with a comment
                    HStack (alignment: .bottom) {
                        Image("quotes")
                            .resizable()
                            .frame(width: 35, height: 28)
                        Spacer(minLength: 10)
                        Text("\(comment)")
                            .font(Font.custom("Avenir Next Bold Italic", size: 16))
                            .tracking(1)
                            .foregroundColor(.white)
                    }
                } else {
                    Text("\(self.headingLabel.uppercased())")
                        .font(Font.custom("Avenir Next Demi Bold", size: 12))
                        .tracking(1)
                        .foregroundColor(.white)
                    HStack (alignment: .top) {
                        Image("quotes")
                            .resizable()
                            .frame(width: 35, height: 28)
                        Text("\(self.quoteLabel.uppercased())")
                            .font(Font.custom("Avenir Next Bold", size: 16))
                            .tracking(1.5)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(10)
            .background(Color("Accent Blue"))
            .clipShape(RoundedCorners(tl: 5, tr: 10, bl: 5, br: 5))
            .frame(height: 60)
        }
    }
}

struct NoLikerView: View {
    @EnvironmentObject var likerVM: LikerViewModel
    
    var body: some View {
        VStack {
            VStack {
                Image("keepLookingIcon")
                    .resizable()
                    .frame(width: 150, height: 165)
                SystemText(text: "Keep Looking!", fontstyle: .headerBold)
                Spacer().frame(height: 15)
                SystemText(text: "The more people you invite, the better your chances are of getting a match! Go back to the counter and send those likes.", fontstyle: .regular)
            }
            .padding(20)
            .background(Color("Neutral"))
            .cornerRadius(10)
        }
        .padding(.horizontal, 20)
    }
}
