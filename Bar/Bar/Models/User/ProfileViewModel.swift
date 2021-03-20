//
//  ProfileViewModel.swift
//  Bar
//
//  Created by David Chen on 1/7/21.
//

import Foundation
import FirebaseFirestore
import Firebase

class ProfileViewModel: ObservableObject {
    @Published var images = [UIImage]()
    @Published var imageLinks = [String]()
    @Published var profPic = UIImage()
    @Published var profPicURL = ""
    
    private var db = Firestore.firestore()
    
    func setImageLinks(imageLinks: [String]) {
        self.imageLinks = imageLinks
    }
    
    func setProfPicURL(urlString: String) {
        self.profPicURL = urlString
    }
    
    // Firebase Storage Paths are formatted as: <UserID>/<orderIdx>, unless it's the profile picture: <UserID>/"profPic"
    func getFirebaseStoragePath(isProfPic: Bool, orderIdx: Int) -> String {
        let id = Auth.auth().currentUser?.uid
        var toReturn = ""
        if let id = id {
            toReturn += id + "/"
            if isProfPic {
                toReturn += "profPic"
            } else {
                toReturn += String(orderIdx)
            }
        }
        return toReturn
    }
    
    // writes the specific image upon choosing to Firebase Storage and Firestore in "users" collection
    // (function is ONLY referenced in ImageHandler -> ImagePicker -> imagePickerController())
    // includes image, if it is the profile picture, and order index
    func writeImageToFirebase(image: UIImage, isProfPic: Bool, orderIdx: Int) {
        let storage = Storage.storage()
        var path: String {
            return getFirebaseStoragePath(isProfPic: isProfPic, orderIdx: orderIdx)
        }
        var shouldReplace: Bool {
            return orderIdx < self.imageLinks.count
        }
        let ref = storage.reference().child(path)
        
        ref.putData(image.jpegData(compressionQuality: 0.35)!, metadata: nil) { (_, error) in
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            ref.downloadURL { (url, error) in
                guard let downloadURL = url?.absoluteString else { return }
                
                if isProfPic {
                    self.profPicURL = downloadURL
                    if let id = Auth.auth().currentUser?.uid {
                        self.db.collection("users").document(id).setData([
                            "profURL" : self.profPicURL
                        ], merge: true)
                    }
                } else {
                    // if is one of user's 6 images
                    if shouldReplace {
                        self.imageLinks[orderIdx] = downloadURL
                    } else {
                        self.imageLinks.append(downloadURL)
                    }
                    if let id = Auth.auth().currentUser?.uid {
                        self.db.collection("users").document(id).setData([
                            "imageLinks" : self.imageLinks
                        ], merge: true)
                    }
                }
            }
        }
    }
    
    // removes image from firebase storage
    func removeImageFirebaseStorage(path: String) {
        let storage = Storage.storage()
        storage.reference().child(path).delete { (error) in
            if error != nil { print(error!.localizedDescription) }
        }
    }
    
    // removes image from firebase storage, self.imageLinks, and rewrites user's imageLinks
    func removeImage(groupIndex: Int) {
        removeImageFirebaseStorage(path: getFirebaseStoragePath(isProfPic: false, orderIdx: groupIndex))
        self.imageLinks.remove(at: groupIndex)
        if let id = Auth.auth().currentUser?.uid {
            self.db.collection("users").document(id).setData([
                "imageLinks" : self.imageLinks
            ], merge: true)
        }
    }
}


