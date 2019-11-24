//
//  SpotDetailVC.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 11/2/19.
//  Copyright © 2019 Michael Alexander. All rights reserved.
//

import UIKit
import Firebase
import Cosmos
import CoreLocation
import MapKit

protocol SpotDetailDelegate {
    func nearbySpotPressed(spot: Spot, spots: [Spot])
}

class SpotDetailVC: UIViewController, UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    var delegate: SpotDetailDelegate?

    var refCurrentSpot: DatabaseReference!
    var ratingRef:DatabaseReference!
    var userRef:DatabaseReference!

    var spot: Spot!
    var spots: [Spot]!
    var nearbySpots = [Spot]()

    var user: User!
    var comments = [Comment]()
    var commentCount = 0
    
    let inputCommentMaxHeight: CGFloat = 70.0
    
    var collectionview: UICollectionView!
    
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var spotNameLabel: UILabel!
    @IBOutlet var spotTypeLabel: UILabel!
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var spotDescriptionTextView: UITextView!
    @IBOutlet var kickOutLabel: UILabel!
    @IBOutlet var bestTimeLabel: UILabel!
    @IBOutlet weak var commentContainer: UIView!
    let commentTableView = UITableView()
    @IBOutlet weak var commentContainerHeight: NSLayoutConstraint!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentTextViewHeightContrstraint: NSLayoutConstraint!
    @IBOutlet weak var addCommentContainer: UIView!
    @IBOutlet weak var starView: CosmosView!
    @IBOutlet weak var starLabel: UILabel!
    @IBOutlet weak var rateBtn: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var directionsView: DirectionsView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var uploadedByImageView: UIImageView!
    @IBOutlet weak var uploadedByLabel: UILabel!
    @IBOutlet weak var nearbyContainer: UIView!
    @IBOutlet weak var nearbyScrollView: UIScrollView!
    @IBOutlet weak var ratingContainer: UIView!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!


    var isFavorite = false

    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if #available(iOS 13.0, *) {
            let statusBar = UIView(frame: UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
            statusBar.backgroundColor = #colorLiteral(red: 0.5650888681, green: 0.7229202986, blue: 0.394353807, alpha: 1)
             UIApplication.shared.keyWindow?.addSubview(statusBar)
        } else {
            UIApplication.shared.statusBarView?.backgroundColor = #colorLiteral(red: 0.5650888681, green: 0.7229202986, blue: 0.394353807, alpha: 1)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }

        subscribeToKeyboardNotifications()
        
        refCurrentSpot = DataService.instance.REF_SPOTS.child(spot.spotKey)
        setupZoomableCollectionView()
        setupSpotLabels()
        

        loadComments()
        commentTextView.delegate = self
        commentTextView.autocorrectionType = .no
        commentTextView.text = "Add a comment.."
        commentTextView.textColor = .lightGray
        addCommentContainer.layer.borderWidth = 0.8
        addCommentContainer.layer.cornerRadius = 8.0
        
        addCommentContainer.layer.borderColor = UIColor.gray.cgColor
        commentContainer.backgroundColor = .groupTableViewBackground
        
        let ref = DataService.instance.REF_USERS.child(Auth.auth().currentUser!.uid)
        ratingRef = ref.child("rated").child(spot.spotKey)
        handleOneReviewPerSpot(ref: ratingRef)
        starView.settings.fillMode = .precise
        
        starView.didFinishTouchingCosmos = { rating in
            self.rateBtn.alpha = 1
            self.rateBtn.isEnabled = true
            let displayRating = String(format: "%.1f", rating)
            self.starLabel.text = "(\(displayRating))"
            self.ratingView.settings.filledBorderColor = UIColor.black
        }
        
        directionsView.spot = spot
        directionsView.layer.cornerRadius = 8.0
        
        var finalSpotString = spot.spotLocation.replacingOccurrences(of: "-", with: " ")
        finalSpotString = finalSpotString.replacingOccurrences(of: ",", with: ", ")
        locationLabel.text = finalSpotString
        
        addUploadedBy()
        updateNearbySpots()
        
        if isFavorite{
            favoriteButton.isEnabled = false
            favoriteButton.layer.opacity = 0.4
        }
        
        view.layoutIfNeeded()

    }

    private func setupZoomableCollectionView() {
        let zoomScrollView = UIScrollView(frame: CGRect(x: imageContainerView.frame.origin.x, y: imageContainerView.frame.origin.y, width: UIScreen.main.bounds.width, height: imageContainerView.frame.height))//imageContainerView.frame)
        zoomScrollView.isScrollEnabled = false
        zoomScrollView.zoomScale = 1.0
        zoomScrollView.minimumZoomScale = 1.0
        zoomScrollView.maximumZoomScale = 10.0
        zoomScrollView.delegate = self
        imageContainerView.addSubview(zoomScrollView)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: imageContainerView.frame.height)
        layout.scrollDirection = .horizontal
        
        
        
        collectionview = UICollectionView(frame: zoomScrollView.frame, collectionViewLayout: layout)
        collectionview.collectionViewLayout = layout
        collectionview.dataSource = self
        collectionview.delegate = self
        collectionview.register(DetailPhotoCell.self, forCellWithReuseIdentifier: "Cell")
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.backgroundColor = UIColor.white
        collectionview.isPagingEnabled = true
        zoomScrollView.addSubview(collectionview)
    }

    private func setupSpotLabels() {
        spotNameLabel.text = spot.spotName
        spotTypeLabel.text = spot.spotType
        setSpotRatingViews()
        spotDescriptionTextView.text = spot.spotDescription == "Spot Description" ? "No description" : spot.spotDescription
        kickOutLabel.text = "\(spot.kickOut) bust"
        bestTimeLabel.text = "\(spot.bestTimeToSkate) spot"
    }

    private func setSpotRatingViews() {
        ratingView.settings.updateOnTouch = false
        ratingView.settings.fillMode = .precise
        
        refCurrentSpot.observeSingleEvent(of: .value, with: { (snapshot) in
            if let ratingTally = snapshot.childSnapshot(forPath: "rating").value as? Double{
                let ratingVotes = snapshot.childSnapshot(forPath: "ratingVotes").value as! Int
                
                var rating = ratingTally / Double(ratingVotes)
                rating = (rating * 10).rounded() / 10
                self.ratingView.rating = rating
                self.ratingView.text = ("(\(ratingVotes))")
                self.ratingLabel.text = "\(rating) out of 5 stars"
            }else{
                self.ratingView.rating = 0.0
                self.ratingView.text = "(\(0))"
                self.ratingLabel.text = "No reviews yet"
            }
        })
    }
    
    func setupCommentsView() {
        
        placeholderLabel?.isHidden = true
        
        for view in commentContainer.subviews {
            view.removeFromSuperview()
        }

        let commentButton = UIButton()
        commentButton.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        commentButton.setTitleColor(.lightGray, for: .normal)

        if comments.count > 3 {
            commentButton.setTitle("View all \(comments.count) comments...", for: .normal)
                commentButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadAllCommentsView)))
        } else {
            commentButton.setTitle("\(comments.count) comments", for: .normal)
        }
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentContainer.addSubview(commentButton)
        commentButton.topAnchor.constraint(equalTo: commentContainer.topAnchor, constant: 8).isActive = true
        commentButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        commentButton.centerXAnchor.constraint(equalTo: commentContainer.centerXAnchor).isActive = true

        
        var lastView: UIView = commentButton
        var lastViewConstraint = NSLayoutConstraint.Attribute.bottom
        
        let num = min(comments.count, 3)
        var height:CGFloat = 36.0
        
        
        for i in 0 ..< num {
            let comment = comments[comments.count - num + i]
            let textView = UITextView()
                textView.translatesAutoresizingMaskIntoConstraints = false
                commentContainer.addSubview(textView)
            textView.font = UIFont.systemFont(ofSize: 14.0)

            textView.text = comment.comment
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.backgroundColor = .groupTableViewBackground

            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40.0).isActive = true
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5).isActive = true
            let textViewHeight = textView.sizeThatFits(CGSize(width:commentContainer.frame.width, height: textView.frame.height)).height
            textView.heightAnchor.constraint(equalToConstant: textViewHeight).isActive = true

            height += textViewHeight + 30

            commentContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view" : textView]))
                commentContainer.addConstraint(NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: lastViewConstraint, multiplier: 1.0, constant: 30))
                
                lastView = textView
                lastViewConstraint = .bottom
            
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            commentContainer.addSubview(label)
            label.text = comment.userName
            label.font = UIFont.systemFont(ofSize: 14.0)
            label.textColor = #colorLiteral(red: 0, green: 0, blue: 1, alpha: 1)
            label.bottomAnchor.constraint(equalTo: textView.topAnchor, constant: 5).isActive = true
            label.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5).isActive = true
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressCommentUser)))
            label.tag = comments.count - num + i
            label.isUserInteractionEnabled = true
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            commentContainer.addSubview(imageView)
            imageView.kf.setImage(with: URL(string: comment.userImageURL), placeholder: UIImage(named: "profile-placeholder"))
            imageView.bottomAnchor.constraint(equalTo: label.bottomAnchor, constant: 10).isActive = true
            imageView.leadingAnchor.constraint(equalTo: commentContainer.leadingAnchor, constant: 2).isActive = true
            imageView.clipsToBounds = true
            //imageView.trailingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 36).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 36).isActive = true
            imageView.layer.cornerRadius = 18.0
            
        }
        
        self.view.addConstraint(NSLayoutConstraint(item: commentContainer ?? UIView(), attribute: .bottom, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 0))
        commentContainerHeight.constant = height
        view.layoutIfNeeded()

    }

    @objc func didPressUploadedByName(gesture : UITapGestureRecognizer) {
        let vc = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "goToProfile") as! ProfileVC
        vc.allSpots = self.spots
        vc.userKey = spot.user
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }

    @objc func didPressCommentUser(gesture : UITapGestureRecognizer) {
        let v = gesture.view!
        let index = v.tag
        let vc = UIStoryboard(name:"Main", bundle: nil).instantiateViewController(withIdentifier: "goToProfile") as! ProfileVC
        vc.allSpots = self.spots
        vc.userKey = comments[index].userKey
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func nearbySpotPressed(gesture : UITapGestureRecognizer) {
        let v = gesture.view!
        let index = v.tag
        dismiss(animated: true) {
            self.delegate?.nearbySpotPressed(spot: self.nearbySpots[index], spots: self.spots)
        }
    }


    
    func loadComments(){

        let commentRef = DataService.instance.REF_SPOTS.child(spot.spotKey).child("comments")
        commentRef.observe(.value, with: {(snapshot) in
            
            self.comments = []
            self.commentCount = 0
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    self.commentCount += 1
                    if let commentDict = snap.value as? Dictionary<String, AnyObject>{
                        let key = snap.key
                        let comment = Comment(commentKey: key, commentData: commentDict)
                        self.comments.append(comment)

                        
                        
                        
                        
//                        DataService.instance.getCurrentUserProfileData(userRef: DataService.instance.REF_USERS.child(commentDict["userKey"] as! String).child("profile"), completionHandlerForGET: {success, data in
//
//                            let user = data!
//                            commentDict["username"] = user.userName as AnyObject
//                            commentDict["userImageURL"] = user.userImageURL as AnyObject
//                            print(user.userName, commentDict["comment"] as! String, "here123")
//                            let comment = Comment(commentKey: key, commentData: commentDict)
//                            self.comments.append(comment)
//
//                            if snap == snapshot.last {
//                                self.setupCommentsView()
//                            }
//                        })
                    }
                    
                    if snap == snapshot.last {
                        self.setupCommentsView()
                    }
                }
            }
        })
        
    }
    
    @objc func loadAllCommentsView() {
        performSegue(withIdentifier: "all_comments_vc", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AllCommentsVC {
            vc.comments = self.comments
            vc.spot = self.spot
            vc.allSpots = self.spots
        }
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
                self.commentContainer.reloadInputViews()
                self.setupCommentsView()
                self.postButton.isEnabled = true
            }
            
        }
        
        func commentPressed(completion: @escaping (Bool) -> ()){
            
            if isInternetAvailable() && hasConnected {
                
                if self.commentTextView.text != "Add a comment.." && commentTextView.text != "" && commentTextView.text != " " && commentTextView.text != "  "{
                    
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
                                    "comment": self.commentTextView.text as AnyObject,
                                    
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
    
    @IBAction func rateSpotPressed(){
        if isInternetAvailable() && hasConnected {
            
            handleOneReviewPerSpot(ref: ratingRef)
            
            ratingRef.setValue(true)
            
            refCurrentSpot.observeSingleEvent(of: .value, with: { (snapshot) in
                if let ratingTally = snapshot.childSnapshot(forPath: "rating").value as? Double {
                    var ratingVotes = snapshot.childSnapshot(forPath: "ratingVotes").value as! Int
                    
                    ratingVotes += 1
                    
                    let rating: Dictionary<String, AnyObject> = [
                        "rating": (self.starView.rating + ratingTally) as AnyObject,
                        "ratingVotes": ratingVotes as AnyObject
                    ]
                    self.refCurrentSpot.updateChildValues(rating)
                    
                    var updatedRating = (self.ratingView.rating + ratingTally) / Double(ratingVotes)
                    updatedRating = (updatedRating * 10).rounded() / 10
                    self.ratingView.rating = updatedRating
                    self.ratingView.text = ("(\(ratingVotes))")
                    
                    self.ratingLabel.text = "\(updatedRating) out of 5 stars"
                    
                    
                } else {
                    let rating: Dictionary<String, AnyObject> = [
                        "rating": self.starView.rating as AnyObject,
                        "ratingVotes": 1 as AnyObject
                    ]
                    self.refCurrentSpot.updateChildValues(rating)
                    
                    self.ratingView.rating = self.ratingView.rating
                    self.ratingView.text = ("(\(1))")
                    
                    let updatedRating = (self.starView.rating * 10).rounded() / 10
                    self.ratingView.rating = updatedRating
                    self.ratingLabel.text = "\(updatedRating) out of 5 stars"
                    
                }
            })
            
            let alert = UIAlertController(title: "\(spot.spotName) rated!", message: "We appreciate your feedback 🙌", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)

            let when = DispatchTime.now() + 2.5
            DispatchQueue.main.asyncAfter(deadline: when){
                alert.dismiss(animated: true, completion: nil)
            }
            
        } else{
            errorAlert(title: "Network Connection Error", message: "Make sure you are connected and try again")
        }
        
    }
    
    func handleOneReviewPerSpot(ref: DatabaseReference){
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                
            }else{
                self.ratingContainer.removeFromSuperview()
                self.rateBtn.isEnabled = false
                self.starView.settings.updateOnTouch = false
                self.starView.isUserInteractionEnabled = false
                self.rateBtn.alpha = 0.3
                self.rateBtn.setTitle("Rated 🙌", for: .normal)
            }
        })
    }
    
    func addUploadedBy(){
        uploadedByLabel.text = spot.username
        uploadedByImageView.kf.setImage(with: URL(string: spot.userImageURL), placeholder: UIImage(named: "profile-placeholder"))
        uploadedByImageView.layer.cornerRadius = uploadedByImageView.frame.width / 2
        
        uploadedByLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didPressUploadedByName)))
        uploadedByLabel.isUserInteractionEnabled = true
        
    }
    
    func updateNearbySpots() {
        let spotLocation = CLLocation(latitude: spot.latitude, longitude: spot.longitude)
        self.spots.sort(by: { $0.distance(to: spotLocation) < $1.distance(to: spotLocation) })
        for nearbySpot in self.spots[1...5] {
            let distanceInMeters = spotLocation.distance(from: nearbySpot.location)
            let milesAway = distanceInMeters / 1609
            nearbySpot.distance = milesAway
            nearbySpots.append(nearbySpot)
        }

        let targetWidth = self.view.frame.size.width - 60.0
        let initialOffset = (self.view.frame.size.width - targetWidth) / 2.0
        
        var lastView: UIView = nearbyContainer
        var lastAttribute: NSLayoutConstraint.Attribute = NSLayoutConstraint.Attribute.left
        var lastConstant: CGFloat = initialOffset
        
        var i = 0
     
        for nearbySpot in nearbySpots {
            let view = UIView()
            nearbyContainer.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            
            view.backgroundColor = UIColor.clear
            view.layer.shadowColor = UIColor.black.cgColor
            view.layer.shadowOffset = CGSize(width: 8, height: 3)
            view.layer.shadowOpacity = 0.7
            view.layer.shadowRadius = 4.0
            view.layer.borderWidth = 1.0
            view.layer.cornerRadius = 10

            let spotView = UIView()
            view.addSubview(spotView)
            spotView.translatesAutoresizingMaskIntoConstraints = false
            
            spotView.frame = view.bounds
            if #available(iOS 13.0, *) {
                spotView.backgroundColor = .systemBackground
            } else {
                spotView.backgroundColor = .white
            }
            spotView.layer.cornerRadius = 10
            spotView.layer.borderColor = UIColor.lightGray.cgColor
            spotView.layer.borderWidth = 1.0
            spotView.layer.masksToBounds = true
            
            
            spotView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            spotView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            spotView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            spotView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            
            view.addSubview(spotView)
            
            

            
            let iv = UIImageView()
            iv.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(iv)

            iv.topAnchor.constraint(equalTo: spotView.topAnchor).isActive = true
            iv.leadingAnchor.constraint(equalTo: spotView.leadingAnchor).isActive = true
            iv.trailingAnchor.constraint(equalTo: spotView.trailingAnchor).isActive = true
            iv.bottomAnchor.constraint(equalTo: spotView.bottomAnchor, constant: -50.0).isActive = true
            
            iv.layer.masksToBounds = true
            iv.layer.cornerRadius = 10.0
            iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            iv.kf.setImage(with: URL(string: nearbySpot.imageUrls.first!))
            iv.tag = i
            iv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(nearbySpotPressed)))
            iv.isUserInteractionEnabled = true

            let nameLabel = UILabel()
            nameLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(nameLabel)
            nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25.0).isActive = true
            nameLabel.font = UIFont.systemFont(ofSize: 16.0)
            nameLabel.text = nearbySpot.spotName
            
            let distanceLabel = UILabel()
            distanceLabel.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(distanceLabel)
            distanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            distanceLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -7.0).isActive = true
            distanceLabel.font = UIFont.systemFont(ofSize: 12.0, weight: .light)
            distanceLabel.text = "\(String(format: "%.1f", nearbySpot.distance!)) miles from this spot"
            
            view.widthAnchor.constraint(equalToConstant: targetWidth).isActive = true
            view.topAnchor.constraint(equalTo: nearbyContainer.topAnchor, constant: 5).isActive = true
            view.bottomAnchor.constraint(equalTo: nearbyContainer.bottomAnchor, constant: -5).isActive = true

            nearbyContainer.addConstraint(NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: lastView, attribute: lastAttribute, multiplier: 1.0, constant: lastConstant))

            lastView = view
            lastAttribute = .right
            lastConstant = 10.0
            i += 1
        }
        self.view.addConstraint(NSLayoutConstraint(item: nearbyContainer!, attribute: .right, relatedBy: .equal, toItem: lastView, attribute: .right, multiplier: 1.0, constant: initialOffset))
        
        self.nearbyScrollView.contentOffset.x = 20
