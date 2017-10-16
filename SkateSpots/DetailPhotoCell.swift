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
  
   
        //download images
        if img != nil{
            DispatchQueue.main.async {
                self.spotImage.image = img
                self.setImageViewContentMode(image: img!)
                self.activityIndicator.stopAnimating()
            }
            
        }else{
            
            //cache image
            
            let ref = Storage.storage().reference(forURL:spot.imageUrls[count])
            ref.getData(maxSize: 2 * 1024 * 1024, completion: {(data, error) in
                if error != nil{
                    DispatchQueue.main.async { self.activityIndicator.stopAnimating() }
                    print("Mke: Unable to download image from firebase storage")
                }else{
                    print("Mike: Image downloaded from firebase storge")
                    
                    if let imgData = data {
                        
                        DispatchQueue.main.async {
                            
                            if let img = UIImage(data: imgData){
                                self.spotImage.image = img
                                self.setImageViewContentMode(image: img)
                                FeedVC.imageCache.setObject(img, forKey: spot.imageUrls[count] as NSString)
                            }
                        }
                        
                    }
                    
                }
                DispatchQueue.main.async { self.activityIndicator.stopAnimating() }
                
            })
            
        }

        
    }
    
    func setImageViewContentMode(image:UIImage){
        
        if image.size.width > image.size.height{
            self.spotImage.contentMode = .scaleAspectFit
        }else{
            self.spotImage.contentMode = .scaleToFill
        }
    }
    
    
}
