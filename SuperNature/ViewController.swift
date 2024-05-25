//
//  ViewController.swift
//  Super_Nature
//
//  Created by Melih Atalay on 27.02.2024.
//

import UIKit
import Firebase
import FirebaseAuth
import Foundation



class ViewController: UIViewController {
    

    
    @IBOutlet weak var EmailField: UITextField!
    
    @IBOutlet weak var PasswordField: UITextField!
    
    @IBOutlet weak var MainImage: UIImageView!
    
    @IBOutlet weak var MainImage2: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
       
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector (hideKeyboard))
       
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
                
                
              
        backgroundImageView.isUserInteractionEnabled = true
                backgroundImageView.addGestureRecognizer(gestureRecognizer)
               
            PasswordField.isSecureTextEntry = true
       
    }
    
    
    @objc func hideKeyboard () {
        view.endEditing(true)
    }
    
 
    
    
    
    @IBAction func SignUpClicked(_ sender: Any) {
        performSegue(withIdentifier: "SignUpClicked", sender: nil)
        
        

        
    }
    
    
    @IBAction func SignInClicked(_ sender: Any) {
        Auth.auth().signIn(withEmail: EmailField.text!, password: PasswordField.text!) { [self]  authdata, error in
            if error != nil {
                alertCreator(titleInput: "error", messageInput: error?.localizedDescription ?? "error")
                
            }
            else {
                performSegue(withIdentifier: "toFeedVC", sender: nil)
            }
            
            
            
        }
      
        
    }
    
    
    func alertCreator (titleInput:String,messageInput:String) {
        let alert = UIAlertController(title: titleInput, message: messageInput, preferredStyle: UIAlertController.Style.alert)
        let okButton = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
  
    
    
    
    
    
}


