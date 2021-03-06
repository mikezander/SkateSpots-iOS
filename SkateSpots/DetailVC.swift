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
import MapKit

class DetailVC: UIViewController, UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    var spot: Spot!
    
    var user: User!
    
    var commentsArray = [Comment]()
    
    var ratingRef:DatabaseReference!
    
    var scrollView: UIScrollView!
    var containerView = UIView()
    var collectionview: UICollectionView!
    var pageControl = UIPageControl()
    var cellId = "Cell"
    var ratingView = CosmosView()
    var ratingDisplayView = CosmosView()
    var ratingDisplayLbl = UILabel()
    var rateBtn = RoundedButton()
    var spotNameLbl = UILabel()
    var spotTypeLbl = UILabel()
    var commentView = UITextView()
    var postButton = UIButton()
    var directionsButton = UIButton()
    var reportButton = UIButton()
    var favoriteButton = UIButton()
    var descriptionTextView = UITextView()
    var kickOutImageView = UIImageView()
    var bestTimeimageView = UIImageView()
    var kickOutLabel = UILabel()
    var bestTimeLabel = UILabel()
    var myActivityIndicator = UIActivityIndicatorView()
    var commentActivityIndicator = UIActivityIndicatorView()
    var isFavorite = false
    
    let kickOutImageName = "cop_logo.png"
    let bestTimeImageName = "time_logo.png"
    
    var commentLbl = UILabel()
    
    var commentCount = 0
    
    let tableView = UITableView()
    
    let screenSize = UIScreen.main.bounds
    
    var refCurrentSpot: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        
        refCurrentSpot = DataService.instance.REF_SPOTS.child(spot.spotKey)
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        
        self.scrollView = UIScrollView()
        self.scrollView.delegate = self
