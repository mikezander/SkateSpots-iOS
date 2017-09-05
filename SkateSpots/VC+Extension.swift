//
//  VC + Extension.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/7/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import SystemConfiguration

var hasConnected = false

extension UIViewController{
    
    func errorAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func isConnected(){
    
        DataService.instance.isConnectedToFirebase(completion: { connected in
            
            if connected{
                
               hasConnected = true
                
                
            }else{
                
                hasConnected = false
                //self.errorAlert(title: "Network Connection Error", message: "Make sure you have a connection and try again")
            }
            
            print("\(hasConnected)hasconnected")
            
        })

    }

}
