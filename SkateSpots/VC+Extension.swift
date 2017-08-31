//
//  VC + Extension.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/7/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import SystemConfiguration

extension UIViewController{

    func errorAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

}
