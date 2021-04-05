//
//  UserView.swift
//  Bar
//
//  Created by David Chen on 12/18/20.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

struct UserView: View {
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @State var invitable: Bool
    @State var isPreview: Bool
    
    @Binding var show: Bool
    @State var inviteType: InviteType = .normal
    @State var showInviteView = false
    @State var startIndex = 0
    @State var comment: String = ""
    @State var sendHeading: String = ""
    @State var sendSubHeading: String = ""
    @State var showChat = false
    
    var user: User {
        return self.userVM.inspectedUser
    }
    
    var body: some View {
        ZStack {
            BGColor()
            ScrollView(.vertical) {
                VStack (spacing: 15) {
                    HStack {
                        Text("TAKE A LOOK")
                            .font(Font.custom("Avenir Next Bold", size: 20))
                            .tracking(3)
                            .foregroundColor(.white)
                            .shadow(color: Color("Pink"), radius: 0, x: -1, y: -1)
                        Spacer()
                    }
                    VStack {
                        PictureViews(pvUser: user, showsButton: false, showUser: $show)
                            .frame(height: UIScreen.main.bounds.height / 2, alignment: .top)
                        VStack {
                            TopBulletsView(user: user)
                            if user.bio != "" { BioView(bio: user.bio) }
                            PersonalityCardsView(user: user, invitable: $invitable, showInviteView: $showInviteView, inviteType: $inviteType, heading: $sendHeading, subHeading: $sendSubHeading, isPreview: $isPreview)
                                .padding(.vertical)
                        }
                        .padding()
                        Spacer()
                    }
                    .background(Color("Navy"))
                    .cornerRadius(10)
                }
            }
            .cornerRadius(10)
            .padding()
            VStack {
                Spacer()
                VStack (spacing: 15) {
                    if self.invitable {
                        Button(action: {
                            self.showInviteView = true
                            self.inviteType = .normal
                        }, label: {
                            Text(self.invitable ? "Invite For a Drink" : "Start Your Conversation")
                                .padding(.vertical, 15)
                                .frame(maxWidth: .infinity)
                                .font(Font.custom("Avenir Next Bold", size: 12))
                                .foregroundColor(.white)
                                .background(Color("Pink"))
                                .cornerRadius(100)
                                .padding(.horizontal, 30)
                        })
                    } else if !self.isPreview {
                        NavigationLink(
                            destination: ChatView(showChat: $showChat)
                                .environmentObject(self.chatVM)
                                .environmentObject(self.likerVM)
                            , isActive: $showChat,
                            label: {
                                StandardButtonView(text: "Start Your Conversation")
                                    .padding(.horizontal, 30)
                            })
                    }
                    if !self.isPreview {
                        Button(action: {
                            self.show = false
                        }, label: {
                            SystemText(text: "Back", fontstyle: .regularDemiBold)
                                .padding(.horizontal, 100)
                        }).padding(.bottom)
                    }
                }
                .background(LinearGradient(
                                gradient: .init(colors: [Color("Midnight").opacity(0), Color("Midnight").opacity(1)]),
                                startPoint: .init(x: 0, y: 0),
                                endPoint: .init(x: 0, y: 0.8)))
            }
            VStack {
                if showInviteView {
                    SendInviteView(heading: sendHeading, subheading: sendSubHeading, inviteType: $inviteType, comment: comment, showInviteView: $showInviteView, showUserView: $show)
                }
            }.transition(.opacity).animation(.easeInOut)
        }
        .navigationBarTitle("\(user.firstName), \(userVM.getYearsDiffFromDate(date: user.dob))", displayMode: .inline)
    }
}

struct PictureViews: View {
    @EnvironmentObject var userVM: UserViewModel
    
    let pvUser: User
    
    @State var photoIndex = 0
    @State var showsButton: Bool
    @Binding var showUser: Bool
    
