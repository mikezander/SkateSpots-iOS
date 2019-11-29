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
import AVFoundation
import SVProgressHUD


class LogInVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, FBSDKLoginButtonDelegate{
    
    @IBOutlet weak var userProflieView: CircleView!
    @IBOutlet weak var userNameField: RoundTextfield!
    @IBOutlet weak var emailField: RoundTextfield!
    @IBOutlet weak var passwordField: RoundTextfield!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var logInButton: RoundedButton!
    @IBOutlet weak var logInLabel: UILabel!
    @IBOutlet weak var logInSwitch: UIButton!
    @IBOutlet weak var eulaStackView: UIStackView!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    
    let fbLoginButton = FBSDKLoginButton()
    
    var imagePicker: UIImagePickerController!
    
    var userProfileURL = ""
    var imageSelected = false
    var hasAgreedToTerms = false
 
    var player: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        let bottomSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
        fbLoginButton.frame = CGRect(x: 0, y: view.frame.height - 50 - bottomSafeArea , width:UIScreen.main.bounds.width,height: 50)
        fbLoginButton.readPermissions = ["public_profile","email"] // , "user_friends"
        view.backgroundColor = .black
        fbLoginButton.delegate = self
        
        view.addSubview(fbLoginButton)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        userProflieView.addGestureRecognizer(setGestureRecognizer())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        

