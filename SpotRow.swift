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
import AVFoundation

protocol SpotRowDelegate{
    func didTapDirectionsButton(spot: Spot)
}

class SpotRow: UITableViewCell {
    
    @IBOutlet weak var spotCollectionView: UICollectionView!
    @IBOutlet weak var userImage: CircleView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var pageContainer: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var distanceContainer: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    
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
        
        var spotLocationString = ""
        
        if spot.spotLocation.contains("United States") {
            if let spotCityState = spot.spotLocation.components(separatedBy: "-").first {
                let comp = spotCityState.components(separatedBy: ",")
                if comp.count == 2 {
                    spotLocationString = "\(comp[0]), \(comp[1])"
                } else {
                    spotLocationString = spotCityState
                }
            } else {
                spotLocationString = spot.spotLocation
            }
        } else {
            let comp = spot.spotLocation.components(separatedBy: ",")
            if comp.count == 2 {
                spotLocationString = "\(comp[0]), \(comp[1])"
            } else {
                spotLocationString = spot.spotLocation
            }
            
        }

        locationLabel.text = spotLocationString
        
        userImage.isUserInteractionEnabled = true
        
        self.userImage.sd_setImage(with: URL(string: spot.userImageURL), placeholderImage: UIImage(named: "profile-placeholder"))
       
        if spot.distance != nil {
            distanceContainer.isHidden = false

            let distanceToSpot = String(format: "%.1f", spot.distance!)
            self.distanceLabel.text = distanceToSpot
            
        } else{
            distanceContainer.isHidden = true
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
        var page = Int()
        if scrollView.contentOffset.x == 0 {
            page = 1
        } else {
            page = Int(scrollView.contentOffset.x / scrollView.frame.width  + 1.0)
        }

        pageControl.currentPage = page - 1
        pageLabel.text = "\(page) / \(spot.imageUrls.count)"
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = spot.imageUrls.count
        return spot.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
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
        return CGSize(width: collectionView.frame.size.width, height: 456.0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
