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

    @IBOutlet weak var messageTableView: UITableView!
    


    override func viewDidLoad() {
        super.viewDidLoad()

        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        //messages?.append(message)
        
        observeMessages()
 
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func observeMessages(){
        let ref = DataService.instance.REF_BASE.child("messages")
        ref.observe(.childAdded, with: { (snapshot) in
            
            
            if let messageDict = snapshot.value as? [String: Any] {
                print(messageDict)
                let message = Message()
                message.setValuesForKeys(messageDict)
                //self.messages.append(message)
                
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
        
        let message = messages[indexPath.row]
        
        if let toId = message.toId{
            let ref = DataService.instance.REF_USERS.child(toId).child("profile")
            
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
        
        cell.detailTextLabel?.text = "YoYo"//message.text
        
        return cell
    }
    
}
