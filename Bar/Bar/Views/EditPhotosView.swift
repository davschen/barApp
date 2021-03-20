//
//  EditPhotosView.swift
//  Bar
//
//  Created by David Chen on 1/23/21.
//

import Foundation
import SwiftUI

struct EditPhotosView: View {
    @EnvironmentObject var pvm: ProfileViewModel
    @EnvironmentObject var cuvm: CurrentUserViewModel
    
    var body: some View {
        ZStack (alignment: .top) {
            BGColor()
            VStack (alignment: .leading) {
                SystemTextTracking(text: "MY PHOTOS", fontstyle: .smallDemiBold)
                    .padding(.vertical, 3).padding(.horizontal, 5)
                    .background(Color("Pink"))
                    .cornerRadius(3.0)
                ImagePickerGridView(profileViewModel: self.pvm)
                SystemText(text: "You must have at least two photos", fontstyle: .regular)
            }
            .padding()
        }
        .navigationBarTitle("Edit Your Photos", displayMode: .inline)
        .animation(.easeInOut)
    }
}
