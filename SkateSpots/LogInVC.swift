//
//  LogInVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

class LogInVC: UIViewController{

    @IBOutlet weak var emailField: RoundTextfield!
    @IBOutlet weak var passwordField: RoundTextfield!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func logInPressed(_ sender: Any) {
        if let email = emailField.text, let pwd = passwordField.text,
            (email.characters.count > 0 && pwd.characters.count > 0){
            
            AuthService.instance.login(email: email, password: pwd, onComplete: { (errMsg, data) in
                guard errMsg == nil else{
                    self.errorAlert(title: "Error Authenticating", message: errMsg!)
                    return
                }
                self.dismiss(animated: true, completion: nil)
            })
        
        } else{
            errorAlert(title: "Email and Password Required", message: "You must enter both an email and a password")
        }
    }
    
    func errorAlert(title: String, message: String){
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
