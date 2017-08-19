//
//  FavoriteCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/19/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class FavoriteCell: UITableViewCell{


    
    @IBOutlet weak var spotPhoto: UIImageView!
    @IBOutlet weak var titleLabel: UILabel! //spotName
    @IBOutlet weak var spotTypeLabel: UILabel!
   
    @IBOutlet weak var detailLabel: UILabel!//spot location
    
    
    func configureFavoriteCell(spot:Spot, img: UIImage? = nil){
        
        titleLabel.text = spot.spotName
        spotTypeLabel.text = spot.spotType
        detailLabel.text = spot.spotLocation
        
        //download images
        if img != nil{
            
            self.spotPhoto.image = img
            
            
        }else{
            
            //cache image
            
            let ref = FIRStorage.storage().reference(forURL:spot.imageUrls[0])
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: {(data, error) in
                if error != nil{
                    print("Mike: Unable to download image from firebase storage")
                }else{
                    print("Mike: Image downloaded from firebase storge")
                    if let imgData = data {
                        
                        
                        if let img = UIImage(data: imgData){
                            self.spotPhoto.image = img
                            FeedVC.imageCache.setObject(img, forKey: spot.imageUrls[0] as NSString)
                        }
                        
                        
                    }
                }
                
            })
        }
        
    }
    
}
