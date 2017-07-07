//
//  DataService.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import FirebaseDatabase

let DB_BASE = FIRDatabase.database().reference()

class DataService{
    private static let _instance = DataService()
    
    static var instance: DataService{
        return _instance
    }

    private var _REF_BASE = DB_BASE
    private var _REF_SPOTS = DB_BASE.child("spots")
    private var _REF_USERS = DB_BASE.child("users")
    
    var REF_BASE: FIRDatabaseReference{
        return _REF_BASE
    }
    
    var REF_SPOTS: FIRDatabaseReference{
        return _REF_SPOTS
    }
    
    var REF_USERS: FIRDatabaseReference{
        return _REF_USERS
    }
    
    func saveUser(uid: String, email: String){
        let profile: Dictionary<String, AnyObject> = ["username": "" as AnyObject, "email": email as AnyObject]
        REF_USERS.child(uid).child("profile").setValue(profile)
    }
}

