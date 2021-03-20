//
//  BarViewModel.swift
//  Bar
//
//  Created by David Chen on 12/29/20.
//

import Foundation
import FirebaseFirestore

class BarViewModel: ObservableObject {
    @Published var bars = [Bar]()
    
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        db.collection("bars").addSnapshotListener { (querySnapshot, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let barData = querySnapshot?.documents else { return }
            self.bars = barData.compactMap { (query) -> Bar? in
                return try? query.data(as: Bar.self)
            }
        }
    }
}
