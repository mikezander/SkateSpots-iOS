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
    
    var spot: Spot!
    
    func configureFavoriteCell(spot:Spot, img: UIImage? = nil){
        
        self.spot = spot
        titleLabel.text = " \(spot.spotName)"
        
        spotTypeLabel.text = spot.spotType
        detailLabel.text = spot.spotLocation
        
        self.spotPhoto.sd_setImage(with: URL(string: spot.imageUrls[0]), placeholderImage: nil)

        
    }
    func emptyImageView(){
        self.spotPhoto.image = nil
    }
}
