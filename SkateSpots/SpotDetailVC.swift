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

class SpotDetailVC: UIViewController, UIScrollViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{

    var refCurrentSpot: DatabaseReference!
    var spot: Spot!
    
    var collectionview: UICollectionView!
    
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var spotNameLabel: UILabel!
    @IBOutlet var spotTypeLabel: UILabel!
    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var ratingLabel: UILabel!

    override func viewWillLayoutSubviews() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refCurrentSpot = DataService.instance.REF_SPOTS.child(spot.spotKey)
        setupZoomableCollectionView()
        setupSpotLabels()
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
    }
    
    
    private func setSpotRatingViews() {
        ratingView.settings.updateOnTouch = false
        ratingView.settings.fillMode = .precise
        
        refCurrentSpot.observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot, "here123")
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
}
