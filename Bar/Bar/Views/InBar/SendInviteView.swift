//
//  SendLikeView.swift
//  Bar
//
//  Created by David Chen on 12/18/20.
//

import Foundation
import SwiftUI

struct SendInviteView: View {
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Binding var heading: String
    @Binding var subheading: String
    @Binding var inviteType: InviteType
    @Binding var comment: String
    @Binding var showInviteView: Bool
    
    var sendInviteTo: User {
        return self.likerVM.sendInviteToUser
    }
    
    var body: some View {
        let customize = customizer(it: inviteType)
        let commentLine = customize.comment
        let buttonLabel = customize.button
        let imageName = customize.image
        
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .dark))
                .edgesIgnoringSafeArea(.all)
            Rectangle()
                .foregroundColor(.black)
                .edgesIgnoringSafeArea(.all)
                .opacity(0.2)
            VStack (alignment: .leading, spacing: 15) {
                Text("\(self.likerVM.sendInviteToUser.firstName)")
                    .font(Font.custom("Avenir Next Demi Bold", size: 36))
                    .foregroundColor(.white)
                    .offset(y: 60)
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Image("\(imageName)")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .offset(y: 30)
                        }
                        .zIndex(1)
                        if inviteType == .normal {
                            if self.likerVM.sendInviteToUser.bio != "" {
                                InviteCardView(bio: self.sendInviteTo.bio, user: self.sendInviteTo)
                            } else {
                                InviteCardView(bio: "Tell \(self.sendInviteTo.firstName) what you like about \(likerVM.generatePronouns(user: self.likerVM.sendInviteToUser)[1])!", user: self.sendInviteTo)
                            }
                        } else {
                            LikeCommentCardView(heading: heading, subheading: subheading)
                        }
                    }
                }
                ZStack (alignment: .leading) {
                    if self.comment.isEmpty {
                        Text(commentLine)
                            .font(Font.custom("Avenir Next", size: 14))
                            .foregroundColor(.gray)
                            .animationsDisabled()
                    }
                    TextField("", text: $comment)
                        .font(Font.custom("Avenir Next", size: 14))
                        .foregroundColor(.black)
                        .accentColor(.black)
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
                .background(Color(.white))
                .cornerRadius(10)
                
                // Send invite button
                Button(action: {
                    self.likerVM.sendInvite(heading: self.heading, subheading: self.subheading, comment: self.comment)
                    self.comment = ""
                    self.showInviteView.toggle()
                }, label: {
                    Text("\(buttonLabel)")
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .font(Font.custom("Avenir Next Bold", size: 12))
                        .foregroundColor(.white)
                        .background(Color("Pink"))
                        .cornerRadius(100)
                })
                Button(action: {
                    self.showInviteView.toggle()
                    self.comment = ""
                }, label: {
                    Text("Cancel")
                        .padding(.horizontal, 100).padding(.vertical)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(Font.custom("Avenir Next Demi Bold", size: 12))
                })
            }
            .padding(.horizontal, 30)
        }
    }
    
    func customizer(it: InviteType) -> (comment: String, button: String, image: String) {
        switch it {
        case .like: return ("Add an Optional Comment", "Send Like", "lightheart")
        case .comment: return ("Drop Your Line", "Send Comment", "lightcomment")
        default: return ("Add a Comment", "Invite for a Drink", "lightmartini")
        }
    }
}

struct InviteCardView: View {
    let bio: String
    let user: User
    var body: some View {
        HStack (spacing: 20) {
            BarWebImage(url: user.profURL, radius: 5)
                .frame(height: UIScreen.main.bounds.height / 6)
            Rectangle()
                .frame(width: 1, height: 100)
                .foregroundColor(.white)
            Text("\(bio)")
                .font(Font.custom("Avenir Next", size: 12))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(Color("Navy"))
        .cornerRadius(10)
    }
}

struct LikeCommentCardView: View {
    let heading: String
    let subheading: String
    var body: some View {
        HStack (alignment: .top) {
            VStack (alignment: .leading) {
                HStack (alignment: .bottom) {
                    Image("quotes")
                        .resizable()
                        .frame(width: 35, height: 28)
                    Text("\(heading.uppercased())")
                        .font(Font.custom("Avenir Next Demi Bold", size: 10))
                        .foregroundColor(.white)
                }
                Text("\(subheading.uppercased())")
                    .font(Font.custom("Avenir Next Bold", size: 16))
                    .tracking(1)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(Color("Navy"))
        .cornerRadius(10)
    }
}

enum InviteType {
    case normal
    case like
    case comment
}
