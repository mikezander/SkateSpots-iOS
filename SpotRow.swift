//
//  SpotRow.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

class SpotRow: UITableViewCell{
    
    
    
    static var shared = SpotRow()
    
    var spots = [Spot]()

    @IBOutlet weak var spotCollectionView: UICollectionView!

    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var spotLocation: UILabel!
    @IBOutlet weak var spotDistance: UILabel!
    
    var spot: Spot!
    
    func configureRow(spot: Spot){
        self.spot = spot
        self.spotName.text = spot.spotName
        self.spotLocation.text = spot.spotLocation
        self.spotDistance.text = "\(spot.distance)"
        spotCollectionView.reloadData()

    }
}

extension SpotRow : UICollectionViewDataSource {
    
  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("\(spot.imageUrls.count)")
        return spot.imageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         //let spot = spots[indexPath.row]
        
        
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
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
       // let itemsPerRow:CGFloat = 1
        //let hardCodedPadding:CGFloat = 5
        //let itemWidth = (screenWidth / itemsPerRow)// - hardCodedPadding
       // let itemHeight = screenHeight - (2 * hardCodedPadding)
        return CGSize(width: screenWidth, height: screenHeight - 60)
    }
    
}
