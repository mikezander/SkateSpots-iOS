//
//  ChatLogController.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/21/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var chatCollectionView: UICollectionView!
    
    var userKey = String()
    var messages = [Message]()
    //var user: User? = nil
    
    var user: User?{
        didSet{
            observeUsersMessages()
        }
    }

    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    let cellId = "cellId"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatCollectionView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
        chatCollectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
        chatCollectionView.register(ChatLogCell.self, forCellWithReuseIdentifier: cellId)
        
        chatCollectionView.alwaysBounceVertical = true

        print(userKey)
        
        titleLabel.text = user?.userName
        
        //observeUsersMessages()

        setupInputComponents()
     
    }
    
    func observeUsersMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }

        let userMessagesRef = DataService.instance.REF_BASE.child("user-messages").child(uid)
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            let messagesRef = DataService.instance.REF_BASE.child("messages").child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dicitonary = snapshot.value as? [String: AnyObject] else{
                    return
                }
                
                let message = Message()
                //potential of crashing if keys don't match!
                message.setValuesForKeys(dicitonary)
                
                if message.chatPartnerId() == self.userKey{
                
                    self.messages.append(message)
                    
                    DispatchQueue.main.async {
                        self.chatCollectionView.reloadData()
                    }
                    
                }

                
            }, withCancel: nil)
            
        }, withCancel: nil)
    
    }
    
    func setupInputComponents(){

        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(containerView)
        
        containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        containerView.addSubview(inputTextField)
        
        inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.20)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 0.75).isActive = true

        
    }
    
    
    @IBAction func backButoonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    
    func handleSend(){
        
        let ref = DataService.instance.REF_BASE.child("messages")
        let childRef = ref.childByAutoId()
        let toId = userKey
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: NSNumber
        timestamp = Int(NSDate().timeIntervalSince1970) as NSNumber
        let values = ["text": inputTextField.text!, "toId": toId, "fromId": fromId, "timestamp": timestamp] as [String: Any]
        //childRef.updateChildValues(values)
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessagesRef = DataService.instance.REF_BASE.child("user-messages").child(fromId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = DataService.instance.REF_BASE.child("user-messages").child(toId)
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
  
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
   
}
extension ChatLogController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    private func estimatedFrameForText(text: String) -> CGRect{
       let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        //modifies message font
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        if let text = messages[indexPath.item].text{
            height = estimatedFrameForText(text: text).height + 20
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setUpCell(cell: cell, message: message)
        
        //modify bubleview width
        cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: message.text!).width + 32


        
        return cell
   
    }
    
    private func setUpCell(cell: ChatLogCell, message: Message){
    
        if message.fromId == Auth.auth().currentUser?.uid{
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatLogCell.blueColor
        }else{
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor.lightGray//UIColor(red: 240, green: 240, blue: 240, alpha: 1)
            cell.textView.textColor = UIColor.black
        }
        
    }

}




