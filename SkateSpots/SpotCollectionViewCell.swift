//
//  SpotCollectionViewCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//


import UIKit

class SpotCollectionViewCell: UICollectionViewCell{

    @IBOutlet weak var spotImage: UIImageView!

    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var spotLocation: UILabel!
    @IBOutlet weak var spotDistance: UILabel!
    
    var spot: Spot!
    
    func configCell(spot: Spot){
        self.spot = spot
//self.spotName = spot.spotName
       // self.spotDistance = spot.distance
    }
}


