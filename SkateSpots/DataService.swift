//
//  DataService.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper
import FBSDKLoginKit

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService{
    private static let _instance = DataService()
    

    
    static var instance: DataService{
        return _instance
    }

    // DB Refrences
    private var _REF_BASE = DB_BASE
    private var _REF_SPOTS = DB_BASE.child("spots")
    private var _REF_USERS = DB_BASE.child("users")

    // Storage Refrences
    private var _REF_SPOT_IMAGES = STORAGE_BASE.child("post-pics")
    private var _REF_USER_IMAGE = STORAGE_BASE.child("user-pics")
    
    var REF_BASE: FIRDatabaseReference{
        return _REF_BASE
    }
    
    var REF_SPOTS: FIRDatabaseReference{
        return _REF_SPOTS
    }
    
    var REF_USERS: FIRDatabaseReference{
        return _REF_USERS
    }

    var REF_SPOT_IMAGES: FIRStorageReference{
        return _REF_SPOT_IMAGES
    }
    
    var REF_USER_IMAGE: FIRStorageReference{
        return _REF_USER_IMAGE
    }

    
    func saveFirebaseUser(uid: String, email: String, username: String){
        let keychainResult = KeychainWrapper.standard.set(uid, forKey: KEY_UID)
        print("Mike: Data saved to keychain\(keychainResult)")
        
        let profile: Dictionary<String, AnyObject> = ["username": username as AnyObject,
                                                      "email": email as AnyObject,
                                                      "bio": "" as AnyObject,
                                                      "link": "" as AnyObject]
        
        REF_USERS.child(uid).child("profile").setValue(profile)
    }
    
    func saveFacebookProfilePicture(uid:String){
    
        let request = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height": 300, "width": "300", "redirect": false], httpMethod: "GET")
        request!.start(completionHandler: {(connection,result,error) -> Void in
            if(error == nil) {
                
                if let dictionary = result as? [String:Any],
                    let dataDic = dictionary["data"] as? [String:Any],
                    let urlPic = dataDic["url"] as? String {
                    //access urlPic here
                    if let imageData = NSData(contentsOf: URL(string: urlPic)!) as Data? {
                        let profilePicRef = DataService.instance.REF_SPOT_IMAGES.child(uid+"/profile_pic.jpg") //user.uid
                        _ = profilePicRef.put(imageData, metadata: nil) {
                            metadata, error in
                            if(error == nil) {
                                _ = metadata!.downloadURL
                            }
                            else {
                                print("Error in dowloading the image")
                            }
                        }
                        let image = UIImage(data: imageData)
                        self.addProfilePicToStorage(image: image!)
                    }
                }
            }
            
        })
    
    }
    
    func addProfilePicToStorage(image: UIImage){
        
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
                        
                        //self.userProfileURL = ("\(url)")
                        let ref = DataService.instance.refrenceToCurrentUser()
                        ref.child("profile").child("userImageURL").setValue(url)
                        
                    }
                }
            }
            
        }
    }

    func updateDBUser(uid: String, child: String, userData: Dictionary<String, AnyObject>){
        REF_USERS.child(uid).child(child).updateChildValues(userData)
        // set value will wipe whats already there*
        
    }

    
    func getSpotsFromUser(userRef: FIRDatabaseReference, completionHandlerForGET: @escaping (_ success: Bool, _ data: [Spot]?, _ error: String?) -> Void){
        
        var spots = [Spot]()
 
        userRef.child("spots").observe(.value, with:{ (snapshot) in
            let spotKeyDict = snapshot.value as? [String : AnyObject] ?? [:]
            
            for spotKey in spotKeyDict{
                
                self.REF_SPOTS.child(spotKey.key).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let spotDict = snapshot.value as? Dictionary<String, AnyObject>{
                        
                        let spot = Spot(spotKey: spotKey.key, spotData: spotDict)
                        spot.removeCountry(spotLocation: spot.spotLocation)
                        spots.insert(spot, at: 0)
                        
                        if spots.count == spotKeyDict.count{
                            completionHandlerForGET(true, spots, nil)
                        }
                    }
                })
                
            }
         
        })
        
    }
    
 
    func getCurrentUserData(userRef: FIRDatabaseReference, completionHandlerForGET: @escaping (_ success: Bool, _ data: User?) -> Void){
    
        var user: User?
        
        userRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if snapshot.exists(){
                
                if let userName = snapshot.childSnapshot(forPath: "username").value as? String{
                    let userImageURL = snapshot.childSnapshot(forPath: "userImageURL").value as! String
                    let bio = snapshot.childSnapshot(forPath: "bio").value as! String
                    let link = snapshot.childSnapshot(forPath: "link").value as! String
                    
                    user = User(userName: userName, userImageURL:userImageURL, bio: bio, link: link)
                    
                }
                
                
                completionHandlerForGET(true, user)
            
            }else{
            
            
            }
            
           
            
            
       
        }){ (error) in
            print(error.localizedDescription)
            completionHandlerForGET(false, nil)
        }

    }
       
      
    
    func refrenceToCurrentUser() -> FIRDatabaseReference{
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
   
}

