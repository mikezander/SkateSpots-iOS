//
//  DetailPhotoCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/22/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseStorage

class DetailPhotoCell: UICollectionViewCell{

    var spotImage = UIImageView()
    
    var activityIndicator = UIActivityIndicatorView()
    
    var spot: Spot!
    
    func configureCell(spot: Spot, img: UIImage? = nil, count: Int){
        
        self.spot = spot
 
        spotImage.kf.setImage(with: URL(string: spot.imageUrls[count]), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
            if let img = image {
                self.setImageViewContentMode(image: img)
            }
            self.activityIndicator.stopAnimating()
        }
        
//        spotImage.sd_setImage(with: URL(string: spot.imageUrls[count])) { (image, error, chacheType, url) in
//
//            if let img = image{
//                self.setImageViewContentMode(image: img)
//            }
//
//           self.activityIndicator.stopAnimating()
//
//        }
  
    }
    
    func setImageViewContentMode(image:UIImage){
        if image.size.width > image.size.height{
            self.spotImage.contentMode = .scaleAspectFit
        } else {
            //self.spotImage.contentMode = .scaleToFill

        }

    }
    
    
}
