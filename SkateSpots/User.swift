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
    private var _userImageURL: String

    var userKey: String{
        return _userKey
    }
    
    var userName: String{
        return _userName
    }
    
    var userImageURL: String{
        return _userImageURL
    }
  
    init(userName: String, userImageURL: String){
        self._userName = userName
        self._userImageURL = userImageURL
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>){
        self._userKey = userKey
        
        self._userName = userData["username"] as? String ?? "no name"
        
        // TODO Put in Default Image for user here *******
        self._userImageURL = userData["userImageURL"] as? String ?? "https://firebasestorage.googleapis.com/v0/b/sk8spots-b8769.appspot.com/o/user-pics%2F5AC0CF9A-4293-4141-B36F-510326CFF51C?alt=media&token=d27ffbcf-3302-4e8d-b8ff-35c44c371a4c"
        
    }
    
}