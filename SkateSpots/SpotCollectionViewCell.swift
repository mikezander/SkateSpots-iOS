//
//  SpotCollectionViewCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/6/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit

class SpotCollectionViewCell: UICollectionViewCell{

    @IBOutlet weak var spotImage: UIImageView!

    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var spotLocation: UILabel!
    @IBOutlet weak var spotDistance: UILabel!
}
