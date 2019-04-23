//
//  Review.swift
//  Snacktacular
//
//  Created by user150978 on 4/22/19.
//  Copyright © 2019 John Gallaugher. All rights reserved.
//

import Foundation
import Firebase

class Review {
    var title: String
    var text: String
    var rating: Int
    var reviewerUserID: String
    var date: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["title": title, "text": text, "rating": rating, "reviewerUserID": reviewerUserID, "date": timeIntervalDate]
    }
    
    init(title: String, text: String, rating: Int, reviewerUserID: String, date: Date, documentID: String) {
        self.title = title
        self.text = text
        self.rating = rating
        self.reviewerUserID = reviewerUserID
        self.date = date
        self.documentID = documentID
    }
    
    convenience init(dictionary: [String: Any]){
        let title = dictionary["title"] as! String? ?? ""
        let text = dictionary["text"] as! String? ?? ""
        let rating = dictionary["rating"] as! Int? ?? 0
        let reviewerUserID = dictionary["reviewerUserID"] as! String
        //let date = dictionary["date"] as! Date? ?? Date()
        let timeIntervalDate = dictionary["date"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        self.init(title: title, text: text, rating: rating, reviewerUserID: reviewerUserID, date: date, documentID: "")
    }
    
    convenience init() {
        let currentUserID = Auth.auth().currentUser?.email ?? "Unknown User"
        self.init(title: "", text: "", rating: 0, reviewerUserID: currentUserID, date: Date(), documentID: "")
    }
    
    func saveData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let dataToSave = self.dictionary
        if self.documentID != "" {
            let ref = db.collection("spots").document(spot.documentID).collection("reviews").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                if error != nil{
                    print("Error: updating document in spot \(spot.documentID)")
                    completed(false)
                } else {
                    print("document updated")
                    spot.updateAverageRating {
                        completed(true)
                    }
                }
            }
        } else{
            var ref: DocumentReference? = nil
            ref = db.collection("spots").document(spot.documentID).collection("reviews").addDocument(data: dataToSave) { error in
                if error != nil{
                    print("Error: creating document in spot \(spot.documentID) for new review documentID")
                    completed(false)
                } else {
                    print("document created")
                    spot.updateAverageRating {
                        completed(true)
                    }
                }
            }
        }
    }
    
    func deleteData(spot: Spot, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        db.collection("spots").document(spot.documentID).collection("reviews").document(documentID).delete() { error in
            if let error = error {
                print("*** ERROR: deleting review document ID \(self.documentID) \(error.localizedDescription)")
                completed(false)
            } else {
                spot.updateAverageRating {
                    completed(true)
                }
            }
        }
    }
}
