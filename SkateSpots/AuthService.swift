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
    
    func login(email: String, password: String, username: String, onComplete: Completion?){
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                
                if let errorCode = AuthErrorCode(rawValue: error!._code){print(errorCode.rawValue)}
                
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
                
            } else{
                if user?.uid != nil{
                    
                    DataService.instance.saveFirebaseUser(uid: user!.uid, email: email, username: username)
                    
                    //Sign in
                    Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
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
    
    func logInExisting(email: String, password: String, onComplete: Completion?){
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil{
                
                if let errorCode = AuthErrorCode(rawValue: error!._code){print(errorCode.rawValue)}
                
                self.handleFirebaseError(error: error! as NSError, onComplete: onComplete)
            } else{
                // we have successfully logged in
                onComplete?(nil, user)
            }
        })
        
    }
    
    func handleFirebaseError(error: NSError, onComplete: Completion?){
        print(error.debugDescription)
        if let errorCode = AuthErrorCode(rawValue: error.code){
            switch errorCode {
            case .invalidEmail:
                onComplete?("Invalid email address", nil)
            case .wrongPassword:
                onComplete?("Invalid password", nil)
            case .emailAlreadyInUse:   //, .errorCodeAccountExistsWithDifferentCredential
                onComplete?("Could not create account email already in use. Please use Log In.", nil)
            case .accountExistsWithDifferentCredential:
                onComplete?("Could not create account email already in use existing credentials", nil)
            case .weakPassword:
                onComplete?("Make sure your password is 6 characters or more", nil)
            case .networkError:
                onComplete?("Make sure your internet is available", nil)
            case .userNotFound:
                onComplete?("Invalid email. There are no users found with that email address.", nil)
            default:
                onComplete?("There was a problem authenticating. Try again.\(error.description)", nil)
            }
            
        }
    }
    
}
