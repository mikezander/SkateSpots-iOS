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

class LogInVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var userProflieView: CircleView!
    @IBOutlet weak var userNameField: RoundTextfield!
    @IBOutlet weak var emailField: RoundTextfield!
    @IBOutlet weak var passwordField: RoundTextfield!
    
    var imagePicker: UIImagePickerController!
    
    var userProfileURL = ""
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        userProflieView.addGestureRecognizer(setGestureRecognizer())
    }

    @IBAction func logInPressed(_ sender: Any) {

        
        if let email = emailField.text, let pwd = passwordField.text, let usrName = userNameField.text,
            (email.characters.count > 0 && pwd.characters.count > 0){
            
            AuthService.instance.login(email: email, password: pwd, username: usrName, onComplete: { (errMsg, data) in
                
                guard errMsg == nil else{
                    self.errorAlert(title: "Error Authenticating", message: errMsg!)
                    return
                }
                
                if self.imageSelected{
                    if let userImg = self.userProflieView.image{
                        self.addPhotoToStorage(image: userImg)
                       
                    }
                }
                self.dismiss(animated: true, completion: nil)
            })
        
        } else{
            errorAlert(title: "Email and Password Required", message: "You must enter both an email and a password")
        }
       
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
    
    func addPhotoToStorage(image: UIImage){
        
        if let imgData = UIImageJPEGRepresentation(image, 0.2){
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
           
            DataService.instance.REF_USER_IMAGE.child(imgUid).put(imgData, metadata:metadata) {(metadata, error) in
                
                if error != nil{
                    print("unable to upload image to firebase storage(\(error?.localizedDescription))")
                }else{
                    
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL{

                        self.userProfileURL = ("\(url)")
                        let ref = DataService.instance.refrenceToCurrentUser()
                        ref.child("profile").child("userImageURL").setValue(self.userProfileURL)
                        
                        }
                    }
                }
                
            }
        }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        view.endEditing(true)
        
        super.touchesBegan(touches, with: event)
        
    }
}
