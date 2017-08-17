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
    var bio: UILabel!
    var linkButton: UIButton!
    var link: UILabel!
    var contributions: UILabel!
    var status: UILabel!

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
        userName.font = UIFont(name: "Avenir-Bold",size: 17)
        
        contentView.addSubview(userName)
        
        bio = UILabel()
        bio.frame = CGRect(x: 0 , y: userName.frame.origin.y + 22, width: screenSize.width, height: 20)
        bio.textAlignment = .center
        bio.textColor = UIColor.black
        bio.font = UIFont(name: "Avenir",size: 14)
        contentView.addSubview(bio)
        
        link = UILabel()
        link.frame = CGRect(x: 0 , y: bio.frame.origin.y + 20, width: screenSize.width, height: 20)
        link.textAlignment = .center
        link.textColor = UIColor.blue
        link.font = UIFont(name: "Avenir",size: 14)
        contentView.addSubview(link)
        
        linkButton = UIButton()
        linkButton.frame = CGRect(x:0,y: bio.frame.origin.y + 17 ,width:screenSize.width / 2,height: 20)
        linkButton.backgroundColor = UIColor.groupTableViewBackground
        linkButton.titleLabel?.font = UIFont(name: "Avenir",size: 14)
        linkButton.setTitleColor(UIColor.blue, for: .normal)
        linkButton.setTitle(link.text, for: .normal)
        contentView.addSubview(linkButton)
        
        contributions = UILabel()
        contributions.frame = CGRect(x: profilePhoto.frame.origin.x , y: link.frame.origin.y + 25, width: 150, height: 20)
        //contributions.textAlignment = .center
        contributions.textColor = UIColor.lightGray
        contributions.font = UIFont(name: "Avenir-Black",size: 14)
        contentView.addSubview(contributions)
        
        status = UILabel()
        status.frame = CGRect(x: contributions.frame.origin.x , y: contributions.frame.origin.y + 25, width: screenSize.width, height: 20)
        //status.textAlignment = .center
        status.textColor = UIColor.lightGray
        status.font = UIFont(name: "Avenir-Black",size: 14)
        contentView.addSubview(status)
        
    }
    
    func returnHeight()->CGFloat{
    
    return status.frame.origin.y
    }


}
