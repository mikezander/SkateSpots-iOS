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
    
    
    
    func saveFirebaseUser(uid: String, email: String){
        let keychainResult = KeychainWrapper.standard.set(uid, forKey: KEY_UID)
        print("Mike: Data saved to keychain\(keychainResult)")
        
        let profile: Dictionary<String, AnyObject> = ["username": "Abc" as AnyObject, "email": email as AnyObject]
        REF_USERS.child(uid).child("profile").setValue(profile)
    }
    
    func updateDBUser(uid: String, child: String, userData: Dictionary<String, String>){
       REF_USERS.child(uid).child(child).updateChildValues(userData)
        // set value will wipe whats already there*
        
    }
    
    func refrenceToCurrentUser() -> FIRDatabaseReference{
        let uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        let user = REF_USERS.child(uid!)
        return user
    }
   
}

