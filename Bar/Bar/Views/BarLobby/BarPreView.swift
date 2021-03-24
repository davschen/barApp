//
//  BarPreView.swift
//  Bar
//
//  Created by David Chen on 12/9/20.
//

import Foundation
import SwiftUI
import Firebase

struct BarPreView: View {
    @EnvironmentObject var barVM: BarViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @Binding var show: Bool

    var body: some View {
        ZStack {
            BGColor()
            VStack (spacing: 10) {
                Spacer()
                    .frame(height: UIScreen.main.bounds.height / 10)
                HStack {
                    Text("BARS")
                        .font(Font.custom("Avenir Next Bold", size: 30))
                        .tracking(5)
                        .foregroundColor(.white)
                        .shadow(color: Color("Pink"), radius: 0, x: -1, y: -2)
                    Spacer()
                }
                .padding(.horizontal, 20)
                ScrollView(.horizontal) {
                    LazyHStack {
                        PageView(barArr: self.barVM.bars.wrap(around: self.barVM.getCurrentIndex()))
                    }
                }
            }
        }
    }
}

struct PageView: View {
    @EnvironmentObject var barVM: BarViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    let barArr: [Bar]
    let db = Firestore.firestore()

    var body: some View {
        TabView {
            ForEach(0..<barArr.count) { i in
                ZStack {
                    Color("Navy")
                    VStack (alignment: .leading, spacing: 10) {
                        let bar: Bar = barArr[i]
                        BarWebImage(url: bar.imageLinkName, radius: 10)
                        SystemText(text: bar.name, fontstyle: .largeBold)
                        TagView(labels: bar.tags)
                        SystemText(text: bar.description, fontstyle: .mediumItalics)
                        HStack (alignment: .top) {
                            HStack {
                                Image("Location Icon")
                                    .resizable()
                                    .frame(width: 12, height: 15)
                                SystemText(text: "\(bar.city), \(bar.state)", fontstyle: .regular)
                            }
                            Spacer()
                            CapacityView(capacity: Double(bar.occup) / Double(bar.cap))
                                .frame(width: UIScreen.main.bounds.size.width / 3)
                                .offset(x: 0, y: 4)
                        }
                        VStack (alignment: .center) {
                            NavigationLink(destination: InBarView()
                                            .environmentObject(self.barVM)
                                            .environmentObject(self.chatVM)
                                            .environmentObject(self.currentUserVM)
                                            .environmentObject(self.likerVM)
                                            .environmentObject(self.userVM)) {
                                Text("Enter Bar")
                                    .padding(.vertical, 15)
                                    .frame(maxWidth: .infinity)
                                    .font(Font.custom("Avenir Next Bold", size: 12))
                                    .foregroundColor(.white)
                                    .background(Color("Pink"))
                                    .cornerRadius(100)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                self.barVM.updateCurrentBar(bar: self.barArr[i])
                                if let id = Auth.auth().currentUser?.uid {
                                    db.collection("users").document(id).setData([
                                        "currentBarID" : bar.id!
                                    ], merge: true)
                                }
                            })
                        }
                        .padding(.vertical, UIScreen.main.bounds.size.height / 25)
                    }
                    .padding(20)
                }
                .background(Color("Navy"))
                .cornerRadius(10)
                .padding(.horizontal, 20)
            }
            .padding(.bottom, UIScreen.main.bounds.height / 15)
        }
        .frame(width: UIScreen.main.bounds.width)
        .tabViewStyle(PageTabViewStyle())
    }
}
