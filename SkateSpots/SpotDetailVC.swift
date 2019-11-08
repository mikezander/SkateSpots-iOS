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

class SpotDetailVC: UIViewController, UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    
    let coms = ["Dope park", "dljfkasj j akflj dklajdklf jfkal jdjkfdsa jskf djaf l;fajfkdjfdlkafjdkfldjfklajfdklfjdkalfjdkfdjfkadlfjadlkfjdfkjsfkdasjfkldfjkdlafjdklfjadskfjdasfkldjfkldsajfkdlsfjdkslfjdkalfjdklfdjkalfdjfkldjf dljfkasj j akflj dklajdklf jfkal jdjkfdsa jskf djaf l;fajfkdjfdlkafjdkfldjfklajfdklfjdkalfjdkfdjfkadlfjadlkfjdfkjsfkdasjfkldfjkdlafjdklfjadskfjdasfkldjfkldsajfkdlsfjdkslfjdkalfjdklfdjkalfdjfkldjf dljfkasj j akflj dklajdklf jfkal jdjkfdsa jskf djaf l;fajfkdjfdlkafjdkfldjfklajfdklfjdkalfjdkfdjfkadlfjadlkfjdfkjsfkdasjfkldfjkdlafjdklfjadskfjdasfkldjfkldsajfkdlsfjdkslfjdkalfjdklfdjkalfdjfkldjf dljfkasj j akflj dklajdklf jfkal jdjkfdsa jskf djaf l;fajfkdjfdlkafjdkfldjfklajfdklfjdkalfjdkfdjfkadlfjadlkfjdfkjsfkdasjfkldfjkdlafjdklfjadskfjdasfkldjfkldsajfkdlsfjdkslfjdkalfjdklfdjkalfdjfkldjf", "just another comment for your tableview to see I can make it's hegiht dynamic", "just another comment for your tableview to see I can make it's hegiht dynamic"]

    var refCurrentSpot: DatabaseReference!
    var spot: Spot!
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
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refCurrentSpot = DataService.instance.REF_SPOTS.child(spot.spotKey)
        setupZoomableCollectionView()
        setupSpotLabels()
        

        loadComments()
        commentTextView.delegate = self
        commentTextView.text = "Add a comment.."
        commentTextView.textColor = .lightGray
        addCommentContainer.layer.borderWidth = 0.8
        addCommentContainer.layer.cornerRadius = 8.0
        
        addCommentContainer.layer.borderColor = UIColor.lightGray.cgColor
        view.layoutIfNeeded()
        //
        //layoutComments()
    }

    private func setupZoomableCollectionView() {
        let zoomScrollView = UIScrollView(frame: imageContainerView.frame)
        zoomScrollView.isScrollEnabled = false
        zoomScrollView.zoomScale = 1.0
        zoomScrollView.minimumZoomScale = 1.0
        zoomScrollView.maximumZoomScale = 10.0
        zoomScrollView.delegate = self
        imageContainerView.addSubview(zoomScrollView)

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: imageContainerView.frame.width, height: imageContainerView.frame.height)
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
        
        let commentButton = UIButton()
        commentButton.titleLabel?.font = UIFont(name: "Avenir-Black", size: 14)
        commentButton.setTitleColor(.lightGray, for: .normal)

        if coms.count > 3 {
            commentButton.setTitle("View all \(coms.count) comments...", for: .normal)
                commentButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(loadAllCommentsView)))
        } else {
            commentButton.setTitle("\(coms.count) comments", for: .normal)
        }
        //commentButton.backgroundColor = .lightGray
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentContainer.addSubview(commentButton)
        commentButton.topAnchor.constraint(equalTo: commentContainer.topAnchor, constant: 10).isActive = true
        commentButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        commentButton.centerXAnchor.constraint(equalTo: commentContainer.centerXAnchor).isActive = true
        
//        var lastView: UIView = commentContainer
//        var lastViewConstraint = NSLayoutConstraint.Attribute.top
        
        var lastView: UIView = commentButton
        var lastViewConstraint = NSLayoutConstraint.Attribute.bottom
        
        let num = min(coms.count, 3)
        

        var height:CGFloat = 40.0
        for i in 0 ..< num {
            let textView = UITextView()
                textView.translatesAutoresizingMaskIntoConstraints = false
                commentContainer.addSubview(textView)
            textView.font = UIFont.systemFont(ofSize: 14.0)
            textView.text = coms[i]
            textView.isScrollEnabled = false
            textView.isEditable = false
            textView.sizeToFit()
            //textView.backgroundColor = colors[i]
     
            textView.leadingAnchor.constraint(equalTo: commentContainer.leadingAnchor).isActive = true
            textView.trailingAnchor.constraint(equalTo: commentContainer.trailingAnchor).isActive = true
            let textViewHeight = textView.sizeThatFits(CGSize(width:commentContainer.frame.width, height: textView.frame.height)).height
            textView.heightAnchor.constraint(equalToConstant: textViewHeight).isActive = true

            height += textViewHeight

            commentContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "|[view]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: ["view" : textView]))
                commentContainer.addConstraint(NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: lastView, attribute: lastViewConstraint, multiplier: 1.0, constant: 0))
                
                lastView = textView
                lastViewConstraint = .bottom

        }
        
        self.view.addConstraint(NSLayoutConstraint(item: commentContainer ?? UIView(), attribute: .bottom, relatedBy: .equal, toItem: lastView, attribute: .bottom, multiplier: 1.0, constant: 0))
        commentContainerHeight.constant = height
        view.layoutIfNeeded()

    }
    
    private func layoutComments() {
        
    }

    
    func loadComments(){
        let commentRef = DataService.instance.REF_SPOTS.child(spot.spotKey).child("comments")
        commentRef.observe(.value, with: {(snapshot) in
            
            self.comments = []
            self.commentCount = 0
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    self.commentCount += 1
                    if var commentDict = snap.value as? Dictionary<String, AnyObject>{
                        print(commentDict)
                        let key = snap.key
                        
                        DataService.instance.getCurrentUserProfileData(userRef: DataService.instance.REF_USERS.child(commentDict["userKey"] as! String).child("profile"), completionHandlerForGET: {success, data in
                            
                            let user = data!
                            commentDict["username"] = user.userName as AnyObject
                            commentDict["userImageURL"] = user.userImageURL as AnyObject
                            
                            let comment = Comment(commentKey: key, commentData: commentDict)
                            self.comments.append(comment)
                            
                            DispatchQueue.main.async {
                                self.setupCommentsView()
                                self.commentTableView.reloadData()
                            }
                            
//                            DispatchQueue.main.async {
//                                self.tableView.reloadData()
//                                let lastItem = IndexPath(item: self.commentsArray.count - 1, section: 0)
//                                self.tableView.scrollToRow(at: lastItem, at: .bottom, animated: false)
//                            }
                            
                        })
                        
                        
                    }
                    
                }
                
                
                //self.configCommentCountLabel(count: self.commentCount)
            }
            
        })
        
    }
    
    @objc func loadAllCommentsView() {
        print("load all comments view")
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        //pageControl.numberOfPages = spot.imageUrls.count
        return spot.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//        pageControl.hidesForSinglePage = true
//        pageControl.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let image = UIImageView(frame: CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y, width: collectionView.frame.width, height: collectionView.frame.height))
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
        print(newSize.height, "here123")

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

