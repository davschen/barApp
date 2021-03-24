//
//  ContentView.swift
//  Bar
//
//  Created by David Chen on 1/2/21.
//

import Foundation
import SwiftUI

struct ContentView: View {
    @State var isLoggedIn = UserDefaults.standard.value(forKey: "isLoggedIn") as? Bool ?? false
    @ObservedObject var barVM = BarViewModel()
    @ObservedObject var chatVM = ChatViewModel()
    @ObservedObject var currentUserVM = CurrentUserViewModel()
    @ObservedObject var likerVM = LikerViewModel()
    @ObservedObject var profileVM = ProfileViewModel()
    @ObservedObject var userVM = UserViewModel()
    
    var body: some View {
        ZStack {
            if !isLoggedIn {
                NavigationView {
                    LoginView()
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .accentColor(.white)
                .preferredColorScheme(.dark)
            } else {
                BarView()
                    .environmentObject(self.barVM)
                    .environmentObject(self.chatVM)
                    .environmentObject(self.currentUserVM)
                    .environmentObject(self.likerVM)
                    .environmentObject(self.profileVM)
                    .environmentObject(self.userVM)
            }
        }.onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("LogInStatusChange"), object: nil, queue: .main) { (_) in
                let isLoggedIn = UserDefaults.standard.value(forKey: "isLoggedIn") as? Bool ?? false
                self.isLoggedIn = isLoggedIn
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
