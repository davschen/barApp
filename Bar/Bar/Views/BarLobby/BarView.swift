//
//  BarView.swift
//  Bar
//
//  Created by David Chen on 12/8/20.
//

import Foundation
import SDWebImageSwiftUI
import SwiftUI
import Firebase

struct BarView: View {
    @EnvironmentObject var barVM: BarViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @State var isShowingProfile = false
    
    var body: some View {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        
        NavigationView {
            ZStack {
                BGColor()
                VStack(alignment: .leading, spacing: 5) {
                    NavigationLink(destination: ProfileView(isShowingProfile: $isShowingProfile).environmentObject(self.currentUserVM), isActive: $isShowingProfile) {
                        EditProfileView()
                    }
                    VStack (alignment: .leading, spacing: 0) {
                        SystemTextTracking(text: "BARS", fontstyle: .jumboBold)
                            .shadow(color: Color("Pink"), radius: 0, x: -1, y: -2)
                        SystemText(text: "Last Call in \(25 - hour) hours, \(60 - minutes) minutes", fontstyle: .mediumBold)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(self.barVM.bars) { bar in
                                if bar.name != self.barVM.featuredBar {
                                    SmallBarView(bar: bar)
                                }
                            }
                        }
                    }
                    HStack {
                        ForEach (self.barVM.bars) { bar in
                            if bar.name == barVM.featuredBar {
                                BigBarView(bar: bar)
                                    .frame(height: UIScreen.main.bounds.height * 0.5)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .accentColor(.white)
        .preferredColorScheme(.dark)
    }
}

struct SmallBarView: View {
    @EnvironmentObject var barVM: BarViewModel
    @EnvironmentObject var chatVM: ChatViewModel
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var showDetail = false
    
    let bar: Bar
    
    var body: some View {
        Button {
            showDetail.toggle()
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                BarWebImage(url: self.bar.imageLinkName, radius: 10)
                SystemText(text: self.bar.name, fontstyle: .regularBold)
                CapacityView(capacity: Double(self.bar.occup) / Double(self.bar.cap))
            }
            .padding(10)
            .background(Color("Navy"))
            .cornerRadius(10.0)
            .padding(.trailing, 5)
            .onTapGesture {
                self.barVM.selectedBarForPreView = self.bar
                self.showDetail.toggle()
            }
        }
        NavigationLink(destination: BarPreView(show: $showDetail)
                        .environmentObject(self.barVM)
                        .environmentObject(self.chatVM)
                        .environmentObject(self.currentUserVM)
                        .environmentObject(self.likerVM)
                        .environmentObject(self.userVM), isActive: $showDetail) {
        }.hidden()
    }
}

struct CapacityView: View {
    let capacity: Double
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color("Muted Blue"))
                        .cornerRadius(.infinity)
                        .frame(height: 4.0)
                    Rectangle()
                        .fill(Color("Pink"))
                        .cornerRadius(.infinity)
                        .frame(width: CGFloat(Double(self.capacity) * Double(geometry.size.width)), height: 4.0)
                }
                let fullPercent: Int = self.capacity > 0 ? Int(self.capacity * 100) : 0
                SystemText(text: "\(fullPercent)% full", fontstyle: .small)
            }
        }
        .frame(height: 30)
    }
}

struct BigBarView: View {
    @EnvironmentObject var barVM: BarViewModel
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    
    @State var bar: Bar
    @State var showBar = false

    var db = Firestore.firestore()
    
    var body: some View {
        Button {
            self.showBar.toggle()
            self.barVM.updateCurrentBar(bar: self.bar)
            if let barID = bar.id {
                self.currentUserVM.changeUserValueDB(key: "currentBarID", value: barID)
            }
        } label: {
            VStack(alignment: .leading) {
                SystemTextTracking(text: "BAR OF THE NIGHT", fontstyle: .largeBold)
                    .shadow(color: Color("Pink"), radius: 0, x: -1, y: -2)
                BarWebImage(url: bar.imageLinkName, radius: 10)
                SystemText(text: bar.name, fontstyle: .largeBold)
                TagView(labels: bar.tags)
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
                StandardButtonView(text: "Enter Bar")
                    .padding()
                NavigationLink(destination: InBarView(presentInBarView: $showBar)
                                .environmentObject(self.currentUserVM)
                                .environmentObject(self.likerVM), isActive: $showBar) {
                }.hidden()
            }
            .padding()
            .background(Color("Navy"))
            .cornerRadius(10.0)
        }
    }
}

struct EditProfileView: View {
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    
    let height = UIScreen.main.bounds.height / 15

    var body: some View {
        HStack {
            BarWebImage(url: self.currentUserVM.currentUser.profURL, radius: 0)
                .clipShape(Circle())
                .overlay(Circle()
                    .stroke(Color("Pink"), lineWidth: 3))
                .frame(width: 30, height: 30)
            Spacer()
                .frame(width: 10)
            Text("\(self.currentUserVM.currentUser.firstName)'s Profile")
                .font(Font.custom("Avenir Next Bold", size: 16))
                .foregroundColor(.white)
            Spacer()
            SettingsIconView()
                .frame(width: 30, height: 30)
        }
        .frame(height: self.height)
        .padding(.horizontal)
        .background(Color("Navy"))
        .cornerRadius(10)
    }
}

struct TagView: View {
    let labels: [String]
    var body: some View {
        HStack {
            ForEach(self.labels, id: \.self) { label in
                Text("\(label)")
                    .font(Font.custom("Avenir Next Regular", size: 10))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(RoundedRectangle(
                        cornerRadius: 10, style: .continuous
                    ).stroke(Color.white, lineWidth: 1))
            }
        }
        
    }
}

struct BarView_Previews: PreviewProvider {
    static var previews: some View {
        BarView()
    }
}
