

import UIKit
import Firebase
import MapKit
import FirebaseAuth



class FeedCell: UITableViewCell,MKMapViewDelegate, CLLocationManagerDelegate,UIPageViewControllerDelegate  {
    
    
    
    @IBOutlet weak var commentField: UITextField!
    
    @IBOutlet weak var proiflepic: UIImageView!
    
    
    
    
    
    
    @IBOutlet weak var emailLabel: UILabel!
    
    
    @IBOutlet weak var LocationLabel: UILabel!
    
    @IBOutlet weak var imageViewInCell: UIImageView!
    
    @IBOutlet weak var likeCounter: UILabel!
    
    
    
    @IBOutlet weak var commentLabel: UILabel!
    
    @IBOutlet weak var IdLabel: UILabel!
    
    @IBOutlet weak var likeImage: UIButton!
    
    var longitudeforMaps = Double()
    var latitudeforMaps = Double()
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        proiflepic.layer.cornerRadius = proiflepic.frame.size.width / 2
        proiflepic.clipsToBounds = true
        
        
        
        
        
        
        LocationLabel.isUserInteractionEnabled = true
        let tapgesturerecognizer = UITapGestureRecognizer(target: self, action: #selector(LocationLabelClicked))
        LocationLabel.addGestureRecognizer(tapgesturerecognizer)
        
        
        
        
        
        
    }
    
    
    
    
    
    
    
