//
//  MapCollectionViewCell.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 7/29/18.
//  Copyright © 2018 Michael Alexander. All rights reserved.
//

import UIKit
import Firebase


class MapCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var spotType: UILabel!
    @IBOutlet weak var borderedView: UIView!
    @IBOutlet weak var spotCountLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    
    func configureCell(spot: Spot, style: String) {
        
        if let spotImageURL = spot.imageUrls.first {
            spotImage.kf.setImage(with: URL(string: spotImageURL))
        }
        spotImage.layer.cornerRadius = 5.0
        spotImage.layoutIfNeeded()

        spotName.text = spot.spotName
        spotType.text = spot.spotLocation//spot.spotType
        
        if #available(iOS 13.0, *) {
            borderedView.backgroundColor = .systemBackground
            backgroundColor = .systemBackground

        } else {
            borderedView.backgroundColor = .white
            backgroundColor = .white
        }
        
        spotName.textColor = .blackWhite()
        spotType.textColor = .blackWhite()
        spotCountLabel.textColor = .blackWhite()
        ratingLabel.textColor = .blackWhite()

        
        let refCurrentSpot = DataService.instance.REF_SPOTS.child(spot.spotKey)
        
        refCurrentSpot.observeSingleEvent(of: .value, with: { (snapshot) in
            if let ratingTally = snapshot.childSnapshot(forPath: "rating").value as? Double{
                let ratingVotes = snapshot.childSnapshot(forPath: "ratingVotes").value as! Int
                
                var rating = ratingTally / Double(ratingVotes)
                rating = (rating * 10).rounded() / 10
                DispatchQueue.main.async {
                    self.ratingLabel.text = "\(rating)"
                    self.ratingImageView.alpha = 1.0
                    self.ratingLabel.alpha = 1.0
                }
                
            }else{
                DispatchQueue.main.async {
                    self.ratingImageView.alpha = 0.0
                    self.ratingLabel.alpha = 0.0
                }
                
            }
            
        })
    }
}

