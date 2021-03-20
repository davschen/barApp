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
    let barArr: [Bar]
    let index: Int
    @EnvironmentObject var currentUserViewModel: CurrentUserViewModel
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
                        PageView(barArr: barArr.wrap(around: index))
                    }
                }
            }
        }
    }
}

struct PageView: View {
    let barArr: [Bar]
    let db = Firestore.firestore()
    @EnvironmentObject var cuvm: CurrentUserViewModel
    
    var body: some View {
        TabView {
            ForEach(0..<barArr.count) { i in
                ZStack {
                    Color("Navy")
                    VStack (alignment: .leading, spacing: 10) {
                        let bar: Bar = barArr[i]
                        SystemWebImage(url: bar.imageLinkName, radius: 10)
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
                            NavigationLink(destination: InBarView(bar: bar)
                                            .environmentObject(LikerViewModel())
                                            .environmentObject(cuvm)) {
                                Text("Enter Bar")
                                    .padding(.vertical, 15)
                                    .frame(maxWidth: .infinity)
                                    .font(Font.custom("Avenir Next Bold", size: 12))
                                    .foregroundColor(.white)
                                    .background(Color("Pink"))
                                    .cornerRadius(100)
                            }
                            .simultaneousGesture(TapGesture().onEnded {
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

struct BarPreView_Previews: PreviewProvider {
    @State private static var show = true
    @State static var cuvm = CurrentUserViewModel()
    static var previews: some View {
        BarPreView(barArr: [], index: 0, show: $show)
    }
}