    @objc func LocationLabelClicked (sender:UITapGestureRecognizer) {
        
        
        let requestLocation = CLLocation(latitude: latitudeforMaps, longitude: longitudeforMaps)
        
        
        CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
            
            
            if let placemark = placemarks {
                if placemark.count > 0 {
                    
                    let newPlacemark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlacemark)
                    
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions: launchOptions)
                    
                }
            }
        }
        
        
        
        
        
    }
    
    
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        
        
        
        var UserUUIDArray  = [String]()
        
        
        
        let fireStoreDatabase = Firestore.firestore()
        
        
        let docRef = fireStoreDatabase.collection("Posts").document(IdLabel.text!)
        
        
        docRef.getDocument { [self] (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
            } else if let document = document, document.exists {
                
                if let userUUIDArrays = document.data()?["UserUUIDArray"] as? [String] {
                    
                    UserUUIDArray = userUUIDArrays
                    
                    
                    
                    
                }
                if let snapshotlongitude = document.data()?["longitude"] as? Double {
                    longitudeforMaps=snapshotlongitude
                    
                }
                if let snapshotlatitude = document.data()?["latitude"] as? Double {
                    latitudeforMaps=snapshotlatitude
                    
                }
                
                
                
                else {
                    print("UserUUIDArray field is missing or not of type [String]")
                }
            } else {
                print("Document does not exist")
            }
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            if let currentuserID = Auth.auth().currentUser?.uid
                
            {
                
                var x  =  UserUUIDArray.contains(currentuserID)
                
                
                if (x == true) {
                    
                    
                    
                    likeImage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                    
                    
                    
                    
                }
                else {
                    
                    
                    
                    self.likeImage.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                    
                    
                    
                    
                    
                    
                    
                }
                
            }
            
        }
        
        
        
        
        
        
    }
    
    
    @IBAction func likeButtonCliked(_ sender: Any) {
        var UserUUIDArray  = [String]()
        
        
        
        let fireStoreDatabase = Firestore.firestore()
        
        
        let docRef = fireStoreDatabase.collection("Posts").document(IdLabel.text!)
        
        
        docRef.getDocument { [self] (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
            } else if let document = document, document.exists {
                
                if let userUUIDArrays = document.data()?["UserUUIDArray"] as? [String] {
                    
                    UserUUIDArray = userUUIDArrays
                    
                    
                    
                    
                }
                
                else {
                    print("UserUUIDArray field is missing or not of type [String]")
                }
            } else {
                print("Document does not exist")
            }
            
            
            
            
            
            
            
            
            
            
            
            
            
            if let currentuserID = Auth.auth().currentUser?.uid
                
            {
                
                var x  =  UserUUIDArray.contains(currentuserID)
                
                if (x == true) {
                    
                    
                    
                    if let likeCount = Int(likeCounter.text!) {
                        let likeStore = ["likes": likeCount - 1] as [String: Any]
                        fireStoreDatabase.collection("Posts").document(IdLabel.text!).setData(likeStore, merge: true)
                        likeImage.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
                    }
                    
                    if let index = UserUUIDArray.firstIndex(of: currentuserID) {
                        UserUUIDArray.remove(at: index)
                    }
                    let UserId = ["UserUUIDArray": UserUUIDArray] as [String: [String]]
                    
                    updatePostUserUUIDArray(postID: IdLabel.text!, updatedUserUUIDArray: UserUUIDArray)
                    
                    
                    
                }
                else {
                    
                    
                    if let likeCount = Int(likeCounter.text!) {
                        let likeStore = ["likes": likeCount + 1] as [String: Any]
                        fireStoreDatabase.collection("Posts").document(IdLabel.text!).setData(likeStore, merge: true)
                        self.likeImage.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
                    }
                    
                    UserUUIDArray.append(currentuserID)
                    
                    self.updatePostUserUUIDArray(postID: IdLabel.text!, updatedUserUUIDArray: UserUUIDArray)
                    
                    
                }
                
            }
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    func updatePostUserUUIDArray(postID: String, updatedUserUUIDArray: [String]) {
        let firestore = Firestore.firestore()
        let postRef = firestore.collection("Posts").document(postID)
        
        
        postRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                var currentUserUUIDArray = document.data()?["UserUUIDArray"] as? [String] ?? []
                
                
                currentUserUUIDArray = updatedUserUUIDArray
                
                
                postRef.setData(["UserUUIDArray": currentUserUUIDArray], merge: true) { error in
                    if let error = error {
                        print("Error updating UserUUIDArray: \(error.localizedDescription)")
                    } else {
                        print("UserUUIDArray updated successfully for post with ID \(postID)")
                    }
                }
            } else {
                print("Post document with ID \(postID) does not exist")
            }
        }
    }
    
    
    @IBAction func CommentButtonClicked(_ sender: Any) {
        //       // UseArray.removeAll(keepingCapacity: false)
        UserUidArrayCommentVC.removeAll(keepingCapacity: false)
        CommentArray.removeAll(keepingCapacity: false)
        
        let fireStoreDatabase = Firestore.firestore()
        let docRef = fireStoreDatabase.collection("Posts").document(IdLabel.text!)
        
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                var existingData = document.data() ?? [:]
                
                
                var commentArray = existingData["CommentArray"] as? [String] ?? []
                
                
                var userUUIDArray = existingData["CommentUserUUIDArray"] as? [String] ?? []
                var EmailArray = existingData["EmailCommentArray"] as? [String] ?? []
                
                guard let newComment = self.commentField.text, !newComment.isEmpty else {
                    print("Comment field is empty")
                    return
                }
                
                
                
                commentArray.append(newComment)
                
                
                
                guard let currentUserUUID = Auth.auth().currentUser?.uid else {
                    print("Current user's UUID not found")
                    return
                }
                guard let currentEmail = Auth.auth().currentUser?.email else {
                    print("not found")
                    return
                }
                EmailArray.append(currentEmail)
                
                
                userUUIDArray.append(currentUserUUID)
                
                
                
                
                
                existingData["CommentArray"] = commentArray
                existingData["CommentUserUUIDArray"] = userUUIDArray
                existingData ["EmailCommentArray"] = EmailArray
                docRef.updateData(existingData) { error in
                    if let error = error {
                        print("Error updating document in Firestore:", error.localizedDescription)
                    } else {
                        print("Document updated successfully in Firestore")
                    }
                }
            } else {
                print("Document does not exist")
            }
            self.commentField.text = ""
            
        }
        
        
        
    }
    
    
    
    
    
    
    
    
}

