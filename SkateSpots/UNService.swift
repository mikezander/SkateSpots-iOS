//
//  UNService.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/26/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import UserNotifications

class UNService: NSObject {
    
    private override init() { }
    static let shared = UNService()
    let unCenter = UNUserNotificationCenter.current()
    
    func authorize(){
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        unCenter.requestAuthorization(options: options) { (granted, error) in
            
            if error != nil{
                print("error sending push notes", error ?? "error push notes")
                return
            }
            
            guard granted else{ return }
 
            DispatchQueue.main.async {
                
                self.configure()
            }
            
        }
    }
    
    func configure(){
        unCenter.delegate = self
        
        let application = UIApplication.shared
        application.registerForRemoteNotifications()
    }
}

extension UNService: UNUserNotificationCenterDelegate{

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("un did recieve")
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("un will present")
        
        let options: UNNotificationPresentationOptions = [.alert, .sound]
        completionHandler(options)
    }
}
