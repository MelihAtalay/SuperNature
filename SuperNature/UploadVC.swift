

import UIKit
import Firebase
import FirebaseStorage
import CoreData





class UploadVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var DatePicker: UIDatePicker!
    
    @IBOutlet weak var CommentText: UITextField!
    var longitudeArray = [Double] ()
    var latitudeArray = [Double] ()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (hideKeyboard))
        let gestureclicked = UITapGestureRecognizer(target: self, action: #selector(PickingClicked))
        imageView.addGestureRecognizer(gestureclicked)
        
        
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        
        
        
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.addGestureRecognizer(gestureRecognizer)
        self.view.addSubview(backgroundImageView)
        self.view.sendSubviewToBack(backgroundImageView)
        
        
    }
    @objc func hideKeyboard () {
        view.endEditing(true)
    }
    
    
    
    
    
    
    @objc func PickingClicked (){
        
        let PickerController = UIImagePickerController()
        PickerController.delegate = self
        PickerController.sourceType = .photoLibrary
        present(PickerController,animated: true,completion: nil)
        
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as?UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func SpotLocationButtonClicked(_ sender: Any) {
        performSegue(withIdentifier: "MapViewSegue", sender: nil)
        
        
        
        
    }
    
    
    
    
    
    
    
    
    @IBAction func ShareClicked(_ sender: Any) {
        getCoreData()
        
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaFolderRef = storageRef.child("media")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest <NSFetchRequestResult> (entityName: "Places")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if var latitudeCore = result.value(forKey: "latitude") as? Double {
                        latitudeArray.append(latitudeCore)
                        
                        
                        
                    }
                    if var longitudeCore = result.value(forKey: "longitude") as? Double {
                        longitudeArray.append(longitudeCore)
                        
                        
                    }
                    
                    
                }
                
                
            }
        }
        catch {
            
        }
        
        if let data = imageView.image?.jpegData(compressionQuality: 0.5) {
            let uuid = UUID().uuidString
            let imageRef = mediaFolderRef.child("\(uuid).jpg")
            imageRef.putData(data) { metadata, error in
                if error != nil {
                    self.AlertCreater(title: "Error occoured", message: error?.localizedDescription ?? "Unknown Error")
                    
                }
                else {
                    imageRef.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            let firestoreDataBase = Firestore.firestore()
                            var firestoreRef : DocumentReference? = nil
                            let firestorePost = ["imageUrl":imageUrl!,"postedBy":Auth.auth().currentUser!.email!,"postComment":self.CommentText.text!,"date":self.DatePicker.date,"postdate":FieldValue.serverTimestamp(),"likes":0,"UserUUIDArray": [UUID](),"longitude":self.longitudeArray.last,"latitude":self.latitudeArray.last,"CommentArray": [String](),"EmailCommentArray": [String](),"PosterUID":Auth.auth().currentUser?.uid] as [String:Any]
                            firestoreRef = firestoreDataBase.collection("Posts").addDocument(data: firestorePost, completion: { a in
                                if a != nil {
                                    self.AlertCreater(title: "error", message: a?.localizedDescription ?? "Error")
                                }
                                else {
                                    self.imageView.image = UIImage(systemName: "photo.on.rectangle")
                                    self.CommentText.text = ""
                                    self.tabBarController?.selectedIndex=0
                                    
                                    
                                }
                                
                                
                                
                            })
                            
                            
                            
                        }
                    }
                    
                    
                }
            }
            
            
        }
        
        
        
        
        
        
        
        
        
    }
    
    
    func AlertCreater (title:String,message:String ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let OkButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(OkButton)
        self.present(alert, animated: true, completion: nil)
        
        
        
        
        
    }
    func getCoreData () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest <NSFetchRequestResult> (entityName: "Places")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if var latitudeCore = result.value(forKey: "latitude") as? Double {
                        
                        latitudeArray.append(latitudeCore)
                        
                        
                        
                        
                    }
                    if var longitudeCore = result.value(forKey: "longitude") as? Double {
                        
                        longitudeArray.append(longitudeCore)
                        
                    }
                    
                    
                }
                
                
            }
        }
        catch {
            
        }
        
    }
    
    
    
    
    
    
}

