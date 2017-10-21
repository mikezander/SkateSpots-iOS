//
//  Message.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/21/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

class Message{
    
    private var _content: String
    private var _user: User
    //var date: NSDate?
    
    var content: String{
        return _content
    }
    
    var user: User{
        return _user
    }
    
    init(content: String, user: User){
        self._content = content
        self._user = user
    }
  
    
}