//
//        containerView = UIView()
//        if #available(iOS 13.0, *) {
//            containerView.backgroundColor = UIColor.systemBackground
//        } else {
//            // Fallback on earlier versions
//        }

        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        scrollView.contentInset = UIEdgeInsets(top: -17, left: 0, bottom: 0, right: 0)
        
        var safeAreaHeight: CGFloat = 0.0
        if let safeAreaTop = UIApplication.shared.keyWindow?.safeAreaInsets.top {
            safeAreaHeight = safeAreaTop
        }
       
        
        let customNav = UIView(frame: CGRect(x:0,y: 0,width: screenWidth, height: 62 + safeAreaHeight))
        customNav.backgroundColor = FLAT_GREEN
        self.view.addSubview(customNav)

        let btn1 = UIButton()
        btn1.setImage(UIImage(named:"back"), for: .normal)
        
        btn1.frame = CGRect(x:4, y:26 + safeAreaHeight, width: 30,height: 30)
        btn1.addTarget(self, action:#selector(backButtonPressed), for: .touchUpInside)
        view.addSubview(btn1)
        
        myActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        myActivityIndicator.frame = CGRect(x:screenWidth - 35 , y:25 + safeAreaHeight, width: 30,height: 30)
        myActivityIndicator.hidesWhenStopped = true
        view.addSubview(myActivityIndicator)
        
        let headerLabel = UILabel()
        headerLabel.frame = CGRect(x: 0,y: 0, width:(screenWidth / 2) + (screenWidth / 4), height:30)
        headerLabel.center = CGPoint(x:view.frame.midX ,y: 41 + safeAreaHeight)
        headerLabel.textAlignment = .center
        headerLabel.text = "Spot Details"
        headerLabel.textColor = UIColor.white
        headerLabel.font = UIFont(name: "Gurmukhi MN", size: 20)
        view.addSubview(headerLabel)
        
        let zoomScrollView = UIScrollView(frame: CGRect(x:0, y:0, width: screenWidth, height: screenHeight - 188))//
        zoomScrollView.delegate = self
        zoomScrollView.minimumZoomScale = 1.0
        zoomScrollView.maximumZoomScale = 10.0//maximum zoom scale you want
        zoomScrollView.zoomScale = 1.0
        zoomScrollView.isScrollEnabled = false
        
        containerView.addSubview(zoomScrollView)
        
 
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //75
        layout.itemSize = CGSize(width: screenWidth, height: 500)
        layout.scrollDirection = .horizontal

        
        
        collectionview = UICollectionView(frame: CGRect(x:0, y:14, width: self.view.frame.width, height: 500), collectionViewLayout: layout)

//        collectionview = UICollectionView(frame: CGRect(x:0, y:5, width: self.view.frame.width, height: self.view.frame.height), collectionViewLayout: layout)
        collectionview.collectionViewLayout = layout
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.register(DetailPhotoCell.self, forCellWithReuseIdentifier: cellId)
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.backgroundColor = UIColor.white
        collectionview.isPagingEnabled = true
        zoomScrollView.addSubview(collectionview)
 
        spotNameLbl = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 25))
        spotNameLbl.font = UIFont.preferredFont(forTextStyle: .title2)
        spotNameLbl.textColor = UIColor.black
        spotNameLbl.center = CGPoint(x: screenWidth / 2, y: collectionview.frame.maxY) //168
        spotNameLbl.textAlignment = .center
        spotNameLbl.text = spot.spotName
        containerView.addSubview(spotNameLbl)
        
        pageControl = UIPageControl(frame: CGRect(x: -25, y: spotNameLbl.frame.origin.y - 13, width: 50, height: 20))
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = FLAT_GREEN
        containerView.addSubview(pageControl)
        
        spotTypeLbl = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 21))
        spotTypeLbl.font = UIFont.preferredFont(forTextStyle: .caption1)
        spotTypeLbl.textColor = .black
        spotTypeLbl.center = CGPoint(x: screenWidth / 2, y: spotNameLbl.frame.maxY + 8)//screenHeight - 144)
        spotTypeLbl.textAlignment = .center
        spotTypeLbl.text = spot.spotType
        spotTypeLbl.font = spotTypeLbl.font.withSize(13)
        containerView.addSubview(spotTypeLbl)
        
        ratingDisplayView.settings.starSize = 25
        ratingDisplayView.frame =  CGRect(x:0, y:0, width: 250,height: 20)
        ratingDisplayView.center = CGPoint(x: screenWidth / 2 + 52 , y: spotTypeLbl.frame.maxY + 6)//screenHeight - 125)
        ratingDisplayView.settings.updateOnTouch = false
        ratingDisplayView.settings.fillMode = .precise
        containerView.addSubview(ratingDisplayView)
        
        ratingDisplayLbl = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 20))
        ratingDisplayLbl.font = UIFont.preferredFont(forTextStyle: .caption1)
        ratingDisplayLbl.textColor = .black
        ratingDisplayLbl.center = CGPoint(x: screenWidth / 2, y: ratingDisplayView.frame.maxY + 6)
        ratingDisplayLbl.textAlignment = .center
        ratingDisplayLbl.alpha = 0.4
        ratingDisplayLbl.font = ratingDisplayLbl.font.withSize(13)
        containerView.addSubview(ratingDisplayLbl)
        
        let descriptionLbl = UILabel(frame: CGRect(x: 10, y: ratingDisplayLbl.frame.maxY + 20, width: screenWidth - 5, height: 20))

//        let descriptionLbl = UILabel(frame: CGRect(x: 10, y: screenHeight - 89, width: screenWidth - 5, height: 20))
        descriptionLbl.font = UIFont(name: "Avenir-Black", size: 14)
        descriptionLbl.textColor = UIColor.lightGray
        descriptionLbl.text = "Description:"
        containerView.addSubview(descriptionLbl)
        
        descriptionTextView = UITextView(frame: CGRect(x: 5, y: descriptionLbl.frame.maxY, width: screenWidth - 5, height: 100))

