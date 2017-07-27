//
//  User.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/27/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import Photos

class User{
    
    private var _userKey: String!
    private var _userName: String

    var userKey: String{
        return _userKey
    }
    
    var userName: String{
        return _userName
    }
  
    init(userName: String){
        self._userName = userName
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>){
        self._userKey = userKey
        
        self._userName = userData["username"] as? String ?? "no name"
        
    }
    
}
