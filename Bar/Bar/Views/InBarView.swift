//
//  InBarView.swift
//  Bar
//
//  Created by David Chen on 12/9/20.
//

import Foundation
import SwiftUI

struct InBarView: View {
    @State var bar: Bar
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
    @EnvironmentObject var likerViewModel: LikerViewModel
    @ObservedObject private var userViewModel = UserViewModel()
    @State var showLikesYou = false
    @State var showInvite = false
    @State var likedUser: User = TempUserLib().user1
    @State var inviteType: InviteType = .normal
    @State var heading = ""
    @State var subheading = ""
    @State var comment = ""
    @State var presentAlert = false
    @State var barHopActive = false
    @State var showMatchView = false
    
    var body: some View {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        ZStack {
            BGColor()
            VStack (alignment: .leading) {
                HStack (alignment: .bottom) {
                    VStack (alignment: .leading) {
                        Text("\(bar.name.uppercased())")
                            .font(Font.custom("Avenir Next Bold", size: 20))
                            .tracking(3)
                            .foregroundColor(.white)
                            .shadow(color: Color("Pink"), radius: 0, x: -1, y: -1)
                        Spacer()
                            .frame(height: 10)
                        SystemText(text: "Last Call in \(25 - hour) hours, \(60 - minutes) minutes", fontstyle: .regularDemiBold)
                    }
                    Spacer()
                    Button(action: {
                        self.presentAlert.toggle()
                        print("matcher count is: " + "\(self.likerViewModel.matcher.count)")
                    }, label: {
                        StandardButtonView(text: "Bar Hop")
                            .frame(width: UIScreen.main.bounds.width / 5)
                    })
                    NavigationLink(destination: BarView(), isActive: $barHopActive){
                        
                    }.hidden()
                }
                NavigationLink(destination: LikesYouView().environmentObject(self.likerViewModel), isActive: $showLikesYou) {
                    HStack {
                        Text("SEE WHO LIKES YOU")
                            .font(Font.custom("Avenir Next Demi Bold", size: 14))
                            .tracking(2)
                            .foregroundColor(.white)
                            .padding()
                        Spacer()
                        ZStack {
                            ForEach(self.likerViewModel.likers) { liker in
                                SystemWebImage(url: liker.profURL, radius: 0)
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                                    .background(Circle().stroke(Color.white, lineWidth: 2))
                            }
                            if likerViewModel.likers.count > 2 {
                                // Circle with +N
                                Group {
                                    Circle()
                                        .strokeBorder(Color.white, lineWidth: 2)
                                        .background(
                                            Circle()
                                                .foregroundColor(.black)
                                                .opacity(0.7))
                                        .frame(width: 30, height: 30)
                                    Text("+\(likerViewModel.likers.count)")
                                        .font(Font.custom("Avenir Next Demi Bold", size: 12))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        Image("goArrow").padding()
                    }
                    .background(Color("Pink"))
                    .cornerRadius(5)
                    .padding(.vertical)
                    .gesture(TapGesture()
                                .onEnded({ _ in
                                    self.showLikesYou = true
                                })
                    )
                }
                Text("THE COUNTER")
                    .font(Font.custom("Avenir Next Bold", size: 20))
                    .tracking(3)
                    .foregroundColor(.white)
                    .shadow(color: Color("Pink"), radius: 0, x: -1, y: -1)
                GeometryReader { geometry in
                    VStack {
                        ScrollView (.vertical, showsIndicators: false) {
                            VStack {
                                scrollOrGridView
                                VStack {
                                    HStack {
                                        Spacer()
                                        HStack {
                                            Text("Next")
                                                .foregroundColor(Color("Midnight"))
                                                .font(Font.custom("Avenir Next Bold", size: 12))
                                                .padding(.vertical)
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.black)
                                        }
                                        .padding(.horizontal, 30)
                                        .background(Color.white)
                                        .clipShape(Capsule())
                                        .padding(.horizontal)
                                        .onTapGesture {
                                            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .background(Color("Navy"))
                .cornerRadius(10)
                Spacer()
            }
            .padding(20)
            // show invite overlay view
            VStack {
                if showInvite {
                    SendInviteView(user: likedUser, heading: $heading, subheading: $subheading, inviteType: $inviteType, comment: $comment, showInviteView: $showInvite)
                }
            }.transition(.opacity).animation(.easeInOut)
            // if they receive a matcher, show the matchview
            VStack {
                if self.likerViewModel.matcher.count > 0 {
                    Text("").onAppear { self.showMatchView.toggle() }
                }
                if showMatchView {
                    MatchView(showMatchView: $showMatchView)
                        .environmentObject(self.likerViewModel)
                        .environmentObject(self.currentUserViewModel)
                }
            }
            .transition(.opacity).animation(.easeInOut)
        }
        .alert(isPresented: $presentAlert) {
            Alert(title: Text("Are You Sure?"), message: Text("Leaving the bar will take you out of everyone's likes"),
                  primaryButton: .cancel(),
                  secondaryButton: .default(Text("Yes, I want to leave"), action: {
                    self.currentUserViewModel.changeUserValueDB(key: "currentBarID", value: "")
                    self.likerViewModel.removeAllLikers()
                    self.barHopActive = true
                  }))
        }
        .accentColor(.white)
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
    
    var twoColumnGrid = [GridItem(.flexible()), GridItem(.flexible())]
    
    @ViewBuilder
    var scrollOrGridView: some View {
        if #available(iOS 14.0, *) {
            LazyVGrid(columns: twoColumnGrid) {
                ForEach(userViewModel.users) { user in
                    ProfilePreView(height: 250, user: user, showInvite: $showInvite, likedUser: $likedUser)
                        .id(user.id)
                }
            }
            .padding(5)
        } else {
            ForEach(userViewModel.users) { user in
                ProfilePreView(height: UIScreen.main.bounds.height / 2, user: user, showInvite: $showInvite, likedUser: $likedUser)
            }
        }
    }
}

struct ProfilePreView: View {
    let height: CGFloat
    let user: User
    @Binding var showInvite: Bool
    @Binding var likedUser: User
    @EnvironmentObject var likerVM: LikerViewModel
    @State var show = false
    
    var body: some View {
        NavigationLink(destination: UserView(user: user, invitable: true, isPreview: false, show: $show).environmentObject(self.likerVM), isActive: $show) {
            ZStack (alignment: .bottom) {
                SystemWebImage(url: user.imageLinks[0], radius: 0)
                Rectangle()
                    .fill(LinearGradient(
                            gradient: .init(colors: [Color.black.opacity(0), Color.black.opacity(0.7)]),
                            startPoint: .init(x: 0, y: 0.7),
                            endPoint: .init(x: 0, y: 1)))
                HStack {
                    Text("\(user.firstName), \(getYearsDiffFromDate(date: user.dob))")
                        .font(Font.custom("Avenir Next Medium", size: 16))
                        .foregroundColor(.white)
                        .frame(alignment: .leading)
                    Spacer()
                    Button(action: {
                        self.showInvite = true
                        self.likedUser = user
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }, label: {
                        Image("like icon")
                            .resizable()
                            .frame(width: 30, height: 30)
                    })
                }
                .padding(10)
            }
            .cornerRadius(10)
            .frame(height: height)
        }
    }
}

public func getYearsDiffFromDate(date: Date) -> Int {
    let difference = Calendar.current.dateComponents([.year], from: date, to: Date())
    return Int(difference.year!)
}

struct ProfileGrid: View {
    let height: CGFloat
    let inBarUserModel: UserViewModel
    @Binding var showInvite: Bool
    @Binding var likedUser: User
    
    var body: some View {
        VStack {
            ForEach(0..<inBarUserModel.users.count / 2) { row in
                HStack {
                    ForEach(0..<3) { column in // create 3 columns
                        let user = self.inBarUserModel.users[row * 3 + column]
                        ProfilePreView(height: height, user: user, showInvite: $showInvite, likedUser: $likedUser)
                    }
                }
                .padding(.horizontal, 15)
            }
        }
        .padding(.vertical)
    }
}

struct InBarView_Previews: PreviewProvider {
    static var cuvm = CurrentUserViewModel()
    static var previews: some View {
        InBarView(bar: Bar(id: "", name: "", description: "", imageLinkName: "", tags: [], cap: 0.0, occup: 0.0, city: "", state: ""))
    }
}
