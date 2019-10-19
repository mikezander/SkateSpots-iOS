//
//  SpotRow.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

protocol SpotRowDelegate{
    func didTapDirectionsButton(spot: Spot)
}

class SpotRow: UITableViewCell {
    
    @IBOutlet weak var spotCollectionView: UICollectionView!
    @IBOutlet weak var userImage: CircleView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var spotLocation: UILabel!
    @IBOutlet weak var spotDistance: UILabel!
    @IBOutlet weak var miLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var pageContainer: UIView!
    
    var delegate: SpotRowDelegate?
    
    var spot: Spot!{
        didSet{
            spotCollectionView.reloadData()
            spotCollectionView.showsHorizontalScrollIndicator = false

        }
    }
    
    func configureRow(spot: Spot, img: UIImage? = nil){
   
        self.userImage.image = nil
        
        self.spot = spot
        self.userName.text = spot.username
        self.spotName.text = spot.spotName
        self.spotName.adjustsFontSizeToFitWidth = true
        self.spotLocation.text = spot.spotLocation
        
        userImage.isUserInteractionEnabled = true
        
        self.userImage.sd_setImage(with: URL(string: spot.userImageURL), placeholderImage: UIImage(named: "profile-placeholder"))
       
        if spot.distance != nil{
            spotDistance.isHidden = false
            miLabel.isHidden = false
            
            let distanceToSpot = String(format: "%.1f", spot.distance!)
            self.spotDistance.text = distanceToSpot
            
        } else{
            spotDistance.isHidden = true
            miLabel.isHidden = true
        }
        
        //pageContainer.layer.cornerRadius = 12.0
        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = 0
        pageLabel.text = "\(1) / \(spot.imageUrls.count)"
    }

    @IBAction func directionsButtonPressed(_ sender: Any) {
        delegate?.didTapDirectionsButton(spot: spot)
    }
   
}

extension SpotRow : UICollectionViewDataSource {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print()
        
        var page = Int()
        if scrollView.contentOffset.x == 0 {
            page = 1
        } else {
            page = Int(scrollView.contentOffset.x / scrollView.frame.width  + 1.0)
        }

        pageControl.currentPage = page - 1
        pageLabel.text = "\(page) / \(spot.imageUrls.count)"
        
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            let witdh = scrollView.frame.width - (scrollView.contentInset.left*2)
//            let index = scrollView.contentOffset.x / witdh
//            let roundedIndex = ceil(index)
//            pageControl?.currentPage = Int(roundedIndex)
//            pageLabel.text = "\(Int(roundedIndex)) / \(spot.imageUrls.count)"
//        }
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = spot.imageUrls.count
        return spot.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        

//
//        pageControl.currentPage = indexPath.row
//        pageLabel.text = "\(indexPath.row + 1) / \(imageCount)"
        
        
//        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//        pageControl.hidesForSinglePage = true
//        pageControl.currentPage = indexPath.row
//        pageLabel.text = "\(indexPath.row + 1) / \(spot.imageUrls.count)"
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.prepareForReuse()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! SpotPhotoCell
        
        cell.emptyImageView()
        cell.configureCell(spot: spot, count: indexPath.row)

        return cell
    }

    
}


extension SpotRow : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.setContentOffset(CGPoint.zero, animated: false)
        
       // return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)

        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        let screenWidth = screenSize.width

        let heightOffset:CGFloat = 225
        let contentHeight = screenHeight - heightOffset

        return CGSize(width: screenWidth, height: contentHeight)
    }
    
    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