    var body: some View {
        ZStack {
            ForEach(0..<pvUser.imageLinks.count) { i in
                let link = self.pvUser.imageLinks[i]
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
                ImageTickerView(n: pvUser.imageLinks.count, photoIndex: photoIndex)
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
                        if photoIndex < pvUser.imageLinks.count - 1 {
                            self.photoIndex += 1
                        }
                        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                    }
                }
                HStack {
                    VStack (alignment: .leading) {
                        Text("\(pvUser.firstName), \(userVM.getYearsDiffFromDate(date: pvUser.dob))")
                            .font(Font.custom("Avenir Next Demi Bold", size: 20))
                            .foregroundColor(.white)
                        if pvUser.profession != "" {
                            ProfessionView
                        }
                        if showsButton {
                            Spacer()
                                .frame(height: 30)
                        }
                    }
                    Spacer()
                }
            }
            .padding()
        }
        .frame(minWidth: 0)
    }
    
    private var ProfessionView: some View {
        let profession = self.pvUser.profession
        let company = self.pvUser.company
        return Text("\(profession)\(company != "" ? (", " + "\(company)") : "")")
            .font(Font.custom("Avenir Next", size: 14))
            .foregroundColor(.white)
    }
}

struct ImageTickerView: View {
    let n, photoIndex: Int
    var body: some View {
        HStack {
            ForEach(0..<n, id: \.self) { i in
                if i == photoIndex {
                    Rectangle()
                        .frame(height: 5)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                } else {
                    Rectangle()
                        .frame(height: 5)
                        .foregroundColor(.black)
                        .opacity(0.4)
                        .cornerRadius(10)
                }
            }
        }
    }
}

struct TopBulletsView: View {
    let user: User
    var body: some View {
        HStack {
            VStack (alignment: .leading) {
                if user.showsLocation {
                    BulletDetailView(headingLabel: "location", subheadingLabel: "\(user.city), \(user.state)")
                }
                if user.education != "" && user.gradYear != 0 {
                    BulletDetailView(headingLabel: "education", subheadingLabel: "\(user.education)\(user.gradYear == 0 ? "" : ", \(String(user.gradYear + 1940))")")
                }
            }
            Spacer()
        }
    }
}

struct BulletDetailView: View {
    let headingLabel: String
    let subheadingLabel: String
    var body: some View {
        VStack (alignment: .leading, spacing: 2) {
            HStack {
                Circle()
                    .foregroundColor(Color("Pink"))
                    .frame(width: 8, height: 8)
                
                Text("\(headingLabel.uppercased())")
                    .font(Font.custom("Avenir Next Demi Bold", size: 12))
                    .foregroundColor(.white)
            }
            Text("\(subheadingLabel)")
                .font(Font.custom("Avenir Next", size: 14))
                .foregroundColor(.white)
        }
    }
}

struct BioView: View {
    let bio: String
    var body: some View {
        VStack (spacing: 15) {
            HStack {
                SystemTextTracking(text: "ABOUT ME", fontstyle: .smallDemiBold)
                    .padding(3)
                    .background(Color("Pink"))
                    .cornerRadius(3)
                Rectangle()
                    .foregroundColor(.white)
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }
            Text("\(bio)")
                .font(Font.custom("Avenir Next", size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.top, 2).padding(.bottom, 9)
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 1)
                .frame(maxWidth: .infinity)
        }
    }
}

struct PersonalityCardsView: View {
    @EnvironmentObject var userVM: UserViewModel
    let user: User
    @State private var rightAlign = true
    @Binding var invitable: Bool
    @Binding var showInviteView: Bool
    @Binding var inviteType: InviteType
    @Binding var heading: String
    @Binding var subHeading: String
    @Binding var isPreview: Bool
    
