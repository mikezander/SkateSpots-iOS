//
//  AgreementVC.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 9/21/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit

class AgreementVC:UIViewController{

    @IBAction func agreePressed(_ sender: Any) {
        defaults.set(true, forKey: agreementKey)
        dismiss(animated: true, completion: nil)
    }
  
    @IBAction func declinePressed(_ sender: Any) {
        errorAlert(title: "You must accept this agreement to use this app", message: "In order to use this application you must accept the end user licensed agreement!")
    }

}
