

import UIKit
import Firebase
import Firebase
import FirebaseStorage

class FixedSignUpVC: UIViewController,UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var GetStartedLabel: UILabel!
    
    @IBOutlet weak var UserProfile: UIImageView!
    
    @IBOutlet weak var NameField: UITextField!
    
    @IBOutlet weak var SurnameField: UITextField!
    
    @IBOutlet weak var EmailField: UITextField!
    
    @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var DatePicker: UIDatePicker!
    
    
    
    
    
    
    func alertCreator (titleInput:String,messageInput:String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func SignUpButtonClicked(_ sender: Any) {
        Auth.auth().createUser(withEmail: EmailField.text!, password: PasswordField.text!) { [self]  authdata, error in
            if error != nil {
                alertCreator(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                
            }
            
            
            
            
            
        }
        
        
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaFolderRef = storageRef.child("UserProfile")
        
        
        if let imageData = UserProfile.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageRef = mediaFolderRef.child("\(uuid).jpg")
            
            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image to Firebase Storage:", error.localizedDescription)
                    return
                }
                
                imageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL:", error.localizedDescription)
                        return
                    }
                    
                    guard let imageUrl = url?.absoluteString else {
                        print("Download URL is nil")
                        return
                    }
                    
                    let firestoreDataBase = Firestore.firestore()
                    let firestorePost = [
                        "Name": self.NameField.text ?? "",
                        "Surname": self.SurnameField.text ?? "",
                        "Birthdate": self.DatePicker.date,
                        "email": self.EmailField.text ?? "",
                        "profileURL": imageUrl
                    ]
                    guard let currentUserUID = Auth.auth().currentUser?.uid else {
                        print("Error: Current user UID is nil")
                        return
                    }
                    
                    
                    let docRef = firestoreDataBase.collection("User").document(currentUserUID)
                    
                    
                    
                    
                    docRef.setData(firestorePost) { error in
                        if let error = error {
                            print("Error adding document to Firestore:", error.localizedDescription)
                            return
                        }
                        
                        print("Data added successfully to Firestore")
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "toFeed", sender: nil)
                        }
                    }
                }
            }
        } else {
            print("Error: UserProfile.image is nil or invalid")
        }
        
        
        
        
        
        
        
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserProfile.image = UIImage(systemName: "person.crop.circle.fill")
        
        
        let customButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(customButtonTapped))
        customButton.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        self.navigationItem.leftBarButtonItem = customButton
        
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goToPickerController))
        UserProfile.isUserInteractionEnabled = true
        UserProfile.addGestureRecognizer(gestureRecognizer)
        UserProfile.layer.cornerRadius = UserProfile.frame.size.width / 2
        UserProfile.clipsToBounds = true
        PasswordField.isSecureTextEntry = true
        
        
        
    }
    
    @objc func goToPickerController (){
        let PickerController = UIImagePickerController()
        PickerController.delegate = self
        PickerController.sourceType = .photoLibrary
        present(PickerController,animated: true,completion: nil)
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        UserProfile.image = info [.originalImage] as?UIImage
        self.dismiss(animated: true, completion: nil)
    }
    @objc func customButtonTapped() {
        
        performSegue(withIdentifier: "ViewController", sender: nil)
    }
    
    
    
    
}
