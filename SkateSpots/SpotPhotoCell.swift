//
//  SpotPhotoCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//
import UIKit
import FirebaseStorage
import SVProgressHUD
import SDWebImage
import Kingfisher

class SpotPhotoCell: UICollectionViewCell{
    
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var pageLabel: UILabel!
    
    var spot: Spot!
    
    func configureCell(spot: Spot, img: UIImage? = nil, count: Int){
       
        self.spot = spot
        self.spotImage.contentMode = .scaleToFill

        spotImage.kf.setImage(with: URL(string: spot.imageUrls[count]), placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
            if let img = image {
                self.setImageViewContentMode(image: img)
            }
                self.activityIndicator.stopAnimating()
        }

    
    }
    
    func setImageViewContentMode(image:UIImage){
        if image.size.width > image.size.height {
            self.spotImage.contentMode = .scaleAspectFit
        } 
    }
    
    func emptyImageView(){
        self.spotImage.image = nil
        activityIndicator.startAnimating()
    }
    
    func imageContentMode() -> Int {
        return spotImage.contentMode.rawValue
    }
}



