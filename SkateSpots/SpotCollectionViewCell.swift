//
//  SpotCollectionViewCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//


import UIKit
import FirebaseStorage

class SpotCollectionViewCell: UICollectionViewCell{
 
    
    @IBOutlet weak var spotImage: UIImageView!
    
    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var spotLocation: UILabel!
    @IBOutlet weak var spotDistance: UILabel!
    
    var spot: Spot!
    
    func configureCell(spot: Spot, img: UIImage? = nil, count: Int){
        self.spot = spot
        self.spotName.text = spot.spotName
        self.spotDistance.text = "\(spot.distance)"
        self.spotLocation.text = spot.spotLocation
        
        
        //download images
        if img != nil{
            self.spotImage.image = img
        }else{

            //cache image

            let ref = FIRStorage.storage().reference(forURL:spot.imageUrls[0])
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: {(data, error) in
                if error != nil{
                    print("Mke: Unable to download image from firebase storage")
                }else{
                    print("Mike: Image downloaded from firebase storge")
                    if let imgData = data {
                        if let img = UIImage(data: imgData){
                            self.spotImage.image = img
                            FeedVC.imageCache.setObject(img, forKey: spot.imageUrls[0] as NSString)
                        }
                    }
                }
            })

        }
        
        
        }
        
}
