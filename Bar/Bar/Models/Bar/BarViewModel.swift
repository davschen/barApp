//
//  BarViewModel.swift
//  Bar
//
//  Created by David Chen on 12/29/20.
//

import Foundation
import FirebaseFirestore
import Firebase

class BarViewModel: ObservableObject {
    @Published var bars = [Bar]()
    @Published var currentBar = EmptyBar().bar
    @Published var featuredBar = "Berkeley Night Lounge"
    @Published var selectedBarForPreView = EmptyBar().bar
    
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        db.collection("bars").addSnapshotListener { (snap, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            guard let data = snap?.documents else { return }
            DispatchQueue.main.async {
                self.bars = data.compactMap { (query) -> Bar? in
                    return try? query.data(as: Bar.self)
                }
            }
        }
    }
    
    func updateCurrentBar(bar: Bar) {
        self.currentBar = bar
    }
    
    func resetCurrentBar() {
        self.currentBar = EmptyBar().bar
    }
     
    func updateBarForPreView(bar: Bar) {
        self.selectedBarForPreView = bar
    }
    
    func getCurrentIndex() -> Int {
        for i in 0..<self.bars.count {
            let bar = self.bars[i]
            if selectedBarForPreView.id == bar.id {
                return i
            }
        }
        return 0
    }
}
