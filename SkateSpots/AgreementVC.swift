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
    @IBOutlet weak var licensedAgreementTextView: UITextView!

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        licensedAgreementTextView.setContentOffset(CGPoint.zero, animated: false)

    }

    @IBAction func agreePressed(_ sender: Any) {
        defaults.set(true, forKey: agreementKey)
        dismiss(animated: true, completion: nil)
    }
  
    @IBAction func declinePressed(_ sender: Any) {
        errorAlert(title: "You must accept this agreement to use this app", message: "In order to use this application you must accept the end user licensed agreement!")
    }

}