        if UIScreen.main.bounds.height <= 568.0{
            subscribeToKeyboardNotifications()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        if defaults.bool(forKey: agreementKey) == false{
//            
//            performSegue(withIdentifier: "Agreement", sender: nil)
//        }

    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeToKeyboardNotifications()
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let vc = segue.destination as? UITabBarController {
//            if #available(iOS 13.0, *) {
//                vc.isModalInPresentation = true
//            } else {
//                // Fallback on earlier versions
//            }
//        }
//    }
//
    @IBAction func logInPressed(_ sender: Any) {
        logInButton.isUserInteractionEnabled = false
       
        guard hasConnected else {
            errorAlert(title: "Network Connection Error", message: "Make sure you connected and try again")
            logInButton.isUserInteractionEnabled = true
            return
        }

        if logInButton.title(for: .normal) == "LOG IN" {
            if let email = emailField.text, let pwd = passwordField.text,(email.count > 0 && pwd.count > 0){
                
                activityIndicator.startAnimating()
                AuthService.instance.logInExisting(email: email, password: pwd, onComplete: {(errMsg, data) in
                    
                    guard errMsg == nil else {
                        DispatchQueue.main.async { self.activityIndicator.stopAnimating() }
                        self.errorAlert(title: "Error Authenticating", message: errMsg!)
                        self.logInButton.isUserInteractionEnabled = true
                        self.activityIndicator.stopAnimating()
                        return
                    }
                    
                    //self.playSound()
                    DispatchQueue.main.async { self.activityIndicator.stopAnimating(); self.logInButton.isUserInteractionEnabled = true }
                    self.performSegue(withIdentifier: "goToFeed", sender: nil)
                    
                })
                
            } else {
                DispatchQueue.main.async { self.activityIndicator.stopAnimating(); self.logInButton.isUserInteractionEnabled = true }
                errorAlert(title: "Email and Password Required", message: "You must enter both an email and a password")
            }
            
        } else {
            
            Auth.auth().fetchProviders(forEmail: emailField.text!, completion: {
                (providers, error) in
                if let error = error {
                    SVProgressHUD.showError(withStatus: "\(error.localizedDescription)")
                    SVProgressHUD.dismiss(withDelay: 2.0)
                    self.logInButton.isUserInteractionEnabled = true
                    return
                } else if let _ = providers {
                    SVProgressHUD.showError(withStatus: "It looks like that email address is already in use. Log in or reset your password below if you've forgotten it.")
                    SVProgressHUD.dismiss(withDelay: 2.7)
                    self.logInButton.isUserInteractionEnabled = true
                    return
                }
                
                if let email = self.emailField.text, let pwd = self.passwordField.text, var usrName = self.userNameField.text, (email.count > 0 && pwd.count > 0) {

                    if usrName == "" || usrName == " " {
                        usrName = "user_\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))\(Int.random(in: 0...9))"
                    }

                    self.activityIndicator.startAnimating()

                    AuthService.instance.login(email: email, password: pwd, username: usrName, onComplete: { (errMsg, data) in

                        guard errMsg == nil else {
                            DispatchQueue.main.async { self.activityIndicator.stopAnimating(); self.logInButton.isUserInteractionEnabled = true }
                            self.errorAlert(title: "Error Authenticating", message: errMsg!)
                            return
                        }
                        
                        if self.imageSelected{
                            if let userImg = self.userProflieView.image {
                                DataService.instance.addProfilePicToStorage(image: userImg)
                            }
                        } else {
                            self.userProfileURL = DEFAULT_NEW//DEFAULT_PROFILE_PIC_URL
                            let ref = DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid)
                            ref.child("profile").child("userImageURL").setValue(self.userProfileURL)

                        }

                        DispatchQueue.main.async { self.activityIndicator.stopAnimating(); self.logInButton.isUserInteractionEnabled = true }
                        self.performSegue(withIdentifier: "goToFeed", sender: nil)
                    })

                } else{
                    DispatchQueue.main.async { self.activityIndicator.stopAnimating(); self.logInButton.isUserInteractionEnabled = true }
                    self.errorAlert(title: "Email and Password Required", message: "You must enter both an email and a password")
                }
            })

        }
        
    }

    //** FB Log In Button **
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        
        loginButton.publishPermissions = ["email, public_profile"]

        fbLoginButton.isHidden = true
        
        if result.isCancelled{
            
            fbLoginButton.isHidden = false
            
        } else {
            
            let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            
            activityIndicator.startAnimating()
            
            Auth.auth().signIn(with: credential){(user, error) in

                if let user = Auth.auth().currentUser{
                    
                    let uid = user.uid
                    var name = user.displayName
                    let email = user.email
                    
                    let delimiter = " "
                    if (name?.contains(delimiter))!{
                        
                        var token = name?.components(separatedBy: delimiter)
                        name = "\(token![0]) " + String(token![1].prefix(1))
                    }
                    
                    let userRef = DataService.instance.REF_USERS.child(user.uid)
                    userRef.observeSingleEvent(of: .value, with: {snapshot in
                        
                        if (snapshot.value is NSNull) {
                            print("fb user hasnt logged in before") //didnt find it, ok to proceed
                            
                            DataService.instance.saveFirebaseUser(uid: uid, email: email!, username: name!)
                            DataService.instance.saveFacebookProfilePicture(uid: uid)
                            
                        } else {
                            print("fb user loggen in before")//found it, stop!
                        }
                    })

                }
                self.activityIndicator.stopAnimating()
                self.performSegue(withIdentifier: "goToFeed", sender: nil)
            }
            
        }
        
    }
    
    @IBAction func logInExistingPressed(_ sender: Any) {
        
        if logInButton.title(for: .normal) == "SIGN UP" {
            userProflieView.alpha = 0.3
            userProflieView.isUserInteractionEnabled = false
            userNameField.alpha = 0.3
            userNameField.isUserInteractionEnabled = false
            
            logInButton.setTitle("LOG IN", for: .normal)
            logInSwitch.setTitle("Sign Up", for: .normal)
            forgotPasswordLabel.isHidden = false
            eulaStackView.isHidden = true
            logInLabel.text = "Don't have an account?"
            
        } else if logInButton.title(for: .normal) == "LOG IN" {
            
            userProflieView.alpha = 1
            userProflieView.isUserInteractionEnabled = true
            userNameField.alpha = 1
            userNameField.isUserInteractionEnabled = true
            
            logInButton.setTitle("SIGN UP", for: .normal)
            logInSwitch.setTitle("Log In", for: .normal)
            forgotPasswordLabel.isHidden = true
            eulaStackView.isHidden = false
            logInLabel.text = "Existing account?"
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
    
    @objc func showPhotoActionSheet(){
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
        
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        guard let selectedImage = info[.editedImage] as? UIImage else { return }
        userProflieView.image = selectedImage
        imageSelected = true
    }
    
   // func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {}
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
        
        super.touchesBegan(touches, with: event)
        
    }
    
    //shifts the view up from bottom text field to be visible
    @objc func keyboardWillShow(notification: NSNotification){
        if passwordField.isFirstResponder{
            view.frame.origin.y = -(getKeyboardHeight(notification: notification) / 2)
        }
    }
    
    //shifts view down once done editing bottom text field
    @objc func keyboardWillHide(notification: NSNotification){
        
        if passwordField.isFirstResponder{
            view.frame.origin.y = 0
        }
    }
    
    //helper function for keyboardWillShow
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "ollie", withExtension: "wav") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            /* iOS 10 and earlier require the following line:
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */

            guard let player = player else { return }

            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
}