//        UIView.animate(withDuration: 20.0, animations: {
//            self.nearbyScrollView.contentOffset.x = 200
//            print(self.nearbyScrollView.contentSize.width, "here123")
//        }, completion: nil)
    }
    
    @IBAction func getDirections(){
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
    
    @IBAction func addSpotToFavorites(){
        let favDict = [spot.spotKey : true]
        
        DataService.instance.updateDBUser(uid: Auth.auth().currentUser!.uid, child: "favorites", userData: favDict as Dictionary<String, AnyObject>)
        
        favoriteButton.isEnabled = false
        favoriteButton.isOpaque = false
        favoriteButton.alpha = 0.3
        errorAlert(title: "", message: "Added \(spot.spotName) to favorites")
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.superview?.frame.origin.y == 0 {
                self.view.superview?.frame.origin.y -= keyboardSize.height - view.safeAreaInsets.bottom
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.superview?.frame.origin.y != 0 {
            self.view.superview?.frame.origin.y = 0
        }
    }
    
    
    func subscribeToKeyboardNotifications(){
       NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var page = Int()
        if scrollView.contentOffset.x == 0 {
            page = 1
        } else {
            page = Int(scrollView.contentOffset.x / scrollView.frame.width  + 1.0)
        }
        pageControl.currentPage = page - 1
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        pageControl.numberOfPages = spot.imageUrls.count
        return spot.imageUrls.count
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//        pageControl.hidesForSinglePage = true
//        pageControl.currentPage = indexPath.row
//    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let image = UIImageView(frame: CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y, width: UIScreen.main.bounds.width, height: collectionView.frame.height))
        image.isUserInteractionEnabled = true
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! DetailPhotoCell
        cell.spotImage.image = nil
        cell.spotImage = image
        cell.addSubview(image)
        
        //myActivityIndicator.startAnimating()
        //cell.activityIndicator = myActivityIndicator

            
        cell.configureCell(spot: spot, count: indexPath.row)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return collectionview
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        
        if newSize.height < inputCommentMaxHeight {
            commentTextViewHeightContrstraint.constant =  newSize.height
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

