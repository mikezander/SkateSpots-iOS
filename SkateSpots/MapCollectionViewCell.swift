//
//  MapCollectionViewCell.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 7/29/18.
//  Copyright © 2018 Michael Alexander. All rights reserved.
//

import UIKit

class MapCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var spotType: UILabel!
    @IBOutlet weak var borderedView: UIView!
    @IBOutlet weak var spotCountLabel: UILabel!
    
    func configureCell(spot: Spot, style: String) {
        
        if let spotImageURL = spot.imageUrls.first {
            spotImage.kf.setImage(with: URL(string: spotImageURL))
        }
        spotImage.layer.cornerRadius = 5.0
        spotImage.layoutIfNeeded()

        spotName.text = spot.spotName
        spotType.text = spot.spotType
        
        if style == "Dark" {
            borderedView.backgroundColor = .black
            spotName.textColor = .white
            spotType.textColor = .white
            spotCountLabel.textColor = .white
        } else {
            borderedView.backgroundColor = .white
            spotName.textColor = .black
            spotType.textColor = .black
            spotCountLabel.textColor = .black
        }
    }
}
