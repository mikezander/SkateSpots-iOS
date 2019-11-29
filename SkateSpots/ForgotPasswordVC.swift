//
//  ForgotPasswordVC.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 11/25/19.
//  Copyright © 2019 Michael Alexander. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class ForgotPasswordVC: UIViewController {
    
    @IBOutlet weak var emailTextField: RoundTextfield!


    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func resetPassword(email: String, onSuccess: @escaping() -> Void, onError: @escaping(_ errorMeesage: String) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                onSuccess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }
    
    @IBAction func passwordResetPressed() {
        
        guard let email = emailTextField.text, email != "", email.contains("@") else {
            return
        }
        
        resetPassword(email: email, onSuccess: {
            self.view.endEditing(true)
            SVProgressHUD.showSuccess(withStatus: "We just have sent you a password reset email. Please check your inbox and follow the instructions to reset your password.")
                self.dismiss(animated: true, completion: nil)

        }) { (error) in
            SVProgressHUD.showError(withStatus: error)
        }
    }
    
    

}
