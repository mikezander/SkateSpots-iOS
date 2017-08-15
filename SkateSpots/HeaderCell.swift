//
//  HeaderCell.swift
//  SkateSpots
//
//  Created by Michael Alexander on 8/15/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

class HeaderCell: UITableViewCell{

    var profilePhoto: UIImageView!
    var userName: UILabel!

    let screenSize = UIScreen.main.bounds
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profilePhoto = UIImageView()
        profilePhoto.frame = CGRect(x: screenSize.width / 2 - 50, y: 10, width: 100, height: 100)
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = FLAT_GREEN.cgColor
        //profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        contentView.addSubview(profilePhoto)
        
        userName = UILabel()
        userName.frame = CGRect(x: 0 , y: profilePhoto.frame.origin.y + 110, width: screenSize.width, height: 20)
        userName.textAlignment = .center
        userName.textColor = UIColor.black
        userName.font = UIFont(name: "Avenir",size: 17)
        
        contentView.addSubview(userName)
    }


}
