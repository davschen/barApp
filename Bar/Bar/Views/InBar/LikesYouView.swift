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
    @EnvironmentObject var likerVM: LikerViewModel
    @State var counter = 0
    @State var offset = CGSize.zero
    @State var noLikeOpacity = 0.0
    @State var showUser = false
    @State var vOffset = CGSize.zero
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
                    } else {
                        Text("").opacity(0)
                            .onAppear {
                                self.counter = 0
                                self.likerVM.refreshLikeCards()
                            }
                    }
                    ForEach(self.likerVM.likeCards.reversed()) { likeCard in
                        let liker: User = likeCard.user
                        HStack {
                            ZStack {
                                PictureViews(pvUser: liker, showsButton: true, showUser: $showUser)
                                    .frame(width: calculateSize().width, height: calculateSize(i: likeCard.id).height)
                                    .cornerRadius(10)
                                    .offset(x: likeCard.id - counter <= 2 ? CGFloat(likeCard.id - counter) * 5 : 5)
                                VStack {
                                    Spacer()
                                    HStack {
                                        NavigationLink(
                                            destination: UserView(user: self.likerVM.likedUser, invitable: false, isPreview: false, show: $showUser).environmentObject(self.likerVM),
                                            isActive: $showUser) {
                                                Text("Show More")
                                                    .font(Font.custom("Avenir Next Demi Bold", size: 12))
                                                    .foregroundColor(.white)
                                                    .padding(.vertical, 2).padding(.horizontal, 10)
                                                    .background(Color("Pink"))
                                                    .cornerRadius(10)
                                            }
                                        .padding()
                                        Spacer()
                                    }
                                }
                            }
                            .offset(y: likeCard.offset)
                            .gesture(DragGesture()
                                        .onChanged { gesture in
                                            withAnimation {
                                                likerVM.likeCards[likeCard.id].offset = gesture.translation.height
                                            }
                                            self.vOffset.height = gesture.translation.height
                                        }
                                        .onEnded { gesture in
                                            withAnimation(.spring()) {
                                                if self.vOffset.height <= -150 {
                                                    likerVM.likeCards[likeCard.id].offset = -1000
                                                    requestMatch()
                                                    self.showWaitView.toggle()
                                                } else if self.vOffset.height > 150 {
                                                    likerVM.likeCards[likeCard.id].offset = 1000
                                                    dislike()
                                                } else {
                                                    likerVM.likeCards[likeCard.id].offset = .zero
                                                }
                                            }
                                            self.vOffset = .zero
                                        }
                            )
                            .frame(width: calculateSize().width, height: UIScreen.main.bounds.height / 1.7)
                        }
                    }
                }
            }
            // Dynamically sizing buttons based on offset
            VStack {
                Spacer()
                if counter < likerVM.likeCards.count {
                    YesNoButtonView(likedUser: self.likerVM.likedUser, showWaitView: $showWaitView, vOffset: $vOffset, pressDislike: $pressDislike)
                        .padding(.bottom)
                }
            }
            VStack {
                if self.likerVM.matcher.count != 0 {
                    Text("").onAppear { self.showWaitView = true }
                }
                if showWaitView {
                    WaitingForMatchView(showWaitView: $showWaitView)
                        .environmentObject(self.chatVM)
                        .environmentObject(self.likerVM)
                }
            }
            .transition(.opacity).animation(.easeInOut)
        }
        .navigationBarTitle("Who's Lovin' You", displayMode: .inline)
    }
    func requestMatch() {
        self.likerVM.updateLikedUser()
        self.likerVM.requestMatch()
        counter += 1
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }
    func calculateSize(i: Int = 0) -> CGSize {
        let screen = UIScreen.main.bounds.size
        let w = screen.width - 50
        let h = (screen.height / 1.7) - CGFloat(i - counter) * 30
        return CGSize(width: w, height: h)
    }
    func dislike() {
        counter += 1
        self.likerVM.dismissUser(counter: counter)
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
            Spacer().frame(height: 40)
            
            Button {
                likerVM.fetchData()
                self.likerVM.refreshLikeCards()
            } label: {
                Text("Refresh")
                    .font(Font.custom("Avenir Next Demi Bold", size: 14))
                    .foregroundColor(Color("Midnight"))
                    .padding(.vertical, 15).padding(.horizontal, 80)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 40)
    }
}

struct LikesYouView_Previews: PreviewProvider {
    static var previews: some View {
        LikesYouView()
    }
}


struct YesNoButtonView: View {
    @State var likedUser: User
    @Binding var showWaitView: Bool
    @Binding var vOffset: CGSize
    @Binding var pressDislike: Bool
    
    var body: some View {
        HStack {
            let restSize: CGFloat = 50
            Button(action: {
                self.pressDislike = true
            }, label: {
                ZStack {
                    let growFrame = self.vOffset.height < 0 ? restSize : restSize + self.vOffset.height / 10
                    Circle()
                        .frame(width: growFrame, height: growFrame)
                        .foregroundColor(Color("Accent Blue"))
                    Image("xIcon")
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                .opacity(self.vOffset.height <= 0 ? 0.2 : (Double(self.vOffset.height) + 80) / 400)
            })
            Spacer().frame(width: 20)
            ZStack {
                let growFrame = self.vOffset.height < 0 ? restSize + -self.vOffset.height / 10 : restSize
                Circle()
                    .frame(width: growFrame, height: growFrame)
                    .foregroundColor(Color("Pink"))
                Image("checkIcon")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
            .opacity(self.vOffset.height >= 0 ? 0.2 : (Double(self.vOffset.height) - 80) / -400)
        }
        .animation(.spring())
        .padding(15)
        .background(Color("Neutral").opacity(abs(self.vOffset.height) == 0 ? 1 : 0))
        .clipShape(Capsule())
        .offset(y: 20)
    }
}
