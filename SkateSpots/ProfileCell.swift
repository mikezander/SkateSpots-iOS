//
//  ProfileCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit
import FirebaseStorage
import Kingfisher
import Firebase

class ProfileCell: UITableViewCell{
    
    @IBOutlet weak var spotImage: UIImageView!
    
    @IBOutlet weak var spotNameLabel: UILabel!
    
    @IBOutlet weak var spotLocationLabel: UILabel!
    
    @IBOutlet weak var spotType: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var activityIdicator: UIActivityIndicatorView!
    
    func configureCell(spot: Spot){
        self.spotNameLabel.text = spot.spotName
        self.spotLocationLabel.text = spot.spotLocation
        self.spotImage.kf.setImage(with: URL(string: spot.imageUrls[0]))
        self.spotType.text = spot.spotType
        
        spotNameLabel.adjustsFontSizeToFitWidth = true
        spotLocationLabel.adjustsFontSizeToFitWidth = true
        spotType.adjustsFontSizeToFitWidth = true
        setDetailLabel(spot: spot)
        DispatchQueue.main.async{self.activityIdicator.stopAnimating()}
    }
    
    func setDetailLabel(spot: Spot){
        let spotRef = DataService.instance.REF_SPOTS.child(spot.spotKey)
            spotRef.observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot!) in
                
                let commentsCount = Int(snapshot.childSnapshot(forPath: "comments").childrenCount)
                let commentsLabel = commentsCount == 1 ? "\(commentsCount) comment" : "\(commentsCount) comments"
                
                let ratingsCount = snapshot.childSnapshot(forPath: "ratingVotes").value as? Int ?? 0
                let ratingsLabel = ratingsCount == 1 ? "\(ratingsCount) rating" : "\(ratingsCount) ratings"
                
                DispatchQueue.main.async {
                    self.detailLabel.text = "\(commentsLabel) • \(ratingsLabel)"
                }
            })
    }
}

