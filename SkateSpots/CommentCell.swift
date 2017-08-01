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
    var comment: UITextView!

    var CellHeight = CGFloat()

    
    let screenSize = UIScreen.main.bounds
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
 
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        

       CellHeight = 100
    
        profilePhoto = UIImageView()
        profilePhoto.frame = CGRect(x: 20, y: 5, width: 50, height: 50)
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = UIColor.green.cgColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        contentView.addSubview(profilePhoto)
        
        userName = UILabel()
        userName.frame = CGRect(x: profilePhoto.frame.origin.x+profilePhoto.frame.width+10 , y: 5, width: screenSize.width - (profilePhoto.frame.origin.x+profilePhoto.frame.width + 25), height: 20)
        userName.textColor = UIColor.blue
        
        contentView.addSubview(userName)
        
        comment = UITextView()
        comment.isScrollEnabled = false
        comment.isEditable = false
        comment.isSelectable = false
        
        comment.frame = CGRect(x: profilePhoto.frame.origin.x+profilePhoto.frame.width + 10, y: userName.frame.origin.y + 10, width: screenSize.width - (profilePhoto.frame.origin.x+profilePhoto.frame.width + 25), height: 115)
        
        comment.font = UIFont(name: "ArialMT", size: 16)
        
        comment.textColor = UIColor.black
        
        comment.backgroundColor = UIColor.clear

        if screenSize.height <= 568.0 {
            comment.font = UIFont(name: "ArialMT", size: 14)
            userName.font = UIFont(name: "ArialMT", size: 13)
        }else if screenSize.height > 568.0 &&  screenSize.height < 700.0{
            comment.font = UIFont(name: "ArialMT", size: 15)
            userName.font = UIFont(name: "ArialMT", size: 14)
            //userName.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightThin)
        }else {
            comment.font = UIFont(name: "ArialMT", size: 16)
            userName.font = UIFont(name: "ArialMT", size: 15)
        }
        
        print("\(screenSize.height)yooo")
       
        
        contentView.addSubview(comment)


       CellHeight = 80
        //CellHeight = 75 //85

        
        
        
        /* got width! CellHeight = 80
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

        comment.frame = CGRect(x: profilePhoto.frame.origin.x+profilePhoto.frame.width + 10, y: 0, width: screenSize.width - (profilePhoto.frame.origin.x+profilePhoto.frame.width + 25), height: CellHeight)

        comment.frame = CGRect(x: profilePhoto.frame.origin.x+profilePhoto.frame.width + 10, y: 5,
        
        comment.font = UIFont(name: "ariel", size: 12)
        comment.lineBreakMode = .byWordWrapping
        comment.numberOfLines = 4

        
        comment.textColor = UIColor.black
        contentView.addSubview(comment)*/
        
        
        //CellHeight = 75 //85
        
      /*
        
        
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
        comment.frame = CGRect(x: profilePhoto.frame.origin.x+profilePhoto.frame.width + 10, y: 0, width: frame.width - (profilePhoto.frame.width + 50), height: CellHeight)
        
        comment.font = UIFont(name: "ariel", size: 14)
        comment.lineBreakMode = .byWordWrapping
        comment.numberOfLines = 4
 
        comment.textColor = UIColor.black
        contentView.addSubview(comment)
       */
  

        

       

    }
   

 
    

}
