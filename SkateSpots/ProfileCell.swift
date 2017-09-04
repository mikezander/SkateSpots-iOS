//
//  ProfileCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseStorage

class ProfileCell: UITableViewCell{
    
    @IBOutlet weak var spotImage: UIImageView!
    
    @IBOutlet weak var spotNameLabel: UILabel!
    
    @IBOutlet weak var spotLocationLabel: UILabel!
    
    @IBOutlet weak var activityIdicator: UIActivityIndicatorView!
    func configureCell(spot: Spot, img: UIImage? = nil, count: Int){
        self.spotNameLabel.text = spot.spotName
        self.spotLocationLabel.text = spot.spotLocation
        
        //download images
        if img != nil{
            
            DispatchQueue.main.async {
                self.spotImage.image = img
                self.activityIndicator.stopAnimating()
            }
            
        }else{
            
            //cache image

            let ref = FIRStorage.storage().reference(forURL:spot.imageUrls[count])
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: {(data, error) in
                if error != nil{
                    print("Mike: Unable to download image from firebase storage")
                }else{
                    print("Mike: Image downloaded from firebase storge")
                    if let imgData = data {

                            
                            if let img = UIImage(data: imgData){
                                self.spotImage.image = img
                                FeedVC.imageCache.setObject(img, forKey: spot.imageUrls[count] as NSString)
                            }
  
                    }
                }
                DispatchQueue.main.async{self.activityIndicator.stopAnimating()}
            })
            
        }
        
    }
    
}
