//
//  LogInVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAuth
import FBSDKLoginKit

class LogInVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBSDKLoginButtonDelegate{

    @IBOutlet weak var userProflieView: CircleView!
    @IBOutlet weak var userNameField: RoundTextfield!
    @IBOutlet weak var emailField: RoundTextfield!
    @IBOutlet weak var passwordField: RoundTextfield!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let fbLoginButton = FBSDKLoginButton()
    
    var imagePicker: UIImagePickerController!
    
    var userProfileURL = ""
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fbLoginButton.frame = CGRect(x:0 ,y:UIScreen.main.bounds.height - 50,width:UIScreen.main.bounds.width,height:50)
        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        fbLoginButton.delegate = self
        view.addSubview(fbLoginButton)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        userProflieView.addGestureRecognizer(setGestureRecognizer())
    }

    @IBAction func logInPressed(_ sender: Any) {

        guard isInternetAvailable() else {
            errorAlert(title: "Network connection error", message: "Make sure you have a network connection and try again")
            return
        }

        
        
        if let email = emailField.text, let pwd = passwordField.text, let usrName = userNameField.text,
            (email.characters.count > 0 && pwd.characters.count > 0){
            
            AuthService.instance.login(email: email, password: pwd, username: usrName, onComplete: { (errMsg, data) in
                
                guard errMsg == nil else{
                    self.errorAlert(title: "Error Authenticating", message: errMsg!)
                    return
                }
                
                if self.imageSelected{
                    if let userImg = self.userProflieView.image{
                        DataService.instance.addProfilePicToStorage(image: userImg)
                    }
                
                }else{
                    self.userProfileURL = DEFAULT_PROFILE_PIC_URL
                    let ref = DataService.instance.refrenceToCurrentUser()
                    ref.child("profile").child("userImageURL").setValue(self.userProfileURL)
                
                }
                //self.dismiss(animated: true, completion: nil)
                self.performSegue(withIdentifier: "goToFeed", sender: nil)
            })
        
        } else{
            errorAlert(title: "Email and Password Required", message: "You must enter both an email and a password")
        }
       
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        print("User logged in")
        fbLoginButton.isHidden = true
        
        if error != nil{
        
            fbLoginButton.isHidden = false
       
        }else if result.isCancelled{
        
            fbLoginButton.isHidden = false
        }
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        activityIndicator.startAnimating()
        
        FIRAuth.auth()?.signIn(with: credential){(user, error) in
            
            if let user = FIRAuth.auth()?.currentUser{
            let uid = user.uid
            var name = user.displayName
            let email = user.email

                let delimiter = " "
                if (name?.contains(delimiter))!{

                    var token = name?.components(separatedBy: delimiter)
                    name = "\(token![0]) " + String(token![1].characters.prefix(1))

                }
    
            DataService.instance.saveFirebaseUser(uid: uid, email: email!, username: name!)
            
            DataService.instance.saveFacebookProfilePicture(uid: uid)

            
            print("User logged in to firebase using facebook")
            }
        
            self.activityIndicator.stopAnimating()
            self.performSegue(withIdentifier: "goToFeed", sender: nil)
        }
      
        
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(showPhotoActionSheet))
        tapGestureRecognizer.numberOfTapsRequired = 1
        return tapGestureRecognizer
    }
    
    func showPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            } else { print("Sorry cant take photo") }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action:UIAlertAction) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            userProflieView.image = image
            imageSelected = true
        }
    }
    
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
        
        super.touchesBegan(touches, with: event)
        
    }
}

