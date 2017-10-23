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
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId

    }

}
