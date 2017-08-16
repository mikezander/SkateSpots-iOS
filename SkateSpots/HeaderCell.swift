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
    var contributions: UILabel!

    let screenSize = UIScreen.main.bounds
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        profilePhoto = UIImageView()
        profilePhoto.frame = CGRect(x: screenSize.width / 2 - 65, y: 10, width: 125, height: 125)
        profilePhoto.layer.borderWidth = 2
        profilePhoto.layer.masksToBounds = false
        profilePhoto.layer.borderColor = FLAT_GREEN.cgColor
        profilePhoto.layer.cornerRadius = profilePhoto.frame.height/2
        profilePhoto.clipsToBounds = true
        contentView.addSubview(profilePhoto)
        
        userName = UILabel()
        userName.frame = CGRect(x: 0 , y: profilePhoto.frame.origin.y + 135, width: screenSize.width, height: 20)
        userName.textAlignment = .center
        userName.textColor = UIColor.black
        userName.font = UIFont(name: "Avenir",size: 17)
        
        contentView.addSubview(userName)
        
        contributions = UILabel()
        contributions.frame = CGRect(x: 0 , y: userName.frame.origin.y + 30, width: screenSize.width, height: 20)
        contributions.textAlignment = .center
        contributions.textColor = UIColor.black
        contributions.font = UIFont(name: "Avenir",size: 14)
        contentView.addSubview(contributions)
    }


}
