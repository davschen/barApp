//
//  EditPhotosView.swift
//  Bar
//
//  Created by David Chen on 1/23/21.
//

import Foundation
import SwiftUI

struct EditPhotosView: View {
    @EnvironmentObject var profileVM: ProfileViewModel
    @EnvironmentObject var currentUserVM: CurrentUserViewModel
    
    var body: some View {
        ZStack (alignment: .top) {
            BGColor()
            ScrollView (.vertical) {
                VStack (alignment: .leading) {
                    SystemTextTracking(text: "MY PHOTOS", fontstyle: .smallDemiBold)
                        .padding(.vertical, 3).padding(.horizontal, 5)
                        .background(Color("Pink"))
                        .cornerRadius(3.0)
                    ImagePickerGridView(profileViewModel: self.profileVM)
                    SystemText(text: "You must have at least two photos", fontstyle: .regular)
                }
                .padding()
            }
        }
        .navigationBarTitle("Edit Your Photos", displayMode: .inline)
        .animation(.easeInOut)
    }
}
