//
//  MessagesVC.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/20/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

class MessagesVC: UIViewController{
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var chatLogUser: User? = nil

    @IBOutlet weak var messageTableView: UITableView!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        messageTableView.delegate = self
        messageTableView.dataSource = self
        //messages?.append(message)
        
       // observeMessages()
        observeUserMessages()
       
        
 
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let ref = DataService.instance.REF_BASE.child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            let messagesRef = DataService.instance.REF_BASE.child("messages").child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let messageDict = snapshot.value as? [String: Any] {
                    print(messageDict)
                    let message = Message()
                    message.setValuesForKeys(messageDict)
                    
                    
                    if let toId = message.toId{
                        // allows for one cell per user..hash
                        self.messagesDictionary[toId] = message
                        
                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort(by: { (message1, message2) -> Bool in
                            
                            return message1.timestamp!.intValue > message2.timestamp!.intValue
                        })
                    }
                    
                    DispatchQueue.main.async { self.messageTableView.reloadData() }
 
                }
    
            }, withCancel: nil)
            
            
        }, withCancel: nil)
        
    }
    
    func observeMessages(){
        let ref = DataService.instance.REF_BASE.child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            
            if let messageDict = snapshot.value as? [String: Any] {
                print(messageDict)
                let message = Message()
                message.setValuesForKeys(messageDict)
 
                
                if let toId = message.toId{
                    // allows for one cell per user..hash
                    self.messagesDictionary[toId] = message
                    
                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort(by: { (message1, message2) -> Bool in
                        
                        return message1.timestamp!.intValue > message2.timestamp!.intValue
                    })
                }
                
                
                
                DispatchQueue.main.async { self.messageTableView.reloadData() }
                
            }
            
            
            
            print(self.messages.count)
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        
    }
    
    

}

extension MessagesVC: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageCell

        cell.emptyImageView()
        
        let message = messages[indexPath.row]
        
        if let id = message.chatPartnerId(){
            
            let ref = DataService.instance.REF_USERS.child(id).child("profile")
            
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let name = dictionary["username"] as! String
                    let profilePicUrl = dictionary["userImageURL"] as! String
                    
                    if let img = FeedVC.imageCache.object(forKey: profilePicUrl as NSString){
                        
                        cell.configureCell(message: message, img: img, userUrl: profilePicUrl, name: name)
                    }else{
                        cell.configureCell(message: message, userUrl: profilePicUrl, name: name)
                    }
                    
                    
                }
                
            }, withCancel: nil)
        }
        
  
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]

        guard let chatPartnerId = message.chatPartnerId() else{
            return
        }
       
        let ref = DataService.instance.REF_USERS.child(chatPartnerId).child("profile")
       
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
          
            guard let dictionary = snapshot.value as? [String: AnyObject] else{
                return
            }

            
            self.chatLogUser = User(userKey: chatPartnerId, userData: dictionary)
           
            // lbta he sets user key
           
            self.performSegue(withIdentifier: "goToChatLog", sender: nil)
            
            
        
        }, withCancel: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatLogController {
            if self.chatLogUser != nil{
                vc.user = self.chatLogUser
                vc.userKey = self.chatLogUser!.userKey

            }
        }
    }
    
}
