
import UIKit
import Firebase
import SDWebImage
import Foundation
import FirebaseStorage
class SettingsVC: UIViewController,UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var ProfilePicture: UIImageView!
    
    @IBOutlet weak var NameLabel: UILabel!
    
    @IBOutlet weak var SurnameLabel: UILabel!
    
    @IBOutlet weak var oldPassword: UITextField!
    
    @IBOutlet weak var newPassword: UITextField!
    
    
    @IBOutlet weak var Click: UIImageView!
    
    @IBAction func ChangeProfile(_ sender: Any) {
        guard let image = ProfilePicture.image else {
                print("No image to upload")
                return
            }
            
            guard let imageData = image.jpegData(compressionQuality: 0.5) else {
                print("Failed to convert image to data")
                return
            }
            
            let storageRef = Storage.storage().reference().child("media").child("\(UUID().uuidString).jpg")
            
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error)")
                    return
                }
                
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("Error getting download URL: \(error)")
                        return
                    }
                    
                    guard let downloadURL = url else {
                        print("Download URL not found")
                        return
                    }
                    
                    let urlString = downloadURL.absoluteString
                    print("Image uploaded successfully. Download URL: \(urlString)")
                    guard let currentUserUID = Auth.auth().currentUser?.uid else {
                            print("No current user")
                            return
                        }
                        
                        let fireStoreDatabase = Firestore.firestore()
                        let docRef = fireStoreDatabase.collection("User").document(currentUserUID)
                        
                        docRef.updateData(["profileURL": urlString]) { error in
                            if let error = error {
                                print("Error updating document: \(error)")
                            } else {
                                print("Document successfully updated")
                            }
                        }
                  
                }
            }
        
        
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (hideKeyboard))
        
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        
        backgroundImageView.addGestureRecognizer(gestureRecognizer)
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
        
        let gestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(goToPickerController))
        ProfilePicture.isUserInteractionEnabled = true
        ProfilePicture.addGestureRecognizer(gestureRecognizer1)
        
        Click.image = UIImage(named: "click")
        
        getUserDocument()
        ProfilePicture.layer.cornerRadius = ProfilePicture.frame.size.width / 2
        ProfilePicture.clipsToBounds = true
        oldPassword.isSecureTextEntry = true
        newPassword.isSecureTextEntry = true
        
        
        
    }
    @objc func hideKeyboard () {
        view.endEditing(true)
    }
    
    
    @IBAction func LogOutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print ("error")
        }
        performSegue(withIdentifier: "LogOutSegue", sender: nil)
        
        
    }
    
    
    
    
    
    func getUserDocument() {
        guard let currentUser = Auth.auth().currentUser else {
            print("No current user")
            return
        }
        
        let fireStoreDatabase = Firestore.firestore()
        
        let docRef = fireStoreDatabase.collection("User").document(currentUser.uid)
        
        docRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
            } else if let document = document, document.exists {
                if let name  = document.get("Name") as? String {
                    self.NameLabel.text = name
                }
                if let surname = document.get("Surname") as? String {
                    self.SurnameLabel.text = surname
                }
                if let imageUrlString = document.get("profileURL") as? String {
                    if let imageUrl = URL(string: imageUrlString) {
                        
                        self.ProfilePicture.sd_setImage(with: imageUrl)
                        
                    }
                    
                    
                    
                }
                
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    
    
    
    
    
    @objc func goToPickerController (){
        let PickerController = UIImagePickerController()
        PickerController.delegate = self
        PickerController.sourceType = .photoLibrary
        present(PickerController,animated: true,completion: nil)
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        ProfilePicture.image = info [.originalImage] as?UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changePasswordClicked(_ sender: Any) {
        let oldPassword = oldPassword.text
        let newPassword = newPassword.text
        
        if let currentUser = Auth.auth().currentUser {
            Auth.auth().signIn(withEmail: currentUser.email!, password: oldPassword!) { (authResult, error) in
                if let error = error {
                    print("Error signing in:", error.localizedDescription)
                    return
                }
                
                currentUser.updatePassword(to: newPassword!) { error in
                    if let error = error {
                        print("Error updating password:", error.localizedDescription)
                        return
                    }
                    
                    print("Password updated successfully")
                }
            }
        } else {
            print("No user is currently signed in")
        }
        
        
    }
    
    
    
    
    
    
    
    
    
    
    
}