    var body: some View {
        VStack (spacing: 10) {
            let cardsInfo = self.userVM.cardsFormatter(user: user)
            let headings = cardsInfo.headings
            let subheadings = cardsInfo.subheadings
            HStack {
                Spacer()
                if cardsInfo.count > 0 && self.invitable {
                    Text("SWIPE TO RESPOND")
                        .font(Font.custom("Avenir Next Demi Bold", size: 10))
                        .tracking(1)
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color("Pink"))
                        .cornerRadius(3)
                }
            }
            if cardsInfo.count > 0 {
                ForEach(1...cardsInfo.count, id: \.self) { i in
                    PersonalityCardView(headingLabel: headings[i], quoteLabel: subheadings[i], alternator: i % 2, invitable: $invitable, showInviteView: $showInviteView, inviteType: $inviteType, heading: $heading, subHeading: $subHeading)
                }
                Spacer().frame(height: self.isPreview ? 0 : 40)
            }
        }
    }
}

struct PersonalityCardView: View {
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    let headingLabel: String
    let quoteLabel: String
    let alternator: Int
    @State private var offset = CGSize.zero
    @State private var backDisplayed = false
    @Binding var invitable: Bool
    @Binding var showInviteView: Bool
    @Binding var inviteType: InviteType
    @Binding var heading: String
    @Binding var subHeading: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("Midnight"))
                .cornerRadius(5)
            HStack {
                Spacer()
                RespondButtonView(headingLabel: headingLabel, quoteLabel: quoteLabel, showInviteView: $showInviteView, inviteType: $inviteType, heading: $heading, subHeading: $subHeading)
            }
            VStack {
                VStack (alignment: self.alternator == 1 ? .leading : .trailing, spacing: 3) {
                    Text("\(self.headingLabel.uppercased())")
                        .font(Font.custom("Avenir Next Demi Bold", size: 12))
                        .tracking(1)
                        .foregroundColor(.white)
                    HStack (alignment: .top) {
                        if self.alternator == 0 {
                            Spacer()
                        } else {
                            Image("quotes")
                                .resizable()
                                .frame(width: 35, height: 28)
                        }
                        Text("\(self.quoteLabel.uppercased())")
                            .font(Font.custom("Avenir Next Bold", size: 16))
                            .tracking(1.5)
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)
                        if self.alternator == 1 {
                            Spacer()
                        } else {
                            Image("backquotes")
                                .resizable()
                                .frame(width: 35, height: 28)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(10)
                .background(Color("Accent Blue"))
                .cornerRadius(5)
            }
            .offset(x: self.offset.width, y: 0)
            .animation(.easeInOut)
            .gesture(DragGesture()
                        .onChanged { gesture in
                            if self.invitable {
                                if !backDisplayed && gesture.translation.width < 0 {
                                    self.offset = gesture.translation
                                } else if backDisplayed {
                                    self.offset = .zero
                                    backDisplayed.toggle()
                                }
                            }
                        }
                        .onEnded { _ in
                            if self.invitable {
                                if abs(self.offset.width) > 50 {
                                    self.backDisplayed = true
                                    self.offset.width = -130
                                } else {
                                    self.offset = .zero
                                }
                            }
                        }
                    )
        }
    }
}

struct RespondButtonView: View {
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    let headingLabel: String
    let quoteLabel: String
    
    @Binding var showInviteView: Bool
    @Binding var inviteType: InviteType
    @Binding var heading: String
    @Binding var subHeading: String
    
    var body: some View {
        HStack {
            Button(action: {
                self.showInviteView = true
                self.inviteType = .like
                self.heading = headingLabel
                self.subHeading = quoteLabel
                self.likerVM.setInvitedUser(user: self.userVM.inspectedUser)
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }, label: {
                Image("like icon")
                    .resizable()
                    .frame(width: 40, height: 40)
            })
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 1, height: 40)
            Button(action: {
                self.showInviteView = true
                self.inviteType = .comment
                self.heading = headingLabel
                self.subHeading = quoteLabel
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }, label: {
                Image("comment icon")
                    .resizable()
                    .frame(width: 40, height: 40)
            })
        }
        .padding()
    }
}
