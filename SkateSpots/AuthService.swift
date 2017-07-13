//
//  AuthService.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import FirebaseAuth

typealias Completion = (_ errMsg: String?,_ data: AnyObject?) -> Void

class AuthService{
    private static let _instance = AuthService()
    
    static var instance: AuthService{
        return _instance
    }
    
    func login(email: String, password: String, onComplete: Completion?){
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if error != nil{
                if let errorCode = FIRAuthErrorCode(rawValue: error!._code){ //CHECK _CODE FOR ERROR
                    if errorCode == .errorCodeUserNotFound{
                        //could handle this by creating sign up button..mispelled email will create new account
                        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                            if error != nil{
                             
                                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
                            
                            } else{
                                if user?.uid != nil{
                                
                                    DataService.instance.saveUser(uid: user!.uid, email: email)
                                    //Sign in
                                    FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                                        if error != nil{
                                           self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
                                        } else{
                                            // we have successfully logged in
                                            onComplete?(nil, user)
                                        }
                                    })
                                }
                            }
                        })
                    }
                }else{
                    self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
                }
            }else{
                //Successfully logged in
                onComplete?(nil, user)
            }
        })
    }
    
    func handleFirebaseError(error: NSError, onComplete: Completion?){
        print(error.debugDescription)
        if let errorCode = FIRAuthErrorCode(rawValue: error.code){
            switch errorCode {
            case .errorCodeInvalidEmail:
                onComplete?("Invalid email address", nil)
                break
            case .errorCodeWrongPassword:
                onComplete?("Invalid password", nil)
                break
            case .errorCodeEmailAlreadyInUse, .errorCodeAccountExistsWithDifferentCredential:
                onComplete?("Could not create account email already in use", nil)
            default:
                onComplete?("There was a problem authenticating. Try again.", nil)
            }
            
        }
    }
    
}
