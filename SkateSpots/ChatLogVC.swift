//
//  ChatLogVC.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/24/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

class ChatLogVC: UICollectionViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout{
    
    var user: User? = nil
    var userKey = String()
    var messages = [Message]()
    
    var nameLabel = UILabel()
    
    let cellId = "cellId"
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter message..."
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        setupCustomNav()
        
        collectionView?.backgroundColor = .white
        
        collectionView?.contentInset = UIEdgeInsets(top: 58, left: 0, bottom: 8, right: 0)
        
        collectionView?.register(ChatLogCell.self, forCellWithReuseIdentifier: cellId)
        
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.keyboardDismissMode = .interactive
        
        collectionView?.alwaysBounceVertical = true
        
        nameLabel.text = user?.userName
        
        observeUsersMessages()
        
        setupKeyboardObservers()
        
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "addImageIcon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        
        containerView.addSubview(uploadImageView)
        //x,y,w,h
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.20)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 0.75).isActive = true
        
        
        
        return containerView
    }()
    
    func setupCustomNav(){
        let screenWidth = UIScreen.main.bounds.width
        let customNav = UIView(frame: CGRect(x:0,y: 0,width: screenWidth,height: 64))
        
        customNav.backgroundColor = FLAT_GREEN
        self.view.addSubview(customNav)
        
        let btn1 = UIButton()
        btn1.setImage(UIImage(named:"back"), for: .normal)
        
        btn1.frame = CGRect(x:4, y:26, width: 30,height: 30)
        btn1.addTarget(self, action:#selector(backButtonPressed), for: .touchUpInside)
        view.addSubview(btn1)
        
        nameLabel.frame = CGRect(x: self.view.center.x - 30,y: 26,width:314, height:28)
        //nameLabel.center.x = self.view.center.x
        
        
        nameLabel.textColor = UIColor.white
        nameLabel.font = UIFont(name: "Gurmukhi MN", size: 18)
        view.addSubview(nameLabel)
        
    }
    
    func backButtonPressed() {
        
        
        _ = navigationController?.popViewController(animated: true)
        
        dismiss(animated: true, completion: nil)
        //navigationController?.popToRootViewController(animated: true)
        
        
        
        //dismiss(animated: true, completion: nil)
        
        
        
        
        /*     let vc = ProfileVC()
         vc.user = self.user
         vc.userKey = self.userKey
         present(vc, animated: true, completion: nil)*/
        
        //dismiss(animated: true, completion: nil)
        
        
        // if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "goToProfile")
        
        //let vc = controller.viewControllers.first as? ProfileVC {
        //  yourViewController.user = user
        //  present(controller, animated: true, completion: nil) // if presented from ViewController
        
        
        
        
        // self.present(controller, animated: true, completion: nil)
        
        
        
        
        
    }
    
    func handleUploadTap(){
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            uploadToFirebaseStorageUsingImage(selectedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    private func uploadToFirebaseStorageUsingImage(_ image: UIImage){
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2){
            
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print("failed to upload message-image", error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString{
                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                }
                
            })
        }
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override var inputAccessoryView: UIView?{
        get{
            
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    func setupKeyboardObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        /*NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
         
         NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)*/
        
        
    }
    
    func handleKeyboardDidShow(notification: NSNotification){
        if messages.count > 0{
            let indexPath = IndexPath(item: messages.count - 1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
            
        }
        
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleKeyboardWillShow(notification: Notification){
        let keyboardFrame = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? CGRect
        let keybordDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        containerViewBottomAnchor?.constant = -keyboardFrame!.height
        UIView.animate(withDuration: keybordDuration!) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func handleKeyboardWillHide(notification: Notification){
        let keybordDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double
        
        containerViewBottomAnchor?.constant = 0
        UIView.animate(withDuration: keybordDuration!) {
            self.view.layoutIfNeeded()
        }
    }
    
    func observeUsersMessages(){
        
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        
        
        
        let userMessagesRef = DataService.instance.REF_BASE.child("user-messages").child(uid).child(userKey)
        
        userMessagesRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            
            let messagesRef = DataService.instance.REF_BASE.child("messages").child(messageId)
            
            messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dicitonary = snapshot.value as? [String: AnyObject] else{
                    return
                }
                
                
                self.messages.append(Message(dictionary: dicitonary))
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    //scroll to the last index
                    let indexPath = IndexPath(item:self.messages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }
                
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
    
    @IBAction func backButoonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    
    func handleSend(){
        let properties: [String: Any] = ["text": inputTextField.text!]
        sendMessageWithProperties(properties: properties)
    }
    
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
        let properties: [String: Any] = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height]
        sendMessageWithProperties(properties: properties)
        
    }
    
    private func sendMessageWithProperties(properties: [String: Any]){
        let ref = DataService.instance.REF_BASE.child("messages")
        let childRef = ref.childByAutoId()
        let toId = userKey
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: NSNumber
        timestamp = Int(NSDate().timeIntervalSince1970) as NSNumber
        
        var values = ["toId": toId, "fromId": fromId, "timestamp": timestamp] as [String: Any]
        
        properties.forEach({values[$0] = $1})
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error!.localizedDescription)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessagesRef = DataService.instance.REF_BASE.child("user-messages").child(fromId).child(toId)
            
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId: 1])
            
            let recipientUserMessagesRef = DataService.instance.REF_BASE.child("user-messages").child(toId).child(fromId)
            
            recipientUserMessagesRef.updateChildValues([messageId: 1])
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    private func estimatedFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        
        //modifies message font
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        
        if let text = message.text{
            height = estimatedFrameForText(text: text).height + 20
        }else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue{
            
            // h1 / w1 = h2 / w2
            // solve for h1
            //h1 = h2 / w2 * w1
            
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogCell
        
        let message = messages[indexPath.item]
        cell.textView.text = message.text
        
        setUpCell(cell: cell, message: message)
        
        if let text = message.text{
            cell.bubbleWidthAnchor?.constant = estimatedFrameForText(text: text).width + 32
        }else if message.imageUrl != nil{
            cell.bubbleWidthAnchor?.constant = 200
        }
        
        return cell
    }
    
    private func setUpCell(cell: ChatLogCell, message: Message){
        
        if let profileImageUrl = self.user?.userImageURL{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromId == Auth.auth().currentUser?.uid{
            //outgoing blue
            cell.bubbleView.backgroundColor = ChatLogCell.blueColor
            cell.textView.textColor = .white
            cell.profileImageView.isHidden = true
            
            cell.bubbleViewRightAnchor?.isActive = true
            cell.bubbleViewLeftAnchor?.isActive = false
        }else{
            //incoming gray
            cell.bubbleView.backgroundColor = UIColor(red: 211, green: 211, blue: 211, alpha: 1)
            cell.textView.textColor = .black
            cell.profileImageView.isHidden = false
            
            cell.bubbleViewRightAnchor?.isActive = false
            cell.bubbleViewLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
        }else{
            cell.messageImageView.isHidden = true
        }
        
    }
    
    
}
