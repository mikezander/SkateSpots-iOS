//
//  FIRMessagingService.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/26/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import FirebaseMessaging

enum SubscriptionTopic: String{
    case newMessage = "newMessage"
}

class FIRMessagingService {

    private init() {}
    static let shared = FIRMessagingService()
    let messaging = Messaging.messaging()
    
    func subscribe(to topic: SubscriptionTopic){
        messaging.subscribe(toTopic: topic.rawValue)
        
    }
    
    
}
