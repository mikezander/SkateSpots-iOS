//
//  AllCommentsVC.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 11/8/19.
//  Copyright © 2019 Michael Alexander. All rights reserved.
//

import UIKit
import Firebase

class AllCommentsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    var comments = [Comment]()
    var spot: Spot!
    var user: User!
    var allSpots: [Spot]!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIButton!
    
    let inputCommentMaxHeight: CGFloat = 70.0
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        subscribeToKeyboardNotifications()
        commentTextView.text = "Add a comment.."
        commentTextView.textColor = .lightGray
        commentTextView.autocorrectionType = .no

        titleLabel.text = "\(comments.count) comments"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()

        commentView.layer.borderWidth = 0.8
        commentView.layer.borderColor = UIColor.lightGray.cgColor
        commentView.layer.cornerRadius = 8.0
        
        tableView.scrollTableViewToBottom(animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    @objc func didPressCommentUser(gesture : UITapGestureRecognizer) {
        let v = gesture.view!
        let index = v.tag
        let vc = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "goToProfile") as! ProfileVC
        vc.allSpots = self.allSpots
        vc.userKey = comments[index].userKey
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentsCell") as! CommentsTableViewCell
        cell.comment = comments[indexPath.row]
        
        cell.userLabel.tag = indexPath.row
        cell.userLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressCommentUser)))
        cell.userLabel.isUserInteractionEnabled = true
        
        return cell
    }

    @IBAction func back(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func commentPressedHandler(){
          commentPressed { (success) in
              guard success == true else {
                  self.errorAlert(title: "Post comment failed", message: "Post comment failed. Check your internet conenction and try again")
                  self.postButton.isEnabled = true
                  return
              }
            self.commentTextView.text = ""
            self.commentTextView.resignFirstResponder()
            
            self.tableView.reloadData()
            self.tableView.scrollTableViewToBottom(animated: false)
            self.titleLabel.text = "\(self.comments.count) comments"
            self.postButton.isEnabled = true
          }
          
      }
      
      func commentPressed(completion: @escaping (Bool) -> ()){
          
          if isInternetAvailable() && hasConnected {
              
              if self.commentTextView.text != "Add a comment.." && commentTextView.text != "" && commentTextView.text != " " && commentTextView.text != "  "{
                  
                  postButton.isEnabled = false
                  
                  DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid).child("profile").observeSingleEvent(of: .value,with: { (snapshot) in
                      if !snapshot.exists() { print("snapshot not found! SpotRow.swift");return }
                      
                      if let username = snapshot.childSnapshot(forPath: "username").value as? String {
                          
                          if let userImageURL = snapshot.childSnapshot(forPath: "userImageURL").value as? String{
                              
                              self.user = User(userName: username, userImageURL: userImageURL, bio: "", link: "", igLink: "")
                              
                              let comment: Dictionary<String, AnyObject> = [
                                  "userKey": (Auth.auth().currentUser?.uid)! as AnyObject,
                                  "username": self.user.userName as AnyObject,
                                  "userImageURL" : self.user.userImageURL as AnyObject,
                                  "comment": self.commentTextView.text as AnyObject,
                                  
                                  ]
                              
                              let commentRef = DataService.instance.REF_SPOTS.child(self.spot.spotKey).child("comments").childByAutoId()
                              
                              commentRef.setValue(comment)
                              self.comments.append(Comment(userKey: Auth.auth().currentUser!.uid, userName: self.user.userName, userImageURL: self.user.userImageURL, comment: self.commentTextView.text))
                          }
                      }
                      
                      completion(true)
                  })
                  
                  
              }

          } else {
              errorAlert(title: "Network Connection Error", message: "Make sure you are connected and try again")
          }
          
      }

     @objc func keyboardWillShow(notification: NSNotification) {
         if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.superview?.superview?.frame.origin.y == 0 {
                self.view.superview?.superview?.frame.origin.y -= keyboardSize.height - view.safeAreaInsets.bottom
             }
         }
     }

     @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.superview?.superview?.frame.origin.y != 0 {
                self.view.superview?.superview?.frame.origin.y = 0
            }

     }

     
     func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
     }
    
    //MARK: UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if newSize.height < inputCommentMaxHeight {
            commentViewHeightConstraint.constant =  newSize.height
            view.layoutIfNeeded()
        }

    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
          if text == "\n" {
              commentTextView.resignFirstResponder()
              commentTextView.layer.borderColor = UIColor.black.cgColor
              return false
          }
          return true
      }
      
      func textViewDidBeginEditing(_ textView: UITextView) {
          self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
          
          if commentTextView.textColor == UIColor.lightGray {
              commentTextView.text = nil
              commentTextView.textColor = UIColor.black
          }
          commentTextView.layer.borderColor = FLAT_GREEN.cgColor
      }
      
      func textViewDidEndEditing(_ textView: UITextView) {
          self.view.gestureRecognizers?.removeAll()
          
          if commentTextView.text.isEmpty {
              commentTextView.text = "Add a comment.."
              commentTextView.textColor = UIColor.lightGray
          }
          commentTextView.layer.borderColor = UIColor.black.cgColor
      }
}

extension UITableView {
    func scrollTableViewToBottom(animated: Bool) {
        guard let dataSource = dataSource else { return }
        var lastSectionWithAtLeasOneElements = (dataSource.numberOfSections?(in: self) ?? 1) - 1
        while dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) < 1 {
            lastSectionWithAtLeasOneElements -= 1
        }
        let lastRow = dataSource.tableView(self, numberOfRowsInSection: lastSectionWithAtLeasOneElements) - 1
        guard lastSectionWithAtLeasOneElements > -1 && lastRow > -1 else { return }
        let bottomIndex = IndexPath(item: lastRow, section: lastSectionWithAtLeasOneElements)
        scrollToRow(at: bottomIndex, at: .bottom, animated: animated)
    }
}
