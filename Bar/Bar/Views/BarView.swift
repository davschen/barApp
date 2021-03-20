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
    @ObservedObject private var viewModel = BarViewModel()
    @ObservedObject private var currentUserViewModel = CurrentUserViewModel()
    @ObservedObject private var likerViewModel = LikerViewModel()
    @State var isShowingProfile = false
    
    var body: some View {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        NavigationView {
            ZStack {
                BGColor()
                VStack(alignment: .leading) {
                    NavigationLink(destination: ProfileView(isShowingProfile: $isShowingProfile).environmentObject(self.currentUserViewModel), isActive: $isShowingProfile) {
                        EditProfileView()
                            .environmentObject(self.currentUserViewModel)
                    }
                    SystemTextTracking(text: "BARS", fontstyle: .jumboBold)
                        .shadow(color: Color("Pink"), radius: 0, x: -1, y: -2)
                    SystemText(text: "Last Call in \(25 - hour) hours, \(60 - minutes) minutes", fontstyle: .mediumBold)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(viewModel.bars) { bar in
                                if bar.name != "Berkeley Night Lounge" {
                                    SmallBarView(barArr: viewModel.bars, bar: bar)
                                        .environmentObject(self.currentUserViewModel)
                                        .environmentObject(self.likerViewModel)
                                }
                            }
                        }
                    }
                    ForEach(viewModel.bars) { bar in
                        if bar.name == "Berkeley Night Lounge" {
                            BigBarView(bar: bar)
                                .frame(height: UIScreen.main.bounds.height * 0.5)
                                .environmentObject(self.currentUserViewModel)
                                .environmentObject(self.likerViewModel)
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
    @State var showDetail = false
    let barArr: [Bar]
    let bar: Bar
    @EnvironmentObject var cuvm: CurrentUserViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    var index: Int {
        var indToReturn = 0
        for i in 0..<barArr.count {
            let scrolledBar = barArr[i]
            if self.bar.name == scrolledBar.name {
                indToReturn = i
            }
        }
        return indToReturn
    }
    var body: some View {
        NavigationLink(destination: BarPreView(barArr: barArr, index: index, show: $showDetail)
                        .environmentObject(cuvm)
                        .environmentObject(likerVM), isActive: $showDetail) {
            VStack(alignment: .leading, spacing: 10) {
                SystemWebImage(url: bar.imageLinkName, radius: 10)
                SystemText(text: bar.name, fontstyle: .regularBold)
                CapacityView(capacity: Double(bar.occup) / Double(bar.cap))
            }
            .padding(10)
            .background(Color("Navy"))
            .cornerRadius(10.0)
        }
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
                        .frame(width: CGFloat(Double(capacity) * Double(geometry.size.width)), height: 4.0)
                }
                SystemText(text: "\(Int(capacity * 100))% full", fontstyle: .small)
            }
        }
        .frame(height: 30)
    }
}

struct BigBarView: View {
    @State var bar: Bar
    @State var showBar = false
    @EnvironmentObject var cuvm: CurrentUserViewModel
    @EnvironmentObject var likerVM: LikerViewModel
    var db = Firestore.firestore()
    
    var body: some View {
        VStack(alignment: .leading) {
            SystemTextTracking(text: "BAR OF THE NIGHT", fontstyle: .largeBold)
                .shadow(color: Color("Pink"), radius: 0, x: -1, y: -2)
            SystemWebImage(url: bar.imageLinkName, radius: 10)
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
            Button(action: {
                self.showBar = true
                if let id = Auth.auth().currentUser?.uid {
                    db.collection("users").document(id).setData([
                        "currentBarID" : bar.id!
                    ], merge: true)
                }
            }, label: {
                StandardButtonView(text: "Enter Bar")
                    .padding()
            })
            NavigationLink(destination: InBarView(bar: self.bar)
                            .environmentObject(likerVM)
                            .environmentObject(cuvm), isActive: $showBar) {
            }.hidden()
        }
        .padding()
        .background(Color("Navy"))
        .cornerRadius(10.0)
    }
}

struct EditProfileView: View {
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    let height = UIScreen.main.bounds.height / 15

    var body: some View {
        HStack {
            SystemWebImage(url: currentUserVM.currentUser.profURL, radius: 0)
                .clipShape(Circle())
                .overlay(Circle()
                    .stroke(Color("Pink"), lineWidth: 3))
                .frame(width: 30, height: 30)
            Spacer()
                .frame(width: 10)
            Text("\(currentUserVM.currentUser.firstName)'s Profile")
                .font(Font.custom("Avenir Next Bold", size: 16))
                .foregroundColor(.white)
            Spacer()
            Image("settings icon")
        }
        .frame(height: height)
        .padding(.horizontal)
        .background(Color("Navy"))
        .cornerRadius(10)
    }
}

struct TagView: View {
    let labels: [String]
    var body: some View {
        HStack {
            ForEach(labels, id: \.self) { label in
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
