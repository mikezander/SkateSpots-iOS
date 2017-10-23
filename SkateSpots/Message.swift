//
//  Message.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/21/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject{
    
    var fromId: String?
    var toId: String?
    var text: String?
    var timestamp: NSNumber?
    
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId

    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        toId = dictionary["toId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        
        imageUrl = dictionary["imageUrl"] as? String
        imageWidth = dictionary["imageWidth"] as? NSNumber
        imageHeight = dictionary["imageHeight"] as? NSNumber
        
    }

}
