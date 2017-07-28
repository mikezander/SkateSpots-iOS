//
//  SpotRow.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SpotRow: UITableViewCell{
  
    @IBOutlet weak var spotCollectionView: UICollectionView!
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var spotLocation: UILabel!
    @IBOutlet weak var spotDistance: UILabel!
    @IBOutlet weak var miLabel: UILabel!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    var spot: Spot!

    func configureRow(spot: Spot){
       
        self.spot = spot
        self.topLabel.text = spot.username
        self.spotName.text = spot.spotName
        self.spotLocation.text = spot.spotLocation
        
        if spot.distance != nil{
            spotDistance.isHidden = false
            miLabel.isHidden = false
           
            let distanceToSpot = String(format: "%.1f", spot.distance!)
            self.spotDistance.text = distanceToSpot
      
        }else{
            
            spotDistance.isHidden = true
            miLabel.isHidden = true
        }

        DispatchQueue.main.async {
            self.spotCollectionView.reloadData()
            self.spotCollectionView.showsHorizontalScrollIndicator = false
        }
    }
  
}

extension SpotRow : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = spot.imageUrls.count
        return spot.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageControl.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        pageControl.hidesForSinglePage = true
        pageControl.currentPage = indexPath.row
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
   
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! SpotPhotoCell

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
 
    }


extension SpotRow : UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.setContentOffset(CGPoint.zero, animated: false)

        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        let screenWidth = screenSize.width
        
        let heightOffset:CGFloat = 225
        
        return CGSize(width: screenWidth , height: screenHeight - heightOffset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
