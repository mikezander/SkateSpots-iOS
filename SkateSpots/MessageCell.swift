//
//  MessageCell.swift
//  Sk8Spots
//
//  Created by Michael Alexander on 10/20/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit
import FirebaseStorage

class MessageCell: UITableViewCell{

    @IBOutlet weak var profileImageView: CircleView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var unreadFlag: UIImageView!
    
    func configureCell(message: Message, img: UIImage? = nil, userUrl: String, name: String){
 
        profileImageView.image = nil
        nameLabel.text = name
        messageLabel.text = message.text
        
        if let seconds = message.timestamp?.doubleValue{
            let timestampDate = Date(timeIntervalSince1970: seconds)
 
            timeLabel.text = timestampDate.timeAgoDisplay()
            timeLabel.textAlignment = .right
        }
 
        self.profileImageView.sd_setImage(with: URL(string: userUrl), placeholderImage: nil)
        
    }
    
    func emptyImageView(){
        profileImageView.image = nil
    }
 

}
