//
//  MessageCell.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/20/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit

class MessageCell: UICollectionViewCell{

    
    @IBOutlet weak var profileImage: CircleView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    
    func configureCell(profileImage: UIImage, name: String, content: String){
    
        self.profileImage.image = profileImage
        self.nameLabel.text = name
        self.contentLabel.text = content
    }

}
