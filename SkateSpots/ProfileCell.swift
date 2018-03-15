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
    
    func configureCell(spot: Spot){
        self.spotNameLabel.text = spot.spotName
        self.spotLocationLabel.text = spot.spotLocation
        
        spotImage.kf.setImage(with: URL(string: spot.imageUrls[0]))

        DispatchQueue.main.async{self.activityIdicator.stopAnimating()}

    }
    
}
