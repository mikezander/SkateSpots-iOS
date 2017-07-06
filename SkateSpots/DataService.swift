//
//  DataService.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DataService{
    private static let _instance = DataService()
    
    static var instance: DataService{
        return _instance
    }
    
    var mainRef: FIRDatabaseReference{
        return FIRDatabase.database().reference()
    }
    
    func saveUser(uid: String, email: String){
        let profile: Dictionary<String, AnyObject> = ["username": "" as AnyObject, "email": email as AnyObject]
        mainRef.child("users").child(uid).child("profile").setValue(profile)
    }
}

