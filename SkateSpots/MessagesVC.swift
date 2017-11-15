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

class MessagesVC: UIViewController, MessageReadProtocol{
    
    static let shared = MessagesVC()
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    var readMesageDictionary = [String: Bool]()
    var chatLogUser: User? = nil
    var unreadUsers = Set<String>()

    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var headerImage: CircleView!
    @IBOutlet weak var headerNameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        messageTableView.delegate = self
        messageTableView.dataSource = self

        observeUserMessages()
        
        messageTableView.allowsMultipleSelectionDuringEditing = true
        
        UNService.shared.unCenter.removeAllDeliveredNotifications()
        
        if messages.count == 0{
            self.messageTableView.backgroundView = emptyDataLabel()
        }
  
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if messages.count == 0{
            messageTableView.backgroundView = emptyDataLabel()
        }
    }

    func hasMessageBeenRead(chatPartnerId: String, edited: Bool){
        
        self.readMesageDictionary[chatPartnerId] = edited
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
 
    func observeUserMessages(){
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        let userRef = DataService.instance.REF_USERS.child(uid).child("profile")
        
        userRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let usersName = snapshot.childSnapshot(forPath: "username").value as? String{
                
                let userProfileUrl = snapshot.childSnapshot(forPath: "userImageURL").value as! String

                self.headerNameLabel.text = usersName
                
                self.headerImage.loadImageUsingCacheWithUrlString(urlString: userProfileUrl)
                
                
            }

        })

        let ref = DataService.instance.REF_BASE.child("user-messages").child(uid)
        
        ref.observe(.childAdded, with: { (snapshot) in
           
            let userId = snapshot.key
            DataService.instance.REF_BASE.child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                self.messageTableView.backgroundView?.isHidden = true

                let messageId = snapshot.key
                
                let readFlag = snapshot.value as! Int
                
                self.fetchMessageWithMessageId(messageId: messageId, readFlag: readFlag)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            
            if self.messagesDictionary.count == 0 {
                self.messageTableView.backgroundView = self.emptyDataLabel()
            } else {
                self.messageTableView.backgroundView = nil
            }
            
            self.attempReloadOfTable()
            
        }, withCancel: nil)
        
    }

    private func fetchMessageWithMessageId(messageId: String, readFlag: Int){
        let messagesRef = DataService.instance.REF_BASE.child("messages").child(messageId)
        
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let messageDict = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: messageDict)

                if let chatPartnerId = message.chatPartnerId(){
                    // allows for one cell per user..hash
                    self.messagesDictionary[chatPartnerId] = message
                    
                    if readFlag == 0{
                        self.readMesageDictionary[chatPartnerId] = false
                    }else{
                        self.readMesageDictionary[chatPartnerId] = true
                    }

                }

                self.attempReloadOfTable()
                
            }
            
        }, withCancel: nil)
 
    }
    
    func attempReloadOfTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    func handleReloadTable(){

        self.messages = Array(self.messagesDictionary.values)
 
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return message1.timestamp!.intValue > message2.timestamp!.intValue
        })
        
       
       
        DispatchQueue.main.async {
            self.messageTableView.reloadData()
        }
    }
    
    func isUnreadFlagHidden(id: String) -> Bool{
        
        for userId in unreadUsers{
            
            if id == userId{
                return false
            }
        }
        
        return true
    
    }
    
    func emptyDataLabel()->UIView{
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
 
        let emptyView = UIView(frame: CGRect(x: 0, y:0 , width:screenWidth , height: screenHeight))
        
        let emptyLabel = UILabel(frame: CGRect(x: (screenWidth / 2) - 100, y: (screenHeight / 2) - 120 ,width: 200 ,height: 200))
        emptyLabel.text = "Your inbox is empty"
        emptyLabel.alpha = 0.4
        emptyLabel.textAlignment = NSTextAlignment.center
        emptyView.addSubview(emptyLabel)
        
        let emptyImage = UIImage(named: "inbox")
        let emptyImageView = UIImageView(image: emptyImage)
        emptyImageView.frame = CGRect(x: emptyLabel.frame.origin.x + 50, y: emptyLabel.frame.origin.y - 20, width: 100, height: 100)
        emptyImageView.alpha = 0.4
        
        emptyView.addSubview(emptyImageView)
        return emptyView
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
                    
                    cell.configureCell(message: message, userUrl: profilePicUrl, name: name)
   
                }
                
            }, withCancel: nil)
            
            if let chatPartnerId = message.chatPartnerId(){
                cell.unreadFlag.isHidden = readMesageDictionary[chatPartnerId]!
            }

        }
        
        return cell
    }
    
    
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        guard let uid = Auth.auth().currentUser?.uid else { return }
  
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId(){
            
            readMesageDictionary[chatPartnerId] = true
            
            DataService.instance.REF_BASE.child("user-messages").child(uid).child(chatPartnerId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil{
                    print("Failed to delete message", error!.localizedDescription)
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attempReloadOfTable()

            })
        }
     
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard isInternetAvailable() && hasConnected else{
            errorAlert(title: "Network Connection Error", message: "Make sure you are connected and try again")
            return
        }
        
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

            self.readMesageDictionary[chatPartnerId] = true
           
            self.messageTableView.reloadData()
            
            self.performSegue(withIdentifier: "goToChatLog", sender: nil)
  
        }, withCancel: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ChatLogVC {
            if self.chatLogUser != nil{
                vc.user = self.chatLogUser
                vc.userKey = self.chatLogUser!.userKey
                vc.delegate = self
            }
        }
    }
    
}
