

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SDWebImage
var UserUidArrayCommentVC = [String]()
var CommentArray = [String]()
var NameArrayCommentVC = [String]()
var SurnameArrayCommentVC = [String]()
var EmailArray = [String]()
var profileURLArrayCommentVC = [String]()


class CommentVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    @IBOutlet weak var TableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TableView.delegate = self
        TableView.dataSource = self
        getDataFromFireStore()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCellview
        
        if indexPath.row < CommentArray.count {
            cell.Comment.text = CommentArray[indexPath.row]
        }
        if indexPath.row < profileURLArrayCommentVC.count {
            cell.profileInfo.sd_setImage(with: URL(string: profileURLArrayCommentVC[indexPath.row]))
        }
        if indexPath.row < EmailArray.count {
            cell.UserInfo.text = EmailArray[indexPath.row]
        }
        
        return cell
    }
    
    func getDataFromFireStore() {
        let firestore = Firestore.firestore()
        let docRef = firestore.collection("Posts").document(selectedId)
        
        
        UserUidArrayCommentVC.removeAll(keepingCapacity: false)
        CommentArray.removeAll(keepingCapacity: false)
        EmailArray.removeAll(keepingCapacity: false)
        profileURLArrayCommentVC.removeAll(keepingCapacity: false)
        
        docRef.addSnapshotListener { documentSnapshot, error in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                return
            }
            
            guard let document = documentSnapshot else {
                print("Document does not exist")
                return
            }
            
            if let postedByUUID = document.get("CommentUserUUIDArray") as? [String] {
                UserUidArrayCommentVC.append(contentsOf: postedByUUID)
            }
            
            if let commentArray = document.get("CommentArray") as? [String] {
                CommentArray.append(contentsOf: commentArray)
            }
            
            if let emailcommentArray = document.get("EmailCommentArray") as? [String] {
                EmailArray.append(contentsOf: emailcommentArray)
            }
            
            
            self.getUserDataCommentVC()
        }
    }
    
    func getUserDataCommentVC() {
        let firestore = Firestore.firestore()
        let dispatchGroup = DispatchGroup()
        
        for userId in UserUidArrayCommentVC {
            dispatchGroup.enter()
            
            let userDocRef = firestore.collection("User").document(userId)
            userDocRef.getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    
                    if let profileURL = data?["profileURL"] as? String {
                        profileURLArrayCommentVC.append(profileURL)
                    }
                } else {
                    print("Document does not exist")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            
            let count = min(CommentArray.count, EmailArray.count, profileURLArrayCommentVC.count)
            CommentArray = Array(CommentArray.prefix(count))
            EmailArray = Array(EmailArray.prefix(count))
            profileURLArrayCommentVC = Array(profileURLArrayCommentVC.prefix(count))
            
            self.TableView.reloadData()
        }
    }
}














