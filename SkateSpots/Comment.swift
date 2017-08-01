//
//  Comment.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/31/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage

class Comment{

    private var _commentKey: String!
    private var _userKey: String
    private var _userName: String
    private var _userImageURL: String
    private var _comment: String

    var commentKey: String{
        return _commentKey
    }
    
    var userKey: String{
        return _userKey
    }
    
    var userName: String{
        return _userName
    }
    
    var userImageURL: String{
        return _userImageURL
    }
    
    var comment: String{
        return _comment
    }
    
    init(userKey: String, userName: String, userImageURL: String, comment: String){
        self._userKey = userKey
        self._userName = userName
        self._userImageURL = userImageURL
        self._comment = comment
    }
    
    init(commentKey: String, commentData: Dictionary<String, AnyObject>){
        self._commentKey = commentKey
        
        self._userKey = commentData["userKey"] as! String
        
        self._userName = commentData["username"] as! String
        

        self._userImageURL = commentData["userImageURL"] as! String
        
        self._comment = commentData["comment"] as! String
        
    }
    
    
    


}
