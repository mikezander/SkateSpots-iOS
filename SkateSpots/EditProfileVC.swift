//
//  EditProfileVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ProfileEditedProtocol {
    func hasProfileBeenEdited(edited: Bool)
}

class EditProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{


    @IBOutlet weak var profileImage: CircleView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!
    @IBOutlet weak var igLinkTextfield: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var hasBeenEdited = false

    var user: User!
    var spots = [Spot]()
    
    let currentUserID = FIRAuth.auth()!.currentUser!.uid
    
    var delegate: ProfileEditedProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
       
        userNameTextField.text = user.userName
        bioTextField.text = user.bio
        linkTextField.text = user.link
        igLinkTextfield.text = user.igLink
        
        userNameTextField.delegate = self
        bioTextField.delegate = self
        linkTextField.delegate = self
        igLinkTextfield.delegate = self
        
        userNameTextField.layer.borderWidth = 1
        userNameTextField.layer.cornerRadius = 4
        
        bioTextField.layer.borderWidth = 1
        bioTextField.layer.cornerRadius = 4
        
        linkTextField.layer.borderWidth = 1
        linkTextField.layer.cornerRadius = 4
        
        igLinkTextfield.layer.borderWidth = 1
        igLinkTextfield.layer.cornerRadius = 4
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        profileImage.addGestureRecognizer(setGestureRecognizer())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        unsubscribeToKeyboardNotifications()
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveChangesPressed(_ sender: Any) {
        
        var userDict = [String:AnyObject]()
        var spotsDict = [String:AnyObject]()
        var photoDict = [String:AnyObject]()
  
        if userNameTextField.text != "" && userNameTextField.text != user.userName{
            
            userDict.updateValue(userNameTextField.text as AnyObject, forKey: "username")
            spotsDict.updateValue(userNameTextField.text as AnyObject, forKey: "username")
            addDictToSpot(dict: spotsDict)
            hasBeenEdited = true
        }
  
        if bioTextField.text != user.bio{
            userDict.updateValue(bioTextField.text as AnyObject, forKey: "bio")
            hasBeenEdited = true
        }
        
        if linkTextField.text != user.link{
            userDict.updateValue(linkTextField.text as AnyObject, forKey: "link")
            hasBeenEdited = true
        }
        
        if igLinkTextfield.text != user.igLink{
            userDict.updateValue(igLinkTextfield.text as AnyObject, forKey: "igLink")
            hasBeenEdited = true
        
        }
        
        if hasBeenEdited{
            DataService.instance.updateUserProfile(uid: currentUserID, child: "profile", userData: userDict)
        }
        
        if self.imageSelected{
            
            activityIndicator.startAnimating()
            
            if user.userImageURL != DEFAULT_PROFILE_PIC_URL{
                DataService.instance.deleteFromStorage(urlString: user.userImageURL)
            }
            
            
            if let userImg = self.profileImage.image{
                DataService.instance.addProfilePicToStorageWithCompletion(image: userImg){ url in

                        photoDict.updateValue( url as AnyObject, forKey: "userImageURL")
                    
                    self.addDictToSpot(dict: photoDict)
                    self.hasBeenEdited = true
                    
                    self.delegate?.hasProfileBeenEdited(edited: self.hasBeenEdited)
                    
                    self.activityIndicator.stopAnimating()
                    
                    _ = self.navigationController?.popViewController(animated: true)
                    
                    self.dismiss(animated: true, completion: nil)
                }
  
        }
    
        }else{
        
            delegate?.hasProfileBeenEdited(edited: hasBeenEdited)
            
            _ = self.navigationController?.popViewController(animated: true)
            
            self.dismiss(animated: true, completion: nil)
        
        
        }
     
    }
    
    
    func addDictToSpot(dict: [String:AnyObject]){
    
        for spot in spots{
        
            DataService.instance.updateSpot(uid: spot.spotKey, userData: dict)
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
            profileImage.image = image
            imageSelected = true
        }
    }
    
    
    //shifts the view up from bottom text field to be visible
    func keyboardWillShow(notification: NSNotification){
        
        if bioTextField.isFirstResponder || linkTextField.isFirstResponder || igLinkTextfield.isFirstResponder{
            view.frame.origin.y = -(getKeyboardHeight(notification: notification) / 2)
        }
    }
    
    //shifts view down once done editing bottom text field
    func keyboardWillHide(notification: NSNotification){
        
        if bioTextField.isFirstResponder || linkTextField.isFirstResponder || igLinkTextfield.isFirstResponder{
            view.frame.origin.y = 0
        }
    }
    
    //helper function for keyboardWillShow
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }

    
}

extension EditProfileVC: UITextFieldDelegate, UITextViewDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
}

}






