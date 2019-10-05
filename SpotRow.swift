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
            
        }else{
            
            spotDistance.isHidden = true
            miLabel.isHidden = true
        }
    }

    @IBAction func directionsButtonPressed(_ sender: Any) {
        delegate?.didTapDirectionsButton(spot: spot)
    }
   
}

extension SpotRow : UICollectionViewDataSource {
    
    override func prepareForReuse() {
        super.prepareForReuse()

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = spot.imageUrls.count
        return spot.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = indexPath.row
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.prepareForReuse()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! SpotPhotoCell
        
        cell.emptyImageView()

        cell.configureCell(spot: spot, count: indexPath.row)
            
            /*if let img = FeedVC.imageCache.object(forKey: spot.imageUrls[indexPath.row] as NSString){
                
                cell.configureCell(spot: spot, img: img, count: indexPath.row)
            }else{
                cell.configureCell(spot: spot, count: indexPath.row)
            }*/

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
