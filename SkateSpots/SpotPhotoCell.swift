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

class SpotPhotoCell: UICollectionViewCell{
    
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var spot: Spot!
    
    func configureCell(spot: Spot, img: UIImage? = nil, count: Int){
        self.spot = spot

        
        
            self.spotImage.sd_setImage(with: URL(string: spot.imageUrls[count])) { (image, error, chacheType, url) in

            if let img = image{
               self.setImageViewContentMode(image: img)
            }
            
           self.activityIndicator.stopAnimating()
           
        }

       /* if img != nil{
            self.spotImage.image = img

            DispatchQueue.main.async {
                self.setImageViewContentMode(image: img!)
                self.activityIndicator.stopAnimating()
            }
            
        }else{
            
            //cache image
            
            let ref = Storage.storage().reference(forURL:spot.imageUrls[count])
            ref.getData(maxSize: 2 * 1024 * 1024, completion: {(data, error) in
                if error != nil{
                    DispatchQueue.main.async { self.activityIndicator.stopAnimating() }
                    print("Mike: Unable to download image from firebase storage")
                    print(error?.localizedDescription ?? "no errrrrrrorrororr")
                    
                }else{
                    print("Mike: Image downloaded from firebase storge")
                    if let imgData = data {
                          
                        if let img = UIImage(data: imgData){
                            self.spotImage.image = img
                            
                            FeedVC.imageCache.setObject(img, forKey: spot.imageUrls[count] as NSString)
                            DispatchQueue.main.async {
                                self.setImageViewContentMode(image: img)
                                self.activityIndicator.stopAnimating()
                            }
                            
                        }
                        
                    }
                }
                
            })
        }*/
        
        
    }
    
    func setImageViewContentMode(image:UIImage){

        if image.size.width > image.size.height{
            self.spotImage.contentMode = .scaleAspectFit
        }else{
            self.spotImage.contentMode = .scaleToFill
        }
    }
    
    func emptyImageView(){
        self.spotImage.image = nil
        activityIndicator.startAnimating()
    }
    
}

