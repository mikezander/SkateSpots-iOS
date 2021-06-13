//
//  ProfileImagesCell.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 11/28/19.
//  Copyright © 2019 Michael Alexander. All rights reserved.
//

import UIKit
import Kingfisher

class ProfileImagesCell: UITableViewCell {
    
    @IBOutlet var spotImageFirst: UIImageView!
    @IBOutlet var spotImageSecond: UIImageView!

    
    func configureCells(spotOne: Spot, spotTwo: Spot?) {
        spotImageFirst.kf.setImage(with: URL(string: spotOne.imageUrls[0]))
        spotImageSecond.kf.setImage(with: URL(string: spotTwo!.imageUrls[0]))
        
    }
    
    func configureCell(spotOne: Spot) {
        spotImageFirst.kf.setImage(with: URL(string: spotOne.imageUrls[0]))
    }
}

