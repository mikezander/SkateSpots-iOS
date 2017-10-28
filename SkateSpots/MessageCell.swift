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
    
    
    func configureCell(message: Message, img: UIImage? = nil, userUrl: String, name: String){
 
        profileImageView.image = nil
        nameLabel.text = name
        messageLabel.text = message.text
        
        if let seconds = message.timestamp?.doubleValue{
            let timestampDate = Date(timeIntervalSince1970: seconds)
 
            timeLabel.text = timestampDate.timeAgoDisplay()
            timeLabel.textAlignment = .right
        }
 
        
        //download images
        if img != nil{

                    self.profileImageView.image = img
                
        }else{
            
            //cache image
            
            let ref = Storage.storage().reference(forURL:userUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: {(data, error) in
                if error != nil{
                    print("Mike: Unable to download image from firebase storage")
                }else{
                    print("Mike: Image downloaded from firebase storge")
                    if let imgData = data {
        
                               
                                if let img = UIImage(data: imgData){
 
                                    self.profileImageView.image = img
 
                                    FeedVC.imageCache.setObject(img, forKey: userUrl as NSString)
                                }
    
                    }
                }

            })
            
        }
        
    }
    
    func emptyImageView(){
        profileImageView.image = nil
    }
 

}
