//
//  SpotRow.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

class SpotRow: UITableViewCell{


    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var spotLocation: UILabel!
    @IBOutlet weak var spotDistance: UILabel!
    
    var spot: Spot!
    
    func configureRow(spot: Spot){
        self.spot = spot
        self.spotName.text = spot.spotName
        self.spotLocation.text = spot.spotLocation
        self.spotDistance.text = "\(spot.distance)"
        
    }
}
