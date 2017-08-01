//
//  CommentCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 7/31/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell{

    var profilePhoto: UIImageView!
    var userName: UILabel!
    var comment: UILabel!

    var CellHeight = CGFloat()

    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
       CellHeight = 80
        //CellHeight = 75 //85
        
        
        
        profilePhoto = UIImageView()
        profilePhoto.frame = CGRect(x: 20, y: 5, width: 50, height: 50)
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = UIColor.green.cgColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        contentView.addSubview(profilePhoto)
        
        userName = UILabel()
        userName.frame = CGRect(x: profilePhoto.frame.origin.x+profilePhoto.frame.width+10 , y: 0, width: 150, height: CellHeight/2-10)
        userName.textColor = UIColor.black
        contentView.addSubview(userName)
        
        comment = UILabel()
        comment.frame = CGRect(x: profilePhoto.frame.origin.x+profilePhoto.frame.width + 10, y: 5, width: contentView.frame.width - 10, height: CellHeight / 2 + 10)
        
        comment.font = UIFont(name: "ariel", size: 12)
        comment.lineBreakMode = .byWordWrapping
        comment.numberOfLines = 4
        comment.textColor = UIColor.black
        contentView.addSubview(comment)
       
    }
    


}
