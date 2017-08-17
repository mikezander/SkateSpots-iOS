//
//  EditProfileVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseAuth

class EditProfileVC: UIViewController{

    @IBOutlet weak var profileImage: CircleView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    @IBOutlet weak var linkTextField: UITextField!

    var user: User!
    var spots = [Spot]()
    
    let currentUserID = FIRAuth.auth()!.currentUser!.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        userNameTextField.text = user.userName
        bioTextField.text = user.bio
        linkTextField.text = user.link
        
        userNameTextField.layer.borderWidth = 1
        userNameTextField.layer.cornerRadius = 4
        
        bioTextField.layer.borderWidth = 1
        bioTextField.layer.cornerRadius = 4
        
        linkTextField.layer.borderWidth = 1
        linkTextField.layer.cornerRadius = 4
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveChangesPressed(_ sender: Any) {
        
        var userDict = [String:AnyObject]()
        var spotsDict = [String:AnyObject]()
        
        if userNameTextField.text != "" || userNameTextField.text != user.userName{
            
            userDict.updateValue(userNameTextField.text as AnyObject, forKey: "username")
            spotsDict.updateValue(userNameTextField.text as AnyObject, forKey: "username")
            
        }
        
        if bioTextField.text != user.bio{
            userDict.updateValue(bioTextField.text as AnyObject, forKey: "bio")
        
        }
        
        if linkTextField.text != user.link{
            userDict.updateValue(linkTextField.text as AnyObject, forKey: "link")
        }
        
        for spot in spots{
         DataService.instance.updateSpot(uid: spot.spotKey, userData: spotsDict)
        }

        DataService.instance.updateDBUser(uid: currentUserID, child: "profile", userData: userDict)
    
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
}