//        descriptionTextView = UITextView(frame: CGRect(x: 5, y: screenHeight - 74, width: screenWidth - 5, height: 100))
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.isEditable = false
        descriptionTextView.isSelectable = false
        descriptionTextView.font = UIFont(name: "Helvetica", size: 14)
        descriptionTextView.alpha = 0.75
        descriptionTextView.backgroundColor = UIColor.clear
        
        if spot.spotDescription == "Spot Description"{
            descriptionTextView.text = "No description"
        }else{
            descriptionTextView.text = spot.spotDescription
        }
        descriptionTextView.textColor = UIColor.black
        
        adjustUITextViewHeight(arg: descriptionTextView)
        containerView.addSubview(descriptionTextView)
        

        let doYourPath = UIBezierPath(rect: CGRect(x: 5, y: descriptionTextView.frame.origin.y + descriptionTextView.frame.height + 7, width: screenWidth - 10, height: 0.7))
        let layer = CAShapeLayer()
        layer.path = doYourPath.cgPath
        layer.fillColor = UIColor.lightGray.cgColor
        containerView.layer.addSublayer(layer)
        
       
        let kickOutImage = UIImage(named: kickOutImageName)
        kickOutImageView = UIImageView(image: kickOutImage)
        kickOutImageView.frame = CGRect(x: screenWidth / 4 - 20, y: descriptionTextView.frame.origin.y + descriptionTextView.frame.height + 25, width: 50, height: 50)
        containerView.addSubview(kickOutImageView)
        
        kickOutLabel = UILabel(frame: CGRect(x: kickOutImageView.frame.origin.x - 25, y: kickOutImageView.frame.origin.y + kickOutImageView.frame.height + 5 , width: 100, height: 21))
        kickOutLabel.font = UIFont(name: "Avenir", size: 14)
        kickOutLabel.textColor = .black
        kickOutLabel.textAlignment = .center
        kickOutLabel.text = "\(spot.kickOut) bust"
        containerView.addSubview(kickOutLabel)
        
        let bestTimeImage = UIImage(named:bestTimeImageName)
        bestTimeimageView = UIImageView(image: bestTimeImage)
        bestTimeimageView.frame = CGRect(x: (screenWidth / 4) * 3 - 25, y: descriptionTextView.frame.origin.y + descriptionTextView.frame.height + 30, width: 50, height: 50)
        containerView.addSubview(bestTimeimageView)
        
        bestTimeLabel = UILabel(frame: CGRect(x: bestTimeimageView.frame.origin.x - 42, y: bestTimeimageView.frame.origin.y + bestTimeimageView.frame.height , width: 125, height: 21))
        bestTimeLabel.font = UIFont(name: "Avenir", size: 14)
        bestTimeLabel.textColor = .black
        bestTimeLabel.textAlignment = .center
        bestTimeLabel.text = "\(spot.bestTimeToSkate) spot"
        containerView.addSubview(bestTimeLabel)
        
        let grayView = UIView(frame: CGRect(x: 0, y: kickOutLabel.frame.origin.y + 30 , width: screenWidth, height: screenHeight / 2 + 36))
        grayView.backgroundColor = UIColor.lightGray
        let shadowSize : CGFloat = 7.0
        let shadowPath = UIBezierPath(rect: CGRect(x: -shadowSize / 2,
                                                   y: -shadowSize / 2,
                                                   width: grayView.frame.size.width + shadowSize,
                                                   height: grayView.frame.size.height + shadowSize))
        grayView.layer.masksToBounds = false
        grayView.layer.shadowColor = UIColor.black.cgColor
        grayView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        grayView.layer.shadowOpacity = 0.8
        grayView.layer.shadowPath = shadowPath.cgPath
        containerView.addSubview(grayView)
        
        tableView.frame = CGRect(x:10, y: kickOutLabel.frame.origin.y + 70, width: screenWidth - 20, height: screenHeight / 3 + 40)
        tableView.register(CommentCell.self, forCellReuseIdentifier: "cell")
        tableView.layer.borderWidth = 1
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        containerView.addSubview(tableView)
        
        commentLbl = UILabel(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 21))
        commentLbl.font = UIFont.preferredFont(forTextStyle: .headline)
        commentLbl.textColor = .white
        commentLbl.center = CGPoint(x: screenWidth / 2, y: tableView.frame.origin.y - 20)
        commentLbl.textAlignment = .center
        commentLbl.alpha = 0.5
        commentLbl.font = commentLbl.font.withSize(15)
        containerView.addSubview(commentLbl)
        
        commentActivityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        commentActivityIndicator.frame = CGRect(x:0 , y: 0, width: 30,height: 30)
        commentActivityIndicator.center = CGPoint(x: screenWidth - 20 , y: tableView.frame.origin.y - 20)
        commentActivityIndicator.hidesWhenStopped = true
        containerView.addSubview(commentActivityIndicator)
        
        commentView = UITextView(frame: CGRect(x: 10, y: tableView.frame.origin.y + tableView.frame.height, width: tableView.frame.size.width - 40, height: 40))
        commentView.delegate = self
        commentView.text = "Add a comment"
        commentView.textContainer.maximumNumberOfLines = 4
        commentView.font = UIFont(name: "avenir", size: 15)
        commentView.textContainer.lineBreakMode = .byTruncatingTail
        commentView.textColor = UIColor.lightGray
        commentView.layer.borderWidth = 1.25
        commentView.layer.cornerRadius = 2.0
        commentView.autocorrectionType = .no
        commentView.spellCheckingType = .no
        containerView.addSubview(commentView)
        
        postButton = UIButton()
        postButton.frame = CGRect(x: screenWidth - 50, y: tableView.frame.origin.y + tableView.frame.height, width: 40, height: 40)
        postButton.backgroundColor = UIColor.black
        postButton.layer.borderWidth = 2.0
        postButton.setImage(UIImage(named: "comment_btn")?.withRenderingMode(.alwaysOriginal), for: .normal)
        postButton.setImage(UIImage(named: "comment_btn")?.withRenderingMode(.alwaysOriginal), for: .highlighted)
        postButton.addTarget(self, action:#selector(commentPressedHandler), for: .touchUpInside)
        containerView.addSubview(postButton)
        
        //Setting scrollview content size
        
        self.scrollView.contentSize = CGSize(width: screenSize.width, height: 1400 + descriptionTextView.frame.height) // - 65

//        if screenHeight >= 736.0{ // for 6+, 7+
//            self.scrollView.contentSize = CGSize(width: screenSize.width, height: screenHeight * 2 + (screenHeight / 4) + (descriptionTextView.frame.height - 165)) // - 65
//        }else if screenHeight <= 568.0{// for 5, 5s, SE and under ** 168 difference to 6+, 7+
//            self.scrollView.contentSize = CGSize(width: screenSize.width, height: screenHeight * 2 + (screenHeight / 4 ) + (descriptionTextView.frame.height - 20)) //+ 83
//
//        }else{ // for 6, 7 and in between largest and smallest iphones ** 69 difference to 6+, 7+
//            self.scrollView.contentSize = CGSize(width: screenSize.width, height: screenHeight * 2 + (screenHeight / 4 ) + (descriptionTextView.frame.height - 116))// - 16
//        }
        
        ratingView.settings.starSize = 30
        ratingView.frame = CGRect(x: 0 , y: 0, width: 250, height: 100)
        ratingView.center = CGPoint(x: screenWidth / 2 + 35, y: commentView.frame.origin.y + commentView.frame.height + (screenHeight / 4 - 25))
        ratingView.settings.fillMode = .precise
        ratingView.settings.updateOnTouch = true
        containerView.addSubview(ratingView)
        
        rateBtn = RoundedButton(frame: CGRect(x:0, y:0, width: 125,height: 30))
        rateBtn.center = CGPoint(x: screenWidth / 2, y:ratingView.frame.origin.y + 58)
        rateBtn.setTitle("Rate Spot!", for: .normal)
        rateBtn.backgroundColor = UIColor.black
        rateBtn.isEnabled = false
        rateBtn.layer.masksToBounds = false
        rateBtn.layer.cornerRadius = 4.0
        rateBtn.addTarget(self, action:#selector(rateSpotPressed), for: .touchUpInside)
        rateBtn.alpha = 0.3
        containerView.addSubview(rateBtn)
        

        let ref = DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid)
        ratingRef = ref.child("rated").child(spot.spotKey)
        
        handleOneReviewPerSpot(ref: ratingRef)
        
        self.ratingView.didFinishTouchingCosmos = { rating in
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
        
        loadComments()
        
        let bottomView = UIView(frame: CGRect(x: 0, y:screenHeight - 42 , width: screenWidth, height: 42))
        bottomView.layer.borderWidth = 1.0
        bottomView.backgroundColor = UIColor.white
        view.addSubview(bottomView)
        
        favoriteButton = UIButton(frame: CGRect(x: 0, y:  0 , width: 135, height: 35))
        favoriteButton.center = CGPoint(x:screenWidth / 4 ,y: screenHeight - 21)
        favoriteButton.setTitle("Favorite", for: .normal)
        favoriteButton.setImage(UIImage(named:"add_fav.png"), for: .normal)
        favoriteButton.imageEdgeInsets = UIEdgeInsets(top: 0,left: -2,bottom: 0,right: 55)
        favoriteButton.backgroundColor = UIColor.black
        favoriteButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 20)
        
        favoriteButton.setTitleColor(UIColor.white, for: .normal)
        favoriteButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        favoriteButton.layer.shadowOffset = CGSize(width:0.0,height: 2.0)
        favoriteButton.layer.shadowOpacity = 1.0
        favoriteButton.layer.shadowRadius = 0.0
        favoriteButton.layer.masksToBounds = false
        favoriteButton.layer.cornerRadius = 4.0
        favoriteButton.addTarget(self, action:#selector(addSpotToFavorites), for: .touchUpInside)
        view.addSubview(favoriteButton)
        
        
        directionsButton = UIButton(frame: CGRect(x:0, y: 0, width: 135, height: 35))
        directionsButton.center = CGPoint(x:(screenWidth / 4) * 3,y: screenHeight - 21)
        directionsButton.setImage(UIImage(named:"direction_icon.png"), for: .normal)
        directionsButton.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 25)
        directionsButton.setTitle("Directions", for: .normal)
        directionsButton.backgroundColor = UIColor.black
        directionsButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 5)
        directionsButton.setTitleColor(UIColor.white, for: .normal)
        directionsButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        directionsButton.layer.shadowOffset = CGSize(width:0.0,height: 2.0)
        directionsButton.layer.shadowOpacity = 1.0
        directionsButton.layer.shadowRadius = 0.0
        directionsButton.layer.masksToBounds = false
        directionsButton.layer.cornerRadius = 4.0
        directionsButton.addTarget(self, action:#selector(getDirections), for: .touchUpInside)
        view.addSubview(directionsButton)

        if isFavorite {
            favoriteButton.isEnabled = false
            favoriteButton.layer.opacity = 0.4
            containerView.frame.size.height -= view.safeAreaInsets.bottom
        }
        
        reportButton = UIButton(frame: CGRect(x: screenWidth / 2 - 50,y: scrollView.contentSize.height - 125,width: 100,height:50)) //87
        reportButton.setTitle("Report Spot", for: .normal)
        reportButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        reportButton.setTitleColor(UIColor.blue, for: .normal)
        reportButton.addTarget(self, action:#selector(reportSpotPressed), for: .touchUpInside)
        containerView.addSubview(reportButton)
        
//        if screenHeight >= 812.0 { // iPhone X configuration
//            customNav.frame.size.height += 20
//            customNav.backgroundColor = .clear
//            btn1.frame.origin.y = 50
//            btn1.backgroundColor = .black
//            btn1.layer.opacity = 0.4
//            headerLabel.isHidden = true
//
//            bottomView.frame =  CGRect(x: 0, y:screenHeight - 62 , width: screenWidth, height: 62)
//            favoriteButton.frame.origin.y -= 15
//            directionsButton.frame.origin.y -= 15
//            scrollView.contentInset = UIEdgeInsets(top: -60, left: 0, bottom: 0, right: 0)
//        }
        
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        containerView.frame = CGRect(x:0, y:50, width: scrollView.contentSize.width, height: scrollView.contentSize.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        guard hasConnected && isInternetAvailable() else{
            errorAlert(title: "Network Connection Error", message: "Make sure you are connected and try again1")
            return
        }
        
        tableView.reloadData()
        
        if commentsArray.count > 0 {
            let lastItem = IndexPath(item: commentsArray.count - 1, section: 0)
            tableView.scrollToRow(at: lastItem, at: .bottom, animated: false)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return collectionview
    }
   
    func loadComments(){
        
        let commentRef = DataService.instance.REF_SPOTS.child(spot.spotKey).child("comments")
        commentRef.observe(.value, with: {(snapshot) in
            
            self.commentsArray = []
            self.commentCount = 0
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                
                for snap in snapshot{
                    
                    self.commentCount += 1
                    
                    if var commentDict = snap.value as? Dictionary<String, AnyObject>{
                        print(commentDict)
                        let key = snap.key
                        
                        DataService.instance.getCurrentUserProfileData(userRef: DataService.instance.REF_USERS.child(commentDict["userKey"] as! String).child("profile"), completionHandlerForGET: {success, data in
                            
                            let user = data!
                            commentDict["username"] = user.userName as AnyObject
                            commentDict["userImageURL"] = user.userImageURL as AnyObject
                            
                            let comment = Comment(commentKey: key, commentData: commentDict)
                            self.commentsArray.append(comment)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let lastItem = IndexPath(item: self.commentsArray.count - 1, section: 0)
                                self.tableView.scrollToRow(at: lastItem, at: .bottom, animated: false)
                            }
                            
                            
                        })
                        
                        
                    }
                    
                }
                
                self.configCommentCountLabel(count: self.commentCount)
            }
            
        })
        
    }
    
    func configCommentCountLabel(count: Int){
        switch count {
        case 0:
            self.commentLbl.text = "No comments"
        case 1:
            self.commentLbl.text = "1 comment"
        case 2,3:
            self.commentLbl.text = "\(count) comments"
        default:
            self.commentLbl.text = "View all \(count) comments ⇡"
        }
        
    }
    
    @objc func commentPressedHandler(){
        commentPressed { (success) in
            guard success == true else {
                self.errorAlert(title: "Post comment failed", message: "Post comment failed. Check your internet conenction and try again")
                return
            }
            
            self.commentView.text = ""
            self.postButton.isEnabled = true
            self.commentView.resignFirstResponder()
        }
        
    }
    
    func commentPressed(completion: @escaping (Bool) -> ()){
        
        if isInternetAvailable() && hasConnected {
            
            if commentView.text != "Add a comment" && commentView.text != "" && commentView.text != " " && commentView.text != "  "{
                
                postButton.isEnabled = false
                
                DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid).child("profile").observeSingleEvent(of: .value,with: { (snapshot) in
                    if !snapshot.exists() { print("snapshot not found! SpotRow.swift");return }
                    
                    if let username = snapshot.childSnapshot(forPath: "username").value as? String{
                        
                        if let userImageURL = snapshot.childSnapshot(forPath: "userImageURL").value as? String{
                            
                            self.user = User(userName: username, userImageURL: userImageURL, bio: "", link: "", igLink: "")
                            
                            let comment: Dictionary<String, AnyObject> = [
                                "userKey": (Auth.auth().currentUser?.uid)! as AnyObject,
                                "username": self.user.userName as AnyObject,
                                "userImageURL" : self.user.userImageURL as AnyObject,
                                "comment": self.commentView.text as AnyObject,
                                
                                ]
                            
                            let commentRef = DataService.instance.REF_SPOTS.child(self.spot.spotKey).child("comments").childByAutoId()
                            
                            commentRef.setValue(comment)
                            
                        }
                    }
                    
                    completion(true)
                })
                
                
            }
            
            
        }else{
            errorAlert(title: "Network Connection Error", message: "Make sure you are connected and try again")
        }
        
    }
    
    @objc func rateSpotPressed(){
        
        if isInternetAvailable() && hasConnected{
            
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
                    self.ratingDisplayView.rating = updatedRating
                    self.ratingDisplayLbl.text = "\(updatedRating) out of 5 stars"
                    
                }
            })
            
        }else{
            errorAlert(title: "Network Connection Error", message: "Make sure you are connected and try again")
        }
        
    }
    
    func handleOneReviewPerSpot(ref: DatabaseReference){
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull{
                
            }else{
                self.rateBtn.isEnabled = false
                self.ratingView.settings.updateOnTouch = false
                self.ratingView.isUserInteractionEnabled = false
                self.rateBtn.alpha = 0.3
                self.rateBtn.setTitle("Rated 🙌", for: .normal)
            }
        })
    }
    
    @objc func addSpotToFavorites(){
        let favDict = [spot.spotKey : true]
        
        DataService.instance.updateDBUser(uid: Auth.auth().currentUser!.uid, child: "favorites", userData: favDict as Dictionary<String, AnyObject>)
        
        favoriteButton.isEnabled = false
        favoriteButton.isOpaque = false
        favoriteButton.alpha = 0.3
        errorAlert(title: "", message: "Added \(spot.spotName) to favorites")
    }
    
    @objc func getDirections(){
        if UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!){
            UIApplication.shared.open(URL(string:
                "comgooglemaps://?saddr=&daddr=\(Float(spot.latitude)),\(Float(spot.longitude))&directionsmode=driving")!, options: [:], completionHandler: { (completed) in  })
        } else {
            let coordinate = CLLocationCoordinate2DMake(spot.latitude, spot.longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = spot.spotName
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
    }
    
    @objc func reportSpotPressed(){
        
        let alert = UIAlertController(title: "Report \(spot.spotName)", message: "Not a skate spot? Duplicate spot?      Let us know.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        alert.addTextField { (configurationTextField) in
            //configure your textfield here
            print(configurationTextField)
            
        }
        alert.addAction(UIAlertAction(title: "Send", style: UIAlertAction.Style.default, handler:{ (UIAlertAction)in
            if let textField = alert.textFields?.first {
                
                let reportDict: Dictionary<String, AnyObject> = [
                    "spotKey": self.spot.spotKey as AnyObject,
                    "spotName": self.spot.spotName as AnyObject,
                    "report": textField.text as AnyObject
                ]
                let reportRef = DataService.instance.REF_REPORTS.childByAutoId()
                reportRef.setValue(reportDict)
                self.errorAlert(title: "", message: "\(self.spot.spotName) reported \n Thanks for your feedback!")
                self.reportButton.isEnabled = false
            }
        }))
        self.present(alert, animated: true, completion: {
        })
    }
    
    
    @objc func backButtonPressed() {
        _ = navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func adjustUITextViewHeight(arg : UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
    
    func setGestureRecognizer() -> UITapGestureRecognizer {
        var tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action:#selector(lblClick))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.cancelsTouchesInView = false
        return tapGestureRecognizer
    }
    
    @objc func lblClick(tapGesture:UITapGestureRecognizer){
        let vc = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "goToProfile") as! ProfileVC
        vc.userKey = commentsArray[tapGesture.view!.tag].userKey
        self.present(vc, animated: true, completion: nil)
       
        //self.navigationController?.pushViewController(vc, animated:true)
    }
    
    
    //shifts the view up from bottom text field to be visible
    @objc func keyboardWillShow(notification: NSNotification){
        if commentView.isFirstResponder{
            view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
    }
    
    //shifts view down once done editing bottom text field
    @objc func keyboardWillHide(notification: NSNotification){
        if commentView.isFirstResponder{
            view.frame.origin.y = 0
        }
    }
    
    //helper function for keyboardWillShow
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        pageControl.numberOfPages = spot.imageUrls.count
        return spot.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
       
        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 500)) //- 193))//150
        image.isUserInteractionEnabled = true
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DetailPhotoCell
        
        cell.spotImage.image = nil
        cell.spotImage = image
        //cell.spotImage.frame.origin.y = collectionView.frame.origin.y
        cell.addSubview(image)
        
        
        myActivityIndicator.startAnimating()
        
        cell.activityIndicator = myActivityIndicator

            
        cell.configureCell(spot: spot, count: indexPath.row)

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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "goToProfile") as! ProfileVC
        vc.userKey = commentsArray[indexPath.row].userKey
        self.present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        
        cell.emptyImageView()
        
        commentActivityIndicator.startAnimating()
        
        cell.activityIndicator = commentActivityIndicator
        
        let comment = commentsArray[indexPath.row]
        
        
        cell.userName.text = comment.userName
        
        cell.comment.text = comment.comment
        
        cell.userName.tag = indexPath.row
        
        cell.userName.addGestureRecognizer(self.setGestureRecognizer())
        
        if let img = FeedVC.imageCache.object(forKey: NSString(string: comment.userImageURL)){
            
            cell.configureProfilePic(comment: comment,img: img)
        }else{
            cell.configureProfilePic(comment:comment)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        let height:CGFloat
        
        let temp = commentsArray[indexPath.row].comment
        let tempCount = temp.count
        print(tempCount)
        
        if tempCount >= 60 && tempCount <= 80{
            height = 80
        }else if tempCount > 80 && tempCount < 100{
            height = 90
        }else if tempCount >= 100 && tempCount <= 125{
            height = 100
        }else if tempCount >= 125 &&  tempCount <= 150{
            height = 110
        }else if tempCount >= 150{
            height = 120
        }else{
            height = 70
        }
        
        print(height)
        return height
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
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        if commentView.textColor == UIColor.lightGray {
            commentView.text = nil
            commentView.textColor = UIColor.black
        }
        commentView.layer.borderColor = FLAT_GREEN.cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.view.gestureRecognizers?.removeAll()
        
        if commentView.text.isEmpty {
            commentView.text = "Add a comment"
            commentView.textColor = UIColor.lightGray
        }
        commentView.layer.borderColor = UIColor.black.cgColor
    }
}








