//
//  VC + Extension.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/7/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import SystemConfiguration
import Foundation


var hasConnected = false
let internetConnectionNotification = Notification.Name("NotificationIdentifier")
private var firstLaunch : Bool = false
var defaults = UserDefaults.standard
let agreementKey = "AgreementKey"

extension UIViewController{
    
    
    func errorAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in6()
        zeroAddress.sin6_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin6_family = sa_family_t(AF_INET6)
        
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
            if connected {
                hasConnected = true
                NotificationCenter.default.post(name: internetConnectionNotification, object: nil)
            } else {
                hasConnected = false
                
            }
        })
        
    }

  
}

extension UIApplication {
    
    static func isFirstLaunch() -> Bool {

            let firstLaunchFlag = "isFirstLaunchFlag"
            let isFirstLaunch = UserDefaults.standard.string(forKey: firstLaunchFlag) == nil
            if (isFirstLaunch) {
                firstLaunch = isFirstLaunch
                UserDefaults.standard.set("false", forKey: firstLaunchFlag)
                UserDefaults.standard.synchronize()
            }
            return firstLaunch || isFirstLaunch
    }
    
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
        
}

extension String {
    
    var isValidEmail : Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with:self)
        
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var alreadyAdded = Set<Iterator.Element>()
        return self.filter { alreadyAdded.insert($0).inserted }
    }
}
