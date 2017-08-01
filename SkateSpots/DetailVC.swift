//
//  DetailVC.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/22/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit
import Cosmos
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class DetailVC: UIViewController, UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var spot: Spot!
    
    var user: User!
    
    var commentsArray = [Comment]()
    
    var ratingRef:FIRDatabaseReference!
    
    var scrollView: UIScrollView!
    var containerView = UIView()
    var collectionview: UICollectionView!
    var cellId = "Cell"
    var ratingView = CosmosView()
    var ratingDisplayView = CosmosView()
    var ratingDisplayLbl = UILabel()
    var rateBtn = RoundedButton()
    var spotNameLbl = UILabel()
    var spotTypeLbl = UILabel()
    var commentView = UITextView()
    
    let tableView = UITableView()
    let products = ["Macbook Pro", "IPhone", "IPad", "Apple Watch", "Macbook Air" ]
 
    let screenSize = UIScreen.main.bounds
    
    var refCurrentSpot: FIRDatabaseReference!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        refCurrentSpot = DataService.instance.REF_SPOTS.child(spot.spotKey)
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height

        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: screenHeight * 2 + 100)
        
        containerView = UIView()
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        
        let customNav = UIView(frame: CGRect(x:0,y: 0,width: screenWidth,height: 50))
        customNav.backgroundColor = UIColor(red: 127/255, green: 173/255, blue: 82/255, alpha: 1)

        self.view.addSubview(customNav)
        
        let btn1 = UIButton()
        btn1.setTitle("Back", for: .normal)
       
        btn1.frame = CGRect(x:0, y:20, width: 45,height: 35)
        btn1.addTarget(self, action:#selector(backButtonPressed), for: .touchUpInside)
        self.view.addSubview(btn1)
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: screenWidth, height: screenHeight)
        layout.scrollDirection = .horizontal
 
        collectionview = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionview.collectionViewLayout = layout
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.register(DetailPhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.backgroundColor = UIColor.white
        self.containerView.addSubview(collectionview)
        
        spotNameLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
        // you will probably want to set the font (remember to use Dynamic Type!)
        spotNameLbl.font = UIFont.preferredFont(forTextStyle: .title2)
        spotNameLbl.textColor = .black
        spotNameLbl.center = CGPoint(x: screenWidth / 2, y: screenHeight - 125)
        spotNameLbl.textAlignment = .center
        spotNameLbl.text = spot.spotName
        self.containerView.addSubview(spotNameLbl)
        
        spotTypeLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 21))
        // you will probably want to set the font (remember to use Dynamic Type!)
        spotTypeLbl.font = UIFont.preferredFont(forTextStyle: .caption1)
        spotTypeLbl.textColor = .black
        spotTypeLbl.center = CGPoint(x: screenWidth / 2, y: screenHeight - 100)
        spotTypeLbl.textAlignment = .center
        spotTypeLbl.text = spot.spotType
        self.containerView.addSubview(spotTypeLbl)
        
        ratingDisplayView = CosmosView(frame: CGRect(x:0, y:0, width: 250,height: 20))
        ratingDisplayView.center = CGPoint(x: screenWidth / 2 , y: screenHeight - 80)
        ratingDisplayView.settings.updateOnTouch = false
        ratingDisplayView.settings.fillMode = .precise
        containerView.addSubview(ratingDisplayView)
        
        ratingDisplayLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 20))
        // you will probably want to set the font (remember to use Dynamic Type!)
        ratingDisplayLbl.font = UIFont.preferredFont(forTextStyle: .caption1)
        ratingDisplayLbl.textColor = .black
        ratingDisplayLbl.center = CGPoint(x: screenWidth / 2, y: screenHeight - 65)
        ratingDisplayLbl.textAlignment = .center
        ratingDisplayLbl.alpha = 0.4
        self.containerView.addSubview(ratingDisplayLbl)
   
        ratingView.settings.starSize = 30
        ratingView.frame = CGRect(x: 0 , y: 0, width: 250, height: 100)
        ratingView.center = CGPoint(x: screenWidth / 2 + 35, y: screenHeight + (screenHeight - 100))
        ratingView.settings.fillMode = .precise
        containerView.addSubview(ratingView)
        
        rateBtn = RoundedButton(frame: CGRect(x:0, y:0, width: 100,height: 20))
        rateBtn.center = CGPoint(x: screenWidth / 2, y: screenHeight + (screenHeight - 100))
        rateBtn.setTitle("Rate Spot!", for: .normal)
        rateBtn.backgroundColor = UIColor.black
        rateBtn.cornerRadius = 2.0
        rateBtn.addTarget(self, action:#selector(rateSpotPressed), for: .touchUpInside)
        
        rateBtn.alpha = 0.3
        containerView.addSubview(rateBtn)

        let ref = DataService.instance.refrenceToCurrentUser()
        ratingRef = ref.child("rated").child(spot.spotKey)
        
        handleOneReviewPerSpot(ref: ratingRef)
        
        ratingView.didFinishTouchingCosmos = { rating in
            self.rateBtn.alpha = 1
            self.rateBtn.isEnabled = true
            let displayRating = String(format: "%.1f", rating)
            self.ratingView.text = "(\(displayRating))"
            self.ratingView.settings.filledBorderColor = UIColor.black
            
        }
        
        
        refCurrentSpot.observeSingleEvent(of: .value, with: { (snapshot) in
            if let ratingTally = snapshot.childSnapshot(forPath: "rating").value as? Double{
            let ratingVotes = snapshot.childSnapshot(forPath: "ratingVotes").value as! Int
                
                var rating = ratingTally / Double(ratingVotes)
                //let displayRating = String(format: "%.1f", rating)

                rating = (rating * 10).rounded() / 10
                print("\(rating) rating")
                self.ratingDisplayView.rating = rating
                self.ratingDisplayView.text = ("(\(ratingVotes))")
                self.ratingDisplayLbl.text = "\(rating) out of 5 stars"
            
            }else{
            
                self.ratingDisplayView.rating = 0.0
                self.ratingDisplayView.text = "(\(0))"
                self.ratingDisplayLbl.text = "No reviews yet"
            }
        
        })
        
        tableView.frame = CGRect(x:0, y:screenHeight + screenHeight / 3, width: screenWidth, height: screenHeight / 3)
        tableView.register(CommentCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0)
        containerView.addSubview(tableView)

        commentView = UITextView(frame: CGRect(x: 10, y: screenHeight + ((screenHeight / 3) * 2), width: tableView.frame.size.width - 50, height: 40))
        commentView.delegate = self
        commentView.text = "Add a comment"
        commentView.textContainer.maximumNumberOfLines = 4
        commentView.font = UIFont(name: "avenir", size: 15)
        commentView.textContainer.lineBreakMode = .byTruncatingTail
        commentView.textColor = UIColor.lightGray
        commentView.layer.borderWidth = 1.5
        
        containerView.addSubview(commentView)
        
        let button = UIButton()
        button.frame = CGRect(x: screenWidth - 50, y: screenHeight + ((screenHeight / 3) * 2), width: 40, height: 40)
        button.backgroundColor = UIColor.red
        button.setTitle("Name your Button ", for: .normal)
        button.addTarget(self, action:#selector(commentPressed), for: .touchUpInside)
        
        containerView.addSubview(button)
        
        let commentRef = DataService.instance.REF_SPOTS.child(spot.spotKey).child("comments")
        commentRef.observe(.value, with: {(snapshot) in
        
            self.commentsArray = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot]{
                
                for snap in snapshot{
                    print(snap.value as Any)
                    if let commentDict = snap.value as? Dictionary<String, AnyObject>{
                        print(commentDict)
                        let key = snap.key
                        let comment = Comment(commentKey: key, commentData: commentDict)
                        self.commentsArray.append(comment)
                        self.tableView.reloadData()
                    }
                }
            }
        
        }) {(error) in
            print(error.localizedDescription)
        }
}
    
    func commentPressed(){
        
        DataService.instance.REF_USERS.child(FIRAuth.auth()!.currentUser!.uid).child("profile").observeSingleEvent(of: .value,with: { (snapshot) in
            if !snapshot.exists() { print("snapshot not found! SpotRow.swift");return }
            
            if let username = snapshot.childSnapshot(forPath: "username").value as? String{
                
                if let userImageURL = snapshot.childSnapshot(forPath: "userImageURL").value as? String{
                    
                    self.user = User(userName: username, userImageURL: userImageURL)
                    
                    //let comment = Comment(userKey: (FIRAuth.auth()?.currentUser?.uid)!, userName: self.user.userName, userImageURL: self.user.userImageURL, comment: self.commentView.text)
                    
                    let comment: Dictionary<String, AnyObject> = [
                        "userKey": (FIRAuth.auth()?.currentUser?.uid)! as AnyObject,
                        "username": self.user.userName as AnyObject,
                        "userImageURL" : self.user.userImageURL as AnyObject,
                        "comment": self.commentView.text as AnyObject,
                       
                    ]
                    
                    let commentRef = DataService.instance.REF_SPOTS.child(self.spot.spotKey).child("comments").childByAutoId()
                    
                    commentRef.setValue(comment)
                }
            }
        })

    
       
        
       
 
    
    }
    
    func rateSpotPressed(){
 
        handleOneReviewPerSpot(ref: ratingRef)
        
        ratingRef.setValue(true)

        refCurrentSpot.observeSingleEvent(of: .value, with: { (snapshot) in
            if let ratingTally = snapshot.childSnapshot(forPath: "rating").value as? Double{
             var ratingVotes = snapshot.childSnapshot(forPath: "ratingVotes").value as! Int
                
                ratingVotes += 1
                
                let rating: Dictionary<String, AnyObject> = [
                    "rating": (self.ratingView.rating + ratingTally) as AnyObject,
                    "ratingVotes": ratingVotes as AnyObject
                    ]
                self.refCurrentSpot.updateChildValues(rating)
                
                var updatedRating = (self.ratingView.rating + ratingTally) / Double(ratingVotes)
                updatedRating = (updatedRating * 10).rounded() / 10
                print("\(updatedRating) Updatedrating")
                self.ratingDisplayView.rating = updatedRating
                self.ratingDisplayView.text = ("(\(ratingVotes))")
                
                self.ratingDisplayLbl.text = "\(updatedRating) out of 5 stars"
            
           
            }else{
                let rating: Dictionary<String, AnyObject> = [
                    "rating": self.ratingView.rating as AnyObject,
                    "ratingVotes": 1 as AnyObject
                    ]
                self.refCurrentSpot.updateChildValues(rating)
                
                self.ratingDisplayView.rating = self.ratingView.rating
                self.ratingDisplayView.text = ("(\(1))")
                
                let updatedRating = (self.ratingView.rating * 10).rounded() / 10
                print("\(updatedRating) Updatedrating")
                self.ratingDisplayView.rating = updatedRating
                self.ratingDisplayLbl.text = "\(updatedRating) out of 5 stars"
                
            }
            
        
        })
        
    }
    
    func handleOneReviewPerSpot(ref: FIRDatabaseReference){
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull{
                self.rateBtn.isEnabled = true
            }else{
                self.rateBtn.isEnabled = false
                self.ratingView.settings.updateOnTouch = false
                self.ratingView.isUserInteractionEnabled = false
                self.rateBtn.alpha = 0.3
                self.rateBtn.setTitle("Rated 🙌", for: .normal)
            }
        })
    }
    
    func backButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        containerView.frame = CGRect(x:0, y:50, width:scrollView.contentSize.width, height:scrollView.contentSize.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return spot.imageUrls.count
    }

    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight - 150))
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DetailPhotoCell
  
        cell.spotImage = image
        cell.addSubview(image)
        
        if indexPath.row < spot.imageUrls.count{

            
            if let img = FeedVC.imageCache.object(forKey: spot.imageUrls[indexPath.row] as NSString){
                print(indexPath.row)
                
                cell.configureCell(spot: spot, img: img, count: indexPath.row)
            }else{
                cell.configureCell(spot: spot, count: indexPath.row)
            }
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
extension DetailVC: UITableViewDelegate, UITableViewDataSource{

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        
        cell.userName.text = commentsArray[indexPath.row].userName
        
        cell.comment.text = commentsArray[indexPath.row].comment
        
        let ref = FIRStorage.storage().reference(forURL: commentsArray[indexPath.row].userImageURL)
        ref.data(withMaxSize: 1 * 1024 * 1024, completion:{ (data, error) in
            if error != nil{
                print("Mke: Unable to download image from firebase storage")
            }else{
            
                if let data = data{
                    cell.profilePhoto.image = UIImage(data:data)
                }
            }
           
            
        })

        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
       
        return 75
    }
    
  
 
}

extension DetailVC: UITextViewDelegate{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
           commentView.resignFirstResponder()
            commentView.layer.borderColor = UIColor.black.cgColor
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if commentView.textColor == UIColor.lightGray {
            commentView.text = nil
            commentView.textColor = UIColor.black
        }
        commentView.layer.borderColor = UIColor.green.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if commentView.text.isEmpty {
            commentView.text = "Add a comment"
            commentView.textColor = UIColor.lightGray
        }
        commentView.layer.borderColor = UIColor.black.cgColor
        
    }
}







