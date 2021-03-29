//
//  ImagePickerView.swift
//  Bar
//
//  Created by David Chen on 3/24/21.
//

import Foundation
import SwiftUI

struct ImagePickerGridView: View {
    @State var profileViewModel: ProfileViewModel
    var body: some View {
        GridStack(rows: 2, columns: 3) { row, col in
            ImagePickerView(profileVM: self.profileViewModel, groupIndex: row * 3 + col)
        }
    }
}

struct ImagePickerView: View {
    @State private var showPhotoLibrary = false
    @State private var showCropImageView = false
    @State private var showImageEditPreview = false
    @State private var image = UIImage()
    @ObservedObject var profileVM: ProfileViewModel
    @State var groupIndex: Int
    @State var invalidAttempts = 0
    var isBlank: Bool {
        return self.groupIndex >= self.profileVM.imageLinks.count
    }
    
    /*
     The only documentation in this project
     When a user selects an image,
        - it is immediately uploaded to Firebase Storage under the filePath <UserID>/<groupIndex>
        - on completion, it will upload itself to the user's firestore user instance under "imageLinks" -> [String]
     When a user deletes an image,
        - it is deleted from Firebase Storage, and from the user's firebase instance
     This ImagePickerView is reused in ProfileView.swift, under the "About" tab
    */
    
    var body: some View {
        let orderIdx = isBlank ? self.profileVM.imageLinks.count : self.groupIndex
        
        ZStack {
            if !isBlank {
                BarWebImage(url: self.profileVM.imageLinks[self.groupIndex], radius: 0)
                    .animationsDisabled()
            } else {
                Image(systemName: "person")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.white)
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    // + or x button
                    Image(systemName: "plus")
                        .frame(width: 10, height: 10)
                        .rotationEffect(.degrees(self.isBlank ? 0 : 45))
                        .padding(10)
                        .foregroundColor(Color("Pink"))
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black, radius: 10, y: 10)
                        .animation(.easeInOut)
                        .padding(5)
                        .simultaneousGesture(TapGesture().onEnded {
                            if isBlank {
                                self.showPhotoLibrary = true
                            } else if !isBlank && profileVM.imageLinks.count > 2 {
                                profileVM.removeImage(groupIndex: groupIndex)
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                            }
                        })
                }
            }
        }
        .frame(height: 150)
        .cornerRadius(5)
        .background(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
        .background(Color("Neutral"))
        .padding(2)
        .onTapGesture {
            self.showPhotoLibrary = true
        }
        .sheet(isPresented: $showCropImageView) {
            ImageCroppingView(isProfPic: false, orderIdx: orderIdx, shown: $showCropImageView, image: $image, croppedImage: $image)
                .environmentObject(self.profileVM)
        }
        NavigationLink(destination: ImagePicker(selectedImage: $image, showCropImageView: $showCropImageView, orderIdx: orderIdx, viewModel: self.profileVM, isProfPic: false, sourceType: .photoLibrary), isActive: $showPhotoLibrary, label: {
            
        }).hidden()
    }
}

struct ProfilePictureView: View {
    @ObservedObject var profileVM: ProfileViewModel
    @State var showProfPicker = false
    @State var showCropImageView = false
    @State var image = UIImage()
    
    var isBlank: Bool {
        return self.profileVM.profPicURL != ""
    }
    
    var body: some View {
        ZStack {
            ZStack {
                if !isBlank {
                    Image("BlankProfPic")
                        .resizable()
                } else {
                    BarWebImage(url: self.profileVM.profPicURL, radius: 0)
                        .animationsDisabled()
                }
            }
            .clipShape(Circle())
            .background(Circle().stroke(Color("Pink"), lineWidth: 20))
            .padding()
            .onTapGesture {
                self.showProfPicker = true
            }
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        self.showProfPicker = true
                    }, label: {
                        Image(systemName: isBlank ? "pencil" : "plus")
                            .frame(width: 20, height: 20)
                            .padding(5)
                            .foregroundColor(.white)
                            .background(Color("Light Muted"))
                            .clipShape(Circle())
                    })
                }
            }
            .offset(x: -10, y: -10)
            .shadow(radius: 10)
        }
        .sheet(isPresented: $showCropImageView, content: {
            ImageCroppingView(isProfPic: true, orderIdx: 0, shown: $showCropImageView, image: $image, croppedImage: $image)
                .environmentObject(self.profileVM)
        })
        .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.width * 0.4)
        NavigationLink(destination: ImagePicker(selectedImage: $image, showCropImageView: $showCropImageView, orderIdx: 0, viewModel: self.profileVM, isProfPic: true, sourceType: .photoLibrary), isActive: $showProfPicker, label: {
            
        }).hidden()
    }
}
